#lang video-editor

(define video1 (clip "./producers/example.mp4"))
(define video2 (clip "./producers/example2.mp4"))

(define playlist1
  (playlist 
    (clip video1 #:in 0 #:out 10)  
    (clip video2 #:in 0 #:out 10)  
    (clip video1 #:in 10 #:out 20)))

playlist1
