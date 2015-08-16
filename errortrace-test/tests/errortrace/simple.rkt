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
  (dynamic-require 'errortrace #f))

(define plain-ns (make-base-namespace))

(define (do-expand s wrap ns)
  (parameterize ([current-namespace ns])
    (define o (open-output-bytes))
    (write (compile (wrap s)) o)
    (decompile (zo-parse (open-input-bytes (get-output-bytes o))))))

(define orig (read-syntax 'orig (open-input-string "x")))
(define (to-original d)
  (namespace-syntax-introduce (datum->syntax #f d orig orig)))

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
                   [(begin (quote _ _) (begin (#%require _ _) expr)) (normalize (datum expr))]))
  (define plain-exp (normalize (do-expand plain values plain-ns)))
  (define alt-exp (normalize (do-expand alt values plain-ns)))
  (unless (equal? et-exp plain-exp)
    (error 'errortrace-test "failed: ~s versus ~s" et-exp plain-exp))
  (when alt
    (when (equal? et-exp alt-exp)
      (error 'errortrace-test "failed (shouldn't match): ~s versus ~s" et-exp plain-exp))))

;; Check that known functions like `void' are not wrapped
;; when applied to the right number of arguments, but other
;; functions are:
;; (check '(void)
;;        '(void))
;; (check '(void 1 2 3)
;;        '(void 1 2 3))
;; (check '(void free)
;;        '(void (with-continuation-mark ? ? free)))
;; (check '(cons)
;;        '(with-continuation-mark ? ? (cons))
;;        '(cons))
;; (check '(cons 1 2)
;;        '(cons 1 2))
;; (check '(list)
;;        '(list))
;; (check '(list*)
;;        '(with-continuation-mark ? ? (list*)))
;; (check '(car (list))
;;        '(with-continuation-mark ? ? (car (list)))
;;        '(car (list)))

;; ;; Wrappers in these cases shouldn't get in the way of optimizations:
;; (check '(+ 1 3)
;;        '4)
;; (check '(car (list 1))
;;        '1)
(check 1 1)
