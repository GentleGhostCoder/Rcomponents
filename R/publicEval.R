#' publicEval
#' @rdname publicEval
#' @name publicEval
#' @usage publicEval({...})
#' @description Environment with private (hidden) and public Sections
#' @keywords internal
publicEval <- function(expr, parentEnv = parent.frame()){

  public <- new.env(parent = parentEnv)
  self <- new.env(parent = public)
  private <- new.env(parent = self)
  self$self <- self
  self$public <- public
  self$private <- private

  .Internal(eval(substitute(expr)
    , envir = private, enclos = .Primitive('baseenv')()))

  object_names <- names(self)
  object_names <- object_names[!(object_names%in%c("public","private","self"))]

  if(length(object_names))
    invisible(
      mapply(assign, object_names, mget(object_names, self), list(public),
        SIMPLIFY = FALSE, USE.NAMES = FALSE) )

  return(invisible(public))
}
