#' listComponentFiles
#' @rdname listComponentFiles
#' @name listComponentFiles
#' @usage listComponentFiles()
#' @description List all existing components in packages
#' @keywords internal
listComponentFiles <- function() {

  search_paths <- sprintf("%s%s",
    list.files(.libPaths(), all.files = FALSE, full.names = TRUE, ignore.case = TRUE, include.dirs = TRUE),
    "/components")

  return(list.files(
    search_paths[dir.exists(search_paths)], pattern = ".rds", all.files = TRUE,
    full.names = TRUE, recursive = TRUE, ignore.case = TRUE, include.dirs = TRUE))

}

