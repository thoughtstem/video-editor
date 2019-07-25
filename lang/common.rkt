#lang racket

(provide 
  pair
  segments
  interleave
  overlay
  melt)

(require "./main.rkt")

(define (id->producer i)
  i)

(define (in-out-arg id s l)
  (list 
    (id->producer id) 
    (in= s)
    (out= (+ s l))))

(define (pair id1 id2 s l)
 (list 
   (in-out-arg id1 s l)
   (in-out-arg id2 s l)))

(define (segments id n l)
  (map
    (lambda (s)
      (in-out-arg id (* s l) l))
    (range n)))


(define (interleave id1 id2 n l)
  (map list
       (segments id1 n l) 
       (segments id2 n l)))

(define (overlay id1 id2)
  (list
    (if (list? id1)
      id1
      (id->producer id1)) 
    "-track"
    (id->producer id2)))




