library(shiny)

source("crosswalk_config.R")
source("get_changes.R")

ui <- fluidPage(
  titlePanel("Item Lookup"),

  sidebarLayout(
    sidebarPanel(
      textInput(
        inputId = "key",
        label = "Enter lookup value",
        placeholder = "ID or name"
      ),
      actionButton("lookup", "Look up")
    ),

    mainPanel(
      verbatimTextOutput("result"),
      textOutput("error")
    )
  )
)

server <- function(input, output, session) {

  result <- eventReactive(input$lookup, {
    tryCatch(
      get_changes(input$key),
      error = function(e) e
    )
  })

  output$result <- renderPrint({
    res <- result()
    if (inherits(res, "error")) return(NULL)
    res
  })

  output$error <- renderText({
    res <- result()
    if (inherits(res, "error")) res$message else ""
  })
}

shinyApp(ui, server)
