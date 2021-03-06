#' Build a character vector or list with variable-based
#' string formatting
#'
#' The \code{rprintv} function applies variable-based formatter to
#' transform the given character vector to specific texts with
#' named variables replaced by a given set of values in correct
#' formats.
#'
#' @param .format The character vector or list to be transformed
#' @param ... The arguments that specify the set of values to be
#'   placed
#' @param .envir The environment in which variables are searched
#' if not explictly specified. Use \code{emptyenv()} to disable
#' this behavior. This feature only works for variable-name
#' formatting.
#' @importFrom stringi stri_extract_all_regex
#' @importFrom stringi stri_replace_all_regex
#' @export
#' @examples
#' \dontrun{
#'
#' # Format a single-entry character vector with variable mechanism
#' rprintf('Hello, $name', name='world')
#' rprintf('$name ($age years old)',name='Ken',age=24)
#' rprintf('He is $age but has a height of $height:.2fcm',age=18,height=190)
#' rprintf('$a, $b:.1f, $c:+.2f, $b, $a:.0f',a=1.56,b=2.34,c=3.78)
#' }
#'
rprintv <- function(.format, ..., .envir = parent.frame()) {
  args <- makelist(...)
  x <- gsub("%", "%%", .format, fixed = TRUE)
  xs <- unlist(stringi::stri_extract_all_regex(x, "(?<!\\$)\\$[\\w\\._]+(:[\\s\\+\\-\\#\\.\\d]*\\w)?"))

  if (length(xs) == 1L && is.na(xs)) {
    pass3 <- x
  } else {
    xss <- stringi::stri_replace_all_regex(xs, "(?<!\\$)\\$([\\w\\._]+)(:[\\s\\+\\-\\#\\.\\d]*\\w)?", "$1")
    pass1 <- stringi::stri_replace_all_regex(x, "(?<!\\$)\\$([\\w\\._]+):(?!\\$)(?!:+)([\\s\\+\\-\\#\\.\\d]*\\w)?", "%$2")
    pass2 <- stringi::stri_replace_all_regex(pass1, "(?<!\\$)\\$([\\w\\._]+)", "%s")
    params <- eval(as.call(c(quote(list), lapply(xss, as.symbol))), args, .envir)
    pass3 <- do.call(sprintf, c(list(pass2), params))
  }

  result <- gsub("\\$\\$", "$", pass3)
  gsub("::", ":", result, fixed = TRUE)
}
