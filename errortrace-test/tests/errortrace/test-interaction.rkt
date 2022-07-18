#lang racket

(require rackunit)

(require "lang.rkt")

(parameterize ([current-namespace (module->namespace "lang.rkt")])
  (check-equal? (eval '(#%top-interaction . (f 0))) 1/10))
