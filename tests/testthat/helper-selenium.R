## Cache to store persistent state in
.selenium <- new.env(parent = emptyenv())

## Create a selenium driver (if we have not already done so), skipping
## gracefully if it is not possible
selenium_driver <- function() {
  testthat::skip_on_cran()
  testthat::skip_if_not_installed("RSelenium")
  if (is.null(.selenium$driver)) {
    .selenium$driver <- tryCatch({
      dr <- RSelenium::remoteDriver()
      dr$open(silent = TRUE)
      dr
    }, error = function(e) testthat::skip(e$message))
  }
  .selenium$driver
}
