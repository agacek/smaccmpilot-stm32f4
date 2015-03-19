{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE MultiParamTypeClasses #-}

-- Autogenerated Mavlink v1.0 implementation: see smavgen_ivory.py

module SMACCMPilot.Mavlink.Ivory.Messages.StateCorrection where

import Ivory.Language
import Ivory.Serialize
import SMACCMPilot.Mavlink.Ivory.Send
import SMACCMPilot.Mavlink.Ivory.Unpack

stateCorrectionMsgId :: Uint8
stateCorrectionMsgId = 64

stateCorrectionCrcExtra :: Uint8
stateCorrectionCrcExtra = 130

stateCorrectionModule :: Module
stateCorrectionModule = package "mavlink_state_correction_msg" $ do
  depend serializeModule
  depend mavlinkSendModule
  incl mkStateCorrectionSender
  incl stateCorrectionUnpack
  defStruct (Proxy :: Proxy "state_correction_msg")
  wrappedPackMod stateCorrectionWrapper

[ivory|
struct state_correction_msg
  { xErr :: Stored IFloat
  ; yErr :: Stored IFloat
  ; zErr :: Stored IFloat
  ; rollErr :: Stored IFloat
  ; pitchErr :: Stored IFloat
  ; yawErr :: Stored IFloat
  ; vxErr :: Stored IFloat
  ; vyErr :: Stored IFloat
  ; vzErr :: Stored IFloat
  }
|]

mkStateCorrectionSender ::
  Def ('[ ConstRef s0 (Struct "state_correction_msg")
        , Ref s1 (Stored Uint8) -- seqNum
        , Ref s1 (Struct "mavlinkPacket") -- tx buffer/length
        ] :-> ())
mkStateCorrectionSender = makeMavlinkSender "state_correction_msg" stateCorrectionMsgId stateCorrectionCrcExtra

instance MavlinkUnpackableMsg "state_correction_msg" where
    unpackMsg = ( stateCorrectionUnpack , stateCorrectionMsgId )

stateCorrectionUnpack :: Def ('[ Ref s1 (Struct "state_correction_msg")
                             , ConstRef s2 (CArray (Stored Uint8))
                             ] :-> () )
stateCorrectionUnpack = proc "mavlink_state_correction_unpack" $ \ msg buf -> body $ packGet packRep buf 0 msg

stateCorrectionWrapper :: WrappedPackRep (Struct "state_correction_msg")
stateCorrectionWrapper = wrapPackRep "mavlink_state_correction" $ packStruct
  [ packLabel xErr
  , packLabel yErr
  , packLabel zErr
  , packLabel rollErr
  , packLabel pitchErr
  , packLabel yawErr
  , packLabel vxErr
  , packLabel vyErr
  , packLabel vzErr
  ]

instance Packable (Struct "state_correction_msg") where
  packRep = wrappedPackRep stateCorrectionWrapper
