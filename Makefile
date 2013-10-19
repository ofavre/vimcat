PREFIX ?= /usr

all: build

clean:
	rm -f runtime/syntax/2ansicolorcodes_colors.vim

build: runtime/syntax/2ansicolorcodes_colors.vim

runtime/syntax/2ansicolorcodes_colors.vim:
	cd runtime/syntax/ && vim -X -S ../../make-rgb-index.vim -E -n >/dev/null

install: build
	install -d $(DESTDIR)$(PREFIX)/bin/
	install -d $(DESTDIR)$(PREFIX)/share/
	install -m0755 vimcat $(DESTDIR)$(PREFIX)/bin/
	install -d $(DESTDIR)$(PREFIX)/share/vimcat/
	install -m0644 thisvimrc $(DESTDIR)$(PREFIX)/share/vimcat/
	install -m0644 make-rgb-index.vim $(DESTDIR)$(PREFIX)/share/vimcat/
	install -d $(DESTDIR)$(PREFIX)/share/vimcat/runtime/
	install -d $(DESTDIR)$(PREFIX)/share/vimcat/runtime/autoload/
	install -m0644 runtime/autoload/toansicolorcodes.vim $(DESTDIR)$(PREFIX)/share/vimcat/runtime/autoload/
	install -d $(DESTDIR)$(PREFIX)/share/vimcat/runtime/doc/
	install -m0644 runtime/doc/syntax.txt $(DESTDIR)$(PREFIX)/share/vimcat/runtime/doc/
	install -d $(DESTDIR)$(PREFIX)/share/vimcat/runtime/plugin/
	install -m0644 runtime/plugin/toansicolorcodes.vim $(DESTDIR)$(PREFIX)/share/vimcat/runtime/plugin/
	install -d $(DESTDIR)$(PREFIX)/share/vimcat/runtime/syntax/
	install -m0644 runtime/syntax/2ansicolorcodes.vim $(DESTDIR)$(PREFIX)/share/vimcat/runtime/syntax/
	install -m0644 runtime/syntax/2ansicolorcodes_colors.vim $(DESTDIR)$(PREFIX)/share/vimcat/runtime/syntax/
	install -d $(DESTDIR)/etc/vimcat.conf.d/

uninstall:
	rm -f											\
		$(DESTDIR)$(PREFIX)/bin/vimcat							\
		$(DESTDIR)$(PREFIX)/share/vimcat/thisvimrc					\
		$(DESTDIR)$(PREFIX)/share/vimcat/make-rgb-index.vim				\
		$(DESTDIR)$(PREFIX)/share/vimcat/runtime/autoload/toansicolorcodes.vim		\
		$(DESTDIR)$(PREFIX)/share/vimcat/runtime/doc/syntax.txt				\
		$(DESTDIR)$(PREFIX)/share/vimcat/runtime/plugin/toansicolorcodes.vim		\
		$(DESTDIR)$(PREFIX)/share/vimcat/runtime/syntax/2ansicolorcodes.vim		\
		$(DESTDIR)$(PREFIX)/share/vimcat/runtime/syntax/2ansicolorcodes_colors.vim	\
		$(DESTDIR)/etc/vimcat.conf
	rmdir --ignore-fail-on-non-empty							\
		$(DESTDIR)$(PREFIX)/share/vimcat/runtime/autoload/				\
		$(DESTDIR)$(PREFIX)/share/vimcat/runtime/doc/					\
		$(DESTDIR)$(PREFIX)/share/vimcat/runtime/plugin/				\
		$(DESTDIR)$(PREFIX)/share/vimcat/runtime/syntax/				\
		$(DESTDIR)$(PREFIX)/share/vimcat/runtime/					\
		$(DESTDIR)$(PREFIX)/share/vimcat/						\
		$(DESTDIR)/etc/vimcat.conf.d/

.PHONY: all help clean build install uninstall
