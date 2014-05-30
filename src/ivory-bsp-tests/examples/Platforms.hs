{-# LANGUAGE Rank2Types #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE FlexibleContexts #-}

module Platforms where

import Ivory.Language
import Ivory.Tower
import Ivory.Tower.Frontend

import LEDTower
import Ivory.BSP.STM32F405.GPIO
import Ivory.BSP.STM32F405.RCC
import qualified Ivory.BSP.STM32F405.Interrupt as F405
import Ivory.BSP.STM32.Signalable

class ColoredLEDs p where
  redLED  :: Proxy p -> LED
  blueLED :: Proxy p -> LED

f24MHz :: Integer
f24MHz = 24000000
f8MHz :: Integer
f8MHz = 8000000

---------- PX4FMUv17 ----------------------------------------------------------
data PX4FMUv17 = PX4FMUv17

instance ColoredLEDs PX4FMUv17 where
  redLED _  = LED pinB14 ActiveLow
  blueLED _ = LED pinB15 ActiveLow

stm32SignalableInstance ''PX4FMUv17 ''F405.Interrupt

instance BoardHSE PX4FMUv17 where
  hseFreqHz _ = f24MHz

---------- PX4FMUv24 ----------------------------------------------------------
data PX4FMUv24 = PX4FMUv24

instance ColoredLEDs PX4FMUv24 where
  redLED _  = LED pinE12 ActiveLow
  blueLED _ = LED pinC1  ActiveLow -- DOES NOT EXIST. pinC1 is unassigned.

stm32SignalableInstance ''PX4FMUv24 ''F405.Interrupt

instance BoardHSE PX4FMUv24 where
  hseFreqHz _ = f24MHz

---------- F4Discovery --------------------------------------------------------
data F4Discovery = F4Discovery

stm32SignalableInstance ''F4Discovery ''F405.Interrupt

instance ColoredLEDs F4Discovery where
  redLED _  = LED pinD14 ActiveHigh
  blueLED _ = LED pinD15 ActiveHigh

instance BoardHSE F4Discovery where
  hseFreqHz _ = f8MHz

---------- Open407VC ----------------------------------------------------------
data Open407VC = Open407VC

stm32SignalableInstance ''Open407VC ''F405.Interrupt

instance ColoredLEDs Open407VC where
  redLED _  = LED pinD12 ActiveHigh
  blueLED _ = LED pinD13 ActiveHigh

instance BoardHSE Open407VC where
  hseFreqHz _ = f8MHz


--------- Platform lookup by name ---------------------------------------------

-- XXX fix interrupt polymorphism later
coloredLEDPlatforms :: (forall p . (ColoredLEDs p, BoardHSE p, STM32Signal F405.Interrupt p)
                    => Tower p ()) -> [(String, Twr)]
coloredLEDPlatforms app =
    [("px4fmu17_bare",     Twr (app :: Tower PX4FMUv17 ()))
    ,("px4fmu17_ioar",     Twr (app :: Tower PX4FMUv17 ()))
    ,("stm32f4discovery",  Twr (app :: Tower F4Discovery ()))
    ,("open407vc",         Twr (app :: Tower Open407VC ()))
    ,("px4fmu24",          Twr (app :: Tower PX4FMUv24 ()))
    ]

