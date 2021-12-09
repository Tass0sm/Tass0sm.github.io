(use-modules (haunt asset)
             (haunt site)
             (haunt artifact)
             (haunt html)
             (haunt post)
             (haunt builder blog)
             (haunt builder assets)
             (haunt reader skribe)
             (haunt reader commonmark)
             (haunt reader)
             (srfi srfi-1)
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
               (p "I am studing Computer Science at the Ohio State University."))))))

(define (filtered-and-sorted key value)
  "Returns a function which filters a list of posts to those where KEY in the
metadata equals VALUE, and then sorts them in reverse-chronological order."
  (lambda (posts)
    (let ((filtered (filter (lambda (post)
                              (string=? (post-ref post key) value))
                            posts)))
      (posts/reverse-chronological filtered))))

(define (projects)
  "Returns a builder which produces a projects overview page and project
subpages, treating POSTS as a list of projects. Very similar to the blog
builder, so using that."
  (blog #:theme tassos-projects-theme
        #:collections `(("Recent Projects"
                         "complete-projects.html"
                         ,(filtered-and-sorted 'recent "t"))
                        ("Hypothetical Projects"
                         "hypothetical-projects.html"
                         ,(filtered-and-sorted 'recent "f")))))

(site #:title "Tassos's Blog"
      #:domain "tass0sm.github.io"
      #:default-metadata
      '((author . "Tassos Manganaris")
        (email  . "tassos.manganaris@gmail.com"))
      #:posts-directory "projects"
      #:readers (list skribe-reader commonmark-reader)
      #:builders (list
                  about-page
                  (static-directory "css")
                  (static-directory "images")
                  (projects)))
