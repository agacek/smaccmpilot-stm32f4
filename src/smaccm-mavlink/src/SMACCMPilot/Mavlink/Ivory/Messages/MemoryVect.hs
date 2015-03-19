{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE MultiParamTypeClasses #-}

-- Autogenerated Mavlink v1.0 implementation: see smavgen_ivory.py

module SMACCMPilot.Mavlink.Ivory.Messages.MemoryVect where

import Ivory.Language
import Ivory.Serialize
import SMACCMPilot.Mavlink.Ivory.Send
import SMACCMPilot.Mavlink.Ivory.Unpack

memoryVectMsgId :: Uint8
memoryVectMsgId = 249

memoryVectCrcExtra :: Uint8
memoryVectCrcExtra = 204

memoryVectModule :: Module
memoryVectModule = package "mavlink_memory_vect_msg" $ do
  depend serializeModule
  depend mavlinkSendModule
  incl mkMemoryVectSender
  incl memoryVectUnpack
  defStruct (Proxy :: Proxy "memory_vect_msg")
  wrappedPackMod memoryVectWrapper

[ivory|
struct memory_vect_msg
  { address :: Stored Uint16
  ; ver :: Stored Uint8
  ; memory_vect_type :: Stored Uint8
  ; value :: Array 32 (Stored Sint8)
  }
|]

mkMemoryVectSender ::
  Def ('[ ConstRef s0 (Struct "memory_vect_msg")
        , Ref s1 (Stored Uint8) -- seqNum
        , Ref s1 (Struct "mavlinkPacket") -- tx buffer/length
        ] :-> ())
mkMemoryVectSender = makeMavlinkSender "memory_vect_msg" memoryVectMsgId memoryVectCrcExtra

instance MavlinkUnpackableMsg "memory_vect_msg" where
    unpackMsg = ( memoryVectUnpack , memoryVectMsgId )

memoryVectUnpack :: Def ('[ Ref s1 (Struct "memory_vect_msg")
                             , ConstRef s2 (CArray (Stored Uint8))
                             ] :-> () )
memoryVectUnpack = proc "mavlink_memory_vect_unpack" $ \ msg buf -> body $ packGet packRep buf 0 msg

memoryVectWrapper :: WrappedPackRep (Struct "memory_vect_msg")
memoryVectWrapper = wrapPackRep "mavlink_memory_vect" $ packStruct
  [ packLabel address
  , packLabel ver
  , packLabel memory_vect_type
  , packLabel value
  ]

instance Packable (Struct "memory_vect_msg") where
  packRep = wrappedPackRep memoryVectWrapper
