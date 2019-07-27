#lang video-editor

(define v1 (clip "producers/clip1.dv"))
(define v2 (clip "producers/clip2.dv"))

(define with-mark
  (add-filter 
    (watermark v1 10 10 10 10)
    v2))

with-mark
