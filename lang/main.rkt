#lang racket 

(provide clip melt-xml melt)

(require xml)

(struct producer (id properties) #:transparent)
(struct property (name value) #:transparent)

(define CURRENT-ID -1)

(define (next-id prefix)
  (set! CURRENT-ID (add1 CURRENT-ID))

  (~a prefix CURRENT-ID))

(define (clip path)
  (producer 
    (next-id "producer")
    (list 
      (property "resource" path))))

(define (property->xml p)
  `(property ([ name ,(property-name p)])
     ,(~a  (property-value p))))

(define (producer->xml p)
  `(producer ([id ,(producer-id p)])
     ,@(map property->xml 
            (producer-properties p))))

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




