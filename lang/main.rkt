#lang racket 

(provide clip melt-xml melt blank

         add-filter
         add-transition

         [rename-out 
           (make-multitrack multitrack)  
           (make-playlist playlist)])

(require xml)

(struct producer-base (id in out properties))
(struct producer producer-base () #:transparent)
(struct playlist producer-base (producers) #:transparent) 
(struct multitrack producer-base (producers transitions filters) #:transparent) 
(struct property (name value) #:transparent)

(struct filter producer-base () #:transparent)
(struct transition producer-base () #:transparent)

(struct blank (length) #:transparent)

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
    '() ;Transitions
    '() ;Filters
    ))

(define (add-filter f p)
  (if (multitrack? p)
    (let ([fs (multitrack-filters p)])
      (struct-copy multitrack p
                   [filters (cons f fs)])) 
    (add-filter f
      (make-multitrack p))))

;TODO: This is isomorphic to add-filter.  Shorten
(define (add-transition f p)
  (if (multitrack? p)
    (let ([fs (multitrack-transitions p)])
      (struct-copy multitrack p
                   [transitions (cons f fs)])) 
    (add-transition f
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

(define (filter->xml f)
  `(filter ([id ,(~a (producer-base-id f))]
		 ;These bits are gross and should be abstracted from the three functions they are in.
                 ,@(if (producer-base-in f)
                     `([in ,(~a (producer-base-in f))]) 
                     '())

                 ,@(if (producer-base-out f)
                     `([out ,(~a (producer-base-out f))]) 
                     '()))

     ,@(map property->xml (producer-base-properties f))))

(define (transition->xml t)
  `(transition ([id ,(~a (producer-base-id t))]
                 ,@(if (producer-base-in t)
                     `([in ,(~a (producer-base-in t))]) 
                     '())

                 ,@(if (producer-base-out t)
                     `([out ,(~a (producer-base-out t))]) 
                     '()))
     ,@(map property->xml (producer-base-properties t))))

(define (multitrack->xml p)
  `(tractor
     (multitrack ([id ,(~a (producer-base-id p))])
                      ,@(map producer->xml (multitrack-producers p)))
     
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
                 ,@(if (producer-base-in p)
                     `([in ,(~a (producer-base-in p))]) 
                     '())

                 ,@(if (producer-base-out p)
                     `([out ,(~a (producer-base-out p))]) 
                     '())
)

                ,@(map property->xml (producer-base-properties p)))]
    [else (raise "Err")]))

(define (melt-xml p)
  `(mlt
     ,(producer->xml p)))

(define (melt #:out (file #f) p)
  (define path 
    (make-temporary-file "videotemp~a.xml"))

  (with-output-to-file path #:exists 'replace
                       (thunk
                         (displayln (xexpr->string (melt-xml p)))))

  (displayln (~a "Playing " path))

  (if file
    (system (~a "melt " path " -consumer avformat:" file " acodec=libmp3lame vcodec=libx264"))
    (system (~a "melt " path))))

(define (mlt-service-property value)
  (property "mlt_service" value))



(provide grayscale)

(define (grayscale #:in (in #f) #:out (out #f))
  (filter
    (next-id "filter")
    in out
    (list
      (mlt-service-property "grayscale"))))

(provide luma-test)

;Just trying to get something working here.  
(define (luma-test #:in (in #f) #:out (out #f))
  (transition
    (next-id "filter")
    in out
    (list
      (property "a_track" 0)
      (property "b_track" 1)
      (mlt-service-property "luma"))))



