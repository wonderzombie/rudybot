#! /bin/sh
#| Hey Emacs, this is -*-scheme-*- code!
exec  mzscheme -l errortrace --require "$0" --main -- ${1+"$@"}
|#
#lang scheme
(require (lib "trace.ss")
         (planet "test.ss"    ("schematics" "schemeunit.plt" ))
         (planet "text-ui.ss" ("schematics" "schemeunit.plt" ))
         (planet "util.ss"    ("schematics" "schemeunit.plt" ))
         "sighting.ss")

(require/expose "sighting.ss" (*sightings-database-directory-name*))


(define sighting-tests

  (test-suite
   "sighting-test"
   (test-case
    "yow"
    (let ((s (make-sighting "1" "2" 3 #f (list "hey" "you"))))
      (note-sighting s)
      (check-not-false (member s (lookup-sightings "1")))
      (check-equal? (lookup-sightings "snorkuplexity") '())))
   (test-case
    "persistent"
    (parameterize ((*sightings-database-directory-name* "persistent-test.db"))
      (let ((stuff (map make-sighting
                        (list "fred" "paul" "mary" "fred_")
                        (list "2" "3" "4" "5")
                        (list 9 8 7 6)
                        (list "QUIT" #f #f "SNORK")
                        (list (list "znork?")
                              (list "I" "am" "NOT" "dead")
                              (list "I" "am" "Jesus'" "mom")
                              (list "I'm" "fred" "with" "a" "trailing" "underscore")))))
        (let ((writing? (not (directory-exists? (*sightings-database-directory-name*)))))
          ;; if the db doesn't exist, note some stuff.
          ;; if the db does exist, check for what we noted.
          (if writing?
            (printf "Putting test data into ~a; run me again and I'll check the contents.~%"
                    (*sightings-database-directory-name*))
            (printf "Reading test data from ~a~%"
                    (*sightings-database-directory-name*)))

          (for ((s (in-list stuff)))

            (if writing?
                (note-sighting s)
                (check-not-false (member s (lookup-sightings (canonicalize-nick (sighting-who s)))))))))))))

(define (main . args)
  (exit (test/text-ui sighting-tests 'verbose)))
(provide (all-defined-out))
