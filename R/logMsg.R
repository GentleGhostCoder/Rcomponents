#' logMsg
#' @rdname logMsg
#' @name logMsg
#' @usage logMsg
#' @param ... Message objects
#' @description ligthweigth function to write msg into a connection
#' @details default connection is stderr and the first argument for the title
#' @keywords internal
logMsg <- function(..., title = paste0(..1, collapse = " "), con = stderr()) {
  msg <- list(...)[-1]
  sep <- ifelse(any(vapply(msg, length, integer(1L))>1),"\n| - "," ")
  sink(con)
  cat(
    paste0(Sys.getpid()," - ",title," [",as.character(Sys.time()),"]",sep,
      paste(msg,collapse=sep), collapse = sep), "\n")
  sink()
}
