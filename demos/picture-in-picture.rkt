#lang video-editor

(define v1 (clip "producers/clip1.dv"))
(define v2 (clip "producers/clip2.dv"))

(define m (multitrack v1 v2))

(define with-mark
  (add-transition
    (pip 0 0 10 10)   
    m))

with-mark
