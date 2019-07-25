#lang video-editor

(require "./common.rkt")

(define path1 (build-path here "./producers/example.mp4"))
(define path2 (build-path here "./producers/example2.mp4")) ;TODO: Get this

(define video1 (clip path1))
(define video2 (clip path2))

(melt (playlist video1 video2)) ;TODO: Implement playlist
