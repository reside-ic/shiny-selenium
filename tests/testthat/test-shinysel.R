context("shinysel")

test_that("ui generation changes title", {
  dat <- shinysel_ui("string")
  tags <- dat[[3]]
  expect_equal(tags[[1]]$children[[1]][[2]]$children[[1]], "string")
})


test_that("test shiny application", {
  dr <- selenium_driver()

  app <- launch_shinysel("mytitle", 8005)
  dr$navigate(app$url)

  title <- dr$getTitle()[[1]]
  expect_equal(title, "mytitle")
})
