#lang racket

(module reader syntax/module-reader
  video-editor)

(provide (all-from-out "./lang/main.rkt")
         (except-out (all-from-out racket)
                     #%module-begin)
         (rename-out [my-module-begin #%module-begin]))

(require "./lang/main.rkt")

(define-syntax-rule (my-module-begin expr ... last-expr)
  (#%module-begin
   expr ... 
  
   (provide main)

   (define main last-expr)

   (module+ main
     (melt main))))
