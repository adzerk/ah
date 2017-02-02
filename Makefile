.PHONY: all clean install uninstall tools

SHELL  := /bin/bash
PREFIX ?= /usr/local

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
