#lang video-editor

(require "./common.rkt")

(define v1 (clip (build-path here "producers" "clip1.dv")))
(define v2 (clip (build-path here "producers" "clip2.dv")))

;Playlist 1 has a hole in the middle
(define p1 (playlist v1 (blank 100) v1))

;Playlist 2 is a video on repeat
(define p2 (playlist v2 v2 v2 v2))

;Overlaying them allows p2 to peek through the blank part of p1
(define m1 (multitrack 
             p2 
             (add-filter (grayscale) p1)))

m1
