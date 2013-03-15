{-# LANGUAGE Rank2Types #-}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE QuasiQuotes #-}

module SMACCMPilot.Flight.GCS.Transmit.MessageDriver
  ( MessageDriver(..)
  , messageDriver
  ) where

import Ivory.Language

import SMACCMPilot.Util.IvoryHelpers

import qualified SMACCMPilot.Flight.Types.Position      as P
import qualified SMACCMPilot.Flight.Types.Servos        as Serv
import qualified SMACCMPilot.Flight.Types.Sensors       as Sens
import qualified SMACCMPilot.Flight.Types.ControlOutput as C
import qualified SMACCMPilot.Flight.Types.UserInput     as U
import qualified SMACCMPilot.Flight.Types.FlightMode    as FM

import qualified SMACCMPilot.Param as Param

import SMACCMPilot.Mavlink.Send
import SMACCMPilot.Mavlink.Messages

import qualified SMACCMPilot.Mavlink.Messages.Heartbeat as HB
import qualified SMACCMPilot.Mavlink.Messages.Attitude as ATT
import qualified SMACCMPilot.Mavlink.Messages.VfrHud as HUD
import qualified SMACCMPilot.Mavlink.Messages.ServoOutputRaw as SVO
import qualified SMACCMPilot.Mavlink.Messages.GpsRawInt as GRI
import qualified SMACCMPilot.Mavlink.Messages.GlobalPositionInt as GPI
import qualified SMACCMPilot.Mavlink.Messages.ParamValue as PV

--------------------------------------------------------------------
-- Generated Defs 
data MessageDriver =
  MessageDriver
    { sendHeartbeat      :: forall s
                          . Def ('[ (Ref s (Struct "flightmode")) ] :-> ())
    , sendAttitude       :: forall s
                          . Def ('[ (Ref s (Struct "sensors_result")) ] :-> ())
    , sendVfrHud         :: forall s1 s2 s3
                          . Def ('[ (Ref s1 (Struct "position_result"))
                                  , (Ref s2 (Struct "controloutput"))
                                  , (Ref s3 (Struct "sensors_result"))
                                  ] :-> ())
    , sendServoOutputRaw :: forall s1 s2
                          . Def ('[ (Ref s1 (Struct "servos"))
                                  , (Ref s2 (Struct "controloutput"))
                                  ] :-> ())
    , sendGpsRawInt      :: forall s
                          . Def ('[ (Ref s (Struct "position_result"))
                                  ] :-> ())
    , sendGlobalPositionInt :: forall s1 s2
                          . Def ('[ (Ref s1 (Struct "position_result"))
                                  , (Ref s2 (Struct "sensors_result"))
                                  ] :-> ())
    , sendParamValue     :: forall s
                          . Def ('[ Ref s (Struct "param_info") ] :-> ())
    , sendParams         :: Def ('[] :-> ())
    }

--------------------------------------------------------------------
-- Generated dependencies

moddefs :: MessageDriver -> ModuleDef
moddefs d = do
  incl (sendHeartbeat d)
  incl (sendAttitude d)
  incl (sendVfrHud d)
  incl (sendServoOutputRaw d)
  incl (sendGpsRawInt d)
  incl (sendGlobalPositionInt d)
  incl (sendParamValue d)
  incl (sendParams d)
  -- dependencies for all the smaccmpilot flight types
  depend P.positionTypeModule
  depend Serv.servosTypeModule
  depend Sens.sensorsTypeModule
  depend C.controlOutputTypeModule
  depend U.userInputTypeModule
  depend FM.flightModeTypeModule
  depend Param.paramModule
  -- dependencies for all the mavlink message types
  depend HB.heartbeatModule
  depend ATT.attitudeModule
  depend HUD.vfrHudModule
  depend SVO.servoOutputRawModule
  depend GRI.gpsRawIntModule
  depend GPI.globalPositionIntModule
  depend PV.paramValueModule
  inclHeader "string"

messageDriver :: MavlinkSender -> (MessageDriver, [Module])
messageDriver sender = (driver, [driverMod,  msgMod])
  where
  (msgSenders, msgMod) = mavlinkMessageSenders sender
  driver =
    MessageDriver
      { sendHeartbeat = mkSendHeartbeat msgSenders
      , sendAttitude = mkSendAttitude msgSenders
      , sendVfrHud = mkSendVfrHud msgSenders
      , sendServoOutputRaw = mkSendServoOutputRaw msgSenders
      , sendGpsRawInt = mkSendGpsRawInt msgSenders
      , sendGlobalPositionInt = mkSendGlobalPositionInt msgSenders
      , sendParamValue = mkSendParamValue msgSenders
      , sendParams = mkSendParams msgSenders
      }
  driverMod = package ("gcs_transmit_driver_" ++ (senderName sender)) $ do
    depend msgMod
    moddefs driver


mkSendHeartbeat :: MavlinkMessageSenders
              -> Def ('[ (Ref s1 (Struct "flightmode")) ] :-> ())
mkSendHeartbeat senders = proc "gcs_transmit_send_heartbeat" $ 
  \fm -> body $ do
  hb <- local (istruct [])
  armed <- (fm ~>* FM.armed)
  mode  <- (fm ~>* FM.mode)
  store (hb ~> HB.custom_mode) (mode_to_ac2mode mode)
  store (hb ~> HB.mavtype)      mavtype_quadrotor
  -- masquerade as an APM so we can use their custom modes, for now
  store (hb ~> HB.autopilot)    autopilot_ardupilotmega
  ifte armed
    (store (hb ~> HB.base_mode) (mavl_armed + mavl_custom_mode))
    (store (hb ~> HB.base_mode) (mavl_custom_mode))
  -- system status stays 0
  store (hb ~> HB.mavlink_version) 3 -- magic number

  call_ (heartbeatSender senders) (constRef hb)
  retVoid 
  where
  _autopilot_generic, autopilot_ardupilotmega, mavtype_quadrotor :: Uint8
  _autopilot_generic      = 0 -- MAV_AUTOPILOT_GENERIC
  autopilot_ardupilotmega = 3 -- MAV_AUTOPILOT_ARDUPILOTMEGA
  mavtype_quadrotor       = 2 -- MAV_TYPE_QUADROTOR

  mavl_armed        = 128  
  mavl_custom_mode  = 1
  ac2mode_stabilize = 0
  ac2mode_alt_hold  = 2
  ac2mode_loiter    = 5
  mode_to_ac2mode :: Uint8 -> Uint32
  mode_to_ac2mode um = foldr translate ac2mode_stabilize t
    where
    translate (umode, ac2mode) c = (um ==? umode) ? (ac2mode, c)
    t = [ (FM.flightModeStabilize, ac2mode_stabilize)
        , (FM.flightModeAltHold,   ac2mode_alt_hold)
        , (FM.flightModeLoiter,    ac2mode_loiter)
        ]


mkSendAttitude :: MavlinkMessageSenders
             -> Def ('[ (Ref s1 (Struct "sensors_result")) ] :-> ())
mkSendAttitude senders = proc "gcs_transmit_send_attitude" $ \sensors -> body $ do
  att <- local (istruct [])
  (sensors ~> Sens.time)    `into` (att ~> ATT.time_boot_ms)
  (sensors ~> Sens.roll)    `into` (att ~> ATT.roll)
  (sensors ~> Sens.pitch)   `into` (att ~> ATT.pitch)
  (sensors ~> Sens.yaw)     `into` (att ~> ATT.yaw)
  (sensors ~> Sens.omega_x) `into` (att ~> ATT.rollspeed)
  (sensors ~> Sens.omega_y) `into` (att ~> ATT.rollspeed)
  (sensors ~> Sens.omega_z) `into` (att ~> ATT.rollspeed)
  call_ (attitudeSender senders) (constRef att)
  retVoid 

mkSendVfrHud :: MavlinkMessageSenders
           -> Def ('[ (Ref s1 (Struct "position_result"))
                    , (Ref s2 (Struct "controloutput"))
                    , (Ref s3 (Struct "sensors_result"))
                    ] :-> ())
mkSendVfrHud senders = proc "gcs_transmit_send_vfrhud" $ \pos ctl sens -> body $ do
  hud <- local (istruct [])
  -- Calculating speed from vx/vy/vz int16s in m/s*100, into float in m/s
  (calcSpeed pos) `resultInto` (hud ~> HUD.groundspeed)
  (calcSpeed pos) `resultInto` (hud ~> HUD.airspeed)
  -- Calculating alt from int32 in milimeters, into float in meters
  (calcAltitude pos) `resultInto` (hud ~> HUD.alt)
  -- Vertical zpeed from vz
  (calcVertSpeed pos) `resultInto` (hud ~> HUD.climb)
  -- Heading from sensors
  (calcHeading sens) `resultInto` (hud ~> HUD.heading)
  -- Throttle from control output 
  (calcThrottle ctl) `resultInto` (hud ~> HUD.throttle)
  call_ (vfrHudSender senders) (constRef hud)
  retVoid 
  where
  calcSpeed :: Ref s (Struct "position_result") -> Ivory lex () IFloat
  calcSpeed pos = do
    vx <- (pos ~>* P.vx)
    vy <- (pos ~>* P.vy)
    vz <- (pos ~>* P.vz)
    sumsquares <- assign (safeCast (vx * vx + vy * vy + vz * vz) :: IFloat)
    return $ sqrt sumsquares

  calcAltitude :: Ref s (Struct "position_result") -> Ivory lex () IFloat
  calcAltitude pos = do
    milimeters <- (pos ~>* P.gps_alt)
    mm_float <- assign $ toFloat milimeters
    return (mm_float / 1000)

  calcVertSpeed :: (Ref s (Struct "position_result")) -> Ivory lex () IFloat
  calcVertSpeed pos = do
    meterspersec <- (pos ~>* P.vz)
    return $ (safeCast meterspersec :: IFloat)

  calcHeading :: Ref s (Struct "sensors_result") -> Ivory lex () Sint16
  calcHeading sens = do
    radians <- (sens ~>* Sens.yaw)
    degrees <- assign $ 180 / pi * radians
    deg_int <- assign $ fromFloat 0 degrees
    return  deg_int

  calcThrottle :: Ref s (Struct "controloutput") -> Ivory l () Uint16
  calcThrottle control = do
    thrFloat <- (control ~>* C.throttle)
    return $ fromFloat 0 (thrFloat * 100)

mkSendServoOutputRaw :: MavlinkMessageSenders
                   -> Def ('[ (Ref s1 (Struct "servos"))
                            , (Ref s2 (Struct "controloutput"))
                            ] :-> ())
mkSendServoOutputRaw senders = proc "gcs_transmit_send_servo_output" $
  \state ctl -> body $ do
  msg <- local (istruct [])
  (state ~> Serv.time)   `into` (msg ~> SVO.time_usec)
  (state ~> Serv.servo1) `into` (msg ~> SVO.servo1_raw)
  (state ~> Serv.servo2) `into` (msg ~> SVO.servo2_raw)
  (state ~> Serv.servo3) `into` (msg ~> SVO.servo3_raw)
  (state ~> Serv.servo4) `into` (msg ~> SVO.servo4_raw)
  pitch <- (ctl ~>* C.pitch)
  roll  <- (ctl ~>* C.roll)
  thr   <- (ctl ~>* C.throttle)
  let toSvo :: IFloat -> Uint16
      toSvo f = fromFloat 9999 ((f + 1) * 100)
  store (msg ~> SVO.servo6_raw) (toSvo roll)
  store (msg ~> SVO.servo7_raw) (toSvo pitch)
  store (msg ~> SVO.servo8_raw) (toSvo thr)

  call_ (servoOutputRawSender senders) (constRef msg)


mkSendGpsRawInt :: MavlinkMessageSenders
              -> Def ('[ (Ref s (Struct "position_result"))
                       ] :-> ())
mkSendGpsRawInt senders = proc "gcs_transmit_send_gps_raw_int" $
  \pos -> body $ do
  msg <- local (istruct [])
  (pos ~> P.lat)     `into` (msg ~> GRI.lat)
  (pos ~> P.lon)     `into` (msg ~> GRI.lon)
  (pos ~> P.gps_alt) `into` (msg ~> GRI.alt)
  store (msg ~> GRI.eph) 10
  store (msg ~> GRI.epv) 10
  store (msg ~> GRI.vel) 1 -- XXX can calculate this
  store (msg ~> GRI.cog) 359 -- XXX can calulate this
  store (msg ~> GRI.fix_type) 3 -- 3d fix
  store (msg ~> GRI.satellites_visible) 8
  call_ (gpsRawIntSender senders) (constRef msg)
  retVoid 

mkSendGlobalPositionInt :: MavlinkMessageSenders
                      -> Def ('[ (Ref s1 (Struct "position_result"))
                               , (Ref s2 (Struct "sensors_result"))
                               ] :-> ())
mkSendGlobalPositionInt senders = proc "gcs_transmit_send_global_position_int" $ 
  \pos sens -> body $ do
  msg <- local (istruct [])
  yawfloat <- (sens ~>* Sens.yaw)
  yawscaled <- assign $ (10*180/pi)*yawfloat -- radians to 10*degrees
  store (msg ~> GPI.hdg) (fromFloat 9999 yawscaled)
  (pos ~> P.lat)     `into` (msg ~> GPI.lat)
  (pos ~> P.lon)     `into` (msg ~> GPI.lon)
  (pos ~> P.gps_alt) `into` (msg ~> GPI.alt)
  (pos ~> P.vx) `into` (msg ~> GPI.vx)
  (pos ~> P.vy) `into` (msg ~> GPI.vy)
  (pos ~> P.vz) `into` (msg ~> GPI.vz)
  call_ (globalPositionIntSender senders) (constRef msg)
  retVoid 

-- Import "strncpy" to fill in the string field with the correct
-- behavior and paper over the char/uint8_t difference.
pv_strncpy :: Def ('[ Ref s1 (CArray (Stored Uint8))
                    , ConstRef s2 (CArray (Stored IChar))
                    , Uint32]
                :-> ())
pv_strncpy = importProc "strncpy" "string"

mkSendParamValue :: MavlinkMessageSenders
               -> Def ('[ Ref s1 (Struct "param_info") ] :-> ())
mkSendParamValue senders = proc "gcs_transmit_send_param_value" $
  \param -> body $ do
  msg   <- local (istruct [])
  value <- call Param.param_get_float_value param
  store (msg ~> PV.param_value) value
  count <- Param.param_get_count
  store (msg ~> PV.param_count) (ixCast count)
  index <- deref (param ~> Param.param_index)
  store (msg ~> PV.param_index) (ixCast index)
  call_ pv_strncpy (toCArray (msg ~> PV.param_id))
                   (constRef (toCArray (param ~> Param.param_name))) 16
  store (msg ~> PV.param_type) 0 -- FIXME
  call_ (paramValueSender senders) (constRef msg)

-- | Send the first parameter marked as requested.
mkSendParams :: MavlinkMessageSenders -> Def ('[] :-> ())
mkSendParams senders = proc "gcs_transmit_send_params" $ body $ do
  pinfo <- call Param.param_get_requested
  withRef pinfo
          (\info -> do
             store (info ~> Param.param_requested) 0
             call_ (mkSendParamValue senders) info)
          retVoid