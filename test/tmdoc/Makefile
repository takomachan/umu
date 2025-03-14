FILE_DIR  = ..
FILE_HOME = $(FILE_DIR)/basic_test.rb

FILES = \
    tmdoc/__dummy__.rb \
    basic_test.rb \
    lexcical_test.rb \
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
    test_helper.rb \

TMDOCPROC		= tmdoc
DBTOEPUB		= /opt/local/share/xsl/docbook-xsl/epub/bin/dbtoepub

DOC_ROOT		= .
TMDOC_LOG		= $(DOC_ROOT)/LOG.txt
DBOOK_TO_HTML	= $(DOC_ROOT)/dbook-to-html.xsl
DBOOK_TO_EPUB	= $(DOC_ROOT)/dbook-to-epub.xsl
CSS				= docbook.css

BOOK_TITLE		= "Umu Test Suite"

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
        --show-all \
        --title      $(BOOK_TITLE) \
        --log-file   $(TMDOC_LOG) \
		--input-dir  $(FILE_DIR) \
		--output-dir $(DBOOK_DIR) \
        $(FILES)

$(HTML_DIR):
	mkdir $(HTML_DIR)

$(DBOOK_DIR):
	mkdir $(DBOOK_DIR)
