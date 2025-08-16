#lang racket/base

(provide no-hash-req-module-tests)

(define (no-hash-req-module-tests)
  (parameterize ([current-namespace (make-base-namespace)])
    (dynamic-require 'errortrace #f) ; install handler
    (eval `(module m racket
             (begin-for-syntax
               (require (for-syntax racket/base))
               (define-syntax (m stx)
                 ;; triggers a `require` while ` (syntax-local-phase-level)` returns 1
                 (syntax-local-module-exports 'tests/errortrace/require-me)
                 #'(void))
               (m))))))

(no-hash-req-module-tests)
