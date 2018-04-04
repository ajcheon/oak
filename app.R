library(shiny)
library(ggplot2)
library(reshape2)
library(plyr)

# Read CSV file
# Melt such that citizen type is a factor with levels waitUsCitizen, waitNonCitizen
waitTimes = read.csv("csvs/oakSecWaitTimes.csv")
waitTimesMelted = melt(waitTimes, variable.name = "citizenship", value.name = "waitTimes")

# Define UI
# Widgets: plot type (hist, density)
ui <- fluidPage(
   
   # Application title
   titlePanel("OAK Airport Security Wait Times"),
   
   sidebarLayout(
      sidebarPanel(
         # Select plot type -- hist, density, scatter, box
         selectInput("plotTypeSelect", "Plot Type", c("histogram", "scatter", "bar", "box")),
         
         conditionalPanel(
             condition = "input.plotTypeSelect == 'histogram'",
             sliderInput("histBinWidth", "Bin width", 1, 15, 5, step = 1)
         ),
         
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
                ggplot(waitTimesMelted(), aes(waitTimes, fill = citizenship)) +
                    geom_histogram(binwidth = input$histBinWidth)
            })
        }
        else if (input$plotTypeSelect == "scatter") {
            output$mainPlot <- renderPlot({
                ggplot(waitTimes(), aes_string(input$xAxisSelect, input$yAxisSelect, color = "time")) +
                    geom_point(size = input$geomPointSize)
            })    
        }
        else if (input$plotTypeSelect == "bar") {
            output$mainPlot <- renderPlot({
                df = ddply(waitTimes(),
                           .(time),
                           summarize,
                           meanWaitTimeUsCitizen = mean(waitUsCitizen),
                           meanWaitTimeNonCitizen = mean(waitNonCitizen))
                df = melt(df, variable.name = "citizenship", value.name = "meanWaitTime")
                
                ggplot(df, aes(time, y = meanWaitTime, fill = citizenship)) + 
                    geom_bar(position = "dodge", stat = "identity") + 
                    theme(axis.text.x = element_text(angle = 60, hjust = 1))
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
        else {
            stop("Seleted plot type is not histogram, scatter, or box.")
        }
    })
    output$checkboxValue = renderText({input$checkbox})
}

# Run the application 
shinyApp(ui = ui, server = server)

