# oak
A lightweight R Shiny app to explore OAK airport security wait times for the month of March 2018.

### Prerequisites
- R 3.4
- RStudio 1.1

### Installation
1. Clone this repository.
2. In your RStudio console, enter
```
library(shiny)
```
3. Run an example Shiny provides to verify that Shiny has been downloaded properly:
```
runExample("01_hello")
```
4. A window containing a Shiny app should pop up, and your RStudio console should show something similar to:
```
Listening on http://127.0.0.1:7253
```
5. Close the window.  Open `app.R` in RStudio, and click "Run App".  The app should appear in your viewer pane, separate window, or in a browser tab (depending on the default that's set).

### Usage
Play around with the widgets to display different plot types and change plotting parameters.

### Resources
This app was built with RStudio and R.  Wait time data were obtained from US Customs and Border Protection's "Airpot Wait Times" [tool](https://awt.cbp.gov/).