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

(define (make-playlist . ps)
  (playlist
    (next-id "playlist")
    0
    (apply + (map producer-length ps)) 
    '()
    ps))

(define (make-multitrack . ps)
  (multitrack
    (next-id "multitrack")
    0
    (apply max (map producer-length ps))
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
  ;All adjust the in,
  ;  Some adjust the out, but only if it is greater than out

  (define (fix-in-out p)
    (define curr-in (producer-base-in p)) 
    (define curr-out (producer-base-out p)) 

    (cond 
      [(in . >= . curr-out) (change-in-out p 0 0)]
      [else (change-in-out p 
                           (max curr-in in)
                           (min curr-out out))]  )
    )

  (map fix-in-out ps))

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


;This function is gross.  Move to another file and break apart.
(define (clip path-or-producer #:in (in #f) #:out (out #f) #:force (force #f))

  (when (and 
          (not force)
          (producer-base? path-or-producer)
          ((- out in) 
           . > .
           (producer-length path-or-producer))) 
    (error "Can't expand a clip by clipping it."))

  (when (producer-base? path-or-producer)
    (set! in (max in (producer-base-in path-or-producer))) 
    (set! out (min out (producer-base-out path-or-producer)))) 

  (define ret
    (cond 
      [(or (string? path-or-producer) 
           (path? path-or-producer))
       (let ([p 
               (if (absolute-path? path-or-producer) 
                 path-or-producer
                 (build-path (script-location) path-or-producer))])
         (producer 
           (next-id "producer")
           (or in 0)  
           (or out (path->number-of-frames p)) ;TODO: REal length 
           (list 
             (property "resource" p))))]
      [(producer-base? path-or-producer)
       (change-in-out path-or-producer in out) ]
      [else 
        (error "Can't pass that to clip")]))

  (when (and in out 
             (not 
               (= (- out in)   
                  (producer-length ret))))
    (error "Clip length came up short!"))
  
  ret)

(define (path->number-of-frames path)
  (define s
    (with-output-to-string
      (thunk*
        (system
          (~a
            "ffprobe -v error -count_frames -select_streams v:0 -show_entries stream=nb_read_frames -of default=nokey=1:noprint_wrappers=1 " 
            path)))))

  (define n 
    (string->number 
      (string-replace s "\n" "")))
  
  n)

(define (producer->path p)
  (define props (producer-base-properties p)) 

  (property-value
    (findf 
      (lambda (p)
        (string=? "resource" (property-name p)))
      props)))
