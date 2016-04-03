#UI.R
fluidPage(
    titlePanel("Noise Free Gaussian Process Regression Visualisation"),
    
    sidebarLayout(
        sidebarPanel(
            sliderInput("alpha",
                        "Alpha value:",
                        min = 0.1,  max = 10, value = 1),
            helpText('Click on the plot to add an observation'),
            hr(),
            actionButton("reset", label = "Reset")
        ),
    
        mainPanel(
            withMathJax(),
            tabsetPanel(
                tabPanel("Plot",plotOutput("GP.plot", click = "plotClick")),
                tabPanel("Help",
                         img(src = "help1.png"),
                         img(src = "help2.png"),
                         img(src = "help3.png"))
            )
        )
    )
)