#lang typed/racket/base
(require "./types.rkt" plot typed/racket/snip)
(provide plot-2fs)

(: wrap-FF (-> FF (-> Real Real)))
(define (wrap-FF f)
  (λ [(x : Real)]
    (f (cast (* 1. x) Float))))

(: plot-2fs (-> FF FF (U Void (Instance Snip%))))
(define (plot-2fs f fp)
  (plot (list (function (wrap-FF f) #:label "Function" #:color 'blue)
              (function (wrap-FF fp) #:label "Derivative"))
        #:x-min -4. #:x-max 4.
        #:y-min -2. #:y-max 2.))
  


