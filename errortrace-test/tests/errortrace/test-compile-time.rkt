#lang racket

(provide test-phase-coverage)
(require errortrace/stacktrace racket/unit tests/eli-tester)

(define (test-phase-coverage)
  (test-phase-0-coverage)
  (test-phase-1-coverage))

(define (with-mark src dest phase) dest)
(define test-coverage-enabled (make-parameter #t))
(define profile-key (gensym))
(define profiling-enabled (make-parameter #f))
(define initialize-profile-point void)
(define (register-profile-start . a) #f)
(define register-profile-done void)

(define (test-phase-0-coverage)
  (define test-coverage-enabled? #t)


  (define covered? #f)
  (define initialized? #f)

  (define (test-covered stx)
    (if (eq? (syntax-e stx) 'x)
        (lambda () (set! covered? #t))
        void))
  (define (initialize-test-coverage-point stx)
    (when (eq? (syntax-e stx) 'x)
      (set! initialized? #t)))

  (define-values/invoke-unit/infer stacktrace@)

  (define test-stx
    #'(module test racket (begin-for-syntax (define x 5) x)))
  (define ns (make-base-namespace))
  (parameterize ([current-namespace ns])
    (eval (annotate-top (expand test-stx) 0))
    (eval '(require 'test)))
  (test initialized? => #f)
  (test covered? => #f))

(define (test-phase-1-coverage)
  (define test-coverage-enabled? #t)

  (define test-coverage-at-compile-time (lambda () #t))


  (define covered? #f)
  (define initialized? #f)

  (define (test-coverage-point body expr phase)
    (cond [(eq? (syntax-e expr) 'x)
           (set! initialized? #t)
           #`(begin (#%plain-app #,(lambda () (set! covered? #t)))
                    #,body)]
          [else body]))

  (define-values/invoke-unit/infer stacktrace/annotator@)

  (define test-stx
    #'(module test racket (begin-for-syntax (define x 5) x)))
  (define ns (make-base-namespace))
  (parameterize ([current-namespace ns])
    (eval (expand (annotate-top (expand test-stx) 0)))
    (eval '(require 'test)))
  (test initialized? => #t)
  (test covered? => #t))
