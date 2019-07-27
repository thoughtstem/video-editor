#lang racket 

(provide (all-from-out "./base.rkt")
         (all-from-out "./filters.rkt") 
         (all-from-out "./transitions.rkt") 
         (all-from-out "./melt.rkt")
         (all-from-out "./special-producers/image-clip.rkt"))

(require "./base.rkt" 
         "./filters.rkt"
         "./transitions.rkt"
         "./melt.rkt"
         "./special-producers/image-clip.rkt")

(provide loop)

(define (loop n p)
  (apply playlist 
         (map (thunk* p) 
              (range n))))
