#lang racket

(provide
 gen:functor
 gen:applicative
 gen:monad
 gen:trivial
 gen:iterator
 let/f begin/m let/m

 (contract-out
  [pure? predicate/c]
  [functor? predicate/c]
  [applicative? predicate/c]
  [monad? predicate/c]
  [trivial? predicate/c]
  [iterator? predicate/c]
  [fmap (-> (-> any/c any/c) functor? functor?)]
  [pure (-> any/c pure?)]
  [fapply (-> applicative? applicative? applicative?)]
  [return (-> any/c pure?)]
  [flatmap (-> (-> any/c monad?) monad? monad?)]
  [join (-> monad? monad?)]
  [extract (-> comonad? any/c)]
  [extend (-> (-> comonad? any/c) comonad? comonad?)]
  [duplicate (-> comonad? comonad?)]
  [iterator-position (-> iterator? exact-integer?)]
  [iterator-length (-> iterator? exact-nonnegative-integer?)]
  [iterator-ref (-> iterator? exact-integer? any/c)]
  [iterator-move (-> iterator? exact-integer? iterator?)]
  [iterator-move-to (-> iterator? exact-integer? iterator?)]
  [list->iterator (-> list? iterator?)]
  [vector->iterator (-> vector? iterator?)]))

(require "private/pure.rkt"
         "private/trivial.rkt"
         "private/iterator.rkt"
         "private/functor.rkt")
