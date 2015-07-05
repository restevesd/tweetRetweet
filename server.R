require('shiny')
require('DT')
source('RtweetsAnalytics.R')

DELTA.WORLD <- 0.2
DELTA.SPAIN <- 0.02

createTwitterModels() # follows schemas in config/db

shinyServer(function(input, output) {

  ## Updating DB

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
                selected = "#STOPDesigualdad")
  })

  output$oxfamImage <- renderImage({
    list(
        src = 'www/assets/imgs/Oxfam_International_logo.svg',
        filetype = "image/svg",
        alt = "Oxfam Logo"
      )
  })
  
  ## DF in memory
  tweets.df <- reactive({
    input$updateDb
    limitByDate(getTweetsFromDB(input$keyword, n.tweets=10000),
                input$dateRange[1], input$dateRange[2]+1)
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
    merge(tweets.sn, usersCoordinates.df(), all.x=TRUE)
  })

  tweetsCoordinatesDisturbed.df <- reactive({
    coords <- tweetsCoordinates.df()
    data.frame(lon=distrurb(coords$lon, delta()),
               lat=distrurb(coords$lat, delta()))
  })

  ## Map
  delta <- reactive({
    if (input$region=='Spain') {
      DELTA.SPAIN
    } else {
      DELTA.WORLD
    }
  })
    
  output$usersMapPlot <- renderPlot({
    usersMapPlot(tweetsCoordinatesDisturbed.df(), region=input$region)
  },  height = 600, width = 1000
  )

  ## Histogramas
  output$freqText <- renderUI({
    p(paste0('Time evolution of numbers of tweets with hash ', input$keyword,
            '. '))
  })

  output$tweetsHist <- renderPlot({
    tweetsHist(tweets.df(), byHours=input$histBinwidth)
  })

  output$actionsHis <- renderPlot({
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
  
  output$freqPlot <- renderPlot({
    freqPlotByTRT(tweets.df())
  })

  ## TRT
  output$trtPlot <- renderPlot({
    rt.graph <- tweetRetweetGraph(tweets.df())
    tweetRetweetPlot(rt.graph,
                     PercentageOfConnections=input$PercentageOfConnections/100)
  },  height = 600, width = 1000)

  
  ## Statistics
  output$basicStat <- renderTable({
    basicStatDf(tweets.df())
  })

  output$basicStat2 <- renderTable({
    users.df <- nodes.df()[c('Nodes', 'followersCount')]
    colnames(users.df) <- c('screenName', 'followersCount')
    basicStat2Df(tweets.df(), users.df)
  })

  ## Tweets
  output$tweets <- renderDataTable({
    tweets.df()
  })

  output$downloadTweets <- downloadHandler(
    filename = function() {
       paste('tweets-', Sys.Date(), '.csv', sep='')
    },
    content = function(file) {
      write.csv(tweets.df(), file)
    }
  )

  ## Users
  
  output$trtNodes <- DT::renderDataTable({
    ns.df <- nodes.df()
    DT::datatable(ns.df[order(-ns.df$Nretwitted),],
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

  ## TRT Eage list

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

  
  ## Coordinates
  
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

})
