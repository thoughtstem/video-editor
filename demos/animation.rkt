#lang video-editor

(require 2htdp/image)

(define (circle-clip color)
  (image-clip (circle 40 'solid color)
              #:in 0 #:out 10))

(define red    (circle-clip 'red))
(define orange (circle-clip 'orange))
(define yellow (circle-clip 'yellow))

(define colors (playlist red orange yellow))

;TODO: Put in pip.

colors
