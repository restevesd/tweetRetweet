require('shiny')

shinyServer(function(input, output) {
    output$plot <- renderText({input$keyword})
});
