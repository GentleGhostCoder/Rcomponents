#' .msgHandler
#' @rdname msgHandler
#' @name .msgHandler
#' @usage .msgHandler
#' @param expr Expression
#' @description Constant Vector for all message functions
#' @keywords internal
.msgHandler <- c("warning", "stop", "message", "packageStartupMessage",
  "gettext", "gettextf", "logMsg")

#' extractStrings
#' @rdname extractStrings
#' @name extractStrings
#' @usage extractStrings(expr)
#' @param expr Expression
#' @description extract Strings from R-Expression
#' @keywords internal
extractStrings <- function(expr){

  idx_character_object <- which(vapply(expr, is.character, logical(1L), USE.NAMES = FALSE))

  idx_has_multiple_object <- which(vapply(expr[-idx_character_object], length, integer(1L), USE.NAMES = FALSE)>1)

  if(!length(idx_has_multiple_object)){
    return(as.character(expr[idx_character_object]))
  }

  return(c(as.character(expr[idx_character_object]),
    unlist(lapply(idx_has_multiple_object, function(idx) {
      extractStrings(expr[[idx]])
    }))))

}

#' evalMsgId
#' @rdname evalMsgId
#' @name evalMsgId
#' @usage evalMsgId(expr)
#' @param expr Expression
#' @description extract MsgIds from R-Expressions by .msgHandler
#' @keywords internal
evalMsgId <- function(expr){

  expr <- substitute(expr)

  if(expr[[1]] %in% .msgHandler){

    if(length(expr)==1) return(NULL)

    extractStrings(expr)
  }

  idx_has_handler <- grep(paste0("(",.msgHandler,")",collapse = "|"),expr)

  if(!length(idx_has_handler)) return(NULL)

  extractStrings(expr[idx_has_handler])

}
