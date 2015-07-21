

module SMACCMPilot.Flight.UserInput.TestApp
  ( app
  ) where

import Ivory.Language
import Ivory.Tower

import           SMACCMPilot.Flight.Platform
import           SMACCMPilot.Flight.Datalink
import           SMACCMPilot.Flight.IO
import           SMACCMPilot.Flight.UserInput

import qualified SMACCMPilot.Comm.Ivory.Types.SensorsResult as S
import           SMACCMPilot.Comm.Tower.Attr
import           SMACCMPilot.Comm.Tower.Interface.ControllableVehicle

app :: (e -> FlightPlatform)
    -> Tower e ()
app tofp = do
  (attrs, _streams) <- datalinkTower tofp 115200

  rcin_ui <- channel
  rcin_cl <- channel

  -- Never write to motor output.
  (_, motor_output) <- channel

  flightIOTower tofp attrs
                (fst rcin_ui) (fst rcin_cl)
                (attrReaderChan (controlLaw attrs))
                motor_output

  userInputTower (snd rcin_ui) (snd rcin_cl) attrs

  -- Just for testing, lets pretend there is a valid IMU.
  monitor "fake_sensor_output_valid" $ do
    handler systemInit "init" $ do
      e <- attrEmitter (sensorsOutput attrs)
      callback $ const $ do
        v <- local izero
        store (v ~> S.valid) true
        emit e (constRef v)


