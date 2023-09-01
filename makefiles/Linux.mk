.PHONY: clean

R_PROFILE := .Rprofile

all: clean
	gcc -v

clean:
	rm -f **/*.so **/*.o **/RcppExports.cpp

.compile:
	Rscript -e "devtools::document()"
	Rscript -e "Rcpp::compileAttributes()"
	Rscript -e "renv::snapshot()"

check:
	Rscript -e "devtools::check()"

build: clean .compile
	# build into dist/<package-name> folder with devtools
	mkdir -p dist
	Rscript -e "devtools::build( path = 'dist' )"

install: clean .compile
	Rscript -e "devtools::install()"


install-fast:
	Rscript -e "devtools::install()"