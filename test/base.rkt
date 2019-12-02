#lang racket

(require rackunit 
         racket/runtime-path
         "../lang/base.rkt")

(define-runtime-path here ".")

(define c1 (clip #:in 0 #:out 10
                (build-path here "../demos/producers/clip1.dv")))

(define c2 (clip #:in 0 #:out 10
                (build-path here "../demos/producers/clip3.dv")))

(define c3 (clip #:in 0 #:out 10
                (build-path here "../demos/producers/clip3.dv")))


(define p1 (playlist c1 c2 c3))

(define m1 (multitrack c1 c2 c3))



(check-equal? 
  10
  (producer-length c1))


(check-equal? 
  30
  (producer-length p1)
  "Three length 10 clips in a squence adds up to 30"
  )


(check-equal? 
  10
  (producer-length (clip #:in 0 #:out 10 
                         p1))
  "Clipping down a length 30 clip to the range 0-10 should have length 10")


(check-equal? 
  60
  (producer-length (playlist p1 p1)))


(check-equal? 
  20
  (producer-length 
    (clip
      #:in 0 #:out 20 
      (playlist p1 p1))))



(check-equal? 
  10
  (producer-length m1))

(check-equal? 
  5
  (producer-length
    (clip
      #:in 0 #:out 5
      m1)))



(define not-bigger
  (clip 
    #:in 0 #:out 20
    #:force #t
    c1))

(check-equal?
  (producer-length not-bigger) 
  (producer-length c1))

