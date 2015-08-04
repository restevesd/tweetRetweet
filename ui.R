require('leaflet')
require('shinydashboard')
require('RColorBrewer')
require('rCharts')

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
      menuItem("Users", tabName = "users", icon = icon("users")),
      menuItem("Downloads", tabName = "downloads", icon = icon("download")),
      menuItem("Updates", tabName = "updates", icon = icon("refresh"))
    )
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
      box(
        title="Time evolution", status = "primary", solidHeader = TRUE,
        width = 8,
        showOutput("myChart1", 'morris') 
      ),
      box(
        title="Histogram", status = "primary", solidHeader = TRUE, width=4,
        tags$b("Number of users that made certian number of actions."),
        plotOutput("actionsHis")
      )
    ),

    fluidRow(
      box(
        width=12,
        DT::dataTableOutput('tweets'),
        br(),
        downloadLink('downloadTweets', 'Download CSV')
      )
    )
  )



connectionsTab <- 
  tabItem(
    tabName = "connections",
    fluidRow(
      infoBoxOutput("DiameterBox"),
      infoBoxOutput("AveragePathLengthBox"),
      infoBoxOutput("DensityBox"),
      infoBoxOutput("ClustersBox")
    ),
    fluidRow(
      box(
        title="Tweet - Retweet connections", status = "primary", solidHeader = TRUE, 
        width=8,
        plotOutput('trtPlot', height=600)
        ## absolutePanel(
        ##   class = "controls",
        ##   top = 100, right = 50,
        ## )
      ),
      box(
        width=4,
        sliderInput(
          "PercentageOfConnections",
          "Percentage Of Connections To Plot",
          0, 100, 50)
      )

    ),
    fluidRow(
      box(
        title="Tweet - Retweet connections", status = "primary", solidHeader = TRUE, 
        div(
          br(),
          DT::dataTableOutput('trtEdgelist'),
          br(),
          downloadLink('downloadTrtEdgelist', 'Download CSV')
        )
        
      )
    )
  )

usersTab <- 
  tabItem(
    tabName = "users",
    fluidRow(
      infoBoxOutput("reachNr"),
      infoBoxOutput("audienceNr")
    ),
    fluidRow(
      box(
        title="Users - Infuence", status = "primary", solidHeader = TRUE, 
        width=12,
        div(
          br(),
          DT::dataTableOutput('trtNodes'),
          br(),
          downloadLink('downloadUsers', 'Download CSV')
        )        
      )
    ),
    fluidRow(
      box(
        title="Users - Actions", status = "primary", solidHeader = TRUE, 
        div(
          br(),
          DT::dataTableOutput('usersNrAcctions')
        )
      ),
      box(
        title="Coordinates", status = "primary", solidHeader = TRUE, 
        div(
          br(),
          DT::dataTableOutput('coordinates'),
          br(),
          downloadLink('downloadCoordinates', 'Download CSV')
        )

      )
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
    usersTab,
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
##         tabPanel("TRTEdgelist",
##                  ),
##         tabPanel("Coordinates",
##                  )
##       )
##     )
##   )
## )

