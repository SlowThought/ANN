#lang typed/racket/base
#| eval.rkt -- artificial neural nets in Racket. (c) Patrick King, 2017
   Licensed under LGPL 3. Make me feel good, mention my name!
|#
(require "./types.rkt" math/matrix)
(provide eval-network teach-network-grad-descent)

; Feed forward - for production after network is trained
(: eval-network (-> FlCM LoFlM LoFlC LoFF FlCM))
(define (eval-network x As bs fs)
  (assert x col-matrix?)
  (let loop [(x x)(As As)(bs bs)(fs fs)]
    (if (null? As)
        x
        (let* [(A (car As))(b (car bs))(f (car fs))
                           (z (matrix+ (matrix* A x) b))
                           (y (matrix-map f z))]
          (loop y (cdr As)(cdr bs)(cdr fs))))))

; Back-propogates error between expected and actual output values to adjust weights and biases throughout network
(: teach-network-grad-descent (-> LoFlC LoFlM LoFlC LoFF LoFF LoFlC Float (values LoFlM LoFlC LoFlC)))
; return values, new weights, biases, and a list of dR/dYs
(define (teach-network-grad-descent xs As bs fs fps  es h)
  ; xs a list of inputs
  ; es a list of expected outputs
  ; As bs lists of weights, biases
  ; fs, fps activation functions and their derivatives
  (let*[(A (car As))
        (b (car bs))
        (f (car fs))
        (fp (car fps))
        (zs (map (λ (x)
                   (matrix+ (matrix* (cast A FlMatrix)
                                     (cast x FlMatrix))
                            b))
                 xs))
        (ys (map (λ (z)
                   (matrix-map f (cast z FlMatrix)))
                 zs))
        (dy/dzs (map (λ (z)
                       (matrix-map fp (cast z FlMatrix)))
                     zs))]
    ; The error, or remainder, R is defined in indicial notation as R = 1/2 * (e_i - y_i)^2, when in the final
    ; layer. In prior layers, we deal with R's derivative, determined by L'Hopital's chain rule.       
    (let-values ([(new-As new-bs -dR/dys)
                  (if (= (length As) 1) ; then this is the last layer
                      (values (list)(list)(map (λ (e y)
                                                 (matrix-map -
                                                             (cast e FlMatrix)
                                                             (cast y FlMatrix)))
                                               (cast es LoFlC)
                                               (cast ys LoFlC)))
                      ; this is NOT the last layer. dR/dy of THIS layer equals dR/dx of the NEXT layer, because
                      ; THIS layer's y is NEXT layer's x
                      (teach-network-grad-descent ys (cdr As)(cdr bs)(cdr fs)(cdr fps) es h))])
      ; Figure deltas
      (let*[(-dR/dzs (map (λ (dy/dz -dR/dy)
                            (matrix-map *
                                        (cast dy/dz FlCM)
                                        (cast -dR/dy FlCM)))
                          dy/dzs -dR/dys))
            ; delta A = h * -dR/dA = h * dz/dA * -dR/dz = h * x * -dR/dz = h * (x * -dR/dz)
            (dA (matrix-scale (foldl matrix+
                                     (make-empty-copy A)
                                     (map matrix* xs -dR/dzs))
                              h))
            ; delta b = h * -dR/db = h * dz/db * -dR/dz = h * 1 * -dR/dz
            (db (matrix-scale (foldl matrix+
                                     (make-empty-copy b)
                                     -dR/dzs)
                              h))
            ; -dR/dx = dz/dx * -dR/dz = A * -dR/dz (more or less... transpose A to match shape of matrices correctly)
            (-dR/dxs (let [(At (matrix-transpose A))]
                       (map (λ (-dR/dz)
                              (matrix* (cast At FlMatrix)
                                       (cast -dR/dz FlMatrix)))
                            -dR/dzs)))]
        ; Return new As, bs, -dR/dxs (which will be prior layer's -dR/dys)
        (values (cons (matrix+ A dA) new-As)(cons (matrix+ b db) new-bs) -dR/dxs)))))


;; Helper functions
(: make-empty-copy (-> (Matrix Float) (Matrix Float)))
(define (make-empty-copy M)
  (let-values ([([m : Integer][n : Integer])(matrix-shape M)])
    (make-matrix m n 0.)))