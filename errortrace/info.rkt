#lang info

(define collection 'multi)

(define deps '("errortrace-lib"
               "errortrace-doc"))
(define implies '("errortrace-lib"
                  "errortrace-doc"))

(define pkg-desc "Instrumentation tools for debugging")

(define pkg-authors '(mflatt "spencer@florence.io"))

(define version "1.1")
