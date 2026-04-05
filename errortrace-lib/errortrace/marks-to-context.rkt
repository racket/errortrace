(module errortrace-key '#%kernel (void '#:errortrace-dont-annotate)

  (#%provide errortrace-continuation-mark-set->context)

  (define-values (errortrace-continuation-mark-set->context)
    (make-parameter #f)))
