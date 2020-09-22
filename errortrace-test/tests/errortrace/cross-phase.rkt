#lang racket/base

(provide cross-phase-tests)

(define (cross-phase-tests)
  ;; Check that errortrace is ok with `(#%declare #:cross-phase-persistent)`
  (let ()
    (define ns (make-base-namespace))
    (parameterize ([current-namespace ns])
      (dynamic-require 'errortrace #f)
      (eval '(module cross-phase '#%kernel
               (#%declare #:cross-phase-persistent)))))
  ;; Check that errortrace doesn't instrument cross phase persistent modules
  (let ()
    (define ns (make-base-namespace))
    (parameterize ([current-namespace ns])
      (dynamic-require 'errortrace #f)
      (eval '(module cross-phase '#%kernel
               (define-values (a) 1)
               (#%declare #:cross-phase-persistent)))))
  ;; Check that errortrace uses free-identifier=? correctly
  (let ()
    (define ns (make-base-namespace))
    (parameterize ([current-namespace ns])
      (dynamic-require 'errortrace #f)
      (eval '(module a racket
               (dynamic-require-for-syntax "cross-phase-mod.rkt" #f)))
      (eval '(module b racket
               (dynamic-require-for-syntax ''a #f)))
      (eval '(require 'b)))))
