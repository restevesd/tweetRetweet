require('shiny')
require('DT')
source('RtweetsAnalytics.R')

delta <- 0.2

createTwitterModels() # follows schemas in config/db

shinyServer(function(input, output) {

  ## Updating DB

  observeEvent(input$updateDb, {
    print('Updating db...')
    twitterOAuth()
    updateAllHashesWithUsers()
    print('...updating done.')
  })  

  ## Side Panel outputs
  
  output$hashSelector <- renderUI({
    selectInput("keyword", "Select hash",
                choices =  getAllHashes()$hash, 
                selected = "#R")
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

  nodes.df <- reactive({
    input$updateDb
    tweetRetweetNodesFull(tweetRetweetGraph(tweets.df()))
  })

  allLocations.df <- reactive({
    getAll('coordinates')
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
    data.frame(lon=distrurb(coords$lon, delta),
               lat=distrurb(coords$lat, delta))
  })

  ## Map

  output$usersMapPlot <- renderPlot({
    usersMapPlot(tweetsCoordinatesDisturbed.df())
  },  height = 600, width = 1000
  )

  
  output$freqText <- renderUI({
    p(paste0('Time evolution of numbers of tweets with hash ', input$keyword,
            '. '))
  })
  
  output$freqPlot <- renderPlot({
    freqPlotByTRT(tweets.df())
  })


  output$basicStat <- renderTable({
    basicStatDf(tweets.df())
  })

  output$basicStat2 <- renderTable({
    users.df <- nodes.df()[c('Nodes', 'followersCount')]
    colnames(users.df) <- c('screenName', 'followersCount')
    basicStat2Df(tweets.df(), users.df)
  })

  output$trtPlot <- renderPlot({
    rt.graph <- tweetRetweetGraph(tweets.df())
    tweetRetweetPlot(rt.graph,
                     PercentageOfConnections=input$PercentageOfConnections/100)
  },  height = 1000, width = 1000)

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
  
  output$locations <- renderDataTable({
    ## tweetsCoordinatesDisturbed.df()
    usersCoordinates.df()
  })

  output$downloadTweets <- downloadHandler(
    filename = function() {
       paste('locations-', Sys.Date(), '.csv', sep='')
    },
    content = function(file) {
      write.csv(usersCoordinates.df(), file)
    }
  )
  
})
