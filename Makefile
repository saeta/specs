
DOCKER ?= $(shell which docker)
DOC_FILES := \
	README.md \
	code-of-conduct.md \
	principles.md \
	style.md \
	ROADMAP.md \
	implementations.md \
	bundle.md \
	runtime.md \
	runtime-linux.md \
	config.md \
	config-linux.md \
	glossary.md
EPOCH_TEST_COMMIT := 041eb73d2e0391463894c04c8ac938036143eba3

docs: pdf html
.PHONY: docs

pdf:
	@mkdir -p output/ && \
	$(DOCKER) run \
	-it \
	--rm \
	-v $(shell pwd)/:/input/:ro \
	-v $(shell pwd)/output/:/output/ \
	-u $(shell id -u) \
	vbatts/pandoc -f markdown_github -t latex -o /output/docs.pdf $(patsubst %,/input/%,$(DOC_FILES)) && \
	ls -sh $(shell readlink -f output/docs.pdf)

html:
	@mkdir -p output/ && \
	$(DOCKER) run \
	-it \
	--rm \
	-v $(shell pwd)/:/input/:ro \
	-v $(shell pwd)/output/:/output/ \
	-u $(shell id -u) \
	vbatts/pandoc -f markdown_github -t html5 -o /output/docs.html $(patsubst %,/input/%,$(DOC_FILES)) && \
	ls -sh $(shell readlink -f output/docs.html)


HOST_GOLANG_VERSION	= $(shell go version | cut -d ' ' -f3 | cut -c 3-)
# this variable is used like a function. First arg is the minimum version, Second arg is the version to be checked.
ALLOWED_GO_VERSION	= $(shell test '$(shell /bin/echo -e "$(1)\n$(2)" | sort -V | head -n1)' == '$(1)' && echo 'true')

.PHONY: test .govet .golint .gitvalidation

test: .govet .golint .gitvalidation

# `go get golang.org/x/tools/cmd/vet`
.govet:
	go vet -x ./...

# `go get github.com/golang/lint/golint`
.golint:
ifeq ($(call ALLOWED_GO_VERSION,1.5,$(HOST_GOLANG_VERSION)),true)
	golint ./...
endif


# `go get github.com/vbatts/git-validation`
.gitvalidation:
	git-validation -q -run DCO,short-subject -v -range $(EPOCH_TEST_COMMIT)..HEAD

# `go get https://github.com/pquerna/ffjson`
ffjson:
	cd specs-go/ && ffjson -force-regenerate config.go
	cd specs-go/ && ffjson -force-regenerate state.go

clean:
	rm -rf output/ *~

