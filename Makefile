SOURCE = /home/jer/git/fnordig.de/_site/
DEST = /var/www/sites/fnordig.de/

default:
	rm -rf _site
	$(MAKE) MAKEFLAGS=--jobs=2 dev
.PHONY: default

dev: serve rerun
.PHONY: dev

build:
	cobalt build --drafts
.PHONY: build

serve: build
	@echo "Served on http://localhost:8000"
	cd _site && http
.PHONY: serve

deploy: clean build
	rsync -va --delete $(SOURCE) $(DEST)
.PHONY: deploy

clean:
	cobalt clean
.PHONY: clean

rerun:
	fd | entr -r -s 'make build'
.PHONY: rerun

latest-html: ## Get latests post renderewd into HTML
	@find _posts -type f | sort | tail -1 | xargs -I% pandoc -f markdown -t html %
.PHONY: latest-html

spellcheck: ## Spellcheck the latest post
	aspell --lang en_US --mode=markdown check $(shell find _posts -type f | sort | tail -1)
.PHONY: spellcheck
