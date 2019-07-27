#lang racket

(provide next-id)

(define CURRENT-ID -1)

(define (next-id prefix)
  (set! CURRENT-ID (add1 CURRENT-ID))

  (~a prefix CURRENT-ID))
