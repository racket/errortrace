#lang racket

(require errortrace/errortrace-lib
         rackunit)

(struct unique-source ())

;; set up a syntax object with a source location
;; to be able to identify it later
(define (set-loc pos exp)
  (-> natural? (not/c syntax?) syntax?)
  (datum->syntax #f exp (vector (unique-source) #f #f pos 1)))

;; find the `pos`s in the syntax objects in `l`,
;; assuming that they were objects built by `set-loc`
(define/contract (find-positions l)
  (-> (listof (list/c any/c natural? natural?)) (set/c natural?))
  (for/set ([s (in-list l)]
            #:when (unique-source? (list-ref s 0)))
    (list-ref s 1)))

(parameterize ([coverage-counts-enabled #t]
               [current-namespace (make-base-namespace)])
  (parameterize ([current-compile (make-errortrace-compile-handler)])

    (let ()
      (eval (set-loc
             1
             `(define (f x)
                ,(set-loc 2
                          `(+ x
                              ,(set-loc 3
                                        `(+ x 1)))))))
      (define-values (all covered) (get-coverage))
      (check-equal? (find-positions all) (set 1 2 3))
      (check-equal? (find-positions covered) (set 1)))

    (let ()
      (eval `(f 11))
      (define-values (all covered) (get-coverage))
      (check-equal? (find-positions all) (set 1 2 3))
      (check-equal? (find-positions covered) (set 1 2 3)))
    ))
