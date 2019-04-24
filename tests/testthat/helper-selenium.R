## Cache to store persistent state in
.selenium <- new.env(parent = emptyenv())

## Create a selenium driver (if we have not already done so), skipping
## gracefully if it is not possible
selenium_driver <- function() {
  testthat::skip_on_cran()
  testthat::skip_if_not_installed("RSelenium")
  ## No point running a test if we can't launch the application either
  testthat::skip_if_not_installed("callr")
  if (is.null(.selenium$driver)) {
    .selenium$driver <- tryCatch({
      dr <- RSelenium::remoteDriver()
      dr$open(silent = TRUE)
      dr
    }, error = function(e) testthat::skip(e$message))
    .selenium$port <- counter(8000)
  }
  .selenium$driver
}


## This version is totally built around our demo app - we'll need to
## generalise this later.
launch_shinysel <- function(title) {
  port <- .selenium$port()
  args <- list(title, port)

  process <- callr::r_bg(function(title, port) {
    options(error = traceback)
    app <- shinysel::shinysel(title)
    shiny::runApp(app, port = port)
  }, args = args)

  url <- paste0("http://localhost:", port)
  ## It will take a short while before the server is responsive to
  ## connections, so we'll poll here until there's a successful read
  ## from this port.
  retry_until_server_responsive(url)

  list(process = process, port = port, url = url)
}


## Generic retry function - evaluate the function 'f' with no
## arguments with a break of 'poll' between evaluations until it
## returns TRUE, or until 'timeout' seconds, in which case throw an
## error (using the string 'description' to make it informative.
## Typically we will use wrappers around this.
retry <- function(f, explanation, timeout = 5, poll = 0.1) {
  give_up <- Sys.time() + timeout
  repeat {
    if (f()) {
      break
    }
    if (Sys.time() > give_up) {
      stop(sprintf("Timeout exceeded before %s", explanation))
    }
    Sys.sleep(poll)
  }
}


## Evaluate the function 'f' until it does not throw an error.
retry_until_no_error <- function(f, ...) {
  g <- function() {
    tryCatch({
      suppressWarnings(f())
      TRUE
    }, error = function(e) FALSE)
  }
  retry(g, ...)
}


## Try and read from the shiny url until it becomes responsive.
retry_until_server_responsive <- function(url, ...) {
  retry_until_no_error(function() readLines(url),
                       "shiny server is responsive")
}


counter <- function(start) {
  x <- as.integer(start)
  function() {
    x <<- start + 1L
    x
  }
}
