#lang racket

(provide luma-test)

(require "./next-id.rkt" 
         "./base.rkt"
         "./properties.rkt")

;Just trying to get something working here.  
(define (luma-test #:in (in #f) #:out (out #f))
  (transition
    (next-id "filter")
    in out
    (list
      (property "a_track" 0)
      (property "b_track" 1)
      (mlt-service-property "luma"))))


