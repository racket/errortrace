#lang racket/base

(provide phase-1-top-module-tests)

;; Simplified program reported in issue #8.
;;
;; Declare a top-level module inside begin-for-syntax
;; then instantiate it at phase 0.
;;
;; This should work as if the module was decalre outside
;; begin-for-syntax except the `module` identifier needs
;; to be bound at phase 1.
(define (phase-1-top-module-tests)
  (parameterize ([current-namespace (make-base-namespace)])
    (dynamic-require 'errortrace #f)
    (eval '(require (for-syntax racket/base)))
    (eval '(begin-for-syntax (module m racket/base)))
    (dynamic-require ''m #f)))
