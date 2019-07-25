#lang racket

(module reader syntax/module-reader
  video-editor)

(provide (all-from-out "./lang/main.rkt")
         (all-from-out racket))

(require "./lang/main.rkt")
