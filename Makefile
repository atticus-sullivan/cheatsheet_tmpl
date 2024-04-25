.PHONY: clean spellA spellT cont count default all pack

MAIN_sheet   := main.sheet
MAIN_script  := main.script

# change here if you want to build the script version by default
MAIN := $(MAIN_sheet)

FILES := $(MAIN).tex main.tex Makefile sections/*.tex

AUX = tex-aux
OPT =

.PRECIOUS: $(MAIN_sheet).pdf $(MAIN_script).pdf

default: $(MAIN).pdf
	

$(MAIN_script).pdf: $(MAIN_script).tex $(FILES)
	test -d $(AUX) || mkdir $(AUX)
	test -d $(AUX)/figures || mkdir $(AUX)/figures
	cluttex_teal --output-directory=$(AUX) --biber --max-iterations=20 --change-directory -e lualatex $(OPT) "$<"

$(MAIN_sheet).pdf: $(MAIN_sheet).tex $(FILES)
	test -d $(AUX) || mkdir $(AUX)
	test -d $(AUX)/figures || mkdir $(AUX)/figures
	cluttex_teal --output-directory=$(AUX) --biber --max-iterations=20 --change-directory -e lualatex $(OPT) "$<"

all:
	make $(MAIN_sheet).pdf
	make $(MAIN_script).pdf

cont: $(FILES)
	$(MAKE) $(MAIN).pdf OPT="--watch=inotifywait"

count:
	texcount -col -inc main.tex

clean:
	-test -d tex-aux  && $(RM) -r tex-aux

spellA: $(FILES)
	-aspell --home-dir=. --personal=dict.txt2 -l de_DE -t -c main.tex
	iconv -f ISO-8859-1 -t UTF-8 ./dict.txt2 > ./dict.txt

spellT: $(FILES)
	-textidote --check de --remove tikzpicture --remove-macros autoref --replace replacements.txt --dict ./dict.txt --output html main.tex > main-texidote.html

# would include .git and other files -> don't do it (github automatically
# attatches zip to releases maybe this is the way to go)
pack:
	@if [ -n "$$(git status --porcelain)" ] ; then echo "Unstaged changes -> don't create archive of git repo" ; exit 1 ; fi
	git archive --output ../cheatsheet.tar.gz HEAD
