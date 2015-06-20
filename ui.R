require('shiny')

shinyUI(fluidPage(
  br(),
  sidebarLayout(
    sidebarPanel(
      img(src ='assets/imgs/Oxfam_International_logo.svg'),
      h1('DataTweets'),
      p("Analysis of Tweets with certain hash."),
      uiOutput('hashSelector'),
      dateRangeInput("dateRange", "Date Range",
                     start = Sys.Date() - 14, end = Sys.Date()),
      p('Connect with Twitter and update database.'),
      actionButton("updateDb", "Update DataBase")
    ),
    mainPanel(
      tabsetPanel(
        tabPanel("Time evolution",
                 div(br(),uiOutput('freqText'),
                     plotOutput("freqPlot"))
                 ),
        tabPanel("Basic Statistics", DT::dataTableOutput('basicStat')),
        tabPanel("Users Statistics",
                 DT::dataTableOutput('trtNodes')),
        tabPanel("Tweet-Retweet Network",
                 div(sliderInput("PercentageOfConnections",
                                 "Percentage Of Connections To Plot",
                                 0, 100, 10),
                     plotOutput('trtPlot')))
      )
    )
  )
))
