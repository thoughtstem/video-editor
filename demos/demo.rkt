#!/usr/bin/racket

#lang racket

(require "./common.rkt")


(define args (current-command-line-arguments))
(define file (vector-ref args 0))
(define id1 (first (string-split file ".")))

(define file2 (vector-ref args 1))
(define id2 (first (string-split file2 ".")))

(define file3 (vector-ref args 2))
(define id3 (first (string-split file3 ".")))


(melt
  (overlay 
    (interleave id1 id2 200 10)
    id3))


