#lang racket

(module+ test
  (require rackunit "../main.rkt")

  (check-equal? (let/f (x '(1 2 3))
                  (sqr x))
                '(1 4 9))

  (check-equal? (let/m ([x '(1 2)]
                        [y '(3 4)])
                  (return (+ x y)))
                '(4 5 5 6))

  (struct wrapped
    (value)
    #:methods gen:trivial
    [(define (constructor-proc trivial) wrapped)
     (define (destructor-proc trivial) wrapped-value)]
    #:transparent)

  (check-equal?
   (let/m ([x (wrapped 3)]
           [y (wrapped 4)])
     (return (+ x y)))
   (wrapped 7)))
