SOURCE = /home/jer/git/fnordig.de/_site/
DEST = /var/www/sites/fnordig.de/

build:
	cobalt build --drafts
.PHONY: build

serve:
	cobalt watch
.PHONY: serve

deploy: clean build
	rsync -va --delete $(SOURCE) $(DEST)
.PHONY: deploy

clean:
	cobalt clean
.PHONY: clean
