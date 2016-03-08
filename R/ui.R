library(shiny)

# Define UI for application that draws a histogram
shinyUI(fluidPage(
     
     # Application title
     titlePanel("Regional Sales (Fall 2015)"),
     
     # Sidebar with a slider input for the number of bins
     sidebarLayout(
          sidebarPanel(
               
               #sliderInput("year_start",
               #            "Start Year:",
               #            min = 2011,
               #            max = 2013,
               #            value = 2011,
               #            width = "300px")
               
               
               #,sliderInput("actual_end",
               #             "End Date:",
               #             min = as.Date('2013-01-05'),
               #             max = as.Date('2016-02-20'),
               #             value = as.Date('2015-04-25'),
               #             step = 7,
               #             width = "300px")
               
               #,selectInput("freq",
               #             "Frequency:",
               #             choices = c("POS_WK_NBR","POS_MTH_NBR","POS_QTR"),
               #             selected = "POS_WK_NBR",
               #             width = "300px")
               #,
               
               uiOutput("CUSTList")
               ,uiOutput("BUList")
               ,uiOutput("BLList")
               ,uiOutput("PLList")
               ,uiOutput("ItemList")
               ,actionButton("upd", "Update")
               ,width = 3),
          
          # Show a plot of the generated distribution
          mainPanel(
               tabsetPanel(
                    tabPanel("Geography",
                             
                             #helpText("Active Item:"),
                             textOutput("item",inline=TRUE),
                             plotOutput("distPlot", height = "900px")
                    )
                    
               )
               , width=8)
     )
))