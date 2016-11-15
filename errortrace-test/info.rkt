#lang info

(define collection 'multi)
(define deps '("errortrace-lib" "eli-tester" "rackunit-lib"))
(define build-deps '("base"
                     "compiler-lib"))

(define pkg-desc "tests for \"errortrace\"")

(define pkg-authors '(mflatt robby florence))
