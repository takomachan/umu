# vim: set nu ai sw=4 ts=4 :
#
MAIN	= umu

SRCS	= commander.rb \
			commander/commander.rb \
			commander/option.rb \
			commander/subcommand.rb \
			commander/prelude.rb \
			abstraction.rb \
			lexical/lexer.rb \
			lexical/lexer/abstract.rb \
			lexical/lexer/separator.rb \
			lexical/lexer/comment.rb \
			lexical/lexer/token.rb \
			lexical/lexer/string.rb \
			lexical/lexer/lexer.rb \
			lexical/token.rb \
			lexical/token/abstraction.rb \
			lexical/token/separator.rb \
			lexical/token/token.rb \
			lexical/escape.rb \
			lexical/location.rb \
			concrete-syntax.rb \
			concrete-syntax/parser.rb \
			concrete-syntax/abstract.rb \
			concrete-syntax/module.rb \
			concrete-syntax/module/abstract.rb \
			concrete-syntax/module/declaration.rb \
			concrete-syntax/module/expression.rb \
			concrete-syntax/module/expression/abstract.rb \
			concrete-syntax/module/expression/struct.rb \
			concrete-syntax/module/expression/identifier.rb \
			concrete-syntax/module/pattern.rb \
			concrete-syntax/module/pattern/abstract.rb \
			concrete-syntax/module/pattern/variable.rb \
			concrete-syntax/core.rb \
			concrete-syntax/core/declaration.rb \
			concrete-syntax/core/declaration/abstract.rb \
			concrete-syntax/core/declaration/assert.rb \
			concrete-syntax/core/declaration/value.rb \
			concrete-syntax/core/declaration/function.rb \
			concrete-syntax/core/declaration/recursive.rb \
			concrete-syntax/core/expression.rb \
			concrete-syntax/core/expression/abstract.rb \
			concrete-syntax/core/expression/unit.rb \
			concrete-syntax/core/expression/unary.rb \
			concrete-syntax/core/expression/unary/abstract.rb \
			concrete-syntax/core/expression/unary/atom.rb \
			concrete-syntax/core/expression/unary/atom/abstract.rb \
			concrete-syntax/core/expression/unary/atom/number.rb \
			concrete-syntax/core/expression/unary/atom/string.rb \
			concrete-syntax/core/expression/unary/atom/symbol.rb \
			concrete-syntax/core/expression/unary/prefix.rb \
			concrete-syntax/core/expression/unary/identifier.rb \
			concrete-syntax/core/expression/unary/class.rb \
			concrete-syntax/core/expression/unary/method.rb \
			concrete-syntax/core/expression/unary/container.rb \
			concrete-syntax/core/expression/unary/container/abstract.rb \
			concrete-syntax/core/expression/unary/container/tuple.rb \
			concrete-syntax/core/expression/unary/container/named-tuple.rb \
			concrete-syntax/core/expression/unary/container/list.rb \
			concrete-syntax/core/expression/unary/container/comprehension.rb \
			concrete-syntax/core/expression/unary/container/sequence.rb \
			concrete-syntax/core/expression/binary.rb \
			concrete-syntax/core/expression/binary/abstract.rb \
			concrete-syntax/core/expression/binary/infix.rb \
			concrete-syntax/core/expression/binary/apply.rb \
			concrete-syntax/core/expression/binary/send.rb \
			concrete-syntax/core/expression/nary.rb \
			concrete-syntax/core/expression/nary/rule.rb \
			concrete-syntax/core/expression/nary/if.rb \
			concrete-syntax/core/expression/nary/branch.rb \
			concrete-syntax/core/expression/nary/branch/abstract.rb \
			concrete-syntax/core/expression/nary/branch/cond.rb \
			concrete-syntax/core/expression/nary/branch/case.rb \
			concrete-syntax/core/expression/nary/lambda.rb \
			concrete-syntax/core/expression/nary/let.rb \
			concrete-syntax/core/pattern.rb \
			concrete-syntax/core/pattern/result.rb \
			concrete-syntax/core/pattern/abstract.rb \
			concrete-syntax/core/pattern/variable.rb \
			concrete-syntax/core/pattern/unit.rb \
			concrete-syntax/core/pattern/container.rb \
			concrete-syntax/core/pattern/container/abstraction.rb \
			concrete-syntax/core/pattern/container/tuple.rb \
			concrete-syntax/core/pattern/container/list.rb \
			abstract-syntax.rb \
			abstract-syntax/result.rb \
			abstract-syntax/abstract.rb \
			abstract-syntax/core.rb \
			abstract-syntax/core/declaration.rb \
			abstract-syntax/core/declaration/abstract.rb \
			abstract-syntax/core/declaration/simple.rb \
			abstract-syntax/core/declaration/mutual-recursive.rb \
			abstract-syntax/core/declaration/import.rb \
			abstract-syntax/core/declaration/declarations.rb \
			abstract-syntax/core/expression.rb \
			abstract-syntax/core/expression/abstract.rb \
			abstract-syntax/core/expression/unit.rb \
			abstract-syntax/core/expression/unary.rb \
			abstract-syntax/core/expression/unary/abstract.rb \
			abstract-syntax/core/expression/unary/atom.rb \
			abstract-syntax/core/expression/unary/atom/abstract.rb \
			abstract-syntax/core/expression/unary/atom/bool.rb \
			abstract-syntax/core/expression/unary/atom/number.rb \
			abstract-syntax/core/expression/unary/atom/string.rb \
			abstract-syntax/core/expression/unary/atom/symbol.rb \
			abstract-syntax/core/expression/unary/identifier.rb \
			abstract-syntax/core/expression/unary/class.rb \
			abstract-syntax/core/expression/unary/container.rb \
			abstract-syntax/core/expression/unary/container/abstraction.rb \
			abstract-syntax/core/expression/unary/container/tuple.rb \
			abstract-syntax/core/expression/unary/container/named-tuple.rb \
			abstract-syntax/core/expression/unary/container/struct.rb \
			abstract-syntax/core/expression/unary/container/list.rb \
			abstract-syntax/core/expression/unary/raise.rb \
			abstract-syntax/core/expression/binary.rb \
			abstract-syntax/core/expression/binary/abstract.rb \
			abstract-syntax/core/expression/binary/kind-of.rb \
			abstract-syntax/core/expression/binary/apply.rb \
			abstract-syntax/core/expression/binary/send.rb \
			abstract-syntax/core/expression/nary.rb \
			abstract-syntax/core/expression/nary/if.rb \
			abstract-syntax/core/expression/nary/switch.rb \
			abstract-syntax/core/expression/nary/lambda.rb \
			abstract-syntax/core/expression/nary/let.rb \
			value.rb \
			value/core.rb \
			value/core/top.rb \
			value/core/base.rb \
			value/core/base/atom.rb \
			value/core/base/atom/abstract.rb \
			value/core/base/atom/unit.rb \
			value/core/base/atom/bool.rb \
			value/core/base/atom/number.rb \
			value/core/base/atom/number/abstract.rb \
			value/core/base/atom/number/int.rb \
			value/core/base/atom/number/real.rb \
			value/core/base/atom/string.rb \
			value/core/base/atom/symbol.rb \
			value/core/base/lsm.rb \
			value/core/base/lsm/abstract.rb \
			value/core/base/lsm/product.rb \
			value/core/base/lsm/product/abstract.rb \
			value/core/base/lsm/product/tuple.rb \
			value/core/base/lsm/product/named-tuple.rb \
			value/core/base/lsm/union.rb \
			value/core/base/lsm/union/abstract.rb \
			value/core/base/lsm/union/datum.rb \
			value/core/base/lsm/union/option.rb \
			value/core/base/lsm/morph.rb \
			value/core/base/lsm/morph/abstract.rb \
			value/core/base/lsm/morph/list.rb \
			value/core/class.rb \
			value/core/function.rb \
			value/core/io.rb \
			value/core/struct.rb \
			environment.rb \
			environment/preference.rb \
			environment/tracer/tracer.rb \
			environment/tracer/stack.rb \
			environment/context.rb \
			environment/context/type.rb \
			environment/context/type/signature.rb \
			environment/context/type/signature/class.rb \
			environment/context/type/signature/set-of-class.rb \
			environment/context/type/signature/method.rb \
			environment/context/type/entry.rb \
			environment/context/value.rb \
			environment/context/value/abstract.rb \
			environment/context/value/initial.rb \
			environment/context/value/bindings.rb \
			environment/context/value/bindings/target.rb \
			environment/context/value/bindings/entry.rb \
			environment/entry.rb \
			common.rb \
			common/constant.rb \
			common/assertion.rb \
			common/exception.rb
RACC_SRCS = concrete-syntax/grammar.ry

EXAMPLES =	example/test.umu \
			example/list.umu \
			example/set.umu \
			example/reynolds.umu \
			example/sicp-ch1.umu \
			example/sicp-ch2.umu \
			example/sicp-ch3.umu \
			example/cjdate1975.umu


TMDOCPROC		= tmdoc
DBTOEPUB		= /opt/local/share/xsl/docbook-xsl/epub/bin/dbtoepub

DOC_ROOT		= tmdoc
TMDOC_LOG		= $(DOC_ROOT)/LOG.txt
DBOOK_TO_HTML	= $(DOC_ROOT)/dbook-to-html.xsl
DBOOK_TO_EPUB	= $(DOC_ROOT)/dbook-to-epub.xsl
CSS				= docbook.css
DOC_FILES		= $(DBOOK_TO_HTML) $(DBOOK_TO_EPUB) $(DOC_ROOT)/$(CSS)

BOOK_TITLE		= "Umu - Functional Scripting Language"

DBOOK_DIR 		= $(DOC_ROOT)/dbook
DBOOK_HOME		= $(DBOOK_DIR)/tmdoc.home.docbook

HTML_DIR		= $(DOC_ROOT)/html
HTML_INDEX		= $(HTML_DIR)/index.html

EPUB			= tmdoc.home.docbook.epub

FILES = $(MAIN) \
		$(SRCS) \
		$(RACC_SRCS) \
		$(EXAMPLES) \
		$(DOC_FILES)



help:
	@echo "[Making Rules]"
	@echo "        run : Interact interpreter."
	@echo "       test : Run scripts for testing."
	@echo ""
	@echo "         wc : Count all source files."
	@echo "       srcs : List all source files (by space)."
	@echo "    srclist : List all source files (by newline)."
	@echo "      files : List all files (by space)."
	@echo "   filelist : List all files (by newline)."
	@echo ""
	@echo "       open : Open TmDoc document (HTML format)."
	@echo "       html : Publish TmDoc document (HTML format)."
	@echo "       epub : Publish TmDoc document (EPUB format)."
	@echo ""
	@echo "      clean : Remove all automatically generated files."
	@echo "        tar : Create tar archive."
	@echo ""


run: $(MAIN)
	./$< -i -t

test: $(MAIN) $(EXAMPLES)
	@for FILE in $(EXAMPLES) ; \
	do \
		echo "==== $$FILE ====" ; \
		./$< $$FILE ; \
		echo ; \
		echo ; \
	done

wc: $(SRCS) $(RACC_SRCS)
	@wc $(SRCS) $(RACC_SRCS)

srcs: $(SRCS) $(RACC_SRCS)
	@echo $(SRCS) $(RACC_SRCS)

srclist: $(SRCS) $(RACC_SRCS)
	@for FILE in $(SRCS) $(RACC_SRCS) ; do echo $$FILE ; done

files: $(FILES)
	@echo $(FILES)

filelist: $(FILES)
	@for FILE in $(FILES); do echo $$FILE ; done

open: $(HTML_INDEX)
	w3m -o anchor_color=green $<

html: $(HTML_INDEX)

epub: $(EPUB)

clean:
	rm -f concrete-syntax/grammar.tab.rb \
			$(DBOOK_DIR)/tmdoc.*.docbook $(HTML_DIR)/*.html $(EPUB) \
			$(MAIN).tar

tar: $(FILES) $(DBOOK_DIR) $(HTML_DIR) Makefile
	tar cvf ../$(MAIN).tar $(FILES) $(DBOOK_DIR) $(HTML_DIR) Makefile



$(MAIN): $(SRCS) concrete-syntax/grammar.tab.rb

concrete-syntax/grammar.tab.rb: concrete-syntax/grammar.ry
	racc $<

$(HTML_INDEX): $(DBOOK_HOME)
	xsltproc \
		--stringparam html.stylesheet ../$(CSS) \
		-xinclude \
		-o $(HTML_DIR)/ \
		$(DBOOK_TO_HTML) $(DBOOK_HOME)

$(EPUB): $(DBOOK_HOME)
	$(DBTOEPUB) -d \
		--css $(DOC_ROOT)/$(CSS) \
		--stylesheet $(DBOOK_TO_EPUB) \
			$(DBOOK_HOME)

$(DBOOK_HOME): $(SRCS)
	$(TMDOCPROC) $(OPTS) -a -e 4 -t $(BOOK_TITLE) -l $(TMDOC_LOG) \
		-o $(DBOOK_DIR) $(SRCS)
