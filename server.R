require('shiny')
require('DT')
source('RtweetsAnalytics.R')

createTwitterModels() # follows schemas in config/db

shinyServer(function(input, output) {

  output$oxfamImage <- renderImage({
    list(
        src = 'www/assets/imgs/Oxfam_International_logo.svg',
        filetype = "image/svg",
        alt = "Oxfam Logo"
      )
  })
  
  observeEvent(input$updateDb, {
    print('Updating db...')
    twitterOAuth()
    updateAllHashesWithUsers()
    print('...updating done.')
  })
  
  output$hashSelector <- renderUI({
    selectInput("keyword", "Select hash",
                choices =  getAllHashes()$hash, 
                selected = "#R")
  })

  tweets.df <- reactive({
    input$updateDb
    limitByDate(getTweetsFromDB(input$keyword, n.tweets=10000),
                input$dateRange[1], input$dateRange[2]+1)
  })

  nodes.df <- reactive({
    input$updateDb
    tweetRetweetNodesFull(tweetRetweetGraph(tweets.df()))
  })
  
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
  
})
