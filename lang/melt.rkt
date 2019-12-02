#lang racket 

(provide melt melt-xml melt-debug)

(require xml 
         "./base.rkt" 
         "./filters.rkt"
         "./transitions.rkt" 
         "./properties.rkt")

(define (property->xml p)
  `(property ([name ,(property-name p)])
     ,(~a (property-value p))))

(define (playlist->xml p)
  `(playlist ([id ,(~a (producer-base-id p))])
     ,@(map producer->xml 
            (filter-not 
              producer-empty?
              (playlist-producers p)))))

(define (maybe-attr val fun str)
  (if (fun str)
    `([,val ,(~a (fun str))]) 
    '()))

(define (filter->xml f)
  `(filter ([id ,(~a (producer-base-id f))]
            ,@(maybe-attr 'in producer-base-in f)
            ,@(maybe-attr 'out producer-base-out f))

     ,@(map property->xml (producer-base-properties f))))

(define (transition->xml t)
  `(transition ([id ,(~a (producer-base-id t))]
                 ,@(maybe-attr 'in producer-base-in t)
                 ,@(maybe-attr 'out producer-base-out t))
     ,@(map property->xml (producer-base-properties t))))

(define (multitrack->xml p)
  `(tractor
     (multitrack ([id ,(~a (producer-base-id p))])
       ,@(map producer->xml 
              (filter-not 
                producer-empty?
                (multitrack-producers p))))
     
       ,@(map transition->xml
	      (multitrack-transitions p) )
     
       ,@(map filter->xml
	      (multitrack-filters p) )))

(define (producer->xml p)
  (cond 
    [(playlist? p) (playlist->xml p)]
    [(multitrack? p) (multitrack->xml p)]
    [(blank? p) `(blank ([length ,(~a (blank-length p))]))]
    [(producer-base? p) 
     `(producer ([id ,(~a (producer-base-id p))]
                 ,@(maybe-attr 'in producer-base-in p)
                 ,@(maybe-attr 'out producer-base-out p))

                ,@(map property->xml (producer-base-properties p)))]
    [else (raise "Err")]))

(define (melt-xml p)
  `(mlt
     ,(producer->xml p)))

(define melt-cmd
  (if (eq? (system-type 'os) 'windows)
      "qmelt "
      "melt "))

(define (melt #:out (file #f) p)
  (define path 
    (make-temporary-file "videotemp~a.xml"))

  (with-output-to-file path #:exists 'replace
                       (thunk
                         (displayln 
                           (xexpr->string (melt-xml p)))))

  (displayln (~a "Playing " path))

  (if file
    (system (~a melt-cmd path " -consumer avformat:" file " acodec=libmp3lame vcodec=libx264"))
    (system (~a melt-cmd path))))

(define (melt-debug p #:xml (xml #f))
  (if xml
    (displayln (xexpr->string (melt-xml p)))
    (pretty-print 
      (melt-xml p))))
