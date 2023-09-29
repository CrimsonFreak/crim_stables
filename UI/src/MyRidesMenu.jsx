import { useContext, useEffect, useState } from "react";
import { RouteCtx } from "./App";
import axios from "axios";

function MyRidesMenu({ Data: { characterId, rides } }) {
  const setRoute = useContext(RouteCtx);
  const [currentRideIndex, setCurrentRideIndex] = useState(0);
  const ride = rides[currentRideIndex];
  const [modalOn, setModalOn] = useState(false);
  const [timer, setTimer] = useState(true);

  useEffect(() => {
    document.onkeydown = (e) => {
      if (e.key === "ArrowLeft" && timer) {
        setCurrentRideIndex(i =>
          i === 0 ? rides.length - 1 : i - 1
        )
        setTimer(false);
        setTimeout(() => setTimer(true), 500)
      }
      else if (e.key === "ArrowRight" && timer) {
        setCurrentRideIndex(i =>
          i === rides.length - 1 ? 0 : i + 1
        )
        setTimer(false);
        setTimeout(() => setTimer(true), 500)
      }
      else if (e.key === "Backspace" && !modalOn) {
        setRoute("/");
      }
    }
  })

  useEffect(() => {
    const ride = rides[currentRideIndex];
    if (!ride) return;
    axios.post(`https://${GetParentResourceName()}/activateCam`, { rideType: ride.type });
    axios.post(`https://${GetParentResourceName()}/showRide`, {
      rideType: ride.type,
      rideName: ride.model,
      rideComps: ride.comps
    });
  }, [currentRideIndex])

  function setDefault() {
    axios.post(`https://${GetParentResourceName()}/setDefault`, { newRide: ride.id, prevRide: rides.find(r => r.type === ride.type && r.isDefault)?.id });
  }

  return (
    <div className="menu-wrap">
      {
        modalOn &&
        <div className="modal-bg">
          <div className="modal">
            <h3>{Data.Lang.EnterNameToConfirm}</h3>
            <input id="deleteConfirm" type="text" placeholder={ride.name} />
            <span>
              <button onClick={() => {
                const confirm = document.querySelector('#deleteConfirm').value
                if (confirm.toLowerCase() === ride.name.toLowerCase()) {
                  axios.post(`https://${GetParentResourceName()}/free`, { rideId: ride.id });
                }
                setModalOn(false)
              }}>{Config.Lang.Ok}</button>
              <button onClick={() => { setModalOn(false) }}>{Config.Lang.Cancel}</button>
            </span>
          </div>
        </div>
      }
      <h1>{Config.Lang.MyRides}</h1>
      <h3>◄ {ride.name}{ride.isDefault ? ` (${Config.Lang.Active})` : null} ►</h3>
      <menu>
        {!ride.isDefault && <span onClick={setDefault}>{Config.Lang.ChooseAsActive.replace("{rideType}", Config.Lang[ride.type])}</span>}
        {
          ride.type == "horse" &&
          <>
            <span onClick={() => setRoute("/buycomps?" + ride.id)}>{Config.Lang.BuyEquipment}</span>
            <span onClick={() => setRoute("/changecomps?" + ride.id)}>{Config.Lang.ModifyEquipment}</span>
          </>
        }
        <span onClick={() => setRoute("/transfer?" + ride.id)}>{Config.Lang.Transfer}</span>
        <span onClick={() => setModalOn(true)}>{Config.Lang.FreeRide}</span>
      </menu>
    </div>
  )
}

export default MyRidesMenu;