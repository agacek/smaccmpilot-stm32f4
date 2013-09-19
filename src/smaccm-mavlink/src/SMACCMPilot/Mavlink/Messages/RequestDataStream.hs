{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE MultiParamTypeClasses #-}

-- Autogenerated Mavlink v1.0 implementation: see smavgen_ivory.py

module SMACCMPilot.Mavlink.Messages.RequestDataStream where

import SMACCMPilot.Mavlink.Pack
import SMACCMPilot.Mavlink.Unpack
import SMACCMPilot.Mavlink.Send

import Ivory.Language

requestDataStreamMsgId :: Uint8
requestDataStreamMsgId = 66

requestDataStreamCrcExtra :: Uint8
requestDataStreamCrcExtra = 148

requestDataStreamModule :: Module
requestDataStreamModule = package "mavlink_request_data_stream_msg" $ do
  depend packModule
  incl requestDataStreamUnpack
  defStruct (Proxy :: Proxy "request_data_stream_msg")

[ivory|
struct request_data_stream_msg
  { req_message_rate :: Stored Uint16
  ; target_system :: Stored Uint8
  ; target_component :: Stored Uint8
  ; req_stream_id :: Stored Uint8
  ; start_stop :: Stored Uint8
  }
|]

-- mkRequestDataStreamSender :: SizedMavlinkSender 6
--                        -> Def ('[ ConstRef s (Struct "request_data_stream_msg") ] :-> ())
-- mkRequestDataStreamSender sender =
--   proc ("mavlink_request_data_stream_msg_send" ++ (senderName sender)) $ \msg -> body $ do
--     noReturn $ requestDataStreamPack (senderMacro sender) msg

-- instance MavlinkSendable "request_data_stream_msg" 6 where
--   mkSender = mkRequestDataStreamSender

-- requestDataStreamPack :: SenderMacro cs (Stack cs) 6
--                   -> ConstRef s1 (Struct "request_data_stream_msg")
--                   -> Ivory (AllocEffects cs) ()
-- requestDataStreamPack sender msg = do
--   arr <- local (iarray [] :: Init (Array 6 (Stored Uint8)))
--   let buf = toCArray arr
--   call_ pack buf 0 =<< deref (msg ~> req_message_rate)
--   call_ pack buf 2 =<< deref (msg ~> target_system)
--   call_ pack buf 3 =<< deref (msg ~> target_component)
--   call_ pack buf 4 =<< deref (msg ~> req_stream_id)
--   call_ pack buf 5 =<< deref (msg ~> start_stop)
--   sender requestDataStreamMsgId (constRef arr) requestDataStreamCrcExtra

instance MavlinkUnpackableMsg "request_data_stream_msg" where
    unpackMsg = ( requestDataStreamUnpack , requestDataStreamMsgId )

requestDataStreamUnpack :: Def ('[ Ref s1 (Struct "request_data_stream_msg")
                             , ConstRef s2 (CArray (Stored Uint8))
                             ] :-> () )
requestDataStreamUnpack = proc "mavlink_request_data_stream_unpack" $ \ msg buf -> body $ do
  store (msg ~> req_message_rate) =<< call unpack buf 0
  store (msg ~> target_system) =<< call unpack buf 2
  store (msg ~> target_component) =<< call unpack buf 3
  store (msg ~> req_stream_id) =<< call unpack buf 4
  store (msg ~> start_stop) =<< call unpack buf 5

