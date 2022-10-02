(module reader racket/base
  (require syntax/module-reader
           errortrace)

  (provide (rename-out [et-read read]
                       [et-read-syntax read-syntax]
                       [et-get-info get-info]))

  (define-values (et-read et-read-syntax et-get-info)
    (make-meta-reader
     'errortrace
     "language path"
     lang-reader-module-paths
     values
     values
     values)))
