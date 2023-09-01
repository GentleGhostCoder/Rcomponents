#' compileFunctions
#' @rdname compileFunctions
#' @name compileFunctions
#' @usage compileFunctions(object = parent.frame())
#' @param object nested object like environment / list / vector
#' @description wrapper of cmpfun function in compiler package to compile functions in a nested object like environment, list or vector
#' @keywords internal
compileFunctions <- function(object = parent.frame(), options = NULL){

  idx_function_object <-
    which(vapply(object, function(child_object){ is.function(child_object) }, logical(1L)))

  idx_has_multiple_object <-
    which(vapply(object, length, integer(1L), USE.NAMES = FALSE)>1)

  # compile functions
  if(is.environment(object)) {
    object_names <- names(object)
    idx_function_object <- object_names[idx_function_object]
    idx_has_multiple_object <- object_names[idx_has_multiple_object]
  }

  # compile functions
  vapply(idx_function_object,
    function(idx){ object[[idx]] <<- compiler::cmpfun(object[[idx]], options = options); TRUE },
    logical(1L), USE.NAMES = FALSE)

  if(!length(idx_has_multiple_object)) return(invisible(object)) # return if no more nested

  # compile functions
  if(is.environment(object)) idx_has_multiple_object <- names(object)[idx_has_multiple_object]

  vapply(idx_has_multiple_object,
    function(idx){ object[[idx]] <<- compileFunctions(object[[idx]]); TRUE },
    logical(1L), USE.NAMES = FALSE)

  return(invisible(object))
}
