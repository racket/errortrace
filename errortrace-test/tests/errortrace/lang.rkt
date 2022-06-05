#lang errortrace racket/base

(require racket/string)

(define (f x)
  (/ (+ 1 x) 10))

(define failed
  (with-handlers ([exn:fail? values])
    (f 'bad)))

(define o (open-output-bytes))
(parameterize ([current-error-port o])
  ((error-display-handler) (exn-message failed) failed))

(unless (regexp-match? #rx"errortrace\\.\\.\\.:\n[^\n]*[(][+] 1 x[)]" (get-output-bytes o))
  (error "expected expression not in the error output"))

(unless (string-prefix? (get-output-string o) "+: contract violation\n  expected: number?\n  given: 'bad\n  errortrace...:\n")
  (error "unexpected format (without custom msg)"))

(define o2 (open-output-bytes))
(parameterize ([current-error-port o2])
  ((error-display-handler) "foobar" failed))

(unless (string-prefix? (get-output-string o2) "foobar\n  message: +: contract violation\n  expected: number?\n  given: 'bad\n  errortrace...:\n")
  (error "unexpected format (with custom msg)"))
