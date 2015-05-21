require('shiny')

shinyUI(fluidPage(
    titlePanel('Tweet - Retweet'),
    sidebarLayout(
        sidebarPanel(
            textInput('keyword', "Keyword", value="#python"),
            submitButton('Submit')
            ),
        mainPanel(
            DT::dataTableOutput('tbl')
            )
        )
    ))
