{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE MultiParamTypeClasses #-}

-- Autogenerated Mavlink v1.0 implementation: see smavgen_ivory.py

module SMACCMPilot.Mavlink.Ivory.Messages.AttitudeQuaternion where

import Ivory.Language
import Ivory.Serialize
import SMACCMPilot.Mavlink.Ivory.Send
import SMACCMPilot.Mavlink.Ivory.Unpack

attitudeQuaternionMsgId :: Uint8
attitudeQuaternionMsgId = 31

attitudeQuaternionCrcExtra :: Uint8
attitudeQuaternionCrcExtra = 246

attitudeQuaternionModule :: Module
attitudeQuaternionModule = package "mavlink_attitude_quaternion_msg" $ do
  depend serializeModule
  depend mavlinkSendModule
  incl mkAttitudeQuaternionSender
  incl attitudeQuaternionUnpack
  defStruct (Proxy :: Proxy "attitude_quaternion_msg")
  wrappedPackMod attitudeQuaternionWrapper

[ivory|
struct attitude_quaternion_msg
  { time_boot_ms :: Stored Uint32
  ; q1 :: Stored IFloat
  ; q2 :: Stored IFloat
  ; q3 :: Stored IFloat
  ; q4 :: Stored IFloat
  ; rollspeed :: Stored IFloat
  ; pitchspeed :: Stored IFloat
  ; yawspeed :: Stored IFloat
  }
|]

mkAttitudeQuaternionSender ::
  Def ('[ ConstRef s0 (Struct "attitude_quaternion_msg")
        , Ref s1 (Stored Uint8) -- seqNum
        , Ref s1 (Struct "mavlinkPacket") -- tx buffer/length
        ] :-> ())
mkAttitudeQuaternionSender = makeMavlinkSender "attitude_quaternion_msg" attitudeQuaternionMsgId attitudeQuaternionCrcExtra

instance MavlinkUnpackableMsg "attitude_quaternion_msg" where
    unpackMsg = ( attitudeQuaternionUnpack , attitudeQuaternionMsgId )

attitudeQuaternionUnpack :: Def ('[ Ref s1 (Struct "attitude_quaternion_msg")
                             , ConstRef s2 (CArray (Stored Uint8))
                             ] :-> () )
attitudeQuaternionUnpack = proc "mavlink_attitude_quaternion_unpack" $ \ msg buf -> body $ packGet packRep buf 0 msg

attitudeQuaternionWrapper :: WrappedPackRep (Struct "attitude_quaternion_msg")
attitudeQuaternionWrapper = wrapPackRep "mavlink_attitude_quaternion" $ packStruct
  [ packLabel time_boot_ms
  , packLabel q1
  , packLabel q2
  , packLabel q3
  , packLabel q4
  , packLabel rollspeed
  , packLabel pitchspeed
  , packLabel yawspeed
  ]

instance Packable (Struct "attitude_quaternion_msg") where
  packRep = wrappedPackRep attitudeQuaternionWrapper
