#lang racket

(require rackunit
         racket/runtime-path)

(define-runtime-path lang.rkt "./lang.rkt")

(define in (open-input-string "(f 0)"))
(define out (open-output-string))

(void
 (parameterize ([current-input-port in]
                [current-output-port out])
   (system* (find-executable-path "racket")
            "--repl"
            "--eval"
            (~a "(enter! (file \"" lang.rkt "\"))"))))

(check regexp-match "> 1/10\n" (get-output-string out))
