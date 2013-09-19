{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE MultiParamTypeClasses #-}

-- Autogenerated Mavlink v1.0 implementation: see smavgen_ivory.py

module SMACCMPilot.Mavlink.Messages.ParamRequestRead where

import SMACCMPilot.Mavlink.Pack
import SMACCMPilot.Mavlink.Unpack
import SMACCMPilot.Mavlink.Send

import Ivory.Language

paramRequestReadMsgId :: Uint8
paramRequestReadMsgId = 20

paramRequestReadCrcExtra :: Uint8
paramRequestReadCrcExtra = 214

paramRequestReadModule :: Module
paramRequestReadModule = package "mavlink_param_request_read_msg" $ do
  depend packModule
  incl paramRequestReadUnpack
  defStruct (Proxy :: Proxy "param_request_read_msg")

[ivory|
struct param_request_read_msg
  { param_index :: Stored Sint16
  ; target_system :: Stored Uint8
  ; target_component :: Stored Uint8
  ; param_id :: Array 16 (Stored Uint8)
  }
|]

-- mkParamRequestReadSender :: SizedMavlinkSender 20
--                        -> Def ('[ ConstRef s (Struct "param_request_read_msg") ] :-> ())
-- mkParamRequestReadSender sender =
--   proc ("mavlink_param_request_read_msg_send" ++ (senderName sender)) $ \msg -> body $ do
--     noReturn $ paramRequestReadPack (senderMacro sender) msg

-- instance MavlinkSendable "param_request_read_msg" 20 where
--   mkSender = mkParamRequestReadSender

-- paramRequestReadPack :: SenderMacro cs (Stack cs) 20
--                   -> ConstRef s1 (Struct "param_request_read_msg")
--                   -> Ivory (AllocEffects cs) ()
-- paramRequestReadPack sender msg = do
--   arr <- local (iarray [] :: Init (Array 20 (Stored Uint8)))
--   let buf = toCArray arr
--   call_ pack buf 0 =<< deref (msg ~> param_index)
--   call_ pack buf 2 =<< deref (msg ~> target_system)
--   call_ pack buf 3 =<< deref (msg ~> target_component)
--   arrayPack buf 4 (msg ~> param_id)
--   sender paramRequestReadMsgId (constRef arr) paramRequestReadCrcExtra

instance MavlinkUnpackableMsg "param_request_read_msg" where
    unpackMsg = ( paramRequestReadUnpack , paramRequestReadMsgId )

paramRequestReadUnpack :: Def ('[ Ref s1 (Struct "param_request_read_msg")
                             , ConstRef s2 (CArray (Stored Uint8))
                             ] :-> () )
paramRequestReadUnpack = proc "mavlink_param_request_read_unpack" $ \ msg buf -> body $ do
  store (msg ~> param_index) =<< call unpack buf 0
  store (msg ~> target_system) =<< call unpack buf 2
  store (msg ~> target_component) =<< call unpack buf 3
  arrayUnpack buf 4 (msg ~> param_id)

