#lang video-editor

(require "./common.rkt")

(define v1 (clip (build-path here "producers" "clip1.dv")))
(define v2 (clip (build-path here "producers" "clip2.dv")))

(define with-mark
  (add-filter 
    (watermark v1 10 10 10 10)
    v2))

with-mark
