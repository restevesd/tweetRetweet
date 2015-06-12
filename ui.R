require('shiny')

shinyUI(fluidPage(
  titlePanel('Tweet - Retweet'),
  sidebarLayout(
    sidebarPanel(
      uiOutput('hashSelector'),
      actionButton("updateDb", "Update DB")
    ),
    mainPanel(
      tabsetPanel(
        tabPanel("The graph", plotOutput("plot")),
        tabPanel("The table",
                 DT::dataTableOutput('posterReposter')),
        tabPanel("Random number",textOutput('rnumber'))
      )
            )
        )
    ))

