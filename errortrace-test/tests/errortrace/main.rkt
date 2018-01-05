#lang racket/base

(require tests/eli-tester
         "wrap.rkt"
         "alert.rkt"
         "phase-0-eval.rkt"
         "phase-1.rkt"
         "phase-1-eval.rkt"
         "phase-1-top-module.rkt"
         "phase-2-profile.rkt"
         "begin.rkt"
         "coverage-let.rkt"
         "coverage-define-syntax.rkt"
         "define-syntaxes-id-test.rkt"
         "profile.rkt"
         "cross-phase.rkt"
         "test-compile-time.rkt")

(wrap-tests)

(test do (alert-tests))
(test do (letrec-test))
(test do (test-phase-coverage))
(test do (define-syntax-test))
(test do (test-define-syntaxes-coverage))

(phase-1-tests)
(phase-1-eval-tests)
(phase-2-profile-tests)
(begin-for-syntax-tests)
(profile-tests)
(cross-phase-tests)
(phase-0-eval-tests)
(phase-1-top-module-tests)
