#lang racket

(provide
 gen:functor
 gen:applicative
 gen:monad
 gen:trivial
 let/f begin/m let/m

 (contract-out
  [pure? predicate/c]
  [functor? predicate/c]
  [applicative? predicate/c]
  [monad? predicate/c]
  [trivial? predicate/c]
  [fmap (-> (-> any/c any/c) functor? functor?)]
  [pure (-> any/c pure?)]
  [fapply (-> applicative? applicative? applicative?)]
  [return (-> any/c pure?)]
  [flatmap (-> (-> any/c monad?) monad? monad?)]
  [join (-> monad? monad?)]
  [extract (-> comonad? any/c)]
  [extend (-> (-> comonad? any/c) comonad? comonad?)]
  [duplicate (-> comonad? comonad?)]))

(require "private/pure.rkt"
         "private/trivial.rkt"
         "private/iterator.rkt"
         "private/functor.rkt")
