#lang video-editor

(require "./common.rkt")

(define path1 (build-path here "./producers/example.mp4"))
(define video1 (clip path1))

video1
