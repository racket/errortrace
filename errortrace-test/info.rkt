#lang info

(define collection 'multi)
(define deps '("errortrace-lib" "eli-tester" "rackunit-lib"))
(define build-deps '("base"
                     "racket-index"
                     "compiler-lib"
                     "at-exp-lib"))

(define pkg-desc "tests for \"errortrace\"")

(define pkg-authors '(mflatt robby florence))

(define license
  '(Apache-2.0 OR MIT))
