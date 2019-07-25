#lang racket 

(provide clip melt-xml melt 
         [rename-out (make-playlist playlist)])

(require xml)

(struct producer-base (id in out properties))
(struct producer producer-base () #:transparent)
(struct playlist producer-base (producers) #:transparent) 
(struct property (name value) #:transparent)

(define CURRENT-ID -1)

(define (next-id prefix)
  (set! CURRENT-ID (add1 CURRENT-ID))

  (~a prefix CURRENT-ID))

;TODO: Can playlists have an in/out?
(define (make-playlist #:in (in #f) #:out (out #f) . ps)
  (playlist
    (next-id "playlist")
    in out
    '()
    ps))

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

(define (producer->xml p)
  (cond 
    [(playlist? p) (playlist->xml p)]
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

