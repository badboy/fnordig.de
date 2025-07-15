default:
	rm -rf _site
	$(MAKE) build
	$(MAKE) MAKEFLAGS=--jobs=2 dev
.PHONY: default

dev: serve rerun
.PHONY: dev

build:
	cobalt build
	./ext/add-feed-stylesheet.sh _site/feed.xml
.PHONY: build

serve:
	@echo "Served on http://localhost:8000"
	cd _site && httplz
.PHONY: serve

index:
	./index.sh
.PHONY: index

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
	aspell --lang en_US --mode=markdown --dont-backup check $(shell find _posts -type f -name '*.md' | sort | tail -1)
.PHONY: spellcheck
