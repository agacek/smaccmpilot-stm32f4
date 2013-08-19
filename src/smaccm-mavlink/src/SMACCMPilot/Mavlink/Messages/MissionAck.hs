{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE MultiParamTypeClasses #-}

-- Autogenerated Mavlink v1.0 implementation: see smavgen_ivory.py

module SMACCMPilot.Mavlink.Messages.MissionAck where

import SMACCMPilot.Mavlink.Pack
import SMACCMPilot.Mavlink.Unpack
import SMACCMPilot.Mavlink.Send

import Ivory.Language

missionAckMsgId :: Uint8
missionAckMsgId = 47

missionAckCrcExtra :: Uint8
missionAckCrcExtra = 153

missionAckModule :: Module
missionAckModule = package "mavlink_mission_ack_msg" $ do
  depend packModule
  incl missionAckUnpack
  defStruct (Proxy :: Proxy "mission_ack_msg")

[ivory|
struct mission_ack_msg
  { target_system :: Stored Uint8
  ; target_component :: Stored Uint8
  ; mission_ack_type :: Stored Uint8
  }
|]

mkMissionAckSender :: SizedMavlinkSender 3
                       -> Def ('[ ConstRef s (Struct "mission_ack_msg") ] :-> ())
mkMissionAckSender sender =
  proc ("mavlink_mission_ack_msg_send" ++ (senderName sender)) $ \msg -> body $ do
    noReturn $ missionAckPack (senderMacro sender) msg

instance MavlinkSendable "mission_ack_msg" 3 where
  mkSender = mkMissionAckSender

missionAckPack :: SenderMacro cs (Stack cs) 3
                  -> ConstRef s1 (Struct "mission_ack_msg")
                  -> Ivory (AllocEffects cs) ()
missionAckPack sender msg = do
  arr <- local (iarray [] :: Init (Array 3 (Stored Uint8)))
  let buf = toCArray arr
  call_ pack buf 0 =<< deref (msg ~> target_system)
  call_ pack buf 1 =<< deref (msg ~> target_component)
  call_ pack buf 2 =<< deref (msg ~> mission_ack_type)
  sender missionAckMsgId (constRef arr) missionAckCrcExtra

instance MavlinkUnpackableMsg "mission_ack_msg" where
    unpackMsg = ( missionAckUnpack , missionAckMsgId )

missionAckUnpack :: Def ('[ Ref s1 (Struct "mission_ack_msg")
                             , ConstRef s2 (CArray (Stored Uint8))
                             ] :-> () )
missionAckUnpack = proc "mavlink_mission_ack_unpack" $ \ msg buf -> body $ do
  store (msg ~> target_system) =<< call unpack buf 0
  store (msg ~> target_component) =<< call unpack buf 1
  store (msg ~> mission_ack_type) =<< call unpack buf 2

