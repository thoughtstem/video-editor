#lang video-editor

(require "./common.rkt")

#;
(melt
  video1
  (-filter greyscale))

(define a (list video1 (-filter greyscale)))
(define b video1)

(melt
  (interleave a b 10 5))
