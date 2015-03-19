{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE MultiParamTypeClasses #-}

-- Autogenerated Mavlink v1.0 implementation: see smavgen_ivory.py

module SMACCMPilot.Mavlink.Ivory.Messages.GlobalPositionSetpointInt where

import Ivory.Language
import Ivory.Serialize
import SMACCMPilot.Mavlink.Ivory.Send
import SMACCMPilot.Mavlink.Ivory.Unpack

globalPositionSetpointIntMsgId :: Uint8
globalPositionSetpointIntMsgId = 52

globalPositionSetpointIntCrcExtra :: Uint8
globalPositionSetpointIntCrcExtra = 141

globalPositionSetpointIntModule :: Module
globalPositionSetpointIntModule = package "mavlink_global_position_setpoint_int_msg" $ do
  depend serializeModule
  depend mavlinkSendModule
  incl mkGlobalPositionSetpointIntSender
  incl globalPositionSetpointIntUnpack
  defStruct (Proxy :: Proxy "global_position_setpoint_int_msg")
  wrappedPackMod globalPositionSetpointIntWrapper

[ivory|
struct global_position_setpoint_int_msg
  { latitude :: Stored Sint32
  ; longitude :: Stored Sint32
  ; altitude :: Stored Sint32
  ; yaw :: Stored Sint16
  ; coordinate_frame :: Stored Uint8
  }
|]

mkGlobalPositionSetpointIntSender ::
  Def ('[ ConstRef s0 (Struct "global_position_setpoint_int_msg")
        , Ref s1 (Stored Uint8) -- seqNum
        , Ref s1 (Struct "mavlinkPacket") -- tx buffer/length
        ] :-> ())
mkGlobalPositionSetpointIntSender = makeMavlinkSender "global_position_setpoint_int_msg" globalPositionSetpointIntMsgId globalPositionSetpointIntCrcExtra

instance MavlinkUnpackableMsg "global_position_setpoint_int_msg" where
    unpackMsg = ( globalPositionSetpointIntUnpack , globalPositionSetpointIntMsgId )

globalPositionSetpointIntUnpack :: Def ('[ Ref s1 (Struct "global_position_setpoint_int_msg")
                             , ConstRef s2 (CArray (Stored Uint8))
                             ] :-> () )
globalPositionSetpointIntUnpack = proc "mavlink_global_position_setpoint_int_unpack" $ \ msg buf -> body $ packGet packRep buf 0 msg

globalPositionSetpointIntWrapper :: WrappedPackRep (Struct "global_position_setpoint_int_msg")
globalPositionSetpointIntWrapper = wrapPackRep "mavlink_global_position_setpoint_int" $ packStruct
  [ packLabel latitude
  , packLabel longitude
  , packLabel altitude
  , packLabel yaw
  , packLabel coordinate_frame
  ]

instance Packable (Struct "global_position_setpoint_int_msg") where
  packRep = wrappedPackRep globalPositionSetpointIntWrapper
