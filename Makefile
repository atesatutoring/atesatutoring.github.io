JEKYLL_VERSION?=3.8
DOCKER_IMAGE=jekyll/jekyll:${JEKYLL_VERSION}
SITE_NAME=atesatutoring
GEM_CACHE_DIR?=.vendor/bundle
DOCKER_RUN_OPTS=run --rm --volume="${PWD}/:/srv/jekyll:Z" --volume="${PWD}/${GEM_CACHE_DIR}:/usr/local/bundle:Z"
DOCKER_PORT?=8085

.PHONY: build
build:                                     ## Build site with Jekyll
	docker ${DOCKER_RUN_OPTS} -i ${DOCKER_IMAGE} jekyll build -V

# Find all targets with comments and display them as help messages
help:                                       ## Show this help message for development
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-20s %s\n", $$1, $$2}'

.PHONY: jekyll-help
jekyll-help:                               ## Request Jekyll help
	docker ${DOCKER_RUN_OPTS} -it ${DOCKER_IMAGE} jekyll help

.PHONY: update
update:                                    ## Update gem dependencies
	docker ${DOCKER_RUN_OPTS} -it ${DOCKER_IMAGE} bundle update
	mkdir ${GEM_CACHE_DIR}

.PHONY: new
new:                                       ## Create a new site with Jekyll
	docker ${DOCKER_RUN_OPTS} -it ${DOCKER_IMAGE} sh -c "set -xv; chown -R jekyll /usr/gem/ && jekyll new ."

.PHONY: start
start:                                     ## Start serving site locally on ${DOCKER_PORT}
	docker ${DOCKER_RUN_OPTS} -it -p ${DOCKER_PORT}:4000 -d ${DOCKER_IMAGE} jekyll serve --watch --drafts

.PHONY: stop
stop:                                     ## Stop serving site locally
	docker ps -f "ancestor=${DOCKER_IMAGE}" --format "{{.ID}}" | xargs docker stop

