context("shinysel")

test_that("ui generation changes title", {
  dat <- shinysel_ui("string")
  tags <- dat[[3]]
  expect_equal(tags[[1]]$children[[1]][[2]]$children[[1]], "string")
})
