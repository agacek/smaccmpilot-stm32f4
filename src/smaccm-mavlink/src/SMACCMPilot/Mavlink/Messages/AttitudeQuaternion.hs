{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE MultiParamTypeClasses #-}

-- Autogenerated Mavlink v1.0 implementation: see smavgen_ivory.py

module SMACCMPilot.Mavlink.Messages.AttitudeQuaternion where

import SMACCMPilot.Mavlink.Pack
import SMACCMPilot.Mavlink.Unpack
import SMACCMPilot.Mavlink.Send

import Ivory.Language

attitudeQuaternionMsgId :: Uint8
attitudeQuaternionMsgId = 31

attitudeQuaternionCrcExtra :: Uint8
attitudeQuaternionCrcExtra = 246

attitudeQuaternionModule :: Module
attitudeQuaternionModule = package "mavlink_attitude_quaternion_msg" $ do
  depend packModule
  incl attitudeQuaternionUnpack
  defStruct (Proxy :: Proxy "attitude_quaternion_msg")

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

mkAttitudeQuaternionSender :: SizedMavlinkSender 32
                       -> Def ('[ ConstRef s (Struct "attitude_quaternion_msg") ] :-> ())
mkAttitudeQuaternionSender sender =
  proc ("mavlink_attitude_quaternion_msg_send" ++ (senderName sender)) $ \msg -> body $ do
    noReturn $ attitudeQuaternionPack (senderMacro sender) msg

instance MavlinkSendable "attitude_quaternion_msg" 32 where
  mkSender = mkAttitudeQuaternionSender

attitudeQuaternionPack :: SenderMacro cs (Stack cs) 32
                  -> ConstRef s1 (Struct "attitude_quaternion_msg")
                  -> Ivory (AllocEffects cs) ()
attitudeQuaternionPack sender msg = do
  arr <- local (iarray [] :: Init (Array 32 (Stored Uint8)))
  let buf = toCArray arr
  call_ pack buf 0 =<< deref (msg ~> time_boot_ms)
  call_ pack buf 4 =<< deref (msg ~> q1)
  call_ pack buf 8 =<< deref (msg ~> q2)
  call_ pack buf 12 =<< deref (msg ~> q3)
  call_ pack buf 16 =<< deref (msg ~> q4)
  call_ pack buf 20 =<< deref (msg ~> rollspeed)
  call_ pack buf 24 =<< deref (msg ~> pitchspeed)
  call_ pack buf 28 =<< deref (msg ~> yawspeed)
  sender attitudeQuaternionMsgId (constRef arr) attitudeQuaternionCrcExtra

instance MavlinkUnpackableMsg "attitude_quaternion_msg" where
    unpackMsg = ( attitudeQuaternionUnpack , attitudeQuaternionMsgId )

attitudeQuaternionUnpack :: Def ('[ Ref s1 (Struct "attitude_quaternion_msg")
                             , ConstRef s2 (CArray (Stored Uint8))
                             ] :-> () )
attitudeQuaternionUnpack = proc "mavlink_attitude_quaternion_unpack" $ \ msg buf -> body $ do
  store (msg ~> time_boot_ms) =<< call unpack buf 0
  store (msg ~> q1) =<< call unpack buf 4
  store (msg ~> q2) =<< call unpack buf 8
  store (msg ~> q3) =<< call unpack buf 12
  store (msg ~> q4) =<< call unpack buf 16
  store (msg ~> rollspeed) =<< call unpack buf 20
  store (msg ~> pitchspeed) =<< call unpack buf 24
  store (msg ~> yawspeed) =<< call unpack buf 28

