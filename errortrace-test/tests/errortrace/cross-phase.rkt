#lang racket/base

(provide cross-phase-tests)

;; Check that errortrace is ok with `(#%declare #:cross-phase-persistent)`
(define (cross-phase-tests)
  (define ns (make-base-namespace))
  (parameterize ([current-namespace ns])
    (dynamic-require 'errortrace #f)
    (eval '(module cross-phase '#%kernel
            (#%declare #:cross-phase-persistent)))))
