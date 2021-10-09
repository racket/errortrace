#lang info

(define collection 'multi)

(define deps '("errortrace-lib"
               "errortrace-doc"))
(define implies '("errortrace-lib"
                  "errortrace-doc"))

(define pkg-desc "Instrumentation tools for debugging")

(define pkg-authors '(mflatt robby florence))

(define version "1.1")

(define license
  '(Apache-2.0 OR MIT))
