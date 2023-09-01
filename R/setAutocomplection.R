

#' setAutocompletion
#' @rdname setAutocompletion
#' @name setAutocompletion
#' @usage setAutocompletion()
#' @description List all existing Component files
#' @keywords internal
setAutocompletion <- function(){

# Autocompletion for import and update function -------------------------------------
    .rs.addJsonRpcHandler(
      "get_completions",
      patch::patch_function(.rs.rpc.get_completions,
        ".rs.getCompletionsEnvironmentVariables",
        # addition portion
        if (length(string) &&
            (("package:Rcomponents" %in% search() && string[[1]] == "importComponent") ||
                string[[1]] %in% c("Rcomponents$import","Rcomponents::import","Rcomponents::Rcomponents$import") ||
                ("package:Rcomponents" %in% search() && string[[1]] == "update") ||
                string[[1]] %in% c("Rcomponents$update","Rcomponents::update","Rcomponents::Rcomponents$update"))) {
          candidates <- getNamespace("Rcomponents")$Rcomponents$get$keywords()
          results <- .rs.selectFuzzyMatches(candidates, token)
          return(.rs.makeCompletions(
            token = token,
            results = results,
            quote = FALSE,
            type = .rs.acCompletionTypes$PACKAGE
          ))
        },
        chop_locator_to = 1,
        safely = TRUE
      )
    )

}
