#lang racket/base
(require syntax/datum
         racket/pretty
         compiler/zo-parse
         compiler/decompile)

;; Check some transformations directly. We check by compiling, which
;; means that we can check that cerain optimizations still apply, but
;; beware of the extra layer.

(define et-ns (make-base-namespace))
(parameterize ([current-namespace et-ns])
  ;; Modules compiled before errortrace, so
  ;; generated expressions should not be instrumented:
  (eval '(module m racket/base
          (define-syntax-rule (div x)
            (+ 0 (/ x)))
          (provide div)))
  (namespace-require ''m)
  ;; Load errortrace:
  (dynamic-require 'errortrace #f))

(define plain-ns (make-base-namespace))

(define (do-expand s wrap ns)
  (parameterize ([current-namespace ns]
                 [current-compile-target-machine
                  (if (eq? 'chez-scheme (system-type 'vm))
                      #f
                      (current-compile-target-machine))])
    (define o (open-output-bytes))
    (write (compile (wrap s)) o)
    (decompile (zo-parse (open-input-bytes (get-output-bytes o))))))

(define orig (read-syntax 'orig (open-input-string "x")))
(define (to-original d)
  (namespace-syntax-introduce
   ;; A plain (datum->syntax #f d orig orig) is not
   ;; good enough to put a property on all contained objects,
   ;; because the property is only put on the immediate syntax object
   (let loop ([d d])
     (define v (cond
                [(pair? d) (cons (loop (car d)) (loop (cdr d)))]
                [else d]))
     (datum->syntax #f v orig orig))))

(define (normalize d)
  (datum-case d (with-continuation-mark begin quote inspector)
    [(begin e) (normalize (datum e))]
    [(begin (quote inspector _) e) (normalize (datum e))]
    [(with-continuation-mark _ _ expr) `(with-continuation-mark 
                                            ?
                                            ?
                                          ,(normalize (datum expr)))]
    [(a ...) (map normalize (datum (a ...)))]
    [else d]))

;; Check that `et' with annotations is like `plain', modulo
;; actual `wcm' keys and value expression. If `alt' is supplied,
;; make sure that it is *different* than `et'.
(define (check et plain [alt #f])
  (define et-exp (datum-case (do-expand et to-original et-ns) (begin #%require quote)
                   ;; v7.x
                   [(begin _ expr) (normalize (datum expr))]
                   ;; v6.x
                   [(begin (quote _ _) (begin (#%require _ _) expr)) (normalize (datum expr))]))
  (define plain-exp (normalize (do-expand plain values plain-ns)))
  (define alt-exp (normalize (do-expand alt values plain-ns)))
  (unless (equal? et-exp plain-exp)
    (error 'errortrace-test "failed: ~s versus ~s" et-exp plain-exp))
  (when alt
    (when (equal? et-exp alt-exp)
      (error 'errortrace-test "failed (shouldn't match): ~s versus ~s" et-exp plain-exp))))

;; Currently, we can only check optimizations with the 'racket VM
(when (eq? 'racket (system-type 'vm))
  (check '(cons)
         '(with-continuation-mark ? ? (cons))
         '(cons))
  (check '(list*)
         '(with-continuation-mark ? ? (list*)))
  (check '(car (list))
         '(with-continuation-mark ? ? (car (list)))
         '(car (list)))
  (check '(+ 1 (/ 0))
         '(with-continuation-mark ? ? (+ 1 (with-continuation-mark ? ? (/ 0)))))
  (check '(+ 1 (+ 0 (/ 0)))
         '(with-continuation-mark ? ? (+ 1 (with-continuation-mark ? ? (+ 0 (with-continuation-mark ? ? (/ 0)))))))
  (check '(+ 1 (div 0))
         '(with-continuation-mark ? ? (+ 1 (with-continuation-mark ? ? (+ 0 (/ 0))))))

  ;; Wrappers in these cases shouldn't get in the way of optimizations:
  (check '(+ 1 3)
         '4)
  (check '(car (list 1))
         '1))

;; Interesting syntax literals for errortrace to traverse
(check '#(0 1 2)
       '#(0 1 2))
(check '#&(0)
       '#&(0))
(check '#s(a 0 1 2)
       '#s(a 0 1 2))
(check '#hash((a . 0))
       '#hash((a . 0)))
(check '#hasheq((a . 0))
       '#hasheq((a . 0)))
(check '#hasheqv((a . 0))
       '#hasheqv((a . 0)))
(check '#hashalw((a . 0))
       '#hashalw((a . 0)))
