#lang typed/racket
#| activators.rkt -- typical activation functions and their derivatives (c) Patrick King, 2017
   Licensed under LGPL 3+. Make me feel good, mention my name!
|#
(require "types.rkt" plot)
(require/typed racket/math
               (tanh FF)
               (sgn FF))
(require/typed racket
               (log FF))
(provide linear linearp
         ReLU ReLUp
         sgn sgnp
         sigmoid sigmoidp
         softplus softplusp
         tanh tanhp
         threshold thresholdp)

;; Main stream activation functions, and their derivatives.

(: linear FF)
(define (linear x) x) ; maps -inf ... inf to -inf ... inf
(: linearp FF)
(define (linearp x) 1.)

(: ReLU FF)
(define (ReLU z)(max z 0.)) ; maps -inf..inf to 0..inf
(: ReLUp FF)
(define (ReLUp x) (if (> x 0.) 1. 0.))

(: sigmoid FF) ; maps -inf ... inf to 0 ... 1 
(define (sigmoid x) (/ (+ 1. (exp (- x))))); maps -inf ... inf to 0 ... 1 
(: sigmoidp FF)
(define (sigmoidp x) (/ (+ 2. (exp x) (exp (- x)))))

(: softplus FF) ; maps -inf..inf to 0..inf. Similar to ReLU, but more helpful derivative
(define (softplus x)(log(add1 (exp x)))) ; maps -inf..inf to 0..inf
(define softplusp sigmoid)

; tanh maps -inf ... inf to -1 ... 1. It's provided from racket/math
(: tanhp FF)
(define (tanhp x)(- 1. (sqr (tanh x))))

;; For those fond of the black and white, some functions that return only -1.0, 0.0, 0.5 or 1.0. Their derivatives are discontinuous,
;; zero if defined at all, and so unsuitable for mainstream learning techniques.
(: zero FF)
(define (zero x) 0.)

; sgn maps -inf ... inf to -1, 0, 1. It's provided from racket/math
(define sgnp zero)

; threshold maps -inf ... inf to 0, 1.
(: threshold FF)
(define (threshold x); scales sgn.
  (cond
    [(> x 0.5) 1.]
    [(< x 0.5) 0.]
    [else 0.5]))
(define thresholdp zero)

