#lang video-editor

(require racket/runtime-path)

(define-runtime-path here ".")

(define path1 (build-path here "./videos/example.mp4"))

(define video1 (clip path1))

(melt video1)
