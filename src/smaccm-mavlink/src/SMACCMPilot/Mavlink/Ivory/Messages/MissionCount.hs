{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE MultiParamTypeClasses #-}

-- Autogenerated Mavlink v1.0 implementation: see smavgen_ivory.py

module SMACCMPilot.Mavlink.Ivory.Messages.MissionCount where

import Ivory.Language
import Ivory.Serialize
import SMACCMPilot.Mavlink.Ivory.Send
import SMACCMPilot.Mavlink.Ivory.Unpack

missionCountMsgId :: Uint8
missionCountMsgId = 44

missionCountCrcExtra :: Uint8
missionCountCrcExtra = 221

missionCountModule :: Module
missionCountModule = package "mavlink_mission_count_msg" $ do
  depend serializeModule
  depend mavlinkSendModule
  incl mkMissionCountSender
  incl missionCountUnpack
  defStruct (Proxy :: Proxy "mission_count_msg")
  wrappedPackMod missionCountWrapper

[ivory|
struct mission_count_msg
  { count :: Stored Uint16
  ; target_system :: Stored Uint8
  ; target_component :: Stored Uint8
  }
|]

mkMissionCountSender ::
  Def ('[ ConstRef s0 (Struct "mission_count_msg")
        , Ref s1 (Stored Uint8) -- seqNum
        , Ref s1 (Struct "mavlinkPacket") -- tx buffer/length
        ] :-> ())
mkMissionCountSender = makeMavlinkSender "mission_count_msg" missionCountMsgId missionCountCrcExtra

instance MavlinkUnpackableMsg "mission_count_msg" where
    unpackMsg = ( missionCountUnpack , missionCountMsgId )

missionCountUnpack :: Def ('[ Ref s1 (Struct "mission_count_msg")
                             , ConstRef s2 (CArray (Stored Uint8))
                             ] :-> () )
missionCountUnpack = proc "mavlink_mission_count_unpack" $ \ msg buf -> body $ packGet packRep buf 0 msg

missionCountWrapper :: WrappedPackRep (Struct "mission_count_msg")
missionCountWrapper = wrapPackRep "mavlink_mission_count" $ packStruct
  [ packLabel count
  , packLabel target_system
  , packLabel target_component
  ]

instance Packable (Struct "mission_count_msg") where
  packRep = wrappedPackRep missionCountWrapper
