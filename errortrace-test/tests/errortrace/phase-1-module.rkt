#lang racket/base

(provide phase-1-module-tests)

(define (phase-1-module-tests)
  (parameterize ([current-namespace (make-base-namespace)])
    (dynamic-require 'errortrace #f) ; install handler
    (define errortrace-error-display-handler
      (dynamic-require 'errortrace/errortrace-lib 'errortrace-error-display-handler))
    (define exn
      (with-handlers ([exn:fail? values])
        (eval `(module m racket/base
                 (require (for-syntax racket/base))
                 (define-syntax (m stx)
                   (eval '(module m racket/base
                            (/ 1 0)))
                   (eval '(require 'm)))
                 (m)))))
    (let ([o (open-output-bytes)])
      (parameterize ([current-error-port o])
        (errortrace-error-display-handler (exn-message exn) exn))
      (unless (regexp-match? #rx"errortrace[.][.][.]:\n[^\n]*./"
                             (get-output-bytes o))
        (error "phase-1 module does not appear to be annotated")))))
