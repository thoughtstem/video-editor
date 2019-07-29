#lang racket

(provide luma-test pip
         (struct-out geometry)
         )

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

(struct geometry (x y w h) #:transparent)

(define (geometry->string geo)
  (~a (geometry-x geo) "%" "/" 
      (geometry-y geo) "%" ":" 
      (geometry-w geo) "%" "x" 
      (geometry-h geo) "%"))

(define (pip (geo (geometry 0 0 100 100))
             #:in (in #f) #:out (out #f))
  (transition
    (next-id "filter")
    in out
    (list
      (property "a_track" 0)
      (property "b_track" 1)
      (property "valign" "middle")
      (property "halign" "middle")
      (property "geometry" 
                (geometry->string geo))
      (mlt-service-property "composite"))))


