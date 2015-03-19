{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE MultiParamTypeClasses #-}

-- Autogenerated Mavlink v1.0 implementation: see smavgen_ivory.py

module SMACCMPilot.Mavlink.Ivory.Messages.ServoOutputRaw where

import Ivory.Language
import Ivory.Serialize
import SMACCMPilot.Mavlink.Ivory.Send
import SMACCMPilot.Mavlink.Ivory.Unpack

servoOutputRawMsgId :: Uint8
servoOutputRawMsgId = 36

servoOutputRawCrcExtra :: Uint8
servoOutputRawCrcExtra = 222

servoOutputRawModule :: Module
servoOutputRawModule = package "mavlink_servo_output_raw_msg" $ do
  depend serializeModule
  depend mavlinkSendModule
  incl mkServoOutputRawSender
  incl servoOutputRawUnpack
  defStruct (Proxy :: Proxy "servo_output_raw_msg")
  wrappedPackMod servoOutputRawWrapper

[ivory|
struct servo_output_raw_msg
  { time_usec :: Stored Uint32
  ; servo1_raw :: Stored Uint16
  ; servo2_raw :: Stored Uint16
  ; servo3_raw :: Stored Uint16
  ; servo4_raw :: Stored Uint16
  ; servo5_raw :: Stored Uint16
  ; servo6_raw :: Stored Uint16
  ; servo7_raw :: Stored Uint16
  ; servo8_raw :: Stored Uint16
  ; port :: Stored Uint8
  }
|]

mkServoOutputRawSender ::
  Def ('[ ConstRef s0 (Struct "servo_output_raw_msg")
        , Ref s1 (Stored Uint8) -- seqNum
        , Ref s1 (Struct "mavlinkPacket") -- tx buffer/length
        ] :-> ())
mkServoOutputRawSender = makeMavlinkSender "servo_output_raw_msg" servoOutputRawMsgId servoOutputRawCrcExtra

instance MavlinkUnpackableMsg "servo_output_raw_msg" where
    unpackMsg = ( servoOutputRawUnpack , servoOutputRawMsgId )

servoOutputRawUnpack :: Def ('[ Ref s1 (Struct "servo_output_raw_msg")
                             , ConstRef s2 (CArray (Stored Uint8))
                             ] :-> () )
servoOutputRawUnpack = proc "mavlink_servo_output_raw_unpack" $ \ msg buf -> body $ packGet packRep buf 0 msg

servoOutputRawWrapper :: WrappedPackRep (Struct "servo_output_raw_msg")
servoOutputRawWrapper = wrapPackRep "mavlink_servo_output_raw" $ packStruct
  [ packLabel time_usec
  , packLabel servo1_raw
  , packLabel servo2_raw
  , packLabel servo3_raw
  , packLabel servo4_raw
  , packLabel servo5_raw
  , packLabel servo6_raw
  , packLabel servo7_raw
  , packLabel servo8_raw
  , packLabel port
  ]

instance Packable (Struct "servo_output_raw_msg") where
  packRep = wrappedPackRep servoOutputRawWrapper
