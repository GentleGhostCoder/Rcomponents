#' evalComponents
#' @rdname evalComponents
#' @name evalComponents
#' @usage evalComponents()
#' @description evalComponents
#' @export
evalComponents <- function(pkg_dir = ".") {
  stopifnot(file.exists("DESCRIPTION"))

  # read package name from description file
  pkg_name <- read.dcf("DESCRIPTION", fields = "Package")[[1]]

  # default dirs
  inst_dir <- sprintf("%s%s%s", pkg_dir, .Platform$file.sep, "inst/components")
  man_dir <- sprintf("%s%s%s", pkg_dir, .Platform$file.sep, "man")
  component_dirs <- list.dirs(sprintf("%s%s%s", pkg_dir, .Platform$file.sep, "R"),
    full.names = TRUE, recursive = FALSE
  ) # subdirs in R

  if (!length(component_dirs)) {
    return(warning("No components found!"))
  }

  # create man / inst folder if not exists
  dir.create(inst_dir, showWarnings = FALSE, recursive = TRUE)
  dir.create(man_dir, showWarnings = FALSE, recursive = TRUE)

  # list all files and subfiles
  component_files <- list(filename = list.files(
    path = component_dirs,
    pattern = ".R$" # only R files
    , all.files = TRUE,
    full.names = TRUE,
    recursive = TRUE,
    include.dirs = FALSE
  ))

  if (!length(component_files)) {
    return(warning(
      "Rcomponents: No components found in:\n",
      paste0(component_files, collapse = "\n")
    ))
  }

  # get meta info for all files
  component_files <- c(component_files, .Internal(file.info(component_files$filename, FALSE)))

  # extract file name without extension and path
  component_files$filename_without_extension <-
    gsub(sprintf(".*%s(.+).R", .Platform$file.sep), "\\1", component_files$filename)

  # build components  -----------------------------------------------------------------
  vapply(1:length(component_files[[1]]), function(idx) {

    # create sourceRef - Class
    srcfile <- new.env(hash = TRUE, parent = parent.frame(), size = 1)
    srcfile$filename <- component_files$filename[[idx]]
    srcfile$lines <- readLines(srcfile$filename)
    if (!length(srcfile$lines)) {
      return(invisible(""))
    }
    class(srcfile) <- c("srcfilecopy", "srcfile")

    # eval source
    expr <- .Internal(parse(
      file = stdin(),
      n = NULL,
      text = srcfile$lines,
      prompt = "?",
      srcfile = srcfile,
      encoding = "unknown"
    ))

    # eval source Expressions into public Environment
    component <- publicEval(expr)

    attr(component, "name") <- sprintf("%s%s%s", pkg_name, ".", component_files$filename_without_extension[[idx]]) # keyword - environment name

    compileFunctions(object = component, options = NULL)

    # eval roxygen tokens from srcref class attribute
    tokens <- lapply(
      roxygen2:::comments(attr(expr, "srcref")),
      roxygen2:::tokenise_ref
    ) # comment tokens (like in roxygen2)


    # generate rd_code ------------------------------------------------------------------
    rd_code <- lapply(
      roxygen2::roclet_process(
        roxygen2::rd_roclet() # roxygen process function
        , roxygen2:::order_blocks( # list of roxygen blocks with tokens
          lapply(which(lengths(tokens) != 0), function(idx) {
            structure( # roxygen blocks with tokens
              list(
                tags = roxygen2:::parse_description(roxygen2:::parse_tags(tokens[[idx]])) # roxygen rd tags
                , file = component_files$filename[[idx]],
                object = structure(
                  list(alias = as.character(rev(as.list(expr[[idx]][[2]]))[[1]])),
                  class = c("function", "object")
                )
              ) # method name -> need for extra alias
              ,
              class = "roxy_block"
            )
          })
        ) # roxygen tags
        , component # source_environment
        , dirname(component_files$filename[[idx]])
      ),
      format
    ) # function

    rd_files <- vapply(names(rd_code), function(name) {
      con <- file(sprintf("%s%s%s", man_dir, .Platform$file.sep, name), open = "w")
      on.exit(close(con), add = TRUE)
      writeLines(text = rd_code[[name]], con = con)
      name
    }, character(1L))

    saveRDS(component,
      file = sprintf(
        "%s%s%s.rds",
        inst_dir,
        .Platform$file.sep,
        component_files$filename_without_extension[[idx]]
      ),
      compress = FALSE
    )

    srcfile$filename
  }, character(1L))

  invisible()
}
