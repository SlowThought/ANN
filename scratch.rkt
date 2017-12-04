#lang racket
(require math/matrix "./ann-base.rkt")

; A1 and b1 should produce "and" and "or" outputs
(define A1
  (matrix [[0.4 0.4]
           [0.6 0.6]]))

(define b1 (col-matrix [0. 0.]))

; A2 and b2 combine the "and" and "or" to get "nand" and "xor"
(define A2
  (matrix [[-1. 0.]
           [-1. 1.]]))

(define b2 (col-matrix [1. 0.]))

(define (try a b)
  (eval-network (col-matrix [a b]) (list A1 A2) (list b1 b2) (list threshold threshold)))