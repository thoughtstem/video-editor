#lang racket 

(provide clip melt-xml melt 

         add-filter

         [rename-out 
           (make-multitrack multitrack)  
           (make-playlist playlist)])

(require xml)

(struct producer-base (id in out properties))
(struct producer producer-base () #:transparent)
(struct playlist producer-base (producers) #:transparent) 
(struct multitrack producer-base (producers filters) #:transparent) 
(struct property (name value) #:transparent)

(define CURRENT-ID -1)

(define (next-id prefix)
  (set! CURRENT-ID (add1 CURRENT-ID))

  (~a prefix CURRENT-ID))

(define (make-playlist #:in (in #f) #:out (out #f) . ps)
  (playlist
    (next-id "playlist")
    in out
    '()
    ps))

(define (make-multitrack #:in (in #f) #:out (out #f) . ps)
  (multitrack
    (next-id "multitrack")
    in out
    '()
    ps
    '() ;Filters
    ))

(define (add-filter f p)
  (if (multitrack? p)
    (let ([fs (multitrack-filters p)])
      (struct-copy multitrack p
                   [filters (cons f fs)])) 
    (add-filter f
      (make-multitrack p))))

(define (clip p #:in (in #f) #:out (out #f))
  (cond 
    [(path? p)
     (producer 
       (next-id "producer")
       in out
       (list 
         (property "resource" p)))]
    [(producer-base? p)
     (struct-copy producer-base p
                  [in in]
                  [out out])]))

(define (property->xml p)
  `(property ([name ,(property-name p)])
     ,(~a (property-value p))))

(define (playlist->xml p)
  `(playlist ([id ,(~a (producer-base-id p))])
      ,@(map producer->xml (playlist-producers p))))

(define (multitrack->xml p)
  `(tractor
     (multitrack ([id ,(~a (producer-base-id p))])
                      ,@(map producer->xml (multitrack-producers p)))
     (filter
       ,@(map property->xml 
              (multitrack-filters p)))))

(define (producer->xml p)
  (cond 
    [(playlist? p) (playlist->xml p)]
    [(multitrack? p) (multitrack->xml p)]
    [(producer-base? p) 
     `(producer ([id ,(~a (producer-base-id p))]
                 ,@(if (producer-base-in p)
                     `([in ,(~a (producer-base-in p))]) 
                     '())

                 ,@(if (producer-base-out p)
                     `([out ,(~a (producer-base-out p))]) 
                     '()))

                ,@(map property->xml (producer-base-properties p)))]
    [else (raise "Err")]))

(define (melt-xml p)
  `(mlt
     ,(producer->xml p)))

(define (melt p)
  (define path 
    (make-temporary-file "videotemp~a.xml"))

  (with-output-to-file path #:exists 'replace
                       (thunk
                         (displayln (xexpr->string (melt-xml p)))))

  (displayln (~a "Playing " path))

  (system (~a "melt " path)))

(define (mlt-service-property value)
  (property "mlt_service" value))



(provide grayscale)

(define grayscale 
  (mlt-service-property "grayscale"))




