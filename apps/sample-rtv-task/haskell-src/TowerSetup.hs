{-# OPTIONS_GHC -fno-warn-orphans #-}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE QuasiQuotes #-}

module TowerSetup where

import Ivory.Tower
import Checker hiding (main)

import Ivory.Language
import qualified Ivory.Tower.Compile.FreeRTOS as F
import qualified Ivory.Compile.C.CmdlineFrontend as C

--------------------------------------------------------------------------------

-- XXX

-- Put all includes, etc. in Tower () and out of tasks
-- Make use of queues easier by external tasks
-- unused vars in, e.g., taskbody_verify_updates_2 in tower.c


--------------------------------------------------------------------------------

-- Struct sent by plugin function
[ivory|

struct assignment
  { var_id :: Stored (Ix 100)
  ; value  :: Stored Uint32
  }

|]

--------------------------------------------------------------------------------
-- Record Assigment
--------------------------------------------------------------------------------
type AssignStruct = Struct "assignment"
type AssignRef s = ConstRef s AssignStruct

assignStructDef = defStruct (Proxy :: Proxy "assignment")

legacyHdr :: String
legacyHdr = "legacy.h"

-- record_assign_emitter ::
--   ChannelEmitter (Struct "assignment") -> Def ('[AssignRef s] :-> ())
-- record_assign_emitter ch = proc "record_assign_emitter" $ \r -> body $ emit ch r

-- recordAssignment ::
--   ChannelSource (Struct "assignment") -> Task () --Def ('[AssignRef s] :-> ())
-- recordAssignment ch = withContext $ do
--   newVal <- withChannelEmitter ch "newVal"
--   taskLoop $ do
--     v <- local (istruct [])

--     emit newVal v

recordEmit :: Schedule
           -> ChannelEmitter AssignStruct
           -> Def ('[AssignRef s] :-> ())
recordEmit sch ch = proc "recordEmit" $ \r -> body $ emit sch ch r

-- proc "record_assign_emitter" $ \r -> body $ emit ch r

--------------------------------------------------------------------------------

-- What to do if a property fails (in this case, led_set(1, 1))?
action :: Def ('[] :-> ())
action = importProc "led_set" "FreeRTOS.h"

append_to_history :: Def ('[Ix 100, Uint32] :-> ())
append_to_history = importProc "append_to_history" "instrumented.h"

-- XXX Seems cool to redefine imported types...
append_to_history' :: Def ('[Ix 100, Uint16] :-> ())
append_to_history' = importProc "append_to_history" "instrumented.h"

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

mkHistory :: Def ('[AssignRef s] :-> ())
mkHistory = proc "mkHistory" $ \s -> body $ do
  var <- deref (s ~> var_id)
  val <- deref (s ~> value)
  call_ append_to_history var val

--------------------------------------------------------------------------------

-- "check_properties" is automatically generated by the RTV system and always
-- has the same type.  We just have to call it and see if it's true.
check_properties :: Def ('[] :-> IBool)
check_properties = importProc "check_properties" "runtime-checker.h"

runCheck :: Def ('[] :-> ()) -> Ivory s ()
runCheck action = do
  bool <- call check_properties
  ifte bool (return ()) (call_ action)

--------------------------------------------------------------------------------

-- Checker task
checkerTask :: ChannelSink AssignStruct -> Task ()
checkerTask sink = do
  -- "src" string only is for graphviz output for now
  rx <- withChannelReceiver sink "rvSink"
  taskModuleDef $ \_sch -> assignStructDef
  taskModuleDef $ \_sch -> incl mkHistory
  taskModuleDef $ \_sch -> incl action
  taskBody $ \sch -> do
    lastVal <- local (istruct [])
    call_ mkHistory (constRef lastVal)
    eventLoop sch $ onChannel rx $ \_ -> runCheck action

--------------------------------------------------------------------------------
-- Legacy tasks
--------------------------------------------------------------------------------

-- Read clock

-- portTICK_RATE_MS :: Sint32
-- portTICK_RATE_MS = extern "portTICK_RATE_MS"

type Clk = Stored Sint32
type ClkEmitterType s = '[ConstRef s Clk] :-> ()

clkEmitter :: Schedule -> ChannelEmitter Clk -> Def (ClkEmitterType s)
clkEmitter sch ch = proc "clkEmitter" $ \r -> body $ emit sch ch r

-- read_clock_init :: Def ('[] :-> ())
-- read_clock_init = importProc "read_clock_init" "legacy.h"

read_clock_block :: Def ('[ProcPtr (ClkEmitterType s)] :-> ())
read_clock_block = importProc "read_clock_block" legacyHdr

-- XXX I'd really like to be able to name channels so they're not given
-- mangled names
readClockTask :: ChannelSource Clk -> Task ()
readClockTask src = do
  clk <- withChannelEmitter src "clkSrc"
  taskModuleDef $ \sch -> (incl $ clkEmitter sch clk)
  p <- withPeriod 1 -- once per ms
  taskBody $ \sch -> do
    eventLoop sch $ onTimer p $ \_now ->
      call_ read_clock_block $ procPtr $ clkEmitter sch clk

--------------------------------------------------------------------------------
-- Legacy tasks
--------------------------------------------------------------------------------

-- Read clock

update_time_init :: Def ('[ProcPtr ('[AssignRef s] :-> ())] :-> ())
update_time_init = importProc "update_time_init" legacyHdr

update_time_block :: Def ('[Sint32] :-> ())
update_time_block = importProc "update_time_block" legacyHdr

updateTimeTask :: ChannelSink Clk -> ChannelSource AssignStruct -> Task ()
updateTimeTask clk chk = do
  rx <- withChannelReceiver clk "timeRx"
  newVal <- withChannelEmitter chk "newVal"
  taskModuleDef $ \sch  -> incl $ recordEmit sch newVal
  taskModuleDef $ \_sch -> incl update_time_init
  taskBody $ \sch -> do
    call_ update_time_init $ procPtr $ recordEmit sch newVal
    eventLoop sch $ onChannel rx $ \time -> do
      t <- deref time
      call_ update_time_block t

--------------------------------------------------------------------------------

-- otherIncls :: Module
-- otherIncls = package "queueStruct" $ do
  -- Package up queue type
  -- assignStructDef
  --  inclHeader legacyHdr
  -- inclHeader "freertos_queue_wrapper.h"
  -- inclHeader "freertos_semaphore_wrapper.h"
  -- inclHeader "freertos_task_wrapper.h"

tasks :: Tower ()
tasks = do
--  addModule otherIncls

  (chkSrc, chkSink) <- channel
  (clkSrc, clkSink) <- channel

  task "verify_updates" $ checkerTask chkSink
  task "readClockTask"  $ readClockTask clkSrc
  task "updateTimeTask" $ updateTimeTask clkSink chkSrc

--------------------------------------------------------------------------------

main :: IO ()
main = do
  let (_, objs) = F.compile tasks
  C.runCompiler objs C.initialOpts { C.srcDir = "tower-srcs"
                                   , C.includeDir = "tower-hdrs"
                                   }
  -- graphvizToFile "out.dot" asm
