#lang racket/base
(provide test-define-syntaxes-coverage)
(require errortrace/stacktrace racket/unit tests/eli-tester)

(define (with-mark src dest phase) dest)
(define test-coverage-enabled (make-parameter #t))
(define profile-key (gensym))
(define profiling-enabled (make-parameter #f))
(define initialize-profile-point void)
(define (register-profile-start . a) #f)
(define register-profile-done void)

(define (test-define-syntaxes-coverage)
  (define covered? (mcons #f #f))
  (define initialized? #f)

  (define ns (make-base-namespace))
  (parameterize ([current-namespace ns])

    (define test-coverage-enabled? #t)
    (define (test-covered stx)
      (if (eq? (syntax-e stx) 'x)
          #`(#%plain-app set-mcar! #,covered? #t)
          void))

    (define (initialize-test-coverage-point stx)
      (when (eq? (syntax-e stx) 'x)
        (set! initialized? #t)))
    (define test-stx
      #'(module test racket/base
          (define-syntax-rule (x) 0)))

    (define-values/invoke-unit/infer stacktrace@)
    (eval (annotate-top (namespace-syntax-introduce (expand test-stx)) 0))
    (eval '(require 'test))
    (test initialized? => #t)
    (test (mcar covered?) => #t)))
