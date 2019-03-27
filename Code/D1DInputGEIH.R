# This script process GEIH files. Output is a demographic table for 
# the Synthetic population database

rm(list=ls())

###.....................................................................
### Macros

## Libraries

library(data.table)
library(foreign)

## Working directory

# Main folders
wd      <- "D:/Usuarios/1018428549/Google Drive/09Projects/092Modelling/NationHMS/"
wd_code <- paste0(wd,"Code/")
wd_data <- paste0(wd,"Data/")

# Subfolders
wdd_orig <- paste0(wd_data,"0Original/")
wdd_inpu <- paste0(wd_data,"1Input/")

setwd(wd_code)

##.....................................................................
## Input data sets

# 1. Individual and household characteristics

df_ind_c <- fread(paste0(wdd_orig,"GEIH_June_2010_txt/",
                         "Cabecera - Características generales (Personas) (6).txt"))
df_ind_r <- fread(paste0(wdd_orig,"GEIH_June_2010_txt/",
                           "Resto - Características generales (Personas) (6).txt"))   
df_ind   <- rbind(df_ind_c,df_ind_r,fill=TRUE) 

# Identification
dvars_iden <- c("directory","secuence","order","household","iweight")
setnames(df_ind, old=c("DIRECTORIO","SECUENCIA_P","ORDEN","HOGAR","fex_c_2011"),
          new=dvars_iden)

df_ind[,idh:=paste0(directory,household)]
df_ind[,id:=paste0(idh,order)]

# Demographics
dvars_demo <- c("dsex", "dage","dhhead","dmarital")
setnames(df_ind, old=c("P6020","P6040","P6050","P6070"), 
                 new=dvars_demo)

# Spatial location
dvars_spat <- c("dldpto","dlzone","dlcity")
setnames(df_ind, old=c("DPTO","CLASE","AREA"), 
         new=dvars_spat)

# Socioeconomic
dvars_soci <- c("deduschool","dedulevel","dedugra","dedudegree","deduyears")
setnames(df_ind, old=c("P6170","P6210","P6210S1","P6220","ESC"), 
         new=dvars_soci)

# Health insurance
svars_insu <- c("sinsaffi","sinsregi","sinsafficlass","sinscontr")
setnames(df_ind, old=c("P6090","P6100","P6110","P6120"), 
         new=svars_insu)

# Subset
df_ind <- df_ind[,c("id","idh",dvars_iden,dvars_spat,dvars_demo,dvars_soci,svars_insu),with=FALSE]

# Clean
rm(df_ind_c,df_ind_r)
rm(dvars_iden,dvars_demo,dvars_spat,dvars_soci,svars_insu)

# 2. DWelling characteristics

# 3. Labor

# 4. Income

##.....................................................................
## Renames and encoding



##.....................................................................
## Joining data sets


##.....................................................................
## Save data set

df <- df_ind[,c("directory","secuence","order","household"):=NULL]

save(df,file=paste0(wdd_inpu,"df_input_demo",".RData"))
saveRDS(df,paste0(wdd_inpu,"df_input_demo",".rds"))
fwrite(df,paste0(wdd_inpu,"df_input_demo",".csv"))

# Clean
rm(df_ind,df)
gc()
detach(package:data.table)
