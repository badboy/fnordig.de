SOURCE = /home/badboy/git/fnordig.de/_site/
DEST = /var/www/sites/fnordig.de/

build:
	cobalt build

serve:
	cobalt watch

deploy: build
	rsync -va $(SOURCE) $(DEST)
