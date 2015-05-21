require('shiny')
source('helpers.R')


shinyServer(function(input, output) {
    tws.df <- reactive({
        tws <- searchTwitter(input$keyword, n=50)
        tws.df <- twListToDF(tws)
        tws.df
      })
    tws.txt <- reactive({
        tws <- tws.df()
        tws.txt <- tws$text
        print(tws.txt)
        tws.txt
      })
    output$tbl = DT::renderDataTable({
      DT::datatable(data.frame(text=tws.txt()),
                    options = list(lengthChange = FALSE))
    })
  })
