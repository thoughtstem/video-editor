#lang racket

(module reader syntax/module-reader
  video-editor)

(provide (all-from-out "./lang/main.rkt")
         (all-from-out "./lang/common.rkt") 
         (all-from-out racket))

(require "./lang/common.rkt")
(require "./lang/main.rkt")
