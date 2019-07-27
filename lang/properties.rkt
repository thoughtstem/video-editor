#lang racket

(provide mlt-service-property)

(require "./base.rkt")

(define (mlt-service-property v)
  (property "mlt_service" v))
