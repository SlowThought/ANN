#lang typed/racket/base
#| constructors.rkt -- artificial neural nets in Racket. (c) Patrick King, 2017
   Licensed under LGPL 3. Make me feel good, mention my name!
|#
(require math/distributions math/matrix "./types.rkt")
(provide make-random-network)

; The Standard Normal Distribution has values of order 1, which is useful in reasoning about weights and learning rates and things
; like that
(define snd (normal-dist))

(define (gen-random-weight i j)(sample snd)); returns a column matrix - TODO fashion a contract/type to enforce this

(: make-random-vector (-> Positive-Index FlCM))
(define (make-random-vector n)
  (build-matrix n 1 gen-random-weight))

(: make-random-weights (-> Positive-Index Positive-Index FlMatrix))
(define (make-random-weights m n)
  (build-matrix m n gen-random-weight))

(: make-random-network (-> (Listof Positive-Index) (values LoFlM LoFlC)))
(define (make-random-network ns)
  ; The list ns contains the nodes in each layer, with the first value being the input layer, and the last the output layer
  (let loop [(m : Positive-Index (car ns))
             (n : Positive-Index (cadr ns))
             (Ws : (Listof (Matrix Float))(list))
             (Bs : (Listof (Matrix Float))(list))
             (rest (cdr ns))]
    (if (= (length rest) 1)
        (values (reverse (cons (make-random-weights m n) Ws))
                (reverse (cons (make-random-vector n) Bs)))
        (loop (car rest)
              (cadr rest)
              (cons (make-random-weights m n) Ws)
              (cons (make-random-vector n) Bs)
              (cdr rest)))))


