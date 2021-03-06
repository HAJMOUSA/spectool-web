all : unpack-examples html

serve-static :
	( cd etc/service/httpd && ./run )

serve-full :
	( cd etc/service && svscan . )


EXAMPLES_GZ = $(shell find htdocs/data/example -name \*.gz | sort)
EXAMPLES = $(EXAMPLES_GZ:%.gz=%)

unpack-examples: $(EXAMPLES)

htdocs/data/example/% : htdocs/data/example/%.gz
	gunzip -c < $< > $@


LOG_FILES = $(EXAMPLES) $(shell find -L htdocs/data -type f -a -not -path "htdocs/data/example/*" -a -not -name ".*" | sort)

html : htdocs/index.html

htdocs/index.html : templates/index.html htdocs/logfiles.html
	@echo "rebuilding page..."
	@LOGFILES_HTML=`tr -d '\n' < htdocs/logfiles.html` ; sed -e "s|%%LOGFILES_HTML%%|$$LOGFILES_HTML|;" templates/index.html > $@

htdocs/logfiles.html : force $(LOG_FILES)
	@echo $^ \
	| sed -e 's/^force //' \
	| tr ' ' '\n' \
	| sed -e 's|^htdocs/||' \
	| while read f; do \
	    sed -e "s|%%VALUE%%|$$f|; s|%%TITLE%%|$$f|;" templates/option.html \
	; done > $@


.PHONY : force

.DELETE_ON_ERROR :

