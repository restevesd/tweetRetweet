require('shiny')
source('RtweetsAnalytics.R')


shinyServer(function(input, output) {

  output$hashSelector <- renderUI({
    selectInput("keyword", "Keyword",
                choices =  getAllHashes()$hash, 
                selected = "#R")
  })

  tweets.df <- reactive({
    #input$updateDb
    getTweetsFromDB(input$keyword, n.tweets=10000)
  })


  output$freqPlot <- renderPlot({
    freqPlotByTRT(tweets.df())
  })
  
  output$basicStat <- renderUI({
    div(p(),
        p(paste('Total number of tweets:', dim(tweets.df())[1])),
        p(paste('Number of retweets:', dim(retwitted(tweets.df()))[1])),
        p(paste('Number of no retwitted tweets:', dim(noRetwitted(tweets.df()))[1])))
  })

  output$trtPlot <- renderPlot({
    rt.graph <- tweetRetweetGraph(tweets.df())
    tweetRetweetPlot(rt.graph)
  })

})
