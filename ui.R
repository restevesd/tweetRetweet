require('leaflet')
require('shinydashboard')
library(RColorBrewer)

header <-
  dashboardHeader(
    title='Twitter Tailored Tool'##,
    ##dropdownMenuOutput("messageMenu")
  )

sidebar <-   
  dashboardSidebar(
    ## Sidebar content
    sidebarMenu(
      menuItem("Dashboard", tabName = "dashboard", icon = icon("dashboard")),
      menuItem("Statistics", tabName = "statistics", icon = icon("bar-chart")),
      menuItem("Connections", tabName = "connections", icon = icon("exchange")),
      menuItem("Downloads", tabName = "downloads", icon = icon("download")),
      menuItem("Updates", tabName = "updates", icon = icon("refresh"))
    )
    ## sidebarMenu(
    ##   menuItem("Dashboard", tabName = "dashboard", icon = icon("dashboard")),
    ##   menuItem("Widgets", tabName = "widgets", icon = icon("th"))
    ## )
  )


dashboardTab <-
  ## First tab content
  tabItem(
    tabName = "dashboard",
    ## selectInput("region", "Select region",
    ##            choices =  c('World', 'Spain'),
    ##            selected = "World"),
    leafletOutput('usersMapPlot', height=600),
    absolutePanel(
      class = "controls",
      top = 100, right = 50,
      br(),
      img(src ='assets/imgs/Oxfam_International_logo.svg'),
      uiOutput('hashSelector'),
      dateRangeInput("dateRange", "Date Range",
                     start = Sys.Date() - 31, end = Sys.Date())
    )
  )

statisticsTab <-
  ## First tab content
  tabItem(
    tabName = "statistics",
    uiOutput('freqText'),
    br(),
    fluidRow(
      infoBoxOutput("totalNrTweetsBox"),
      infoBoxOutput("nrOrginalTweetsBox"),
      infoBoxOutput("nrReweetsBox")
    ),
    fluidRow(
      infoBoxOutput("reachNr"),
      infoBoxOutput("audienceNr")
    ),

    fluidRow(
      box(
        title="Time evolution", status = "primary", solidHeader = TRUE,
        plotOutput("freqPlot")
      ),
      box(
        title="Histogram", status = "primary", solidHeader = TRUE,
        tags$b("Number of users that made certian number of actions."),
        plotOutput("actionsHis")
      )
    ),
    fluidRow(
      box(
        tableOutput('basicStat3')
      )
    )
  )



connectionsTab <- 
  tabItem(
    tabName = "connections",
    plotOutput('trtPlot', height=600),
    absolutePanel(
      class = "controls",
      top = 100, right = 50,
      sliderInput(
        "PercentageOfConnections",
        "Percentage Of Connections To Plot",
        0, 100, 30)
    )
  )


downloadsTab <-
  tabItem(
    tabName = "downloads",
    fluidRow(
      box(
        width=4,
        radioButtons('format', 'Document format', c('PDF', 'HTML', 'Word'),
                     inline = TRUE),
        downloadButton('downloadReport')
      )
    )
  )

updateTab <-
  tabItem(
    tabName = "updates",
    fluidRow(
      box(
        width=6,
        p('Connect with Twitter and update database.'),
        actionButton("updateDb", "Update DataBase")
      ),
      box(
        width=6,
        p('Connect with Google and update database of coordinates.'),
        actionButton("updateCoordinates", "Update DataBase")
      )
    )
  )



body <-   dashboardBody(
  tags$head(
    ## Include our custom CSS
    includeCSS("styles.css")
  ),
  tabItems(
    dashboardTab,
    statisticsTab,
    connectionsTab,
    downloadsTab,
    updateTab
    
  )
)


dashboardPage(
  skin = "black",
  header,
  sidebar,
  body
)

## fluidPage(
##   br(),
##   sidebarLayout(
##     sidebarPanel(
##     ),
##     mainPanel(
##       tabsetPanel(
##         tabPanel("Map",
##                  ),
##         tabPanel("Histograms",
##                  div(
##                    br(),
##                    sliderInput("histBinwidth",
##                                "Binwidth of bars (in hours)",
##                                1, 7*24, 3),
##                    ##plotOutput("tweetsHist"),
##                    plotOutput("actionsHis"),
##                    uiOutput('freqText'),
##                    plotOutput("freqPlot")
##                  )
##                  ),
##         tabPanel("TRT Network",
##                  div(sliderInput("PercentageOfConnections",
##                                  "Percentage Of Connections To Plot",
##                                  0, 100, 10),
##                      plotOutput('trtPlot'))),
##         tabPanel("Statistics",
##                  div(
##                    br(),
##                    tableOutput('basicStat'),
##                    tableOutput('basicStat2'),
##                    tableOutput('basicStat3')
##                    ## DT::dataTableOutput('basicStat')
##                  )
##                  ),
##         tabPanel("Tweets",
##                  div(
##                    br(),
##                    br(),
##                    DT::dataTableOutput('tweets'),
##                    br(),
##                    downloadLink('downloadTweets', 'Download CSV')
##                  )
##                  ),
##         tabPanel("Users",
##                  div(
##                    br(),
##                    DT::dataTableOutput('trtNodes'),
##                    br(),
##                    downloadLink('downloadUsers', 'Download CSV')
##                  )
##                  ),
##         tabPanel("TRTEdgelist",
##                  div(
##                    br(),
##                    DT::dataTableOutput('trtEdgelist'),
##                    br(),
##                    downloadLink('downloadTrtEdgelist', 'Download CSV')
##                  )
##                  ),
##         tabPanel("Coordinates",
##                  div(
##                    br(),
##                    br(),
##                    DT::dataTableOutput('coordinates'),
##                    br(),
##                    downloadLink('downloadCoordinates', 'Download CSV')
##                  )
##                  )
##       )
##     )
##   )
## )

