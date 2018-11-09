#lang racket/base
(require errortrace/errortrace-lib)

(define m
  #'(module m racket/base
      (define (foo3 x)
        (/ x "1"))
      (define (foo2 x)
        (foo3 x))
      (define (foo1 x)
        (list (foo2 x)))
      (define (foo0 x)
        (car (foo1 x)))
      
      (+ 1 (foo0 3))))

(define ns (make-base-namespace))
(namespace-attach-module (current-namespace) 'errortrace/errortrace-lib ns)
(parameterize ([current-namespace ns])
  (eval '(require errortrace/errortrace-lib))
  (eval (errortrace-annotate m)))

(define o (open-output-string))

(print-error-trace
 o
 (with-handlers ([exn:fail? values])
   (parameterize ([current-namespace ns])
     (dynamic-require ''m #f))))

(unless (regexp-match? #rx"[(]/ x \"1\"[)].*[(]list [(]foo2 x[)][)].*[(]car [(]foo1 x[)][)].*[(][+] 1 [(]foo0 3[)][)]"
                       (get-output-string o))
  (error 'backtrace-nontail
         "didn't get expected backtrace:~a"
         (get-output-string o)))
