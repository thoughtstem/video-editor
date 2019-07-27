#lang racket

(provide grayscale watermark)

(require "./next-id.rkt" 
         "./base.rkt"
         "./properties.rkt")

(define (grayscale #:in (in #f) #:out (out #f))
  (filter
    (next-id "filter")
    in out
    (list
      (mlt-service-property "grayscale"))))

(define (watermark p x y w h #:in (in #f) #:out (out #f))
  (filter
    (next-id "filter")
    in out
    (list
      (property "resource" (~a (producer->path p)))
      (mlt-service-property "watermark")
      (property "composite.start" 
                (~a x "%" "/" y "%" ":" w "%" "/" h "%")))))

