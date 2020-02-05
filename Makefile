SOURCE = /home/jer/git/fnordig.de/_site/
DEST = /var/www/sites/fnordig.de/

default:
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
	fd | entr -s 'make build'
.PHONY: rerun
