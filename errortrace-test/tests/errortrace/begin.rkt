#lang racket/base

(provide begin-for-syntax-tests)

(define (begin-for-syntax-tests)
  (define ns (make-base-namespace))
  (parameterize ([current-namespace ns])
    (dynamic-require 'errortrace #f)
    (eval '(module m racket/base
             (require (for-syntax racket/base)
                      (for-meta 2 racket/base)
                      (for-meta 3 racket/base))
             (begin-for-syntax
               1 2
               (begin-for-syntax 1
                                 (begin-for-syntax 2)))))))

(module+ main
  (begin-for-syntax-tests))
