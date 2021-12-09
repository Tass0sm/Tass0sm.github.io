title: Video-Lang on Guix
date: 2021-06-05 01:20
tags: Guix packaging Racket video video editing video-lang
recent: t
status: Completed
purpose: Edit video conveniently and without bloat
---

## Summary

Video editing translates well to functional programming. Common video elements
or effects can be thought of as functions combining videos, images, and other
data to produce new components in the timeline. The Racket video-lang has this
design.

There isn't a lot of support for Racket on Guix, but it looks like the normal
Racket package installation process still works reliably. The only extra step
was redefining the Racket package so that the ffmpeg libraries from guix were
accessible via the ffi. The package definition is shown below.

```scheme
(package
   (inherit racket)
   (name "racket-with-ffmpeg")
   (inputs
    `(("ffmpeg" ,ffmpeg)
      ,@(package-inputs racket)))
   (arguments
    `(#:configure-flags
      `(,(string-append "CPPFLAGS=-DGUIX_RKTIO_PATCH_BIN_SH="
                        (assoc-ref %build-inputs "sh")
                        "/bin/sh")
        "--enable-libz"
        "--enable-liblz4")
      #:modules
      ((guix build gnu-build-system)
       (guix build utils)
       (srfi srfi-1))
      #:phases
      (modify-phases %standard-phases
        (add-before 'configure 'pre-configure-minimal
          (lambda* (#:key inputs #:allow-other-keys)
            (chdir "src")
            #t))
        (add-after 'build 'patch-config.rktd-lib-search-dirs
          (lambda* (#:key inputs outputs #:allow-other-keys)
            ;; We do this between the `build` and `install` phases
            ;; so that we have racket to read and write the hash table,
            ;; but it comes before `raco setup`, when foreign libraries
            ;; are needed to build the documentation.
            (define out (assoc-ref outputs "out"))
            (apply invoke
                   "./cs/c/racketcs"
                   "-e"
                   ,(format #f
                            "~s"
                            '(let* ((args
                                     (vector->list
                                      (current-command-line-arguments)))
                                    (file (car args))
                                    (extra-lib-search-dirs (cdr args)))
                               (write-to-file
                                (hash-update
                                 (file->value file)
                                 'lib-search-dirs
                                 (lambda (dirs)
                                   (append dirs extra-lib-search-dirs))
                                 null)
                                #:exists 'truncate/replace
                                file)))
                   "--"
                   "../etc/config.rktd"
                   (filter-map (lambda (lib)
                                 (cond
                                  ((assoc-ref inputs lib)
                                   => (lambda (pth)
                                        (string-append pth "/lib")))
                                  (else
                                   #f)))
                               '("cairo"
                                 "fontconfig"
                                 "glib"
                                 "glu"
                                 "gmp"
                                 "gtk+"
                                 "libjpeg"
                                 "libpng"
                                 "libx11"
                                 "mesa"
                                 "mpfr"
                                 "openssl"
                                 "pango"
                                 "sqlite"
                                 "unixodbc"
                                 "libedit"
                                 "ffmpeg")))
            #t)))
      ;; Tests are in packages like racket-test-core and
      ;; main-distribution-test that aren't part of the main distribution.
      #:tests? #f)))
```

Now I can make videos with the complete power of a programming language like so:

```racket
#lang video

(playlist (color "blue" #:properties (hash "length" 10))
          (fade-transition 5)
          (clip "a_video.mp4"))
```

## Lessons Learned

- A little Racket Programming
- Some more Guix Experience
