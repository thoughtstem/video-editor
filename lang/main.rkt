#lang racket

(provide melt melt-test greyscale)

(define (sys . args )
  (system (arg-splat args)))

(define (melt . args)
  (apply sys "melt" (flatten args)))

(define (melt-test . args)
  (displayln (arg-splat 
               "melt" 
               args)))

(define (arg-splat . args)
  (apply ~a 
         (add-between (flatten args) " ")))

(define-syntax-rule (-flag -f)
  (begin
    (provide -f)
    (define (-f . args)
      (arg-splat '-f args))))

(define-syntax-rule (prop= prop)
  (begin
    (provide prop)
    (define (prop n)
      (~a 'prop n))))

(define-syntax-rule (prop: prop)
  (begin
    (provide prop)
    (define (prop n)
      (~a 'prop n))))

(-flag -filter)
(-flag -transition)
(-flag -track)
(-flag -group)
(-flag -attach)
(-flag -attach-cut)
(-flag -mix)
(-flag -mixer)
(prop= in=)
(prop= out=)
(prop= composite.progressive=)
(prop= producer.align=)
(prop= composite.valign=)
(prop= composite.halign=)
(prop= geometry=)
(prop: mix:)
(prop: colour:)
(define color: colour:)



(define (watermark: #:pre (pre "") f type)
  (~a "watermark:" pre f "." type))

(define greyscale
  "greyscale")

(define invert
  "invert")

(define affine
  "affine")

(define composite
  "composite")

(module+ test
  (define ex1 "./example.mp4")
  (define ex2 "./example2.mp4")
  (define hello.txt "./hello.txt")

  #;
  (melt 
    ex1
    (-filter greyscale))
  

  #;
  (melt 
    ex1
    (-filter greyscale (in= 0) (out= 50)))

  ;Plays fisrt 50 frames of each
  #;
  (melt 
    (-group (in= 0) (out= 50)
            "./example*.mp4"))
  

  ;Plays fisrt 50 frames of each, greyscale for all (empty group "sheds' group properties" -- terminates the group expression?)
  #;
  (melt 
    (-group (in= 0) (out= 50)
            "./example*.mp4"
            (-group)
            (-filter greyscale) ))
  

  #;
  (melt 
    ex1
    ex2
    (-attach greyscale)
    ex1)


  ;Attaches inversion of color to watermark (cool!)
  #;
  (melt 
    ex1
    (-attach (watermark: #:pre '+ "hola" 'txt))
    (-attach invert))

  ;Attaches inversion to watermark and clip
  #;
  (melt 
    ex1
    (-attach-cut (watermark: #:pre '+ "hola" 'txt))
    (-attach-cut invert))



  ;melt colour:red -filter watermark:"+First Line~Second Line.txt" composite.progressive=1 producer.align=centre composite.valign=c composite.halign=c 
  #;
  (melt
    (color: "red")
    (-filter (watermark: #:pre '+ "Hello~There" 'txt))
    (composite.progressive= 1)
    (producer.align= 'centre)
    (composite.valign= 'c)
    (composite.halign= 'c))
  
  ;Image Example: melt clip.dv -filter watermark:logo.png

  #;
  (melt
    ex1
    (-filter (watermark: "logo" 'png))
    (composite.progressive= 1)
    (producer.align= 'centre)
    (composite.valign= 'c)
    (composite.halign= 'c))

  ;melt clip1.dv clip2.dv -mix 25 -mixer luma -mixer mix:-1

  #;
  (melt
    ex1
    (in= 0)
    (out= 100)
    ex2
    (-mix 10)
    (-mixer 'luma)
    (-mixer (mix: -1)))

  (melt
    ex2 
    (-track 
      ex1    
      (-transition composite (geometry= "0%,0%:50%x50%")))))






