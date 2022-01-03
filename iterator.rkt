#lang racket

(provide
 (contract-out
  [iterator? predicate/c]
  [build-iterator (-> natural-number/c (-> natural-number/c any/c) iterator?)]
  [iterator-ref (-> iterator? natural-number/c any/c)]
  [iterator-move (-> iterator? natural-number/c iterator?)]
  [iterator->list (-> iterator? list?)]
  [iterator->stream (-> iterator? stream?)]
  [iterator->vector (-> iterator? vector?)]
  [list->iterator (-> list? iterator?)]
  [vector->iterator (-> vector? iterator?)]
  [stream->iterator (-> stream? iterator?)]))

(require "private/iterator.rkt")
