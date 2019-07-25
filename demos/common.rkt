#lang racket

(provide video1)

(require racket/runtime-path)

(define-runtime-path here ".")

(define video1 (build-path here "videos" "example.mp4"))
