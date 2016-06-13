#lang racket/base

(provide define-syntax-test)
(require errortrace/stacktrace racket/unit tests/eli-tester)


(define (with-mark src dest phase) dest)
(define test-coverage-enabled (make-parameter #t))
(define profile-key (gensym))
(define profiling-enabled (make-parameter #f))
(define initialize-profile-point void)
(define (register-profile-start . a) #f)
(define register-profile-done void)
(define test-coverage-enabled? #t)

(define covered? #f)
(define initialized? #f)
(define (test-covered stx)
  (if (eq? (syntax-e stx) '++)
      (lambda () (set! covered? #t))
      void))
(define (initialize-test-coverage-point stx)
  (when (eq? (syntax-e stx) '++)
    (set! initialized? #t)))
(define-values/invoke-unit/infer stacktrace@)

(define (define-syntax-test)
  (define test-stx
    #'(module test racket
        (require (for-syntax syntax/parse))
        (define-syntax (define/broken-provide stx)
          (syntax-parse stx
            [(_ x:id y)
             #'(begin
                 (define-syntax x (make-rename-transformer #'y))
                 (provide x)
                 (define (k) x))]))

        (define/broken-provide ++ +)))
  (define ns (make-base-namespace))
  (parameterize ([current-namespace ns])
    (eval (annotate-top (expand test-stx) 0))
    (eval '(require 'test)))
  (test initialized? => #t)
  (test covered? => #t))
