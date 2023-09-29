-- SERVER_MAIN
local db = exports.oxmysql

local VorpCore
local VorpInv = exports.vorp_inventory:vorp_inventoryApi()

TriggerEvent("getCore", function(core)
    VorpCore = core
end)

RegisterNetEvent(Events.loadStable, function(charid)
    local src = source
    LoadStableContent(src, charid)
end)
RegisterNetEvent(Events.loadStableRuntime, function()
    local src = source
    local id = VorpCore.getUser(src).getUsedCharacter.charIdentifier
    LoadStableContent(src, id)
end)

function LoadStableContent(src, charId)
    db:execute(
        "SELECT * FROM stables WHERE `charidentifier`=? OR `status` LIKE '%\"transferTarget\":?,%' OR `status` LIKE '%\"transferTarget\":?}'",
        {charId, charId, charId}, function(result)
            db:execute("SELECT `complements` FROM horse_complements WHERE `charidentifier`=?", {charId},
                function(compsResult)
                    local comps
                    if (#compsResult == 0) then
                        comps = {}
                    else
                        comps = compsResult[1]["complements"]
                    end
                    local ownedRides = {}
                    local waitingRides = {}
                    for k, v in ipairs(result) do
                        if v.charidentifier == charId then
                            table.insert(ownedRides, 1, v)
                        else
                            table.insert(waitingRides, 1, v)
                        end
                    end
                    local out = {
                        rides = ownedRides,
                        transferedRides = waitingRides,
                        availableComps = comps,
                        charId = charId
                    }
                    TriggerClientEvent(Events.onStableLoaded, src, out)
                end)
            for k, ride in pairs(result) do
                local limit
                if Config.CustomMaxWeight[ride.model] ~= nil then
                    limit = Config.CustomMaxWeight[ride.model]
                else
                    limit = Config.DefaultMaxWeight
                end
                VorpInv.registerInventory(ride.name, ride.name, limit, true, Config.ShareInv[ride.type], false)
            end
        end)

    db:execute("SELECT charidentifier, firstname, lastname FROM characters", function(result)
        TriggerClientEvent("charsLoaded", src, result)
    end)
end

RegisterNetEvent(Events.onBuyRide, function(rideName, rideModel, rideType, ridePrice)
    local src = source
    local player = VorpCore.getUser(src).getUsedCharacter
    local id = player.charIdentifier

    if ridePrice > player.money then
        return TriggerClientEvent("vorp:TipRight", src, Config.Lang.TipCantAfford, 4000)
    end

    player.removeCurrency(0, ridePrice)
    db:execute("INSERT INTO stables (`charidentifier`, `name`, `type`, `modelname`) VALUES (?, ?, ?,?)",
        {id, rideName, rideType, rideModel}, function(result)
            if result.affectedRows > 0 then
                TriggerClientEvent("vorp:TipRight", src, Config.Lang.TipRidePurchased:gsub("%{rideName}", rideName)
                    :gsub("%{price}", ridePrice), 4000)
                LoadStableContent(src, id)
            end
        end)
end)

RegisterNetEvent(Events.onBuyComp, function(compModel, compType, price, horseId, horseComps, playerAvailableComps)
    local src = source
    local player = VorpCore.getUser(src).getUsedCharacter
    local id = player.charIdentifier

    if price > player.money then
        return TriggerClientEvent("vorp:TipRight", src, Config.Lang.TipCantAfford, 4000)
    end
    compModel = tonumber(compModel)
    player.removeCurrency(0, price)
    local compsForDB = {}
    horseComps[compType] = compModel
    local alreadyHasComp = false
    for compTypeName, compModels in pairs(playerAvailableComps) do
        for compModelName, comps in pairs(compModels) do
            for k, comp in ipairs(comps) do
                compModels = tonumber(comp)
                table.insert(compsForDB, 1, compModels)
                if comp == compModel then
                    alreadyHasComp = true
                    break
                end
            end
        end
    end
    
    db:execute("UPDATE stables SET `gear` = ? WHERE `id` = ?", {json.encode(horseComps), horseId}, function(result)
        if result.affectedRows > 0 then
            TriggerClientEvent("vorp:TipRight", src,
                Config.Lang.TipSuccessfulBuyComp:gsub("%{0}", compType):gsub("%{1}", price), 4000)
            if not alreadyHasComp then
                table.insert(compsForDB, 1, compModel)
                db:execute("UPDATE horse_complements SET `complements` = ? WHERE `charidentifier` = ?",
                    {json.encode(compsForDB), id}, function(result)
                        if result.affectedRows > 0 then
                            TriggerClientEvent("vorp:TipRight", src, "Ajouté à l'inventaire de l'étable", 4000)
                        else
                            TriggerClientEvent("vorp:TipRight", src,
                                "Erreur lors de l'ajout à l'inventaire de l'étable", 4000)
                        end
                        LoadStableContent(src, id)
                    end)
            else
                LoadStableContent(src, id)
            end
        else
            TriggerClientEvent("vorp:TipRight", src, Config.Lang.TipErrorOnPurchase, 4000)
        end
    end)

end)

RegisterNetEvent(Events.onDelete, function(rideId)
    local src = source
    local player = VorpCore.getUser(src).getUsedCharacter
    local id = player.charIdentifier
    db:execute("DELETE FROM stables WHERE `id` = ?", {rideId}, function()
        TriggerClientEvent("vorp:TipRight", src, Config.Lang.TipHorseFreed, 4000)
        LoadStableContent(src, id)
    end)
end)

RegisterNetEvent(Events.onTransfer, function(rideId, targetChar, price, activePlayers)
    local src = source
    local player = VorpCore.getUser(src).getUsedCharacter
    local id = player.charIdentifier
    local targetSource = nil
    for k, v in ipairs(activePlayers) do
        local u = VorpCore.getUser(v)
        if u ~= nil then
            local p = u.getUsedCharacter
            local i = p.charIdentifier
            if i == targetChar then
                targetSource = v
                break
            end
        end
    end
    db:execute("UPDATE stables SET status = ? WHERE `id` = ?", {json.encode({
        transferTarget = targetChar,
        price = price
    }), rideId}, function()
        TriggerClientEvent("vorp:TipRight", src, Config.Lang.TipOfferSent, 4000)
        LoadStableContent(src, id)
        if targetSource ~= nil then
            LoadStableContent(targetSource, targetChar)
        end
    end)
end)

RegisterNetEvent(Events.onTransferRecieve, function(rideId, accepted, price, activePlayers)
    local src = source
    local player = VorpCore.getUser(src).getUsedCharacter
    local id = player.charIdentifier
    local targetSource = nil
    for k, v in ipairs(activePlayers) do
        local u = VorpCore.getUser(v)
        if u ~= nil then
            local p = u.getUsedCharacter
            local i = p.charIdentifier
            if i == targetChar then
                targetSource = v
                break
            end
        end
    end
    if not accepted then
        db:execute("UPDATE stables SET status = NULL WHERE `id` = ?", {rideId}, function()
            TriggerClientEvent("vorp:TipRight", src, Config.Lang.TipOfferDeclined, 4000)
            LoadStableContent(src, id)
        end)
    elseif player.money >= price then
        db:execute("UPDATE stables SET status = NULL, charidentifier = ? WHERE `id` = ?", {id, rideId}, function()
            TriggerClientEvent("vorp:TipRight", src, Config.Lang.TipOfferAccepted:gsub("%{price}", price), 4000)
            LoadStableContent(src, id)
            player.removeCurrency(0, price)
            if targetSource ~= nil then
                local tPlayer = VorpCore.getUser(targetSource).getUsedCharacter
                tPlayer.addCurrency(0, price)
                LoadStableContent(targetSource, targetChar)
            end
            -- //TODO add currency to seller if disconnected
        end)
    elseif player.money < price then
        TriggerClientEvent("vorp:TipRight", src, Config.Lang.TipCantAfford .. " " .. Config.Lang.TipOfferStillOn, 4000)
    end
end)

RegisterNetEvent(Events.openInventory, function(rideName)
    local src = source
    local player = VorpCore.getUser(src).getUsedCharacter
    local id = player.charIdentifier
    VorpInv.OpenInv(src, rideName)
end)

RegisterNetEvent(Events.setDefault, function(newRide, prevRide)
    local src = source
    local player = VorpCore.getUser(src).getUsedCharacter
    local id = player.charIdentifier
    db:execute("UPDATE stables SET `isDefault` = 1 WHERE `id` = ?", {newRide}, function(updated, b)

        if updated.affectedRows > 0 and prevRide ~= nil then
            db:execute("UPDATE stables SET `isDefault` = 0 WHERE `id` = ?", {prevRide}, function(secondUpdate)
                if secondUpdate.affectedRows > 0 then
                    TriggerClientEvent("vorp:TipRight", src, Config.Lang.TipChanged, 4000)
                    LoadStableContent(src, id)
                else
                    TriggerClientEvent("vorp:TipRight", src, Config.Lang.TipErrorOnUpdate, 4000)
                    LoadStableContent(src, id)
                end
            end)
        elseif updated.affectedRows > 0 then
            TriggerClientEvent("vorp:TipRight", src, Config.Lang.TipChanged, 4000)
            LoadStableContent(src, id)
        else
            TriggerClientEvent("vorp:TipRight", src, Config.Lang.TipErrorOnUpdate, 4000)
        end
    end)
end)

RegisterNetEvent(Events.onHorseDown, function(rideId, killerObjectHash)
    local src = source
    local player = VorpCore.getUser(src).getUsedCharacter
    local id = player.charIdentifier
    if Config.HardDeath then
        local LTDamages = DeathReasons[killerObjectHash] or DeathReasons.Default
        db:execute("UPDATE stables SET injured = injured + ? WHERE `id` = ?", {LTDamages, rideId}, function(updated)
            if updated.affectedRows > 0 then
                db:execute("SELECT injured FROM stables WHERE `id` = ?", {rideId}, function(result)
                    if result[1].injured >= Config.LongTermHealth then
                        db:execute("DELETE FROM stables WHERE `id` = ?", {rideId}, function(deleted)
                            if deleted.affectedRows > 0 then
                                TriggerClientEvent("vorp:TipRight", src, Config.Lang.TipHorseDeadDefinitive, 4000)
                                LoadStableContent(src, id)
                            end
                        end)
                    end
                end)
            end
        end)
    end
end)

