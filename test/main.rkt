#lang racket

(require rackunit
         racket/runtime-path
         xml
         "../lang/main.rkt")

(define-runtime-path here ".")

(define path1
  (build-path here "../demos/producers/example.mp4"))   

(define video1 (clip path1))

(check-equal?
  (melt-xml video1)  
  `(mlt
     (producer ([id "producer0"])
        (property ([name "resource"])
                  ,(~a path1)))))


(define path2
  (build-path here "../demos/producers/example2.mp4"))   

(define video2 (clip path2))

(define playlist1
  (playlist 
    (clip video1 #:in 0 #:out 10)  
    (clip video2 #:in 0 #:out 10)  
    (clip video1 #:in 10 #:out 20)))

(check-equal?
  (melt-xml playlist1)  
  ;TODO: Should probably factor out the producers to the top (MLT "normal form"), for efficiency.
  `(mlt 
     (playlist ((id "playlist2"))
               (producer ((id "producer0")  
                          (in "0")  (out "10"))  
                         (property 
                           ((name "resource")) 
                           ,(~a path1)))
               (producer ((id "producer1")  
                          (in "0")  (out "10"))  
                         (property ((name "resource")) ,(~a path2)))

               (producer ((id "producer0")  
                          (in "10")  (out "20"))  
                         (property ((name "resource")) ,(~a path1))))))


;TODO: Working.  Turn into test.
#;
(melt (add-filter grayscale
                      (playlist playlist1 playlist1)))


