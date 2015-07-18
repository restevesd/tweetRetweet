require('shinydashboard')

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
      radioButtons('format', 'Document format', c('PDF', 'HTML', 'Word'),
                   inline = TRUE),
      downloadButton('downloadReport')
    ),
    mainPanel(
      tabsetPanel(
        tabPanel("Map",
                 div(
                   br(),
                   selectInput("region", "Select region",
                               choices =  c('World', 'Spain'),
                               selected = "World"),
                   plotOutput('usersMapPlot'))),
        tabPanel("Histograms",
                 div(
                   br(),
                   sliderInput("histBinwidth",
                               "Binwidth of bars (in hours)",
                               1, 7*24, 3),
                   ##plotOutput("tweetsHist"),
                   plotOutput("actionsHis"),
                   uiOutput('freqText'),
                   plotOutput("freqPlot")
                 )
                 ),
        tabPanel("TRT Network",
                 div(sliderInput("PercentageOfConnections",
                                 "Percentage Of Connections To Plot",
                                 0, 100, 10),
                     plotOutput('trtPlot'))),
        tabPanel("Statistics",
                 div(
                   br(),
                   tableOutput('basicStat'),
                   tableOutput('basicStat2'),
                   tableOutput('basicStat3')
                   ## DT::dataTableOutput('basicStat')
                 )
                 ),
        tabPanel("Tweets",
                 div(
                   p('Connect with Twitter and update database.'),
                   actionButton("updateDb", "Update DataBase"),
                   br(),
                   br(),
                   DT::dataTableOutput('tweets'),
                   br(),
                   downloadLink('downloadTweets', 'Download CSV')
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
        tabPanel("TRTEdgelist",
                 div(
                   br(),
                   DT::dataTableOutput('trtEdgelist'),
                   br(),
                   downloadLink('downloadTrtEdgelist', 'Download CSV')
                 )
                 ),
        tabPanel("Coordinates",
                 div(
                   p('Connect with Google and update database of coordinates.'),
                   actionButton("updateCoordinates", "Update DataBase"),
                   br(),
                   br(),
                   DT::dataTableOutput('coordinates'),
                   br(),
                   downloadLink('downloadCoordinates', 'Download CSV')
                 )
                 )
      )
    )
  )
))
