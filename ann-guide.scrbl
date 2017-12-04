#lang scribble/manual
@title{Guide -- Examples of simple neural networks}
@author{Patrick King}
@(require (for-label (except-in racket tanh sgn)
                     "./activators.rkt"
                     "./constructors.rkt"
                     "./eval.rkt"
                     "./types.rkt")
          racket/sandbox scribble/eval)
@(define my-eval (make-base-eval))

ANN is a collection of modules from which you can pick and choose with fancy uses of @racket[require] to attempt to minimize ANN's
memory footprint, which might be useful in practical applications. In this example, we will be using "ann-base.rkt", which imports all
of ANN. As input and output vectors and connection weights and biases are represented as matrices as defined in @racket[math/matrix],
we'll need that, too.

NOTE: Need to work github require line, (properly pushing to github, for that matter) and rework this line and similar in
"ann-manual.scrbl".
@(interaction #:eval my-eval
              (require math/matrix "ann-base.rkt"))

@margin-note{"Quotes" denote "jargon" that may be used for an "effective Google search".}
Artificial neural networks are collections of "perceptrons", which model real neurons by applying an "activation function" to a "linear
combination" of inputs to come up with an output. 

[insert perceptron diagram, Latex equation, here]

In ANN, the inputs and outputs are represented by @racket[FlCM], floating point column matrices. The weights and biases applied to the
inputs are also represented by matrices. Because there can be interior layers, weights, biases, and activation functions are always
represented by lists of matrices. The matrices below are meant to map two input bits to two output bits, with no interior layers.

@(interaction #:eval my-eval
              (define As (list (matrix [[-0.4 -0.4]
                                        [ 0.6  0.6]])))
              (define bs (list (col-matrix [1.0 0.])))
              (define fs (list threshold)))

The @racket[threshold] function rounds inputs less than 0.5 to 0., and greater than 0.5 to 1.0. Almost all common activation activation
functions are in some sense "non-linear", which is what gives artificial neural networks their magic. Below, we apply the weights, biases,
and functions to an input vector to produce an output vector.

@(interaction #:eval my-eval
              (eval-network (col-matrix [0. 0.]) As bs fs))

@margin-note{Why NAND? Insert link. Why XOR? Insert link.}
The above example purports to show a network computing the "nand" and "xor" of the inputs. It works for this case. Let's try it against
all possible inputs.

@(interaction #:eval my-eval
              (define all-inputs
                (list (col-matrix [0. 0.])
                      (col-matrix [0. 1.])
                      (col-matrix [1. 0.])
                      (col-matrix [1. 1.])))
              (define correct-outputs
                (list (col-matrix [1. 0.])
                      (col-matrix [1. 1.])
                      (col-matrix [1. 1.])
                      (col-matrix [0. 0.]))))
Fair warning. The @racket[Matrix] output is not pretty; some of the guts of its implementation are exposed.
An ideally tuned network could map these inputs and outputs exactly. The weights above are hand tuned to do the best(?) a human can.
How well is that? Note the @racket[matrix-]. We are subtracting the correct outputs from the actual outputs. Zero is good.
@(interaction #:eval my-eval
              (map (λ (x y)(matrix- (eval-network x As bs fs) y))
                   all-inputs correct-outputs))
The network correctly evaluates the "nand" function, but is having trouble with the "xor" function. If you followed the links above,
you're not surprised. To fix this problem, we're going to create a (relatively) deep network, by introducing an interior layer.
@(interaction #:eval my-eval
              (set! As
                    (list (matrix [[0.4 0.4]
                                   [0.6 0.6]])
                          (matrix [[-1. 0.0]
                                   [-1. 1.0]])))
              (set! bs
                    (list (col-matrix [0. 0.])
                          (col-matrix [1. 0.])))
              (set! fs
                    (list threshold threshold))
              (map (λ (x y) (matrix- (eval-network x As bs fs) y)) all-inputs correct-outputs))

All zeros; the new network is performing as desired. Of course it's a very small network, solving a very simple problem. Suppose that the network
were bigger, that it was not easy to guess suitable values for the weights and biases. Luckily, neural networks can start with random
numbers and learn the answers themselves! Below, we supply ANN with an architecture for our network (@racket[(list 2 2 2)], denoting
three layers of two neurons each), and we are returned suitable random weights and biases.

@(interaction #:eval my-eval
              (set!-values (As bs) (make-random-network (list 2 2 2)))
              (display As)
              (display bs))
