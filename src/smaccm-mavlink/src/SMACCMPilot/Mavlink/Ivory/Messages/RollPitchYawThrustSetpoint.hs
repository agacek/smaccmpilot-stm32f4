{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE MultiParamTypeClasses #-}

-- Autogenerated Mavlink v1.0 implementation: see smavgen_ivory.py

module SMACCMPilot.Mavlink.Ivory.Messages.RollPitchYawThrustSetpoint where

import Ivory.Language
import Ivory.Serialize
import SMACCMPilot.Mavlink.Ivory.Send
import SMACCMPilot.Mavlink.Ivory.Unpack

rollPitchYawThrustSetpointMsgId :: Uint8
rollPitchYawThrustSetpointMsgId = 58

rollPitchYawThrustSetpointCrcExtra :: Uint8
rollPitchYawThrustSetpointCrcExtra = 239

rollPitchYawThrustSetpointModule :: Module
rollPitchYawThrustSetpointModule = package "mavlink_roll_pitch_yaw_thrust_setpoint_msg" $ do
  depend serializeModule
  depend mavlinkSendModule
  incl mkRollPitchYawThrustSetpointSender
  incl rollPitchYawThrustSetpointUnpack
  defStruct (Proxy :: Proxy "roll_pitch_yaw_thrust_setpoint_msg")
  wrappedPackMod rollPitchYawThrustSetpointWrapper

[ivory|
struct roll_pitch_yaw_thrust_setpoint_msg
  { time_boot_ms :: Stored Uint32
  ; roll :: Stored IFloat
  ; pitch :: Stored IFloat
  ; yaw :: Stored IFloat
  ; thrust :: Stored IFloat
  }
|]

mkRollPitchYawThrustSetpointSender ::
  Def ('[ ConstRef s0 (Struct "roll_pitch_yaw_thrust_setpoint_msg")
        , Ref s1 (Stored Uint8) -- seqNum
        , Ref s1 (Struct "mavlinkPacket") -- tx buffer/length
        ] :-> ())
mkRollPitchYawThrustSetpointSender = makeMavlinkSender "roll_pitch_yaw_thrust_setpoint_msg" rollPitchYawThrustSetpointMsgId rollPitchYawThrustSetpointCrcExtra

instance MavlinkUnpackableMsg "roll_pitch_yaw_thrust_setpoint_msg" where
    unpackMsg = ( rollPitchYawThrustSetpointUnpack , rollPitchYawThrustSetpointMsgId )

rollPitchYawThrustSetpointUnpack :: Def ('[ Ref s1 (Struct "roll_pitch_yaw_thrust_setpoint_msg")
                             , ConstRef s2 (CArray (Stored Uint8))
                             ] :-> () )
rollPitchYawThrustSetpointUnpack = proc "mavlink_roll_pitch_yaw_thrust_setpoint_unpack" $ \ msg buf -> body $ packGet packRep buf 0 msg

rollPitchYawThrustSetpointWrapper :: WrappedPackRep (Struct "roll_pitch_yaw_thrust_setpoint_msg")
rollPitchYawThrustSetpointWrapper = wrapPackRep "mavlink_roll_pitch_yaw_thrust_setpoint" $ packStruct
  [ packLabel time_boot_ms
  , packLabel roll
  , packLabel pitch
  , packLabel yaw
  , packLabel thrust
  ]

instance Packable (Struct "roll_pitch_yaw_thrust_setpoint_msg") where
  packRep = wrappedPackRep rollPitchYawThrustSetpointWrapper
