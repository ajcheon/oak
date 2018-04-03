library(shiny)
library(ggplot2)
library(reshape2)
library(plyr)

# Read CSV file
# Melt such that citizen type is a factor with levels waitUsCitizen, waitNonCitizen
waitTimes = read.csv("csvs/oakSecWaitTimes.csv")
waitTimesMelted = melt(df, variable.name = "citizenship", value.name = "waitTimes")

# Define UI
# Widgets: plot type (hist, density)
ui <- fluidPage(
   
   # Application title
   titlePanel("OAK Airport Security Wait Times"),
   
   sidebarLayout(
      sidebarPanel(
         # Select plot type -- hist, density, scatter, box
         selectInput("plotTypeSelect", "Plot Type", c("histogram", "density", "scatter", "box")),
         
         conditionalPanel(
             condition = "input.plotTypeSelect == 'scatter'",
             selectInput("xAxisSelect", "x axis", c("waitUsCitizen", "waitNonCitizen"), selected = "waitUsCitizen"),
             selectInput("yAxisSelect", "y axis", c("waitUsCitizen", "waitNonCitizen"), selected = "waitNonCitizen"),
             sliderInput("geomPointSize", "Point size", 1, 5, 2, step = 0.5)
         ),
         
         conditionalPanel(
             condition = "input.plotTypeSelect == 'box'",
             radioButtons("boxplotXSelect", label = NULL,
                          choices = c("By citizenship only" = "citizenship",
                                      "By time interval" = "time")),
             conditionalPanel(
                 condition = "input.boxplotXSelect == 'time'",
                 checkboxInput("facetSelect", label = "Facet by time interval", value = FALSE)
             )
         )
      ),
      
      # Show a plot of the generated distribution
      mainPanel(
         plotOutput("mainPlot")
      )
   )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
    
    # Create reactive values using original and melted data frames
    waitTimes = reactiveVal(waitTimes)
    waitTimesMelted = reactiveVal(waitTimesMelted)
    
    observe({
        
        if (input$plotTypeSelect == "histogram") {
            output$mainPlot <- renderPlot({
                ggplot(waitTimesMelted(), aes(waitTimes, col = "red")) +
                    geom_histogram(position = "identity", binwidth = 5)
            })
        }
        else if (input$plotTypeSelect == "scatter") {
            output$mainPlot <- renderPlot({
                ggplot(waitTimes(), aes_string(input$xAxisSelect, input$yAxisSelect, color = "time")) +
                    geom_point(size = input$geomPointSize)
            })    
        }
        else if (input$plotTypeSelect == "box") {
            output$mainPlot <- renderPlot({
                p = ggplot(waitTimesMelted(), aes_string(input$boxplotXSelect, "waitTimes")) +
                        geom_boxplot(aes(fill=citizenship))
                
                if (input$boxplotXSelect == "time" && input$facetSelect) {
                    return (p + facet_wrap( ~ time, scales="free"))
                }
                return(p)
            })
        }
    })
    output$checkboxValue = renderText({input$checkbox})
}

# Run the application 
shinyApp(ui = ui, server = server)

