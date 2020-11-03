NAME := test-more
DOC  := doc/$(NAME).swim
MAN3 := man/man3

DOCKER_IMAGE := ingy/bash-testing:0.0.1

default: help

help:
	@echo 'Rules: test, doc'

.PHONY: test
test:
	prove $(PROVEOPT:%=% )test/

test-all: test docker-test

docker-test:
	$(call docker-make-test,3.2)
	$(call docker-make-test,4.0)
	$(call docker-make-test,4.1)
	$(call docker-make-test,4.2)
	$(call docker-make-test,4.3)
	$(call docker-make-test,4.4)
	$(call docker-make-test,5.0)
	$(call docker-make-test,5.1)

doc: ReadMe.pod $(MAN3)/$(NAME).3

ReadMe.pod: $(DOC)
	swim --to=pod --complete --wrap $< > $@

$(MAN3)/%.3: doc/%.swim
	swim --to=man $< > $@

define docker-make-test
	docker run -i -t --rm \
	    -v $(PWD):/git-subrepo \
	    -w /git-subrepo \
	    $(DOCKER_IMAGE) \
		/bin/bash -c ' \
		    set -x && \
		    [[ -d /bash-$(1) ]] && \
		    export PATH=/bash-$(1)/bin:$$PATH && \
		    bash --version && \
		    make test \
		'
endef
