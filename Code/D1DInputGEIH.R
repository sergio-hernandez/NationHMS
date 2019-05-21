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
#wd      <- "G:/Mi unidad/09Projects/092Modelling/NationHMS/"
wd_code <- paste0(wd,"Code/")
wd_data <- paste0(wd,"Data/")

# Subfolders
wdd_orig <- paste0(wd_data,"0Original/")
wdd_inpu <- paste0(wd_data,"1Input/")

setwd(wd_code)

##.....................................................................
## Input data sets

# 1. Individual demographics and household characteristics

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

# 2. Education
dvars_soci <- c("deduschool","dedulevel","dedugra","dedudegree","deduyears")
setnames(df_ind, old=c("P6170","P6210","P6210S1","P6220","ESC"), 
         new=dvars_soci)

# 3. Health insurance
svars_insu <- c("sinsaffi","sinsregi","sinsafficlass","sinscontr")
setnames(df_ind, old=c("P6090","P6100","P6110","P6120"), 
         new=svars_insu)

# Subset
df_ind <- df_ind[,c("id","idh",dvars_iden,dvars_spat,dvars_demo,dvars_soci,svars_insu),with=FALSE]

# Clean
rm(df_ind_c,df_ind_r)
rm(dvars_iden,dvars_demo,dvars_spat,dvars_soci,svars_insu)


# 4. Labor

# labor force
dvars_labol <- c("id","dlabowa")

df_lab_c_l <- fread(paste0(wdd_orig,"GEIH_June_2010_txt/",
                         "Cabecera - Fuerza de trabajo (6).txt"))
df_lab_r_l <- fread(paste0(wdd_orig,"GEIH_June_2010_txt/",
                         "Resto - Fuerza de trabajo (6).txt"))   
df_lab_l   <- rbind(df_lab_c_l,df_lab_r_l,fill=TRUE) 
df_lab_l[,dlabowa:=1]
df_lab_l[,id:=paste0(DIRECTORIO,HOGAR,ORDEN)]

df_lab_l <- df_lab_l[,dvars_labol,with=FALSE]

# Clean
rm(df_lab_c_l,df_lab_r_l,dvars_labol)

# Inactive

dvars_laboi <- c("id","dlaboinac")

df_lab_c_l <- fread(paste0(wdd_orig,"GEIH_June_2010_txt/",
                           "Cabecera - Inactivos (6).txt"))
df_lab_r_l <- fread(paste0(wdd_orig,"GEIH_June_2010_txt/",
                           "Resto - Inactivos (6).txt"))   
df_lab_i   <- rbind(df_lab_c_l,df_lab_r_l,fill=TRUE) 
df_lab_i[,dlaboinac:=1]
df_lab_i[,id:=paste0(DIRECTORIO,HOGAR,ORDEN)]

df_lab_i <- df_lab_i[,dvars_laboi,with=FALSE]

# Clean
rm(df_lab_c_l,df_lab_r_l,dvars_laboi)

# Employed

df_lab_c_l <- fread(paste0(wdd_orig,"GEIH_June_2010_txt/",
                           "Cabecera - Ocupados (6).txt"))
df_lab_r_l <- fread(paste0(wdd_orig,"GEIH_June_2010_txt/",
                           "Resto - Ocupados (6).txt"))   
df_lab_e   <- rbind(df_lab_c_l,df_lab_r_l,fill=TRUE) 

df_lab_e[,id:=paste0(DIRECTORIO,HOGAR,ORDEN)]

dvars_laboe <- c("dlaboempl","dincowage","dlabocwork","spencot","dlabohours")
setnames(df_lab_e, old=c("OCI","INGLABO","P6430","P6920","P6640S1"), 
         new=dvars_laboe)

df_lab_e <- df_lab_e[,c("id",dvars_laboe),with=FALSE]

# Clean
rm(df_lab_c_l,df_lab_r_l,dvars_laboe)

# Unemployed

dvars_labou <- c("id","dlabounem")

df_lab_c_l <- fread(paste0(wdd_orig,"GEIH_June_2010_txt/",
                           "Cabecera - Desocupados (6).txt"))
df_lab_r_l <- fread(paste0(wdd_orig,"GEIH_June_2010_txt/",
                           "Resto - Desocupados (6).txt"))   
df_lab_u   <- rbind(df_lab_c_l,df_lab_r_l,fill=TRUE) 
df_lab_u[,dlabounem:=1]
df_lab_u[,id:=paste0(DIRECTORIO,HOGAR,ORDEN)]

df_lab_u <- df_lab_u[,dvars_labou,with=FALSE]

# Clean
rm(df_lab_c_l,df_lab_r_l,dvars_labou)

# Consolidating labor table

df_lab <- merge(df_lab_l,df_lab_i,by=c("id"),all.x = TRUE)
df_lab <- merge(df_lab,df_lab_e,by=c("id"),all.x = TRUE)
df_lab <- merge(df_lab,df_lab_u,by=c("id"),all.x = TRUE)

# Clean
rm(df_lab_l,df_lab_i,df_lab_e,df_lab_u)

# Encoding type of work
df_lab[,dlabotwork:=2]
df_lab[,dlabotwork:=ifelse(!is.na(dlaboempl) & !(dlabocwork %in% c(1,2)),1,dlabotwork)]
df_lab[,dlabotwork:=ifelse(!is.na(dlaboinac==1),3,dlabotwork)]
df_lab[,dlabotwork:=ifelse(!is.na(dlabounem==1),4,dlabotwork)]

# Consolidating individual table

df_ind <- merge(df_ind,df_lab,by=c("id"),all.x = TRUE)

# clean
rm(df_lab)

# 5. Wages and income

# Household income variables
dvars_inco <- c("dincoh")

# Household yearly income different to wages (Only monetary)

df_inc_h_c <- fread(paste0(wdd_orig,"GEIH_June_2010_txt/",
                           "Cabecera - Otros ingresos (6).txt"))
df_inc_h_r <- fread(paste0(wdd_orig,"GEIH_June_2010_txt/",
                           "Resto - Otros ingresos (6).txt"))   
df_inc_h   <- rbind(df_inc_h_c,df_inc_h_r,fill=TRUE) 

df_inc_h[,idh:=paste0(DIRECTORIO,HOGAR)]

# imputing encoded data

# df_inc_h <- df_inc_h[, lapply(.SD, function(x){ifelse(as.numeric(x)>10000000,0,x)}), by=c("id"),
#                   .SDcols= c("P7500S1A1","P7500S2A1","P7500S3A1",
#                              "P7510S1A1","P7510S2A1","P7510S3A1",
#                              "P7510S5A1","P7510S6A1","P7510S7A1")]


df_inc_h <- df_inc_h[, lapply(.SD, sum, na.rm=TRUE),by=c("idh"), 
           .SDcols= c("P7500S1A1","P7500S2A1","P7500S3A1",
                      "P7510S1A1","P7510S2A1","P7510S3A1",
                      "P7510S5A1","P7510S6A1","P7510S7A1")]

df_inc_h[,dincohot:=P7500S1A1]

df_inc_h <- df_inc_h[,c("idh","dincohot"),with=FALSE]


df_ind[,dincowageh:=sum(dincowage,na.rm = TRUE),by=c("idh")]

df_ind <- merge(df_ind,df_inc_h,by=c("idh"),all.x = TRUE)

df_ind[,dincoh:=dincowageh+dincohot]

# delete aux variables

df_ind[,c("dincowageh","dincohot"):=NULL]

# Clean
rm(df_inc_h,df_inc_h_c,df_inc_h_r)


# 6. Dwelling characteristics


##.....................................................................
## Renames and encoding


# Missing health regime assigned to "no affiliated"

table(df_ind$sinsregi)

df_ind[,sinsregi:=ifelse(sinsaffi==2,4,sinsregi)]
df_ind[,sinsregi:=ifelse(sinsregi==9,4,sinsregi)]


##.....................................................................
## Joining data sets


##.....................................................................
## Save data sets

# GEIH Sample
df <- df_ind[,c("directory","secuence","order","household"):=NULL]

save(df,file=paste0(wdd_inpu,"df_input_demo",".RData"))
saveRDS(df,paste0(wdd_inpu,"df_input_demo",".rds"))
fwrite(df,paste0(wdd_inpu,"df_input_demo",".csv"))

# Expanded adults sample

dvars_synth <- c("dsex","dage","dldpto","dlzone","dedulevel","dlabotwork","sinsregi","dincowage","dincoh")

df_synth <- df[,c("id","idh","iweight",dvars_synth),with=FALSE]

# Round to expand: records differ from population projection this way
df_synth[,iweight:=round(iweight,0)]

df_synth <- df_synth[rep(seq_len(nrow(df_synth)), df_synth$iweight), ]

# Create a sequnce of ids

df_synth[,id:=seq(.N)]

df_synth <- df_synth[,c("id",dvars_synth),with=FALSE]

save(df_synth,file=paste0(wdd_inpu,"df_synth_demo",".RData"))
saveRDS(df_synth,paste0(wdd_inpu,"df_synth_demo",".rds"))

# Clean
rm(df_ind,df,df_synth)
gc()
detach(package:data.table)
