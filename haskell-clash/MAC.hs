module MAC where

import Clash.Prelude
import Clash.Explicit.Testbench

mac :: (Num a) => a -> (a, a) -> (a, a)
mac acc (x, y) = (acc + x * y, acc)

macS :: (HiddenClockResetEnable dom, Num a, NFDataX a) => Signal dom (a, a) -> Signal dom a
macS = mealy mac 0

topEntity
  :: Clock System
  -> Reset System
  -> Enable System
  -> Signal System (Int, Int)
  -> Signal System Int
topEntity = exposeClockResetEnable macS
