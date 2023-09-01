# # .datatable.aware = TRUE
# # .future_data = TRUE
# #' import
# #' @rdname import
# #' @name import
# #' @usage import()
# #' @description import
# #' @export
# importComponent <- function() {
#   rstudioapi::getActiveDocumentContext()
#   # assign(".onLoad",function(...) {
#   #   assign("bla","blub",envir = getNamespace(pkgload::pkg_name()))
#   # }, envir = parent.frame())
# }
#
# .onLoad <- function(libname, pkgname) {
#
#   # if session_status is FALSE package is imported while building process
#   session_status <- tryCatch(rstudioapi::isAvailable(), error = function(cond) {
#     return(FALSE)
#   })
#
#   if (session_status) {
#     setAutocompletion()
#
#     return(NULL)
#   }
#
#   setHook("rstudio.sessionInit", function(newSession) {
#     setAutocompletion()
#   }, action = "append")
#
#   message("***building components")
#   try(evalComponents(), silent = TRUE)
#
#
#   # privateEval({
#
#   # # load cached components ------------------------------------------------------------
#
#   #     invisible(
#   #       lapply(which(component_keywords %in%
#   #           gsub(".rds","",list.files(HOME, pattern = ".rds", all.files = FALSE,
#   #         full.names = FALSE, recursive = TRUE, ignore.case = TRUE, include.dirs = TRUE))),
#   #       function(id) {
#   #         components[[id]] <<- readRDS(sprintf("%s/%s.rds",HOME,component_keywords[id]))
#   #         component_status[id] <<- components[[id]]$.singleton
#   #       }))
#
#   # # functions -------------------------------------------------------------------------
#   #
#   #     # public index for components
#   #     get$keywords <- function() component_keywords
#   #     get$components <- function() components
#   #     get$component_status <- function() component_status
#   #
#   #
#   #     public$refresh <- function(component = NULL){
#   #       if(!is.integer(substitute(component)) || !(substitute(component) %in% component_ids))
#   #         id <- which(component_keywords == substitute(component))
#   #
#   #       if(length(id)){
#   #
#   #         return(eval(substitute(eval(quote(components[[id]]$.onImport()))),components[[id]]$data))
#   #       }
#   #
#   #       return(invisible(lapply(components, function(component) component$.onImport())))
#   #     }
#   #
#   #     public$import <- function(component){
#   #       if(!is.integer(substitute(component)) || !(substitute(component) %in% component_ids))
#   #         id <- which(component_keywords == substitute(component))
#   #
#   #       if(length(id) && !component_status[id]) {
#   #         components[[id]] <<- readRDS(component_files[id])
#   #         component_status[id] <<- components[[id]]$.singleton
#   #         refresh(id)
#   #       }
#   #
#   #       return(components[[id]]$data)
#   #
#   #     }
#   #
#   #     public$save <- function(component) {
#   #
#   #       id <- ifelse(exists(".self", envir = parent.frame()),
#   #         which(component_keywords ==
#   #             environmentName(get(".self", envir = parent.frame()))),
#   #         which(component_keywords == substitute(component)))
#   #
#   #       if(length(id))
#   #         saveRDS(components[[id]], sprintf("%s/%s.rds",HOME,component_keywords[id]))
#   #
#   #       return(invisible(NULL))
#   #     }
#   #
#   # })
#   #
#   #   importComponent <<- Rcomponents$import
#   #   saveComponent <<- Rcomponents$save
#   #   refreshComponent <<- Rcomponents$refresh
# }
