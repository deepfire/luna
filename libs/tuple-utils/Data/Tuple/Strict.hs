module Data.Tuple.Strict (module Data.Tuple.Strict, module X) where

import Data.Tuple.Utils.Class as X

import Prologue hiding (FromList, ToList)
import Data.Tuple.Utils.TH

import qualified Type.Data.List as List



-- >> data T2 a b = T2 !a !b deriving (Show)
genStrictTupDecls

-- >> FromList '[t1, t2] = T2 t1 t2
-- >> ToList   T2 t1 t2  = '[t1, t2]
genFromList
genToList

-- >> type instance GetElemAt 0 (T2 t1 t2) = t1
-- >> type instance SetElemAt 0 v (T2 t1 t2) = T2 v t2
genGetElemAt
genSetElemAt

-- >> instance IxElemGetter 0 (T3 t1 t2 t3) where
-- >>     getElemAt (T3 !t1 !t2 !t3) = t1 ; {-# INLINE getElemAt #-}
-- >> instance IxElemSetter 0 (T3 t1 t2 t3) where
-- >>     setElemAt v (T3 !t1 !t2 !t3) = T3 v t2 t3 ; {-# INLINE setElemAt #-}
genIxElemGetters
genIxElemSetters


type ElemIndex  el t = (List.ElemIndex' el (ToList t))
type ElemSetter el t = IxElemSetter (ElemIndex el t) t
type ElemGetter el t =
    ( GetElemAt    (ElemIndex el t) t ~ el
    , IxElemGetter (ElemIndex el t) t
    )
type ElemSetterKeepType el t =
    ( ElemSetter el t
    , SetElemAt (ElemIndex el t) el t ~ t
    )

getElem :: ∀ el t. ElemGetter el t => t -> el
getElem = getElemAt @(ElemIndex el t) ; {-# INLINE getElem #-}

setElem :: ∀ el v t. ElemSetter el t => v -> t -> SetElemAt (ElemIndex el t) v t
setElem = setElemAt @(ElemIndex el t) ; {-# INLINE setElem #-}

-- | Like 'setElem', but does not modify the result type
setElemKeepType :: ∀ el t. ElemSetterKeepType el t => el -> t -> t
setElemKeepType = setElem @el ; {-# INLINE setElemKeepType #-}
