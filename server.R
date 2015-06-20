require('shiny')
require('DT')
source('RtweetsAnalytics.R')


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
    updateAllHashes()
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

  output$freqText <- renderUI({
    p(paste0('Time evolution of numbers of tweets with hash ', input$keyword,
            '. '))
  })
  
  output$freqPlot <- renderPlot({
    freqPlotByTRT(tweets.df())
  })
  
  output$basicStat <- DT::renderDataTable({
    ## div(p(),
    ##     p(paste('Total number of tweets:', dim(tweets.df())[1])),
    ##     p(paste('Number of retweets:', dim(retwitted(tweets.df()))[1])),
    ##     p(paste('Number of no retwitted tweets:', dim(noRetwitted(tweets.df()))[1])))

    bs.df <- basicStatDf(tweets.df())
    bs.DT <- DT::datatable(bs.df, options = list(lengthChange = FALSE))
    bs.DT
  })

  output$trtPlot <- renderPlot({
    rt.graph <- tweetRetweetGraph(tweets.df())
    tweetRetweetPlot(rt.graph,
                     PercentageOfConnections=input$PercentageOfConnections/100)
  },  height = 1000, width = 1000)

  output$trtNodes <- DT::renderDataTable({
    nodes.df <- tweetRetweetNodes(tweetRetweetGraph(tweets.df()))
    DT::datatable(nodes.df[order(-nodes.df$Nretwitted),],
                  options = list(lengthChange = FALSE))
  })
})
