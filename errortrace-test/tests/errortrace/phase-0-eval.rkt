#lang racket/base

(provide phase-0-eval-tests)

;; A Test case from @florence in issue #14
;;
;; When phase-1-eval is required for-template, the evaluation takes place at phase 0,
;; so errortrace will generate top-level #%requires after annotating '(+ 1 2).
;;
;; we need to use namespace-base-phase (which is 0) for these top-level #%requires
;; instead of syntax-local-phase-level (which is -1), which should be used for #%requires
;; inside phase-1-eval.
(define (phase-0-eval-tests)
  ;; In 'phase-1-eval, we are evaling in the namespace of racket/base.
  ;; Therefore we re-load racket/base in a fresh empty namespace
  ;; to avoid affecting other programs.
  (define source-namespace (current-namespace))
  (parameterize ([current-namespace (make-empty-namespace)])
    (namespace-attach-module source-namespace ''#%builtin)
    (namespace-require 'racket/base)

    (dynamic-require 'errortrace #f)

    (eval '(module phase-1-eval racket/base
             (require (for-syntax racket/base))
             (begin-for-syntax
               (parameterize ([current-namespace (module->namespace 'racket/base)])
                 (eval '(+ 1 2))))))

    (eval '(module template racket/base
             (require (for-template 'phase-1-eval))))

    (dynamic-require ''template #f)))
