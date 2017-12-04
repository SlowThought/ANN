#lang scribble/manual
@title{ANN Manual -- An artificial neural network framework}
@author{Patrick King}

ANN is published under the LGPL 3+ license. Mention my name. I'll be happy.

@(require (for-label (except-in racket tanh sgn)
                     "./types.rkt"
                     "./activators.rkt")
          "./activators.rkt" "./ann-plot.rkt")
This library implemenents functions for creating, training, evaluating, and saving simple artificial neural networks.
This document describes the individual definitions and functions. For an example of their use, please see the
@bold{guide -- hyperlink to come}.

@table-of-contents[]

@include-section["ann-guide.scrbl"]
@section[#:tag "types"]{Types}
@defmodule["./types.rkt"]

ANN is implemented in typed Racket. The contracts described help ensure consistency throughout the framework. For performance
and consistency, everything is a 64 bit floating point number (@racket{Float}) or some derivative thereof.

@defthing[FF (-> Float Float)]{
All activation functions map float to float (see @secref{activators}).
}

@defthing[FlMatrix (Matrix Float)]{Matrices from @racket[math/matrix] represent the weights of connections between
network layers.
}
@defthing[FlCM FlMatrix]{
CM stands for column matrix, a matrix of width one. Input and output vectors are represented as @racket[math/matrix] column matrices.
For now, the type is provided mostly as a convention for the programmer. It is enforced here and there via assertions.}

The layers of the network are represented by lists of functions, matrices, and column vectors.
@defthing[LoFF (Listof FF)]
@defthing[LoFlM (Listof FlMatrix)]
@defthing[LoFlC LoFlM]{Like @racket[FlCM], @racket[LoFlC] currently has little enforcement mechanism.}

@section[#:tag "activators"]{Activation Functions}
@defmodule["./activators.rkt"]

The activation function of an ANN "cell" or "neuron" maps the linear combination of inputs to an output, usually in a non-
linear fashion. The non-linear nature of this mapping is what provides the magic of ANNs. The choice of an appropriate
mapping function for a given application, or for a given layer, is still a bit of an art.

Each function has the signature @racket[FF]. The domain is always [-∞,∞]. Each function has an associated derivative function,
denoted by appending "p" to the name. For instance @racket[tanh]'s derivative is @racket[tanhp](read as "tan h prime").

@subsection[#:tag "derivatives"]{Functions with Meaningful Derivatives}

The most popular learning algorithms require activation functions with smooth, continuous derivatives.

@defproc[(linear (z Float)) Float]{Output range [-∞,∞].
 Returns the input, and turns your neural net into an exercise in linear programming. Perhaps appropriate in output layer,
 depending on the problem.}
@defproc[(linearp (z Float)) Float]{Output is 1.0.}

@(plot-2fs linear linearp)

@defproc[(sigmoid (z Float)) Float]{Output range is [0,1]. A "classic" activation function. A popular choice in interior layers.}
@defproc[(sigmoidp (z Float)) Float]{Output range is [0,0.25].}

@(plot-2fs sigmoid sigmoidp)

@margin-note{@racket[tanh] is imported from @racket[racket/math], and its type info changed to @racket[FF]. Users of @racket[racket/math]
             must be aware of collisions, and manage them with the appropriate use of @racket[require].}
@defproc[(tanh (z Float)) Float]{Very similar to @racket[sigmoid], except the output range is [-1, 1].}
@defproc[(tanhp(z Float)) Float]{Output range [0, 1].}

@(plot-2fs tanh tanhp)

@defproc[(ReLU (z Float)) Float]{ReLU stands for Rectifying Linear Unit. Output range is [0,∞]. Its simple (read "fast") implementation proved
                        useful when "big data" came into favor. ReLU is behind the recent big advances in visual applications.}
@defproc[(ReLUp(z Float)) Float]{Output range [0, 1].}

@(plot-2fs ReLU ReLUp)

@defproc[(softplus (z Float)) Float]{Output range is [0,∞]. Very similar to @racket[ReLU], but with a smooth derivative, which can help
                             with various learning issues, but sacrificing performance.}
@defproc[(softplusp(z Float)) Float]{Output range [0, 1].}

@(plot-2fs softplus softplusp)

@subsection[#:tag "bad_derivatives"]{Functions with Discontinuities}

The following functions are discontinuous. Their derivatives are everywhere zero, except at the discontinuity, where the derivative
is undefined. They are only suitable for Hebbian learning, but using them with gradient descent will not cause errors, but merely suppress
learning in the layers they are used, and prior layers.

@margin-note{@racket[sgn] is imported from @racket[racket/math], and its type info changed to @racket[FF]. Users of @racket[racket/math]
             must be aware of collisions, and manage them with the appropriate use of @racket[require].}
@defproc[(sgn (z Float)) Float]{From the @racket[racket/math] library, with type information added. Range is [-1, 1].}
@defproc[(sgnp (z Float)) Float]{Returns 0.}

@(plot-2fs sgn sgnp)

@defproc[(threshold (z Float)) Float]{Very similar to @racket[sgn], but with a range of [0,1].}
@defproc[(thresholdp (z Float)) Float]{Returns 0.}

@(plot-2fs threshold thresholdp)

@section[#:tag "eval"]{Evaluation and Learning}
The following functions accept lists of weights and biases (of type @racket{FlMatrix} and functions (of type @racket{FF}) and
return outputs or new weights and biases.

@defproc[(eval-network (x FlCM)(As LoFlM)(bs LoFlC)(fs LoFF))FlCM]