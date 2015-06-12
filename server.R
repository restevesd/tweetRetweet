require('shiny')
require('stringr')
source('helpers.R')
require('igraph')
#source("http://biostat.jhsph.edu/~jleek/code/twitterMap.R")

#
#
wd <- getwd()
setwd('lib/RtweetsDb/')
source('twitterDb.R')
setwd(wd)

wd <- getwd()
setwd('lib/RtweetsAnalytics/')
source('retweets.R')
setwd(wd)




register_sqlite_backend('tweets.db')

shinyServer(function(input, output) {

  output$hashSelector <- renderUI({
    selectInput("keyword", "Keyword",
                choices =  getAllHashes()$hash, 
                selected = "#R")
  })

  ts.df <- reactive({
    input$updateDb
    getTweetsFromDB(input$keyword)
  })
  
  rt.graph <- reactive({
    tweetRetweetGraph(ts.df())
  })

  output$plot <- renderPlot({
    if (!is.null(input$keyword)) {
      tweetRetweetPlot(rt.graph())
    }
  })

  observeEvent(input$updateDb, {
    print('Updating db...')
    updateAllHashes()
    print('...updating done.')
  })

  
  output$rnumber <- renderText({
    input$updateDb
    rnorm(1)
  })
  
  tws.df <- reactive({
    getTweetsFromDB(input$keyword)
  })


  tws.txt <- reactive({
        tws <- tws.df()
        tws.txt <- tws$text
        tws.txt
      })
    rtws.idx <- reactive({
        grep("(RT|via)((?:\\b\\W*@\\w+)+)", 
             tws.txt(), ignore.case=TRUE)
      })

    posters.reposters <- reactive({
        tws <-tws.df()
        idx <- rtws.idx()
        N <- length(idx)
        reposters <- as.list(1:N)
        posters <- as.list(1:N)
        for (i in 1:N) { 
          tw <- tws[idx[i],]
          poster <- str_extract_all(tw$text,
                                    "(RT|via)((?:\\b\\W*@\\w+)+)") 
          poster <- gsub(":", "", unlist(poster)) 
          posters[[i]] <- gsub("(RT @|via @)", "",
                                poster, ignore.case=TRUE) 
          reposters[[i]] <- rep(tw$screenName, length(poster)) 
        }
        data.frame(poster=unlist(posters), reposter=unlist(reposters))
      })

  trt.graph <- reactive({
    graph.edgelist(as.matrix(posters.reposters()))
  })

  
  output$tws <- DT::renderDataTable({
    DT::datatable(tws.df(), options = list(lengthChange = FALSE))
  })
    
  output$posterReposter <- DT::renderDataTable({
      DT::datatable(posters.reposters(),
                    options = list(lengthChange = FALSE))
    })
    
    output$tbl <- DT::renderDataTable({
      DT::datatable(data.frame(text=tws.txt()[rtws.idx()]),
                    options = list(lengthChange = FALSE))
    })

    output$s <- renderText({
          degree(trt.graph())
       })


    
  ## output$plot2 <- renderPlot({
  ##      ver.labs <- get.vertex.attribute(trt.graph(), "name",
  ##                                       index=V(trt.graph()))
  ##      glay <- layout.fruchterman.reingold(trt.graph())
  ##      par(bg="white",mar=c(1,1,1,1))
  ##      plot(trt.graph(), layout=glay,
  ##           vertex.color="green",
  ##           vertex.size=10,
  ##           vertex.label=ver.labs,
  ##           vertex.label.family="sans",
  ##           vertex.shape="none",
  ##           vertex.label.color=hsv(h=.58, s=.46, v=.52, alpha=0.8),
  ##           vertex.label.cex=0.85,
  ##           edge.arrow.size=0.8,
  ##           edge.arrow.width=0.5,
  ##           edge.width=3,
  ##           edge.color=hsv(h=.95, s=1, v=.7, alpha=0.5))
  ##      title(paste("\nTweets with", input$keyword, ":  Who retweets whom"),
  ##            cex.main=1, col.main="orange")
  ##      })

    #output$plot2 <- renderPlot({
    #    twitterMap("Oxfam", userLocation="Barcelona")
    #  })
  })
