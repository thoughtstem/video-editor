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
         producer-length
         producer-empty?
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
    (or in 0) 
    (or out (apply + (map producer-length ps)))
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



(define (change-base-in-out pb in out)
  (cond 
    [(producer? pb)
     (struct-copy producer pb
                  [in #:parent producer-base in]
                  [out #:parent producer-base out])]
    [(playlist? pb)
     (struct-copy playlist pb
                  [in #:parent producer-base in]
                  [out #:parent producer-base out])]
    [(multitrack? pb)
     (struct-copy multitrack pb
                  [in #:parent producer-base in]
                  [out #:parent producer-base out])]
    [else (error "...")]))


(define (producer-empty? p)
  (= 0 (producer-length p)))

(define (producer-length p)
  (define in  (producer-base-in p))
  (define out (producer-base-out p))

  (if (and in out)
    (- out in)
    +inf.0))

(require "./clip-math.rkt")

(define (producer-in-out p) 
  (list (producer-base-in p)
        (producer-base-out p)))

(define (playlist-producers-clip p in out)
  (define ps          (playlist-producers p))
  (define in-outs     (map producer-in-out ps))
  (define new-in-outs (clamp-in-outs in-outs in out))
  
  (map (lambda (p io)
         (change-in-out p 
                        (first io) 
                        (second io))) 
       ps
       new-in-outs))

(define (multitrack-producers-clip m in out)
  (define ps          (multitrack-producers m))
  ps)

(define (change-children-in-out pb in out)
  (cond
    [(producer? pb) pb]
    [(playlist? pb)
     (let ([new-producers (playlist-producers-clip pb in out)])
       (struct-copy playlist pb
                    [producers new-producers]))]
    [(multitrack? pb)
     (let ([new-producers (multitrack-producers-clip pb in out)])
       (struct-copy multitrack pb
                    [producers new-producers]))]
    [else (error "...")]))


(define (change-in-out pb in out)
  (define rebased (change-base-in-out pb in out))
  
  (change-children-in-out rebased in out))


;takes a file or string or another producer
(define (clip path-or-producer #:in (in #f) #:out (out #f))
  (cond 
    [(or (string? path-or-producer) 
         (path? path-or-producer))
     (let ([p 
            (if (absolute-path? path-or-producer) 
              path-or-producer
              (build-path (script-location) path-or-producer))])
       (producer 
         (next-id "producer")
         (or in 0)  ;TODO: REal length
         (or out 100)
         (list 
           (property "resource" p))))]
    [(producer-base? path-or-producer)
     (change-in-out path-or-producer in out) ]
    [else (error "Cant pass that to clip")]))

(define (producer->path p)
  (define props (producer-base-properties p)) 

  (property-value
    (findf 
      (lambda (p)
        (string=? "resource" (property-name p)))
      props)))
