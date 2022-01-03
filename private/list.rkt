#lang racket

(provide
 nonempty-list?
 list-flatmap
 nonempty-list-extend)

(define (nonempty-list? x)
  (and (list? x) (not (null? x))))

(define (rappend xs ys)
  (if (null? xs) ys
    (rappend (cdr xs) (cons (car xs) ys))))

(define (list-flatmap f xs)
  (define (recur xs accum)
    (if (null? xs) (reverse accum)
      (recur (cdr xs) (rappend (f (car xs)) accum))))
  (recur xs '()))

(define (nonempty-list-extend f xs)
  (define (recur xs accum)
    (if (null? xs) (reverse accum)
      (recur (cdr xs) (cons (f xs) accum))))
  (recur xs '()))
