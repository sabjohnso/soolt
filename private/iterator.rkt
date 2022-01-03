#lang racket

(require tag "functor.rkt")

(tag unset)

(struct iterator
  (proc length position cache)

  #:property prop:procedure
  (λ (xs offset)
    (iterator-ref xs offset))

  #:methods gen:functor
  [(define (fmap f xs)
     (build-iterator (iterator-length xs)
       (λ (offset)
         (f (xs offset)))))]

  #:methods gen:comonad-apply
  [(define (zapply fs xs)
     (build-iterator (iterator-length xs)
       (λ (offset) ((fs offset) (xs offset)))))]

  #:methods gen:comonad
  [(define (extract-proc comonad)
    (λ (xs) (xs 0)))

   (define (extend-proc comonad)
     (λ (f xs)
       (build-iterator (iterator-length xs)
         (λ (offset) (f (iterator-move xs offset))))))

   (define (duplicate-proc comonad)
     (λ (xs) (build-iterator (iterator-length xs)
             (λ (offset) (iterator-move xs offset)))))])

(define (build-iterator n proc)
  (iterator proc n 0 (make-vector n unset)))

(define (iterator-move xs offset)
  (struct-copy iterator xs
    [position (+ (iterator-position xs) offset)]))

(define (iterator-ref xs offset)
  (match-let ([(iterator proc length position cache) xs])
    (let ([m (modulo (+ position offset) length)])
      (when (unset? (vector-ref cache m))
        (vector-set! cache m (proc m)))
      (vector-ref cache m))))

(define (iterator->list xs)
  (for/list ([i (in-range (iterator-length xs))])
    (xs i)))

(define (iterator->vector xs)
  (for/vector ([i (in-range (iterator-length xs))])
    (xs i)))

(define (iterator->stream xs)
  (for/stream ([i (in-range (iterator-length xs))])
              (xs i)))

(define (vector->iterator xs)
  (iterator (λ (x) (void)) (vector-length xs) 0 xs))

(define (list-iterator xs)
  (vector->iterator (list->vector xs)))


(module+ test
  (require rackunit)

  (check-equal?
   (iterator->list (build-iterator 5 identity))
   '(0 1 2 3 4))

  (check-equal?
   (iterator->list
    (extend (λ (xs) (- (xs 1) (xs 0))) (build-iterator 10 identity)))
   '(1 1 1 1 1 1 1 1 1 -9))

  (check-equal?
   (iterator->list
    (let* ([n 5]
           [dx (/ (* 2 pi) n)])
      (let/w ([indices (build-iterator n identity)])
          ([xs (/ (* 2 pi (indices 0)) n)]
           [ys (cos (xs 0))]
           [zs (/ (- (ys 1) (ys 0)) dx)])
        (vector (indices 0)
                (xs 0)
                (ys 0)
                (zs 0)))))
   '(#(0 0 1 -0.5498668046886102)
     #(1 1.2566370614359172 0.30901699437494745 -0.8897031792714714)
     #(2 2.5132741228718345 -0.8090169943749473 -1.7669748230352872e-16)
     #(3 3.7699111843077517 -0.8090169943749476 0.8897031792714714)
     #(4 5.026548245743669 0.30901699437494723 0.5498668046886104))))
