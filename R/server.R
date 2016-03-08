library(shiny)
library(dplyr)
library(ggplot2)
library(data.table)
library(choroplethr)
source('County_Map.R')
data(continental_us_states)

map_df <- readRDS('../data/map_df.RDS')

PROD_HIER <- unique(select(ungroup(map_df),SEGMENT1, SEGMENT2, SEGMENT3, SEGMENT4)) %>% na.omit() %>% data.table
BU <- c('ALL',as.character(unique(PROD_HIER$SEGMENT1)))
BL <- c('ALL',as.character(unique(PROD_HIER$SEGMENT2)))
PL <- c('ALL',as.character(unique(PROD_HIER$SEGMENT3)))
PF <- as.character(unique(PROD_HIER$SEGMENT4))
CUST <- unique(map_df$CUSTOMER)

shinyServer(function(input, output, session) {
     
     output$CUSTList <- renderUI({
          selectizeInput("vCUST", "Choose Customer(s):", 
                         choices  = CUST,
                         #selected = 'ALL'
                         multiple=TRUE,
                         options=list(closeAfterSelect=TRUE))
     })
     
     output$BUList <- renderUI({
          selectizeInput("BU", "Choose Bus Unit:", 
                         choices  = BU,
                         #selected = 'ALL'
                         multiple=TRUE,
                         options=list(closeAfterSelect=TRUE))
     })
     
     output$BLList <- renderUI({
          selectizeInput("BL", "Choose Bus Line:", 
                         choices  = getBLlist(),
                         #selected = 'ALL'
                         multiple=TRUE,
                         options=list(closeAfterSelect=TRUE))
     })
     
     output$PLList <- renderUI({
          selectizeInput("PL", "Choose Prod Line:", 
                         choices  = getPLlist(),
                         #selected = 'ALL'
                         multiple=TRUE,
                         options=list(closeAfterSelect=TRUE))
     })
     
     output$ItemList <- renderUI({
          selectizeInput("item", "Choose item:", 
                         choices  = getPFlist(),
                         #selected = 'PICNIC BASKET',
                         multiple=TRUE,
                         options=list(closeAfterSelect=TRUE))
     })
     
     output$item <- renderText({input$item})
     
     
     getBLlist <- reactive({
          # If missing input, return to avoid error later in function
          
          if(is.null(input$BU))
               return(BL)
          
          if(is.null(input$BU)) {
               return(as.character(unique(PROD_HIER$SEGMENT2)))
          }else{as.character(unique(PROD_HIER[SEGMENT1 %in% (input$BU),SEGMENT2]))}
     })
     
     getPLlist <- reactive({
          if(is.null(input$BL))
               return(PL)
          
          if(is.null(input$BU)) {
               l <- PROD_HIER
          }else{
               l <- PROD_HIER[SEGMENT1 %in% (input$BU)]}
          
          if(is.null(input$BL)) {
               l <- l
          }else{
               l <- l[SEGMENT2 %in% (input$BL)]}
          
          return(as.character(l[,SEGMENT3]))
     })
     
     getPFlist <- reactive({
          #if(is.null(input$BU)) {
          #     print("item is null")
          #     return(PF)}
          
          if(is.null(input$BU)) {l <- PROD_HIER
          }else{l <- PROD_HIER[SEGMENT1 %in% (input$BU)]}
          
          if(is.null(input$BL)) {l <- l
          }else{l <- l[SEGMENT2 %in% (input$BL)]}
          
          if(is.null(input$PL)) {l <- l
          }else{l <- l[SEGMENT3 %in% (input$PL)]}
          
          return(as.character(l[,SEGMENT4]))
     })
     

     TheMap <- eventReactive(input$upd, {
          filterMap_df(map_df, 
                       SEGMENT1 = input$BU, SEGMENT2 = input$BL, 
                       SEGMENT3 = input$PL, SEGMENT4 = input$PF, 
                       CUSTOMER = input$vCUST) %>% 
          returnMap(title=paste("Sales by County:"), state_zoom = continental_us_states)
     })
     
     output$distPlot <- renderPlot({
          #cat('DistPlot')
          #filterMap_df(map_df, 
          #             SEGMENT1 = input$BU, SEGMENT2 = input$BL, 
          #             SEGMENT3 = input$PF, SEGMENT4 = input$PL, 
          #             CUSTOMER = input$vCUST) %>% 
          #returnMap(.,title=paste("Sales by County:"))
          TheMap()
     })
     
     
})