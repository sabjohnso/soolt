#lang racket

(provide gen:semigroup semigroup? <>)

(require racket/generic)

(define-generics semigroup
  (<>-proc semigroup))

(define (<> x y)
  ((<>-proc x) x y))
