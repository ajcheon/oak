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
   
   # Sidebar with a slider input for number of bins 
   sidebarLayout(
      sidebarPanel(
         # Select plot type -- hist, density, scatter, box
         selectInput("plotTypeSelect", "Plot Type", c("histogram", "density", "scatter", "box")),
         
         # Select axes if "scatter" plot type chosen
         uiOutput("xAxis"),
         uiOutput("yAxis")
      ),
      
      # Show a plot of the generated distribution
      mainPanel(
         plotOutput("distPlot")
      )
   )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
    
    # Create reactive values using original and melted data frames
    waitTimes = reactiveVal(waitTimes)
    waitTimesMelted = reactiveVal(waitTimesMelted)
    
    observe ({
        if (input$plotTypeSelect == "scatter") {
            cat("scatter chosen")
            output$xAxis = renderUI({
                selectInput("xAxisSelect", "y axis", c("waitUsCitizen", "waitNonCitizen"), selected = "waitUsCitizen")
            })
            output$yAxis = renderUI({
                selectInput("yAxisSelect", "x axis", c("waitUsCitizen", "waitNonCitizen"), selected = "waitNonCitizen")
            })
        }
    })
    
    output$distPlot <- renderPlot({
        ggplot(waitTimes(), aes_string(input$xAxisSelect, input$yAxisSelect)) + geom_point()
   })
}

# Run the application 
shinyApp(ui = ui, server = server)

