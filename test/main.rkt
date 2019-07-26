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



(define multitrack1 
  (add-filter (grayscale)
	      (playlist playlist1 playlist1)))


(check-equal?
  (melt-xml multitrack1)

  '(mlt
     (tractor
       (multitrack
	 ((id "multitrack5"))
	 (playlist
	   ((id "playlist4"))
	   (playlist
	     ((id "playlist2"))
	     (producer
	       ((id "producer0") (in "0") (out "10"))
	       (property
		 ((name "resource"))
		 "/home/thoughtstem/Desktop/Dev/video-editor/test/./../demos/producers/example.mp4"))
	     (producer
	       ((id "producer1") (in "0") (out "10"))
	       (property
		 ((name "resource"))
		 "/home/thoughtstem/Desktop/Dev/video-editor/test/./../demos/producers/example2.mp4"))
	     (producer
	       ((id "producer0") (in "10") (out "20"))
	       (property
		 ((name "resource"))
		 "/home/thoughtstem/Desktop/Dev/video-editor/test/./../demos/producers/example.mp4")))
	   (playlist
	     ((id "playlist2"))
	     (producer
	       ((id "producer0") (in "0") (out "10"))
	       (property
		 ((name "resource"))
		 "/home/thoughtstem/Desktop/Dev/video-editor/test/./../demos/producers/example.mp4"))
	     (producer
	       ((id "producer1") (in "0") (out "10"))
	       (property
		 ((name "resource"))
		 "/home/thoughtstem/Desktop/Dev/video-editor/test/./../demos/producers/example2.mp4"))
	     (producer
	       ((id "producer0") (in "10") (out "20"))
	       (property
		 ((name "resource"))
		 "/home/thoughtstem/Desktop/Dev/video-editor/test/./../demos/producers/example.mp4")))))
       (filter ((id "filter3")) (property ((name "mlt_service")) "grayscale")))))


(define playlist2
  (add-filter (grayscale)
	      (playlist 
		(clip video1 #:in 0 #:out 50)  
		(clip video2 #:in 0 #:out 50))))

(define playlist3
  (playlist 
    (clip video1 #:in 0 #:out 50)  
    (clip video2 #:in 0 #:out 50)))

(define multitrack2
  (multitrack playlist3 playlist2))


#; ;Does SOMETHING with a fade, but not sure exactly what...
(melt (add-transition 
         (luma-test #:in 45 #:out 55) 
         multitrack2))


