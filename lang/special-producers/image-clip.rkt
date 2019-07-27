#lang racket

(provide image-clip)

(require 2htdp/image 
         "../base.rkt")

(define (image-clip image #:in (in #f) #:out (out #f))
  (define path (make-temporary-file "image-clip~a.png"))

  (save-image image path)

  (clip path #:in in #:out out))
