.PHONY: all clean install uninstall tools instance-types aws-actions

SHELL  := /bin/bash
PREFIX ?= /usr/local
AWS_USERS_GUIDE := "http://docs.aws.amazon.com/IAM/latest/UserGuide"
AWS_SPOT_HIST   := "http://docs.aws.amazon.com/cli/latest/reference/ec2/describe-spot-price-history.html"

export PREFIX

all: doc/ah.1.html src/man/man1/ah.1 doc/ah-client.1.html src/man/man1/ah-client.1 build/json-table/jt

clean:
	rm -rf build

install: all
	(cd src && tar cf - .) | (cd $(PREFIX) && tar xf -)
	cp build/json-table/jt $(PREFIX)/lib/ah

uninstall:
	rm -rf $(PREFIX)/{bin,etc,lib,share}/ah
	rm -f $(PREFIX)/man/man1/ah.1
	rm -f $(PREFIX)/man/man1/ah-client.1

src/lib/ah/aws-actions.txt:
	curl -s $(AWS_USERS_GUIDE)/reference_policies_actionsconditions.html \
		|hxnormalize -x \
		|hxselect .highlights ul li a \
		|grep -o '"list_[^"]*"' \
		|tr -d '"' \
		|while read a; do \
			curl -s $(AWS_USERS_GUIDE)/$$a \
				|hxnormalize -x \
				|hxselect -cs '\n' ul.itemizedlist li p code a \
				|tr '[:]' '[\t]'; \
		done > $@

src/lib/ah/aws-conditions-context-keys.txt:
	curl -s $(AWS_USERS_GUIDE)/reference_policies_actionsconditions.html \
		|hxnormalize -x \
		|hxselect .highlights ul li a \
		|grep -o '"list_[^"]*"' \
		|tr -d '"' \
		|while read a; do \
			curl -s $(AWS_USERS_GUIDE)/$$a \
				|hxnormalize -x \
				|hxselect -cs '\n' ul.itemizedlist li p code \
				|grep -v '^<' \
				|tr '[:]' '[\t]'; \
		done |sort > $@

src/lib/ah/instance-types.txt:
	curl -s $(AWS_SPOT_HIST) \
		|hxnormalize -x \
		|hxselect -cs '\n' '#options.section' .highlight-python pre \
		|grep '^  *[a-z]' \
		|awk '{print $1}' \
		> $@

instance-types: src/lib/ah/instance-types.txt

aws-actions: src/lib/ah/aws-actions.txt

tools: tools/json-table.tar.gz

doc/ah.1.md.out: doc/ah.1.md
	cat $< |envsubst '$${PREFIX}' > $@

doc/ah-client.1.md.out: doc/ah-client.1.md
	cat $< |envsubst '$${PREFIX}' > $@

doc/ah.1.html: doc/ah.1.md.out doc/ah.1.css
	cat $< |ronn -5 --style=doc/ah.1.css --manual="AH MANUAL" --pipe > $@

doc/ah-client.1.html: doc/ah-client.1.md.out doc/ah.1.css
	cat $< |ronn -5 --style=doc/ah.1.css --manual="AH MANUAL" --pipe > $@

src/man/man1/ah.1: doc/ah.1.md.out
	cat $< |ronn -r --manual="AH MANUAL" --pipe > $@

src/man/man1/ah-client.1: doc/ah-client.1.md.out
	cat $< |ronn -r --manual="AH MANUAL" --pipe > $@

build/json-table/jt: tools/json-table.tar.gz
	rm -rf build/json-table
	mkdir -p build/json-table
	cat $< | (cd build/json-table && tar xzf - && make)

tools/json-table.tar.gz:
	rm -rf build/json-table
	(mkdir -p build && cd build && git clone git@github.com:micha/json-table)
	(cd build/json-table && git archive --format tar $$(git tag --sort=v:refname |tail -1)) |gzip -9 > $@
