#lang video-editor

(require "./common.rkt")

(define path1 (build-path here "./producers/example.mp4"))
(define path2 (build-path here "./producers/example2.mp4")) ;TODO: Get this

(define video1 (clip path1))
(define video2 (clip path2))

(define playlist1
  (playlist 
    (clip video1 #:in 0 #:out 10)  
    (clip video2 #:in 0 #:out 10)  
    (clip video1 #:in 10 #:out 20)))

playlist1
