{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE MultiParamTypeClasses #-}

-- Autogenerated Mavlink v1.0 implementation: see smavgen_ivory.py

module SMACCMPilot.Mavlink.Messages.ParamRequestList where

import SMACCMPilot.Mavlink.Pack
import SMACCMPilot.Mavlink.Unpack
import SMACCMPilot.Mavlink.Send

import Ivory.Language

paramRequestListMsgId :: Uint8
paramRequestListMsgId = 21

paramRequestListCrcExtra :: Uint8
paramRequestListCrcExtra = 159

paramRequestListModule :: Module
paramRequestListModule = package "mavlink_param_request_list_msg" $ do
  depend packModule
  incl paramRequestListUnpack
  defStruct (Proxy :: Proxy "param_request_list_msg")

[ivory|
struct param_request_list_msg
  { target_system :: Stored Uint8
  ; target_component :: Stored Uint8
  }
|]

mkParamRequestListSender :: SizedMavlinkSender 2
                       -> Def ('[ ConstRef s (Struct "param_request_list_msg") ] :-> ())
mkParamRequestListSender sender =
  proc ("mavlink_param_request_list_msg_send" ++ (senderName sender)) $ \msg -> body $ do
    noReturn $ paramRequestListPack (senderMacro sender) msg

instance MavlinkSendable "param_request_list_msg" 2 where
  mkSender = mkParamRequestListSender

paramRequestListPack :: SenderMacro cs (Stack cs) 2
                  -> ConstRef s1 (Struct "param_request_list_msg")
                  -> Ivory (AllocEffects cs) ()
paramRequestListPack sender msg = do
  arr <- local (iarray [] :: Init (Array 2 (Stored Uint8)))
  let buf = toCArray arr
  call_ pack buf 0 =<< deref (msg ~> target_system)
  call_ pack buf 1 =<< deref (msg ~> target_component)
  sender paramRequestListMsgId (constRef arr) paramRequestListCrcExtra

instance MavlinkUnpackableMsg "param_request_list_msg" where
    unpackMsg = ( paramRequestListUnpack , paramRequestListMsgId )

paramRequestListUnpack :: Def ('[ Ref s1 (Struct "param_request_list_msg")
                             , ConstRef s2 (CArray (Stored Uint8))
                             ] :-> () )
paramRequestListUnpack = proc "mavlink_param_request_list_unpack" $ \ msg buf -> body $ do
  store (msg ~> target_system) =<< call unpack buf 0
  store (msg ~> target_component) =<< call unpack buf 1

