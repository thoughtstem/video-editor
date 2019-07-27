#lang racket

(module reader syntax/module-reader
  video-editor)

(provide (all-from-out "./lang/main.rkt")
         (except-out (all-from-out racket)
                     #%module-begin)
         (rename-out [my-module-begin #%module-begin]))

(require "./lang/main.rkt"
         syntax/parse/define
         (for-syntax racket/list))


(define-syntax (my-module-begin stx)
  (syntax-parse stx 
    [(_ expr ... last-expr)
     (define src 
       (explode-path (syntax-source stx)))
     (define src-folder
       (take src (sub1 (length src))))
     #`(#%module-begin

        (script-location #,(apply build-path src-folder))

        expr ... 

        (provide main)
        (define main last-expr)

        (module+ main
          (melt main)))]))
