#lang racket/base

(require tests/eli-tester
         "wrap.rkt"
         "alert.rkt"
         "phase-1.rkt"
         "phase-1-eval.rkt"
         "begin.rkt"
         "coverage-let.rkt"
         "coverage-define-syntax.rkt"
         "define-syntaxes-id-test.rkt"
         "test-compile-time.rkt")

(wrap-tests)

(test do (alert-tests))
(test do (letrec-test))
(test do (test-phase-coverage))
(test do (define-syntax-test))
(test do (test-define-syntaxes-coverage))

(phase-1-tests)
(phase-1-eval-tests)
(begin-for-syntax-tests)
