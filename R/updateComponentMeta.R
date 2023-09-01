#' updateComponentMeta
#' @rdname updateComponentMeta
#' @name updateComponentMeta
#' @usage updateComponentMeta()
#' @description Sets all Meta Information Data
#' @keywords internal
updateComponentMeta <- function(){

  eval(substitute({

    HOME <- Sys.getenv("RCOMPONENTS_HOME","~/.Rcomponents")

    # meta vectors ----------------------------------------------------------------------

    component_files <- Rcomponents:::listComponentFiles()
    component_status <- rep(FALSE, length(component_files))
    component_packages <-gsub("^.*/(.+)/components.*$","\\1",component_files)
    component_features <- gsub("^/","",gsub("^.*components(.+)/.*$","\\1",component_files))
    component_names <- gsub(".*/(.+).rds$","\\1",component_files)
    component_keywords <- sprintf("%s%s%s",component_packages,".",component_names)
    component_ids <- seq_len(length(component_keywords))
    component_status <- rep(FALSE, length(component_keywords))

  }), envir = getNamespace("Rcomponents"))

}
