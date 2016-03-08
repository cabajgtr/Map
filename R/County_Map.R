require(dplyr)

filterMap_df <- function(df, measure=SALES, SEGMENT1=NA, SEGMENT2=NA, SEGMENT3=NA, SEGMENT4=NA, GIN=NA, CUSTOMER=NA) {
cat("running filter")
     if(is.null(SEGMENT1)) SEGMENT1 <- NA
     if(is.null(SEGMENT2)) SEGMENT2 <- NA
     if(is.null(SEGMENT3)) SEGMENT3 <- NA
     if(is.null(SEGMENT4)) SEGMENT4 <- NA
     if(is.null(CUSTOMER)) CUSTOMER <- NA
     if(is.null(GIN)) GIN <- NA
#Consolidate Product Filters
fl <- data.frame(SEGMENT=c('SEGMENT1', 'SEGMENT2', 'SEGMENT3', 'SEGMENT4','GIN','CUSTOMER'),
                 VAL = c(SEGMENT1, SEGMENT2, SEGMENT3, SEGMENT4, GIN, CUSTOMER)) %>% 
          na.omit() 

print(fl)

if(nrow(fl) > 0) {
          fl <- paste(paste0(fl$SEGMENT," %in% '",fl$VAL,"'"), collapse = " & ")
          print(fl)
          return(filter_(df, fl))
     } else {
            return(df)
     }


}

returnMap <- function(df,title, pal=NULL, ...) {
cat("running returnMap")
     if(is.null(pal)) pal <- "Greens"
     #print(str(df))
     df %>% 
          #filter(CUSTOMER == 'WMT') %>% 
          select(.,value=SALES,region) %>% 
          group_by(.,region) %>% 
          summarise(., value=sum(value)) %>% na.omit() %>% 
          county_choropleth(., title = title, ...) + scale_fill_brewer(palette = (pal), na.value="white")
}


