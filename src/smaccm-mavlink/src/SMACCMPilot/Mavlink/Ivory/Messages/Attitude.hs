{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE MultiParamTypeClasses #-}

-- Autogenerated Mavlink v1.0 implementation: see smavgen_ivory.py

module SMACCMPilot.Mavlink.Ivory.Messages.Attitude where

import Ivory.Language
import Ivory.Serialize
import SMACCMPilot.Mavlink.Ivory.Send
import SMACCMPilot.Mavlink.Ivory.Unpack

attitudeMsgId :: Uint8
attitudeMsgId = 30

attitudeCrcExtra :: Uint8
attitudeCrcExtra = 39

attitudeModule :: Module
attitudeModule = package "mavlink_attitude_msg" $ do
  depend serializeModule
  depend mavlinkSendModule
  incl mkAttitudeSender
  incl attitudeUnpack
  defStruct (Proxy :: Proxy "attitude_msg")
  wrappedPackMod attitudeWrapper

[ivory|
struct attitude_msg
  { time_boot_ms :: Stored Uint32
  ; roll :: Stored IFloat
  ; pitch :: Stored IFloat
  ; yaw :: Stored IFloat
  ; rollspeed :: Stored IFloat
  ; pitchspeed :: Stored IFloat
  ; yawspeed :: Stored IFloat
  }
|]

mkAttitudeSender ::
  Def ('[ ConstRef s0 (Struct "attitude_msg")
        , Ref s1 (Stored Uint8) -- seqNum
        , Ref s1 (Struct "mavlinkPacket") -- tx buffer/length
        ] :-> ())
mkAttitudeSender = makeMavlinkSender "attitude_msg" attitudeMsgId attitudeCrcExtra

instance MavlinkUnpackableMsg "attitude_msg" where
    unpackMsg = ( attitudeUnpack , attitudeMsgId )

attitudeUnpack :: Def ('[ Ref s1 (Struct "attitude_msg")
                             , ConstRef s2 (CArray (Stored Uint8))
                             ] :-> () )
attitudeUnpack = proc "mavlink_attitude_unpack" $ \ msg buf -> body $ packGet packRep buf 0 msg

attitudeWrapper :: WrappedPackRep (Struct "attitude_msg")
attitudeWrapper = wrapPackRep "mavlink_attitude" $ packStruct
  [ packLabel time_boot_ms
  , packLabel roll
  , packLabel pitch
  , packLabel yaw
  , packLabel rollspeed
  , packLabel pitchspeed
  , packLabel yawspeed
  ]

instance Packable (Struct "attitude_msg") where
  packRep = wrappedPackRep attitudeWrapper
