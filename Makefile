WEB_ROOT = .
GIT_COMMAND = git --git-dir $(WEB_ROOT)/Tass0sm.github.io.git --work-tree $(WEB_ROOT)/site

all: build

build:
	haunt build

view:
	firefox site/index.html

deploy:
	git subtree push --prefix site origin gh-pages
