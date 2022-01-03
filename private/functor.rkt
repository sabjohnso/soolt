#lang racket

(provide
 gen:functor functor?
 fmap
 let/f

 gen:applicative applicative?
 fapply

 gen:monad monad?
 return flatmap join
 begin/m let/m

 gen:comonad comonad?
 extract extend duplicate

 gen:comonad-apply comonad-apply?
 zapply extend* lambda/w let/w)

(require
 (for-syntax racket racket/syntax syntax/parse)
 racket/generic
 "pure.rkt" "list.rkt" "trivial.rkt")

(define (fold-left f init xs)
  (if (null? xs) init
    (fold-left f (f init (car xs)) (cdr xs))))

;;
;; ... Comonad
;;
(define-generics comonad
  (extract-proc comonad)
  (extend-proc comonad)
  (duplicate-proc comonad)

  #:fast-defaults
  ([trivial?
    (define extract-proc destructor-proc)
    (define duplicate-proc constructor-proc)]

   [nonempty-list?
    (define (extract-proc comonad) car)
    (define (extend-proc comonad) nonempty-list-extend)])

  #:fallbacks
  [(define (extend-proc comonad)
     (λ (f wx) (fmap f (duplicate wx))))

   (define (duplicate-proc comonad)
     (λ (wx) (extend identity wx)))])

(define (extract wx)
  ((extract-proc wx) wx))

(define (extend f wx)
  ((extend-proc wx) f wx))

(define (duplicate wx)
  ((duplicate-proc wx) wx))

(define-generics comonad-apply
  (zapply comonad-apply comonad-argument))

(define (extend* f wx . wys)
  (fold-left zapply (extend f wx) (map duplicate wys)))


(define-syntax lambda/w
  (syntax-parser
   [(_ (wx:id ...+) ([wa:id a:expr] ...) e:expr)
    (define (make-comonad-bindings forms ids accum)
      (if (null? forms) (reverse accum)
        (syntax-parse (car forms)
          [(wc:id e:expr)
           (make-comonad-bindings
            (cdr forms)
            (append ids (list #'wc))
            (cons (with-syntax ([(current-vars ...) ids])
                    #'(wc (extend* (curry (lambda (current-vars ...) e)) current-vars ...)))
                  accum))])))
    (with-syntax ([(comonad-bindings ...) (make-comonad-bindings (syntax-e #'([wa a] ...)) (syntax-e #'(wx ...)) '())])
      #'(lambda (wx ...)
          (let* (comonad-bindings ...) e)))]))


(define-syntax let/w
  (syntax-parser
   [(_ ([wx:id we:expr] ...)
       ([wa:id ex:expr] ...)
       e:expr)
    #'(extend* (lambda/w (wx ...) ([wa ex] ...) e) we ...)]))


;;
;; ... Monad
;;

(define-generics monad
  (return-proc monad)
  (flatmap-proc monad)
  (join-proc monad)

  #:fast-defaults
  ([trivial?
    (define return-proc constructor-proc)
    (define join-proc destructor-proc)]

   [list?
    (define (return-proc monad) list)
    (define (flatmap-proc monad) list-flatmap)])

  #:fallbacks
  [(define (join-proc monad)
     (λ (mmx) (flatmap identity mmx)))

   (define (flatmap-proc monad)
     (λ (f mx) (join (fmap f mx))))])

(define return pure)

(define (flatmap f mx)
  (let* ([flatmap (flatmap-proc mx)]
         [f (λ (x)
              (match (f x)
                [(pure value) ((pure-proc mx) value)]
                [mres mres]))])
    (flatmap f mx)))

(define (join mmx)
  (let ([join (join-proc mmx)])
    (match (join mmx)
      [(pure value)
       (let ([return (return-proc mmx)])
         (return value))]
      [mx mx])))

(define-syntax begin/m
  (syntax-parser
   [(_ e:expr) #'e]
   [(_ e:expr es:expr ...+)
    (with-syntax ([ignored (generate-temporary 'ignored)])
      #'(flatmap (λ (ignored) (begin/m es ...)) e))]))

(define-syntax let/m
  (syntax-parser
   [(_ ([x:id mx:expr]) es:expr ...+)
    #'(flatmap (λ (x) (begin/m es ...)) mx)]
   [(_ ([x:id mx:expr] more-bindings:expr ...+) es:expr ...+)
    #'(let/m ([x mx])
        (let/m (more-bindings ...)
            es ...))]))

;;
;; ... Applicative
;;
(define-generics applicative
  (pure-proc applicative)
  (fapply-proc applicative)
  #:defaults
  ([monad?
    (define pure-proc return-proc)
    (define (fapply-proc applicative)
      (let ([return (return-proc applicative)])
        (λ (mf mx)
          (let/m ([f mf]
                [x mx])
            (return (f x))))))]))

(define (fapply-aux mf mx)
  ((fapply-proc mf) mf mx))

(define (fapply mf mx)
  (cond [(not (or (pure? mf) (pure? mx))) (fapply-aux mf mx)]
        [(and (pure? mf) (pure? mx)) (fapply-aux mf mx)]
        [(pure? mf) (fapply-aux ((pure-proc mx) (pure-value mf)) mx)]
        [(pure? mx) (fapply-aux mf ((pure-proc mf) mx))]))

;;
;; ... Functor
;;
(define-generics functor
  (fmap-proc functor)
  #:defaults
  ([trivial?
    (define (fmap-proc functor) trivial-map)]

   [applicative?
    (define (fmap-proc functor)
      (λ (f mx)
        (fapply ((pure-proc mx) f) mx)))]

   [comonad?
    (define (fmap-proc functor)
      (λ (f wx) (extend (λ (wx) (f (extract wx))) wx)))]))

(define (fmap f mx)
  (let ([fmap (fmap-proc mx)])
    (fmap f mx)))

(define-syntax let/f
  (syntax-parser
   [(_ (x:id mx:expr) e:expr)
    #'(fmap (λ (x) e) mx)]))
