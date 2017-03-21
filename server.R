#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
library("ggplot2")
# Define server logic
shinyServer(function(input, output) {
   
  output$fieldPlot <- renderPlot({
    
    ## importing amperian radius & current values from ui.R file  
    amper_rad <- input$r 
    current <- input$I
    r_wire <- input$numeric
    
    ## constants
    pi <- 3.14
    mu_o <- 4*pi*10^(-7)  # T*m/A
    const <- mu_o/(2*pi)
    
   
    ## variable radius 
    r <- seq(0.1,20,0.1) # mm 

    ## function to calculate B field 
    mag_field <- function(x, curr) {
        B_in = const*curr*x / (r_wire*r_wire) 
        B_out <- const*curr / x
        B <- ifelse(x < r_wire, B_in, B_out)
        return(B*1000*10000)  # 1000 takes into account mm, 10000
                              # for conversion from T to gauss
    }    
    
  
    ## combining dist and B_field into data.frame
    df <- data.frame(r, B = mag_field(r, current) )
    
    ## coordinates for amperian loop
    x_point <- amper_rad; y_point <- mag_field(x_point, current)
    
    ## x,y coords for wire
    x_wire <- 15.0; y_wire <- 0.6*mag_field(r_wire, current)
    
    
    ## plotting the graph
    plot_title <- ifelse(input$show_title, "Magnetic field of long current carrying wire vs distance", "")
    p <- ggplot(aes(x=r, y=B), data=df) + geom_line(colour='red') + theme_bw() +
            theme(text=element_text(family="Times New Roman")) +
            labs(title = plot_title, x = "r [mm]", y="B [Gauss]", color="") +
            theme(axis.title = element_text(size = 18.0), axis.text = element_text(size=14), 
                    plot.title = element_text(size = 18, hjust = 0.5))+
            #annotating point to show movement of obs. point along graph
            annotate("pointrange", x = x_point, y = y_point,
                    ymin = y_point, ymax = y_point, colour = "blue", size = 1.0)+
            #putting wire along z-axis, so we see its cross section as red area
            annotate("pointrange", x = x_wire, y = y_wire,
                    ymin = y_wire, ymax = y_wire,
                    colour = "red", size = r_wire, alpha=0.2) +
            #attaching amperian loop   
            annotate("pointrange", x = x_wire, y = y_wire,
                    ymin = y_wire, ymax = y_wire, alpha=0.2,
                    colour="blue",size = amper_rad) +
            annotate("text", x = x_wire, y = y_wire, label="Wire", family="serif",
                    fontface="italic", colour="red", size=5)+
            annotate("text", x = x_wire - amper_rad*0.2, y = 1.2*y_wire, label="Amperian loop",
                    family="serif",fontface="italic", colour="blue", size=5)
        
    print(p)
    })
  
    ## reactive B field
    reactB <- reactive({
        
        ## constants
        pi <- 3.14
        mu_o <- 4*pi*10^(-7)  # T*m/A
        const <- mu_o/(2*pi)
        
        r_inp <- input$r
        current_inp <- input$I
        r_wire <- input$numeric
        
        ## function to calculate B field 
        mag_field <- function(x, curr) {
            B_in = const*curr*x / (r_wire*r_wire) 
            B_out <- const*curr / x
            B <- ifelse(x < r_wire, B_in, B_out)
            return(B*1000*10000)  # 1000 takes into account mm, 10000
                                  # for conversion from T to gauss
        }    
        
        mag_field(r_inp, current_inp)
    })
  
    #printing reactive B value
    output$Bfield <- renderText({
       round(reactB(),3)
    })
    
    # expression for Amper's law
    output$ex1 <- renderUI({
        if (!input$ex1_visible) return()
        withMathJax(
            helpText('Path integral over close Amperian loop is propotional to
                    the amount of enclosed current: $$ \\oint{\\vec{B} \\cdot d\\vec{r}}=\\mu_{o}I_{enc}$$'))
    })
    
    # expression for B_in and B_out
    output$ex2 <- renderUI({
        if (!input$ex2_visible) return()
        withMathJax(
            helpText(
                'Assuming current density J is constant one can derive: 
                    $$ r<r_{wire}, \\ B_{in}=\\mu_o I r/ 2\\pi r_{wire}^{2}$$
                    $$ r \\geq r_{wire}, \\ B_{out}=\\mu_o I / 2\\pi r$$')
        )
    })
})
