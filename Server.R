#Server.R

function(input, output, session) {
    
    observeEvent(input$reset, {
        f.init <<- data.frame(x=NA,y=NA)
        updateSliderInput(session, "alpha", value = 1)
    })
    
    observeEvent(input$plotClick, {
        f.init <<- rbind(f.init,
                        data.frame(x=input$plotClick$x,
                                   y=input$plotClick$y))
     })
    
    output$GP.plot <- renderPlot({
        input$plotClick
        input$reset
        
        if (nrow(f.init) > 1) {
            Gen.posterior(alpha = input$alpha)
        } else {
            Gen.prior(alpha = input$alpha)
        }
    })
}