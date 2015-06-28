require('shiny')

shinyUI(fluidPage(
  br(),
  sidebarLayout(
    sidebarPanel(
      img(src ='assets/imgs/Oxfam_International_logo.svg'),
      h1('Twitter Tailored Tool'),
      p("Analysis of Tweets with certain hash."),
      uiOutput('hashSelector'),
      dateRangeInput("dateRange", "Date Range",
                     start = Sys.Date() - 31, end = Sys.Date()),
      p('Connect with Twitter and update database.'),
      actionButton("updateDb", "Update DataBase")
    ),
    mainPanel(
      tabsetPanel(
        tabPanel("Map", plotOutput('usersMapPlot')),
        tabPanel("Time evolution",
                 div(br(),uiOutput('freqText'),
                     plotOutput("freqPlot"))
                 ),
        tabPanel("Tweet-Retweet Network",
                 div(sliderInput("PercentageOfConnections",
                                 "Percentage Of Connections To Plot",
                                 0, 100, 10),
                     plotOutput('trtPlot'))),
        tabPanel("Basic Statistics",
                 div(
                   tableOutput('basicStat'),
                   tableOutput('basicStat2')
                   ## DT::dataTableOutput('basicStat')
                 )
                 ),
        tabPanel("Users",
                 div(
                   br(),
                   DT::dataTableOutput('trtNodes'),
                   br(),
                   downloadLink('downloadUsers', 'Download CSV')
                 )
                 ),
        tabPanel("Tweets",
                 div(
                   br(),
                   dataTableOutput('tweets'),
                   br(),
                   downloadLink('downloadTweets', 'Download CSV')
                 )
                 ),
        tabPanel("Locations",
                 dataTableOutput('locations')
                 )
      )
    )
  )
))
