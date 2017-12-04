#lang typed/racket/base

#| types.rkt -- artificial neural nets in Racket. (c) Patrick King, 2017
   Licensed under LGPL 3. Make me feel good, mention my name!

   The ANN library uses 64 bit floats, for accuracy, typed racket, for speed, and matrices, for convenience. 

   This file provides some types to shorten, and hopefully make more comprehensible, contracts using these structures.
|#
(require math/matrix)
(provide FlMatrix FlCM FF LoFF LoFlM LoFlC)

(define-type FlMatrix (Matrix Float))

(define-type FlCM FlMatrix) ; Inputs, outputs, and biases are represented as column matrices. The type here is
; presented for the programmer's convenience, and its intent enforced with assertions elsewhere.

(define-type FF (-> Float Float)) ; For activation functions

(define-type LoFF (Listof FF))
(define-type LoFlM (Listof FlMatrix))
(define-type LoFlC (Listof FlCM))







