#lang racket

(require rackunit
         racket/runtime-path
         xml
         "../lang/main.rkt")

(define-runtime-path here ".")

(define path1
  (build-path here "../demos/videos/example.mp4"))   

(define video1 (clip path1))

(check-equal?
  (melt-xml video1)  
  `(mlt
     (producer ([id "producer0"])
        (property ([name "resource"])
                  ,(~a path1)))))
