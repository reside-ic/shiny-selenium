shinysel <- function(title) {
  shiny::shinyApp(shinysel_ui(title), shinysel_server)
}


shinysel_ui <- function(title) {
  shiny::fluidPage(
    shiny::titlePanel(title),
    shiny::sidebarLayout(
      shiny::sidebarPanel(
        shiny::numericInput("obs", "Number of observations", 10),
        shiny::actionButton("go", "Go")),
      shiny::mainPanel(
        shiny::plotOutput("plot"))))
}


shinysel_server <- function(input, output, session) {
  shiny::observeEvent(
    input$go,
    output$plot <- renderPlot({
      n <- input$obs
      x <- runif(n)
      y <- runif(n)
      plot(x, y)
    }))
}
