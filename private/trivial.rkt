#lang racket

(provide gen:trivial trivial?
         destructor-proc constructor-proc
         destructor constructor
         trivial-map)
(require racket/generic "pure.rkt")

(define-generics trivial
  (constructor-proc trivial)
  (destructor-proc trivial)
  #:fast-defaults
  ([pure?
    (define (constructor-proc trivial) pure)
    (define (destructor-proc trivial) pure-value)]))

(define (destructor mx)
  ((destructor-proc mx) mx))

(define constructor pure)

(define (trivial-map f mx)
  (let ([constructor (constructor-proc mx)])
    (constructor (f (destructor mx)))))
