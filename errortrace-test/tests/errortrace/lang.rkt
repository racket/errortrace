#lang errortrace racket/base

(define (f x)
  (/ (+ 1 x) 10))

(define failed
  (with-handlers ([exn:fail? values])
    (f 'bad)))

(define o (open-output-bytes))
(parameterize ([current-error-port o])
  ((error-display-handler) (exn-message failed) failed))

(unless (regexp-match? #rx"errortrace...:\n[^\n]*[(][+] 1 x[)]" (get-output-bytes o))
  (error "expected expression not in the error output"))
