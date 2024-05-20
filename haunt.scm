(use-modules (haunt asset)
             (haunt site)
             (haunt artifact)
             (haunt html)
             (haunt post)
             (haunt builder blog)
             ;; (haunt builder wiki)
             (haunt builder assets)
             (haunt reader skribe)
             (haunt reader commonmark)
             (haunt reader dir-tagging-reader)
             (haunt reader)
             (srfi srfi-1)
             (ice-9 format)
             (theme))

(define about-page
  (static-page
   "About Me"
   "index.html"
   `((div (@ (class "row center-row"))
          (div (@ (class "col"))
               (img (@ (id "self-img")
                       (src "images/me.png")
                       (alt "A picture of me."))))
          (div (@ (class col))
               (h2 "About Me")
               (p "I am a Ph.D. student studying Computer Science at Purdue University."))))))

(define (projects)
  "Returns a builder which produces a projects overview page and project
subpages, treating POSTS as a list of projects. Very similar to the blog
builder, so using that."
  (define projects-blog (blog #:theme tassos-projects-theme
                              #:collections `(("Recent Projects"
                                               "complete-projects.html"
                                               ,posts/reverse-chronological))))

  (lambda (site posts)
    (projects-blog site (filter (lambda (post) (post-ref post 'projects)) posts))))

(define (wiki)
  "Wiki"
  (define wiki-blog (blog #:theme tassos-wiki-theme
			  #:collections `(("Wiki"
                                           "wiki.html"
                                           ,identity))))

  (lambda (site posts)
    (wiki-blog site (filter (lambda (post)
                              (format #t "~a~%" (post-ref post 'date))
                              (and (post-ref post 'wiki)
                                   ;; (equal? (post-ref post 'good) "t")
                                   )) posts))))


(site #:title "TassosM"
      #:domain "tass0sm.github.io"
      #:default-metadata
      '((author . "Tassos Manganaris")
        (email  . "tassos.manganaris@gmail.com"))
      #:posts-directory "posts"
      #:readers (list (make-dir-tagging-reader html-reader)
                      (make-dir-tagging-reader skribe-reader)
                      (make-dir-tagging-reader commonmark-reader))
      #:builders (list
                  about-page
                  (static-directory "css")
                  (static-directory "images")
                  (projects)
                  (wiki)))
