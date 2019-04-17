PACKAGE := $(shell grep '^Package:' DESCRIPTION | sed -E 's/^Package:[[:space:]]+//')
RSCRIPT = Rscript --no-init-file

all: install

test:
	${RSCRIPT} -e 'library(methods); devtools::test()'

roxygen:
	@mkdir -p man
	${RSCRIPT} -e "library(methods); devtools::document()"

install:
	R CMD INSTALL .

build:
	R CMD build .

check:
	_R_CHECK_CRAN_INCOMING_=FALSE make check_all

check_all:
	${RSCRIPT} -e "rcmdcheck::rcmdcheck(args = c('--as-cran', '--no-manual'))"

pkgdown:
	${RSCRIPT} -e "library(methods); pkgdown::build_site()"

website: pkgdown
	./update_web.sh

README.md: README.Rmd
	Rscript -e 'library(methods); devtools::load_all(); knitr::knit("README.Rmd")'
	sed -i.bak 's/[[:space:]]*$$//' $@
	rm -f $@.bak

clean:
	rm -f src/*.o src/*.so src/*.dll

coverage:
	Rscript -e 'covr::shine(covr::package_coverage(quiet=FALSE))'

vignettes/odin.Rmd: vignettes/src/odin.R
	${RSCRIPT} -e 'library(sowsear); sowsear("$<", output="$@")'
vignettes/discrete.Rmd: vignettes/src/discrete.R
	${RSCRIPT} -e 'library(sowsear); sowsear("$<", output="$@")'
vignettes: vignettes/odin.Rmd vignettes/discrete.Rmd
	${RSCRIPT} -e 'library(methods); devtools::build_vignettes()'

ir_reference:
	${RSCRIPT} scripts/ir-build.R

# No real targets!
.PHONY: all test document install vignettes build
