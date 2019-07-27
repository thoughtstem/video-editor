#lang racket

(provide (struct-out producer-base )
         (struct-out producer) 
         (except-out (struct-out playlist)
                     playlist) 
         (except-out (struct-out multitrack)
                     multitrack) 
         (struct-out filter) 
         (struct-out transition)
         (struct-out blank)
         (struct-out property)
         add-filter
         add-transition
         clip
         [rename-out 
           (make-multitrack multitrack)  
           (make-playlist playlist)]

         producer->path
         script-location)

(require "./next-id.rkt")

(struct producer-base (id in out properties))
(struct producer producer-base () #:transparent)
(struct playlist producer-base (producers) #:transparent) 
(struct multitrack producer-base (producers transitions filters) #:transparent) 
(struct property (name value) #:transparent)

(struct filter producer-base () #:transparent)
(struct transition producer-base () #:transparent)

(struct blank (length) #:transparent)

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

(define script-location (make-parameter "."))

(define (clip file #:in (in #f) #:out (out #f))
  (define p (build-path (script-location) file))
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

(define (producer->path p)
  (define props (producer-base-properties p)) 

  (property-value
    (findf 
      (lambda (p)
        (string=? "resource" (property-name p)))
      props)))
