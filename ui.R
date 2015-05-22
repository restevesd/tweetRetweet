require('shiny')

shinyUI(fluidPage(
    titlePanel('Tweet - Retweet'),
    sidebarLayout(
        sidebarPanel(
            textInput('keyword', "Keyword", value="#oxfam"),
            sliderInput("nMax", "Maximum tweeters", 10, 2000, 50),
            submitButton('Submit')
            ),
        mainPanel(
            tabsetPanel(
                tabPanel("The graph", plotOutput("plot")),
                tabPanel("The table",
                         DT::dataTableOutput('posterReposter'))
                )
            )
        )
    ))

