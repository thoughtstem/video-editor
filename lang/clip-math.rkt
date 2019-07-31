#lang racket

(provide clamp-in-outs)


(define (clamp-in-outs in-outs in out)
  (clip-after
    (clip-before in-outs in)
    (- out in))) 

(define (clip-before in-outs in)
  (if (empty? in-outs) '()
    (let*
      ((curr (first in-outs))
       (curr-in  (first curr))
       (curr-out (second curr))

       (curr-length (- curr-out curr-in)))


      (if (in . > . curr-length)
        (cons '[0 0]
              (clip-before (rest in-outs)
                           (- in curr-length)))
        (cons `[,(+ curr-in in) 
                ,curr-out]
              (rest in-outs))))))



(define (clip-after in-outs out)
  (if (empty? in-outs) '()
    (let*
      ((curr (first in-outs))
       (curr-in  (first curr))
       (curr-out (second curr))
       (curr-length (- curr-out curr-in)))

      (if (out . > . curr-length)
        (cons curr
              (clip-after (rest in-outs)
                          (- out curr-length)))
        (cons `[,curr-in ,(- curr-out 
                             (- curr-out out))]
              (map 
                (thunk* '[0 0])
                (rest in-outs)))))))

(module+ test
  (require rackunit)

  ;Hmm.  Actually, neither of these are    
  ;  correct.  Should snip "from both ends".  

  ;TODO: Move from another file and get it right there


  (check-equal?
    (clamp-in-outs '([0 50]) 0 25)
    '([0 25]))

  (check-equal?
    (clamp-in-outs '([0 50] [0 50] [0 50]) 0 25)
    '([0 25] [0 0] [0 0]))

  (check-equal?
    (clamp-in-outs '([0 50] [0 50] [0 50])
                   55 65)
    '([0 0] [5 10] [0 0]))

  (check-equal?
    (clamp-in-outs '([0 50] [0 50] [0 50]) 
                   105 115)
    '([0 0] [0 0] [5 10]))

  (check-equal?
    (clamp-in-outs '([0 50] [0 50] [0 50])  
                   75 125)
    '([0 0] [25 50] [0 25]))

  (check-equal?
    (clamp-in-outs '([0 50] [0 50] [0 50])  
                   5 145)
    '([5 50] [0 50] [0 45]))

  )

