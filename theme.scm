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

(define header
  '(header
    (nav
     (a (@ (href "index.html"))
        "Home")
     (a (@ (href "complete-projects.html"))
        "Projects")
     (a (@ (href "hypothetical-projects.html"))
        "Ideas"))))

(define footer
  '(footer
    (p "Website Created with "
       (a (@ (href "https://dthompson.us/projects/haunt.html"))
          "Haunt"))))

(define tassos-layout
  (lambda (site title body)
    `((doctype "html")
      (html
       (head
        (meta (@ (charset "utf-8")))
        (title ,title)
        ,(stylesheet "style"))
       (body
        ,header
        ,body
        ,footer)))))

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
  `(div (@ (class "row"))
        (div (@ (class "col"))
             (h1 ,(post-ref post 'title))
             ,(compact-metadata post)
             (div (@ (class "post"))
                  ,(post-sxml post)))))

(define tassos-projects-theme
  (theme #:name "tassos"
         #:layout
         tassos-layout
         #:post-template
         post-layout
         #:collection-template
         (lambda (site title posts prefix)
           (define (post-uri post)
             (string-append "/" (if (eq? prefix "")
                                    (string-append prefix "/")
                                    "")
                            (site-post-slug site post) ".html"))
           `(div (@ (class "row center-row"))
                (div (@ (class "col"))
                     (h1 ,title)
                     (ul
                      ,(map (lambda (post)
                              (let ((uri (post-uri post)))
                                `(li (a (@ (href ,uri))
                                        ,(post-ref post 'title)))))
                            posts)))))))

;; Returns a builder for one "serialized artifact" with TITLE, FILE-NAME, and
;; BODY.
(define (static-page title file-name body)
  (lambda (site posts)
    (serialized-artifact file-name
                         (tassos-layout site title body)
                         sxml->html)))
