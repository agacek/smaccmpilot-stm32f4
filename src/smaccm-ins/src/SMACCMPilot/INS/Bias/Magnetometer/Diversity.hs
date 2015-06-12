{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE DataKinds #-}

module SMACCMPilot.INS.Bias.Magnetometer.Diversity
  ( monitorDiverseMagBiasEstimator
  , ivoryDiverseMagBiasEstimator
  , MagBiasEstimator(..)
  , magDiversityHelpersModule
  ) where

import Ivory.Language
import Ivory.Tower
import Ivory.Stdlib
import SMACCMPilot.INS.Bias.Magnetometer.Estimator


monitorDiverseMagBiasEstimator :: Monitor e MagBiasEstimator
monitorDiverseMagBiasEstimator = do
  n <- freshname "magbias"
  let (f, moduledef) = ivoryDiverseMagBiasEstimator (showUnique n)
  monitorModuleDef moduledef
  return f

-- MBE Buf Depth and distance_threshold (see below) are decided fairly
-- arbitrarily. These numbers *seem to work* for a small number of tests.
type MBEBufDepth = 64

ivoryDiverseMagBiasEstimator :: String -> (MagBiasEstimator, ModuleDef)
ivoryDiverseMagBiasEstimator n = (f, moddef)
  where
  distance_threshold = 40.0

  (mbe, mbe_moddef) = ivoryMagBiasEstimator n
  f = MagBiasEstimator
    { mbe_init = do
        mbe_init mbe
        store mbe_ix 0
        store mbe_vx 0
    , mbe_sample = \s -> do
        distance <- call closest_distance_proc (constRef mbe_buf)
                                               (constRef mbe_vx)
                                               s
        when (distance >? distance_threshold) $ do
          call_ insert_proc s mbe_buf mbe_ix mbe_vx
          -- TODO: only use sample if sufficiently far from existing samples
          mbe_sample mbe s
    , mbe_output = \o -> do
        -- underlying MBE returns 0 or 1
        success <- mbe_output mbe o
        vx <- deref mbe_vx
        return $ success * safeCast vx / arrayLen mbe_buf
    }

  moddef = do
    mbe_moddef
    depend magDiversityHelpersModule
    defMemArea mbe_buf_area
    defMemArea mbe_ix_area
    defMemArea mbe_vx_area


  mbe_buf_area :: MemArea (Array MBEBufDepth (Array 3 (Stored IFloat)))
  mbe_buf_area = area (named "buf") Nothing
  mbe_buf      = addrOf mbe_buf_area

  mbe_ix_area :: MemArea (Stored (Ix MBEBufDepth))
  mbe_ix_area = area (named "ix") Nothing
  mbe_ix      = addrOf mbe_ix_area

  mbe_vx_area :: MemArea (Stored Uint32)
  mbe_vx_area = area (named "vx") Nothing
  mbe_vx      = addrOf mbe_vx_area

  named nn = n ++ "_diversity_" ++ nn


magDiversityHelpersModule :: Module
magDiversityHelpersModule = package "mag_diversity_helpers" $ do
  incl insert_proc
  incl euclidian_distance_proc
  incl closest_distance_proc


insert_proc :: Def('[ ConstRef s1 (Array 3 (Stored IFloat))
                    , Ref s2 (Array MBEBufDepth(Array 3 (Stored IFloat)))
                    , Ref s3 (Stored (Ix MBEBufDepth))
                    , Ref s4 (Stored Uint32)
                    ] :-> ())
insert_proc = proc "mbeh_insert" $ \v vs ix_ref vx_ref -> body $ do
  ix <- deref ix_ref
  refCopy (vs ! ix) v
  vx <- deref vx_ref
  let ix_uint32 :: Uint32
      ix_uint32 = safeCast ix
  ifte_ (ix ==? (arrayLen vs - 1))
        (do store ix_ref 0
            store vx_ref (arrayLen vs))
        (do store ix_ref (ix+1)
            store vx_ref ((vx >? ix_uint32) ? (vx, ix_uint32)))


euclidian_distance_proc :: Def('[ ConstRef s1 (Array 3 (Stored IFloat))
                                , ConstRef s2 (Array 3 (Stored IFloat))
                                ] :-> IFloat)
euclidian_distance_proc = proc "mbeh_euclidian_distance" $ \v1 v2 -> body $ do
  x1 <- deref (v1 ! 0)
  y1 <- deref (v1 ! 1)
  z1 <- deref (v1 ! 2)
  x2 <- deref (v2 ! 0)
  y2 <- deref (v2 ! 1)
  z2 <- deref (v2 ! 2)
  dx <- assign (x1 - x2)
  dy <- assign (y1 - y2)
  dz <- assign (z1 - z2)
  ret (sqrt (dx*dx + dy*dy + dz*dz))

closest_distance_proc :: Def('[ ConstRef s1 (Array MBEBufDepth (Array 3 (Stored IFloat)))
                              , ConstRef s2 (Stored Uint32)
                              , ConstRef s3 (Array 3 (Stored IFloat))
                              ] :-> IFloat)
closest_distance_proc = proc "mbeh_closest_distance" $ \vs vx_ref v -> body $ do
  valid_vs <- deref vx_ref
  d <- local (ival 99999.9)
  arrayMap $ \ix -> do
    when ((safeCast ix) <? valid_vs) $ do
      this_d <- call euclidian_distance_proc (vs ! ix) v
      min_d <- deref d
      when (this_d <? min_d) (store d this_d)

  deref d >>= ret
