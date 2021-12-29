WEB_ROOT = .
GIT_COMMAND = git --git-dir $(WEB_ROOT)/Tass0sm.github.io.git --work-tree $(WEB_ROOT)/site

all: build

build:
	haunt build

serve:
	haunt serve &
	firefox "localhost:8080"

view:
	firefox site/index.html

status:
	$(GIT_COMMAND) status

stage: build
	$(GIT_COMMAND) add --all

commit: stage
	$(GIT_COMMAND) commit

push:
	$(GIT_COMMAND) push origin master
