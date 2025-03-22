FILE_DIR  = ..
FILE_HOME = $(FILE_DIR)/basic_test.rb

FILES = \
    tmdoc/__dummy__.rb \
    basic_test.rb \
    lexcical_test.rb \
    grammar_test.rb \
    module_language/module_language_test.rb \
    module_language/structure_declaration_test.rb \
    module_language/import_declaration_test.rb \
    core_language/declaration/declaration_test.rb \
    core_language/declaration/value_test.rb \
    core_language/declaration/function_test.rb \
    core_language/declaration/recursive_test.rb \
    core_language/declaration/assert_test.rb \
    core_language/expression/entry_test.rb \
    core_language/expression/entry/if_expression_test.rb \
    core_language/expression/entry/cond_expression_test.rb \
    core_language/expression/entry/case_expression_test.rb \
    core_language/expression/entry/case_expression/atom_test.rb \
    core_language/expression/entry/case_expression/datum_test.rb \
    core_language/expression/entry/case_expression/class_test.rb \
    core_language/expression/entry/case_expression/poly_test.rb \
    core_language/expression/entry/case_expression/mono_test.rb \
    core_language/expression/entry/let_expression_test.rb \
    core_language/expression/entry/do_expression_test.rb \
    core_language/expression/infix_test.rb \
    core_language/expression/send_test.rb \
    core_language/expression/apply_test.rb \
    core_language/expression/product_test.rb \
    core_language/expression/atomic_test.rb \
    core_language/expression/atomic/identifier_test.rb \
    core_language/expression/atomic/constant_test.rb \
    core_language/expression/atomic/brackets_test.rb \
    core_language/expression/atomic/lambda_expression_test.rb \
    core_language/expression/atomic/list_test.rb \
    core_language/expression/atomic/stream_test.rb \
    core_language/pattern/pattern_test.rb \
    core_language/pattern/variable_test.rb \
    core_language/pattern/unit_test.rb \
    core_language/pattern/tuple_test.rb \
    core_language/pattern/named_tuple_test.rb \
    core_language/pattern/list_test.rb \
    core_language/pattern/poly_test.rb \
    class_library/device_test.rb \
    class_library/object_test.rb \
    class_library/unit_test.rb \
    class_library/atom/atom_test.rb \
    class_library/atom/bool_test.rb \
    class_library/atom/int_test.rb \
    class_library/atom/float_test.rb \
    class_library/atom/string_test.rb \
    class_library/atom/symbol_test.rb \
    class_library/product/tuple_test.rb \
    class_library/product/named_tuple_test.rb \
    class_library/union/datum_test.rb \
    class_library/union/option_test.rb \
    class_library/union/result_test.rb \
    test_helper.rb \

TMDOCPROC		= tmdoc
DBTOEPUB		= /opt/local/share/xsl/docbook-xsl/epub/bin/dbtoepub

DOC_ROOT		= .
TMDOC_LOG		= $(DOC_ROOT)/LOG.txt
DBOOK_TO_HTML	= $(DOC_ROOT)/dbook-to-html.xsl
DBOOK_TO_EPUB	= $(DOC_ROOT)/dbook-to-epub.xsl
CSS				= docbook.css

BOOK_TITLE		= "Umu(Preliminary) Test Suite"

DBOOK_DIR 		= $(DOC_ROOT)/dbook
DBOOK_HOME		= $(DBOOK_DIR)/tmdoc.home.docbook

HTML_DIR		= $(DOC_ROOT)/html
HTML_HOME		= $(HTML_DIR)/index.html

EPUB			= umu-test-suite.epub



help:
	@echo "[Making Rules]"
	@echo "      files : List source files"
	@echo ""
	@echo "       open : Open TmDoc document (HTML format)"
	@echo "       html : Publish TmDoc document (HTML format)"
	@echo "       epub : Publish TmDoc document (EPUB format)"
	@echo ""
	@echo "      clean : Remove all automatically generated files"
	@echo ""


files:
	@for FILE in $(FILES) ; do echo $$FILE ; done

open: $(HTML_HOME)
	w3m -o anchor_color=green $<

html: $(HTML_HOME)

epub: $(EPUB)

clean:
	rm -f Make.FILES \
         $(TMDOC_LOG) \
         $(DBOOK_DIR)/tmdoc.*.docbook \
         $(HTML_DIR)/*.html \
         $(EPUB)



$(HTML_HOME): $(DBOOK_HOME) $(HTML_DIR)
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

$(DBOOK_HOME): $(FILE_HOME) $(DBOOK_DIR)
	$(TMDOCPROC) $(OPTS) \
        --show-module-siblings \
        --no-show-class-siblings \
        --title      $(BOOK_TITLE) \
        --log-file   $(TMDOC_LOG) \
		--input-dir  $(FILE_DIR) \
		--output-dir $(DBOOK_DIR) \
        $(FILES)

$(HTML_DIR):
	mkdir $(HTML_DIR)

$(DBOOK_DIR):
	mkdir $(DBOOK_DIR)
