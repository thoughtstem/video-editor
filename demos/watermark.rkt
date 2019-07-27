#lang video-editor

(require 2htdp/image)

;Two ways of loading in an image producer
(define red (clip "producers/watermark.png"))
(define green (image-clip (circle 40 'solid 'green)))

(define v2 (clip "producers/clip2.dv"))

(define with-mark
  (add-filter
    (watermark green 20 10 10 10)
    (add-filter 
      (watermark red 10 10 10 10)
      v2)))

with-mark
