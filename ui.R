require('shiny')

shinyUI(fluidPage(
    titlePanel('Tweet - Retweet'),
    sidebarLayout(
        sidebarPanel(
            textInput('keyword', "Keyword"),
            submitButton('Submit')
            ),
        mainPanel(
            textOutput("plot")
            )
        
        )
    ))
