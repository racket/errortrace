#lang racket/base

(require tests/eli-tester 
         "wrap.rkt" 
         "alert.rkt"
         "phase-1.rkt"
         "phase-1-eval.rkt"
         "begin.rkt"
         "coverage-let.rkt")

(wrap-tests)

(test do (alert-tests))
(test do (letrec-test))

(phase-1-tests)
(phase-1-eval-tests)
(begin-for-syntax-tests)
