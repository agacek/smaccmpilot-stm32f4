{-# LANGUAGE DataKinds #-}
module SMACCMPilot.Hardware.LIDARLite where


import Prelude ()
import Prelude.Compat

import Ivory.BSP.STM32.Driver.I2C
import Ivory.Language
import Ivory.Stdlib
import Ivory.Tower
import Ivory.Tower.HAL.Bus.Interface
import SMACCMPilot.Comm.Ivory.Types.LidarliteSample
import SMACCMPilot.Time

data LIDARLite = LIDARLite { lidarlite_i2c_addr :: I2CDeviceAddr }

lidarliteSensorManager ::
     BackpressureTransmit ('Struct "i2c_transaction_request")
                          ('Struct "i2c_transaction_result")
  -> ChanOutput ('Stored ITime)
  -> ChanInput  ('Struct "lidarlite_sample")
  -> I2CDeviceAddr
  -> Tower e ()
lidarliteSensorManager
  (BackpressureTransmit req_chan res_chan)
  init_chan
  sensor_chan
  addr = do
  towerModule lidarliteSampleTypesModule
  towerDepends lidarliteSampleTypesModule
  p <- period (Milliseconds 20) -- 50 hz. Can be faster if required.
  monitor "lidarliteSensorManager" $ do
    s <- state "sample"
    pending <- state "pending"
    coroutineHandler init_chan res_chan "lidarlite" $ do
      req_e <- emitter req_chan 1
      sens_e <- emitter sensor_chan 1
      return $ CoroutineBody $ \yield -> do
        comment "entry to lidarlite coroutine"

        forever $ do
          -- Request originates from period below
          setup_read_result <- yield
          is_pending <- deref pending
          assert is_pending
          rc <- deref (setup_read_result ~> resultcode)
          -- Reset the samplefail field
          store (s ~> samplefail) (rc >? 0)
          -- Send request to perform read (see LIDAR-Lite datasheet
          -- for explanation of magic numbers)
          read_tx_req <- fmap constRef $ local $ istruct
            [ tx_addr .= ival addr
            , tx_buf  .= iarray [
                  -- set register pointer to result register
                  ival 0x8F
                ]
            , tx_len  .= ival 1
            , rx_len  .= ival 0
            ]
          emit req_e read_tx_req
          ack <- yield
          rc2 <- deref (ack ~> resultcode)
          when (rc2 >? 0) (store (s ~> samplefail) true)
          read_rx_req <- fmap constRef $ local $ istruct
            [ tx_addr .= ival addr
            , tx_buf  .= iarray []
            , tx_len  .= ival 0
            , rx_len  .= ival 2
            ]
          emit req_e read_rx_req
          res <- yield
          store pending false
          -- Unpack read, updating samplefail if failed.
          rc3 <- deref (res ~> resultcode)
          when (rc3 >? 0) (store (s ~> samplefail) true)
          distance_raw <- payloadu16 res 0 1
          store (s ~> distance) (safeCast distance_raw / 100)
          fmap timeMicrosFromITime getTime >>= store (s ~> time)
          -- Send the sample upstream.
          emit sens_e (constRef s)

    handler p "periodic_read" $ do
      req_e <- emitter req_chan 1
      callback $ const $ do
        is_pending <- deref pending
        unless is_pending $ do
          -- Initiate a read (see LIDAR-Lite datasheet for explanation
          -- of magic numbers)
          setup_read_req <- fmap constRef $ local $ istruct
            [ tx_addr .= ival addr
            , tx_buf  .= iarray [
                  -- set register pointer
                  ival 0x00
                  -- acquisition and correlation processing with DC correction
                , ival 0x04
                ]
            , tx_len  .= ival 2
            , rx_len  .= ival 0
            ]
          store pending true
          emit req_e setup_read_req
  where
  payloadu16 :: Ref s ('Struct "i2c_transaction_result")
             -> Ix 128 -> Ix 128 -> Ivory eff Uint16
  payloadu16 res ixhi ixlo = do
    hi <- deref ((res ~> rx_buf) ! ixhi)
    lo <- deref ((res ~> rx_buf) ! ixlo)
    assign $ (((safeCast hi `iShiftL` 8) .| safeCast lo) :: Uint16)
