#lang racket/base

(require rackunit)

(provide profile-tests)

(define (profile-tests)
  (define ns (make-base-namespace))
  (parameterize ([current-namespace ns])
    (dynamic-require 'errortrace #f)
    ((dynamic-require 'errortrace 'profiling-enabled) #t)
    (check-not-exn
     (lambda ()
       (eval
        '(void (#%expression (+ 1 1))))))
    (check-not-exn
     (lambda ()
       (eval '(require racket/class))
       (eval
        '(define my-class%
           (class object%
             (super-new)
             (define/public (foo)
               (parameterize ([current-input-port 1200])
                 (dict-ref #f)))))))) ; this needs to be a call to a contracted function
    ))

(profile-tests)
