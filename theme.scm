(define-module (theme)
  #:use-module (haunt builder blog)
  #:use-module (haunt html)
  #:use-module (haunt artifact)
  #:use-module (haunt post)
  #:use-module (haunt site)
  #:use-module (ice-9 match)
  #:use-module (srfi srfi-19)
  #:use-module (utils)
  #:export (tassos-layout
            tassos-projects-theme
            static-page))

;; general layout elements

(define header
  '(header
    (nav
     (a (@ (href "index.html"))
        "Home")
     (a (@ (href "complete-projects.html"))
        "Projects")
     (a (@ (href "hypothetical-projects.html"))
        "Ideas")
     (a (@ (href "https://github.com/Tass0sm"))
        "GitHub"))))

(define footer
  `(footer
    (p "This website was created using org-mode and haunt. The complete source can be found "
       (a (@ (href "https://github.com/Tass0sm/Tass0sm.github.io")) "here") ".")
    (p "Version 0.3.0")))

(define (tassos-layout site title body)
  `((doctype "html")
    (html
     (head
      (meta (@ (charset "utf-8")))
      (meta (@ (name "viewport")
	       (content "width=device-width, initial-scale=1")))
      (title ,(string-append title " | " (site-title site)))

      ;; CSS
      ,(stylesheet "style"))
     (body
      ,header
      (div (@ (class "main-column"))
           ,body
           ,footer)))))

;; post layout elements

(define (compact-metadata post)
  `(ul
    (li ,(string-append
          (post-ref post 'status)
          " - "
          (date->string
           (post-date post) "~B ~d, ~Y")))
    (li ,(string-append
          "Purpose: "
          (post-ref post 'purpose)))))

(define (post-layout post)
  `(div
    (h1 ,(post-ref post 'title))
    ,(compact-metadata post)
    (div (@ (class "post"))
         ,(post-sxml post))))

;; collection layout elements

(define (collection-layout site title posts prefix)
  (define (post-uri post)
    (string-append "/" (if (eq? prefix "")
                           (string-append prefix "/")
                           "")
                   (site-post-slug site post) ".html"))

  `(div
    (h1 ,title)
    (ul
     ,(map (lambda (post)
             (let ((uri (post-uri post)))
               `(li (a (@ (href ,uri))
                       ,(post-ref post 'title)))))
           posts))))

(define tassos-projects-theme
  (theme #:name "tassos"
         #:layout
         tassos-layout
         #:post-template
         post-layout
         #:collection-template
         collection-layout))

;; Returns a builder for one "serialized artifact" with TITLE, FILE-NAME, and
;; BODY.
(define (static-page title file-name body)
  (lambda (site posts)
    (serialized-artifact file-name
                         (tassos-layout site title body)
                         sxml->html)))
