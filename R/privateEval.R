#' privateEval
#' @rdname privateEval
#' @name privateEval
#' @usage privateEval({...})
#' @description Environment with private (hidden) and public Sections
#' @keywords internal
privateEval <- function(expr, parentEnv = parent.frame()) {
    public <- new.env(parent = parentEnv)
    private <- new.env(parent = public)
    private$self <- private
    private$public <- public
    private$private <- private

    .Internal(eval(substitute(expr)
      , envir = private, enclos = .Primitive('baseenv')()))

    return(invisible(public))

}
