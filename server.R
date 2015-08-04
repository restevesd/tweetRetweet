require('leaflet')
require('shiny')
require('shinydashboard')
require('rCharts')
require('data.table')
require('reshape2')

require('DT')

source('RtweetsAnalytics.R')


DELTA.WORLD <- 0.2
DELTA.SPAIN <- 0.02

createTwitterModels() # follows schemas in config/db

shinyServer(function(input, output) {
  
  output$myChart1 <- renderChart2({
    dt1 <- tweets.dt()[,.(count=.N),
                       by=.(date=format(toDateTime(created), "%Y-%m-%d"),
                            isRetweet)]
    dt2 <- dcast(dt1, date ~ isRetweet, fill=0)
    colnames(dt2) <- c('date', 'Original', 'Retwitted')
    m1 <- mPlot(x = "date", y = c('Original', 'Retwitted'),
                type = "Line", data = dt2)
    m1$set(pointSize = 2, lineWidth = 1)
    return(m1)
  })

  output$myChart2 <- renderChart2({
    dt1 <- tweets.dt()[,.(count=.N),
                       by=.(date=format(toDateTime(created), "%Y-%m-%d"),
                            isRetweet)]
    dt2 <- dcast(dt1, date ~ isRetweet, fill=0)
    colnames(dt2) <- c('date', 'Original', 'Retwitted')
    m1 <- mPlot(x = "date", y = c('Original', 'Retwitted'),
                type = "Line", data = dt2)
    m1$set(pointSize = 2, lineWidth = 1)
    return(m1)
  })

  
  output$messageMenu <- renderMenu({
    dropdownMenu(
      type = "messages",
      messageItem(
        from = "Sales Dept",
        message = "Sales are steady this month."
      ),
      messageItem(
        from = "New User",
        message = "How do I register?",
        icon = icon("question"),
        time = "13:45"
      ),
      messageItem(
        from = "Support",
        message = "The new server is ready.",
        icon = icon("life-ring"),
        time = "2014-12-01"
      )
    )
  })

  ## ## Updating DB
  observeEvent(input$updateDb, {
    print('Connecting with Twitter and updating db...')
    twitterOAuth()
    updateAllHashesWithUsers()
    print('...updating done.')
  })  

  observeEvent(input$updateCoordinates, {
    print('Connectiong with google and updating db...')
    lookupAndAddCoordinates(nodes.df()$location)
    print('...updating done.')
  })  

  ## Side Panel outputs  
  output$hashSelector <- renderUI({
    selectInput("keyword", "Select hash",
                choices =  getAllHashes()$hash, 
                selected = getAllHashes()$hash[1])
  })

  ## output$oxfamImage <- renderImage({
  ##   list(
  ##       src = 'www/assets/imgs/Oxfam_International_logo.svg',
  ##       filetype = "image/svg",
  ##       alt = "Oxfam Logo"
  ##     )
  ## })
  
  ## DF in memory
  dateRange <- reactive({
    input$dateRange
  })
  
  tweets.df <- reactive({
    input$updateDb
    df <- data.frame()
    keyword <- input$keyword
    if (is.null(keyword)) {
      keyword <- getAllHashes()$hash[1]
    }
    df <- limitByDate(getTweetsFromDB(keyword, n.tweets=10000),
                        input$dateRange[1], input$dateRange[2]+1)
    df
  })

  tweets.dt <- reactive({
    data.table(tweets.df())
  })
  
  tweetsByScreenName.df <- reactive({
    tbs.df <- data.frame(table(by(tweets.df()$id, tweets.df()$screenName, length)))
    colnames(tbs.df) <- c("actionsNumber", "Freq")
    tbs.df
  })
  
  nodes.df <- reactive({
    input$updateDb
    tweetRetweetNodesFull(tweetRetweetGraph(tweets.df()))
  })

  trtEdgelist.df <- reactive({
    input$updateDb
    retweetsEdgelist(tweets.df())
  })
  
  allLocations.df <- reactive({
    getAll('coordinates')
  })

 
  coordinates.df <- reactive({
    input$updateDb
    subset(allLocations.df(), location %in% nodes.df()$location)
  })
  
  usersCoordinates.df <- reactive({
    usersLoc <- nodes.df()[c("Nodes", "location")]
    merge(usersLoc, allLocations.df(), all.x=TRUE)
  })

  tweetsCoordinates.df <- reactive({
    tweets.sn <- data.frame(Nodes=tweets.df()$screenName)
    coords <- merge(tweets.sn, usersCoordinates.df(), all.x=TRUE)
    coords <- coords[!is.na(coords$lon),]
  })

  tweetsCoordinatesDisturbed.df <- reactive({
    coords <- tweetsCoordinates.df()
    data.frame(lon=distrurb(coords$lon, delta()),
               lat=distrurb(coords$lat, delta()))
  })

  tweetsCoordinatesSP.df <- reactive({
    coords <- tweetsCoordinates.df()
    lonLat <- coords[c("lon", "lat")]
    sp::SpatialPointsDataFrame(lonLat, coords[c("Nodes")])
  })

  
  ## ## Map
  delta <- function(region='Spain') {
    if (region=='Spain') {
      DELTA.SPAIN
    } else {
      DELTA.WORLD
    }
  }

  output$usersMapPlot <- renderLeaflet({
    ## usersMapPlot(tweetsCoordinatesDisturbed.df(), region=input$region)
    ## leaflet(tweetsCoordinatesSP.df()) %>%
    ##   addTiles() %>%  # Add default OpenStreetMap map tiles
    ##   setView(lng = 0, lat = 40, zoom = 5) %>%
    ##   addCircleMarkers(
    ##     radius = 6,
    ##     color = "darkred",
    ##     stroke = FALSE, fillOpacity = 0.3
    ##   )
    leaflet() %>%
      addTiles() %>%  # Add default OpenStreetMap map tiles
      setView(lng = 0, lat = 40, zoom = 5) %>%
      addCircleMarkers(
        data=tweetsCoordinates.df()[c("lon", "lat")],
        radius = 6,
        color = "darkred",
        stroke = FALSE, fillOpacity = 0.3
      )
  }  
  )

  ## ## Histogramas
  output$freqText <- renderUI({
    h1(paste0('Tweets with hash ', input$keyword,
            ' from ', dateRange()[1], ' through ', dateRange()[2], '.'))
  })

  ## output$tweetsHist <- renderPlot({
  ##   tweetsHist(tweets.df(), byHours=input$histBinwidth)
  ## })

  actionsHisPlot <- reactive({
    tbs.df <- tweetsByScreenName.df()
    tbs1.freq <- sum(tbs.df[tbs.df$actionsNumber==1,2])
    tbs2.freq <- sum(tbs.df[tbs.df$actionsNumber %in% 2:4,2])
    tbs3.freq <- sum(tbs.df[tbs.df$actionsNumber %in% 5:10,2])
    tbs4.freq <- sum(tbs.df[!(tbs.df$actionsNumber %in% 1:10),2])
    aN <- factor(c('1','2-4', '5-10', '>10'), levels=c('1','2-4', '5-10', '>10'), ordered=TRUE)
    tbs2.df <- data.frame(actionsNumber=aN,
                          Freq=c(tbs1.freq, tbs2.freq, tbs3.freq, tbs4.freq))
    ggplot(tbs2.df, aes(actionsNumber, Freq)) + geom_bar(stat="identity") +
      theme_bw()
  })
  
  output$actionsHis <- renderPlot({
    actionsHisPlot()
  })
  
  output$freqPlot <- renderPlot({
    freqPlotByTRT(tweets.df())
  })

  output$chart1 <- renderChart({
    data(economics, package = "ggplot2")
    econ <- transform(economics, date = as.character(date))
    m1 <- mPlot(x = "date", y = c("psavert", "uempmed"), type = "Line", data = econ)
    m1$set(pointSize = 0, lineWidth = 1)
    m1
  })
  ## ## TRT
  output$trtPlot <- renderPlot({
    rt.graph <- tweetRetweetGraph(tweets.df())
    tweetRetweetPlot(rt.graph, PercentageOfConnections=input$PercentageOfConnections/100)
  })##,  height = "100%", width = "100%")

  
  ## Statistics
  output$basicStat <- renderTable({
    basicStatDf(tweets.df())
  })

  output$totalNrTweetsBox <- renderInfoBox({
    infoBox(
      "Total Number of Tweets",  basicStatDf(tweets.df())[1,1], icon = icon("twitter"),
      color = "green"
    )
  })

  output$nrOrginalTweetsBox <- renderInfoBox({
    infoBox(
      "Number of orginal tweets",  basicStatDf(tweets.df())[2,1], icon = icon("long-arrow-right"),
      color = "green"
    )
  })

  output$nrReweetsBox <- renderInfoBox({
    infoBox(
      "Number of retweets",  basicStatDf(tweets.df())[3,1], icon = icon("retweet"),
      color = "green"
    )
  })

  basicStat2 <- reactive({
    users.df <- nodes.df()[c('Nodes', 'followersCount')]
    colnames(users.df) <- c('screenName', 'followersCount')
    basicStat2Df(tweets.df(), users.df)
  })
  
  output$basicStat2 <- renderTable({
    basicStat2()
  })

  output$reachNr <- renderInfoBox({
    infoBox(
      "Reach",  basicStat2()[1,1], icon = icon("comments"),
      color = "orange"
    )
  })

  output$audienceNr <- renderInfoBox({
    infoBox(
      "Audience",  basicStat2()[1,2], icon = icon("users"), 
      color = "orange"
    )
  })

  
  basicStat3 <- reactive({
    basicStat3Df(tweetRetweetGraph(tweets.df()))
  })
  
  output$basicStat3 <- renderTable({
    basicStat3()
  })

  output$DiameterBox <- renderInfoBox({
    infoBox(
      "Diameter of graph", basicStat3()[1,1], icon = icon("arrows-alt"),
      color = "green"
    )
  })

  output$AveragePathLengthBox <- renderInfoBox({
    infoBox(
      "Average Path Length", basicStat3()[1,2], icon = icon("arrows-h"),
      color = "green"
    )
  })

  output$DensityBox <- renderInfoBox({
    infoBox(
      "Density", basicStat3()[1,3], icon = icon("cubes"),
      color = "green"
    )
  })

  output$ClustersBox <- renderInfoBox({
    infoBox(
      "Number of Cluster", basicStat3()[1,4], icon = icon("ellipsis-h"),
      color = "green"
    )
  })

  ## Tweets
  output$tweets <- renderDataTable({
    tweets.df()[c("text", "screenName")]
  })

  output$downloadTweets <- downloadHandler(
    filename = function() {
       paste('tweets-', Sys.Date(), '.csv', sep='')
    },
    content = function(file) {
      write.csv(tweets.df(), file)
    }
  )

  ## ## Users
  
  output$trtNodes <- DT::renderDataTable({
    ns.df <- nodes.df()[c("Nodes", "Nretwitted","Nretweets", "PageRank","location")]
    DT::datatable(ns.df[order(-ns.df$Nretwitted),],
                  options = list(lengthChange = FALSE))
  })

  output$usersNrAcctions <- DT::renderDataTable({
    DT::datatable(tweets.dt()[,.(Number_of_actions=.N), by=screenName][order(-Number_of_actions)],
                  options = list(lengthChange = FALSE))
  })

  
  output$downloadUsers <- downloadHandler(
    filename = function() {
       paste('users-', Sys.Date(), '.csv', sep='')
    },
    content = function(file) {
      write.csv(nodes.df(), file)
    }
  )

  ## ## TRT Eage list

  output$trtEdgelist <- DT::renderDataTable({
    DT::datatable(trtEdgelist.df())
  })

  output$downloadTrtEdgelist <- downloadHandler(
    filename = function() {
       paste('trtEdgelist-', Sys.Date(), '.csv', sep='')
    },
    content = function(file) {
      write.csv(trtEdgelist.df(), file)
    }
  )

  
  ## ## Coordinates
  
  output$coordinates <- renderDataTable({
    ## tweetsCoordinatesDisturbed.df()
    coordinates.df()
  })
  
  output$downloadCoordinates <- downloadHandler(
    filename = function() {
       paste('coordinates-', Sys.Date(), '.csv', sep='')
    },
    content = function(file) {
      write.csv(coordinates.df(), file)
    }
  )

  output$downloadReport <- downloadHandler(
    filename = function() {
      paste('my-report', sep = '.', switch(
        input$format, PDF = 'pdf', HTML = 'html', Word = 'docx'
      ))
    },

    content = function(file) {
      if (input$format=='PDF') {
        filename = 'reportPDF.Rmd'
      } else {
        filename = 'report.Rmd'
      }
      src <- normalizePath(filename)

      # temporarily switch to the temp dir, in case you do not have write
      # permission to the current working directory
      owd <- setwd(tempdir())
      on.exit(setwd(owd))
      file.copy(src, filename)
      require(rmarkdown)
      if (input$format=='PDF')
      {
        print("Preparing pdf...")
        out <- render(filename, pdf_document())
      } else {
        out <- render(filename, switch(
          input$format,
          PDF = pdf_document(), HTML = html_document(), Word = word_document()
          ))
      }
      file.rename(out, file)
    }
  )

  
})
