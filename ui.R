#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
#library("ggplot2")
# Define UI for application that draws a histogram
shinyUI(fluidPage(
  
  # Application title
  titlePanel(""),
  # for formula
  withMathJax(),
  # Sidebar with a slider input for number of bins 
  sidebarLayout(
    sidebarPanel(
       numericInput("numeric", "Input radius of the wire [mm]", value = 4.0,
                    min = 0.5, max = 10.0, step=0.5 ), 
       sliderInput("r", "B field evaluation distance or radius of amperian loop[mm]:",
                   min = 0.1, max = 20.0, value = 20.0),
       sliderInput("I", "Current value[A]:",
                   min = 0.1, max = 3.0, value = 1.0),
       checkboxInput("show_title", "Show/Hide Title")
    ),
    
    # Show a plot of the generated distribution
    mainPanel(
       plotOutput("fieldPlot"),
       span("B(r)=", textOutput("Bfield", inline = TRUE), "Gauss"),
       p("Red line in above plot demonstrates how magnetic field changes with distance both
        inside(metallic area) and outside the wire with DC current. By altering a distance value
        in a second slider one can observe magnetic field and distance real time relationship via
        movements of blue point along the red line. In additon, lightred and lightblue circles
        illustrate cross section view of the wire and amperian loop(circle made of observation
        distance) respectivaly. Circle size is rescaled down to 15%.")
    )
  ),
  checkboxInput('ex1_visible', "Show Amper's Law", TRUE), uiOutput('ex1'),
  checkboxInput('ex2_visible', "Show B field inside the wire", TRUE), uiOutput('ex2')
  
))
