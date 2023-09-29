Config = {
  Lang = Langs.Fr,  
  StaticData = Data,     
  MaxHorses = 3,
  MaxCarts = 1,
  StableSlots = 3,

  JobRequired = true,

  DisableBuyOptions = false, 

  JobForHorseDealer = "Horsedealer",
  JobForCarriagesDealer = "Carriagesdealer",
  JobForHorseAndCarriagesDealer = "HorseAndCarriagesdealer",

  -- When a horse dies, make it unavailable for x seconds
  SecondsToRespawn = 120,

  -- The hard death mechanism will make a horse unavailable after it has died too many times
  -- Set false to disable or set true, then set overall health, and Check deathResasons.lua To
  -- adjust the long term damages dealt by any death reasons.
  -- the reasons can really be vast and will be updated.
  HardDeath = true,
  LongTermHealth = 100,

  ShowTagsOnHorses = false,

  HorseSkillPullUpFailPercent = 20,
  DistanceToTeleport = 200,
  ShareInv = {
    horse = true,
    cart = true
  },
  
  DefaultMaxWeight = 100,
  CustomMaxWeight = {},

  Stables = {
    {
      Name = "Saint Denis Stable",
      BlipIcon = 1938782895,
      EnterStable = { 2510.58, -1456.83, 46.31, 2.0 },
      StableNPC = { 2512.35, -1456.89, 45.2, 91.68 },
      SpawnHorse = { 2508.59, -1449.96, 45.5, 90.09 },
      CamHorse = { 2506.807, -1452.29, 48.61699, -34.77003, 0.0, -35.20742 },
      CamHorseGear = { 2508.876, -1451.953, 48.67999, -35.29771, 0.0, -0.4993192 },
      SpawnCart = { 2503.47, -1441.89, 46.31, 0.24 },
      CamCart = { 2506.428, -1437.7, 50.57832, -39.4497, 0.0, 120.535 }
    },
    {
      Name= "Ecurie de Valentine",
      BlipIcon= 1938782895,
      EnterStable= { -365.87, 789.51, 116.17, 2.0 },
      StableNPC = { -365.15, 792.68, 115.18, 178.47 },
      SpawnHorse = { -366.07, 781.81, 115.14, 5.97 },
      CamHorse= { -367.9267, 783.0237, 117.7778, -36.42624, 0.0, -100.9786 },
      CamHorseGear= { -367.9267, 783.0237, 117.7778, -36.42624, 0.0, -100.9786 },
      SpawnCart= { -370.11, 786.99, 115.16, 274.18 },
      CamCart= { -363.5831, 792.1113, 118.0419, -16.35144, 0.0, 143.9759 },
      --[[
        To setup a custom inventory for the stable, there are 2 ways 
        first of all use horses = {} and carts = {} do define them. If not defined or left empty, the vendor
        will be selling everything.

        You can then chose to define a custom price for this vendor, or take the price defined in data: 
        horses = {
          "A_C_Horse_AmericanPaint_Overo", --the price will be the one from Data
          A_C_Horse_AmericanPaint_GreyOvero = 50 -- the price will be 50 only for that vendor
        }

        hf
      ]]
    },
    {
      Name = "Strawberry Stable",
      BlipIcon = 1938782895,
      EnterStable = { -1816.81, -561.99, 156.07, 2.0 },
      StableNPC = { -1818.45, -564.83, 155.06, 347.22 },
      SpawnHorse = { -1820.26, -555.84, 155.16, 163.01 },
      CamHorse = { -1819.512, -558.6999, 157.6765, -23.95241, 0.0, 28.46066 },
      CamHorseGear = { -1819.512, -558.6999, 157.6765, -23.95241, 0.0, 28.46066 },
      SpawnCart = { -1821.46, -561.41, 155.06, 256.24 },
      CamCart = { -1816.372, -560.2017, 157.6678, -22.02157, 0.0, 124.3779 }
    },
    {
      Name = "Blackwater Stable",
      BlipIcon = 1938782895,
      EnterStable = { -876.57, -1365.1, 43.53, 2.0 },
      StableNPC = { -878.35, -1364.81, 42.53, 266.28 },
      SpawnHorse = { -864.25, -1361.8, 42.7, 177.48 },
      CamHorse = { -862.6163, -1362.927, 45.58158, -40.96593, 0.0, 71.8129 },
      CamHorseGear = { -862.6163, -1362.927, 45.58158, -40.96593, 0.0, 71.8129 },
      SpawnCart = { -872.58, -1366.57, 42.53, 270.35 },
      CamCart = { -869.7852, -1361.103, 45.26991, -17.11994, 0.0, 161.4039 }
    },
    {
      Name = "Tumbleweed Stable",
      BlipIcon = 1938782895,
      EnterStable = { -5514.24, -3041.81, -2.39, 2.0 },
      StableNPC = { -5515.07, -3039.51, -3.39, 179.88 },
      SpawnHorse = { -5519.47, -3039.32, -3.31, 181.62 },
      CamHorse = { -5517.651, -3041.113, -0.50949, -33.14523, 0.0, 55.47822 },
      CamHorseGear = { -5517.651, -3041.113, -0.50949, -33.14523, 0.0, 55.47822 },
      SpawnCart = { -5520.65, -3044.3, -3.39, 270.83 },
      CamCart = { -5514.191, -3040.633, -0.5108569, -18.79705, 0.0, 141.3175 }
    }
  }
}

