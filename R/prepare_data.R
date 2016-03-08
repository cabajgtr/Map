#Scrapped from Generating County plot of Target Sales
#
#tzip2 <- merge(tzip,zip.regions,by.x='ZIP',by.y='region')
#tzip2[,.(value=sum(value)),by=.(region=county.fips.numeric)]
#county_choropleth(tzip2[,.(value=sum(value)),by=.(region=county.fips.numeric)], title = "Target Sales by County 2014+2015") + scale_fill_brewer(palette = 'Reds', na.value="white")
library(dplyr)
library(choroplethr)
library(choroplethrZip)
library(ggplot2)
library(readr)

#Prep zip to county lookup table
data("zip.regions")
ZipToCounty <- select(zip.regions, ZIP = region, COUNTY = county.name, COUNTY.FIPS = county.fips.numeric) %>% 
     group_by(ZIP) %>% 
     summarize(COUNY = first(COUNTY), COUNTY.FIPS = first(COUNTY.FIPS))
rm(zip.regions)

#Product Heirarchy for Mapping GINS
tblPRODUCT <- readRDS('data/tblPRODUCT.rds')
tblPRODUCT <- mutate(tblPRODUCT, GIN = as.integer(GIN)) %>% na.omit()

###############################
#Import WMT DATA
WMT <- read_tsv('data/walmart_detail.tab')
names(WMT) <- c('SALES','UNITS','STORE','STORE_NAME','CITY','STATE','ZIP','GIN','UPC','DESC')
WMT$CUSTOMER <- 'WMT'
WMT$ZIP <- as.character(WMT$ZIP)

#WMT$region <- as.character(WMT$Zip.Code)
##WMT <- mutate(WMT, POS.Sales = sub('\\$','',POS.Sales))
#WMT <- mutate(WMT, POS.Sales = sub('\\(','-',POS.Sales))
#WMT <- mutate(WMT, POS.Sales = sub('\\,','',POS.Sales))
#WMT <- mutate(WMT, POS.Sales = as.numeric(trimws((sub('\\)','',POS.Sales)))))
#WMT$Month_Start <- as.Date(WMT$Month_Start, "%m/%d/%Y")
WMT <- left_join(WMT, ZipToCounty, by = 'ZIP') 
WMT_BYCOUNTY <- group_by(WMT, region = COUNTY.FIPS, GIN, CUSTOMER) %>% 
     summarize(SALES = sum(SALES), UNITS = sum(UNITS))

###############################
#Import TRU / TGT Data (OBIEE)
TT <- readr::read_csv('data/obiee_store.csv')
TT <- select(TT, CUSTOMER = `Customer Name`, 
             STORE = contains('Store Number'), 
             GIN, 
             Month_Start = `POS Month-Year`, 
             UNITS = `POS Units`, 
             SALES = `POS Sales Amount Local`)
TT <- mutate(TT, STORE = as.integer(TT$STORE), Month_Start = as.Date(paste0("01-", TT$Month_Start), format = "%d-%b-%y"))

#Filter Target until I get TRU store list
TT <- filter(TT, CUSTOMER == 'TARGET' & Month_Start >= as.Date('2015-08-01') & Month_Start <= as.Date('2015-12-31'))

TGT_STORELIST <- read_csv('data/TGT_STORE_LIST.csv', col_types = "icc")
TGT_STORELIST$CUSTOMER <- 'TARGET'
TGT_STORELIST <- left_join(TGT_STORELIST,ZipToCounty, by = 'ZIP') 
TGT_STORELIST <- rename(TGT_STORELIST, STORE = Store)

TGT_BYCOUNTY <- left_join(TT, TGT_STORELIST, by = c('STORE','CUSTOMER')) %>% 
     group_by(region = COUNTY.FIPS, GIN, CUSTOMER) %>% na.omit() %>% 
     summarize(SALES = sum(SALES, na.rm = TRUE), UNITS = sum(UNITS, na.rm = TRUE))
#############
#############

map_df <- rbind(TGT_BYCOUNTY,WMT_BYCOUNTY) 
map_df <- left_join(map_df, tblPRODUCT, by = 'GIN')

saveRDS(map_df,'data/map_df.RDS')

#cleanup
rm(TGT_BYCOUNTY)
rm(WMT_BYCOUNTY)
rm(TT)
rm(WMT)
rm(ZipToCounty)
rm(TGT_STORELIST)


##               filter(WMT, Month_Start > as.Date('2015-09-30')) %>% 
#              left_join(., zip.regions, by = 'region') %>% 
#             mutate(.,county.fips=(county.fips.numeric))
