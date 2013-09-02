all: build

clean:
	rm -f runtime/syntax/2ansicolorcodes_colors.vim

build: runtime/syntax/2ansicolorcodes_colors.vim

runtime/syntax/2ansicolorcodes_colors.vim:
	cd runtime/syntax/ && vim -X -S ../../make-rgb-index.vim -E -n

install:
	install -m0755 vimcat /usr/bin/
	install -d /usr/share/vimcat/
	install -m0644 thisvimrc /usr/share/vimcat/
	install -m0644 make-rgb-index.vim /usr/share/vimcat/
	install -d /usr/share/vimcat/runtime/
	install -d /usr/share/vimcat/runtime/autoload/
	install -m0644 runtime/autoload/toansicolorcodes.vim /usr/share/vimcat/runtime/autoload/
	install -d /usr/share/vimcat/runtime/doc/
	install -m0644 runtime/doc/syntax.txt /usr/share/vimcat/runtime/doc/
	install -d /usr/share/vimcat/runtime/plugin/
	install -m0644 runtime/plugin/toansicolorcodes.vim /usr/share/vimcat/runtime/plugin/
	install -d /usr/share/vimcat/runtime/syntax/
	install -m0644 runtime/syntax/2ansicolorcodes.vim /usr/share/vimcat/runtime/syntax/
	install -m0644 runtime/syntax/2ansicolorcodes_colors.vim /usr/share/vimcat/runtime/syntax/
	install -d /etc/vimcat.conf.d/

uninstall:
	rm -f									\
		/usr/bin/vimcat							\
		/usr/share/vimcat/thisvimrc					\
		/usr/share/vimcat/make-rgb-index.vim				\
		/usr/share/vimcat/runtime/autoload/toansicolorcodes.vim		\
		/usr/share/vimcat/runtime/doc/syntax.txt			\
		/usr/share/vimcat/runtime/plugin/toansicolorcodes.vim		\
		/usr/share/vimcat/runtime/syntax/2ansicolorcodes.vim		\
		/usr/share/vimcat/runtime/syntax/2ansicolorcodes_colors.vim	\
		/etc/vimcat.conf
	rmdir --ignore-fail-on-non-empty					\
		/usr/share/vimcat/runtime/autoload/				\
		/usr/share/vimcat/runtime/doc/					\
		/usr/share/vimcat/runtime/plugin/				\
		/usr/share/vimcat/runtime/syntax/				\
		/usr/share/vimcat/runtime/					\
		/usr/share/vimcat/						\
		/etc/vimcat.conf.d/

.PHONY: all help clean build install uninstall
