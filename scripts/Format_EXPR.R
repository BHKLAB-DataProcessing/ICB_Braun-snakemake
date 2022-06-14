library(data.table)
library(R.utils)
args <- commandArgs(trailingOnly = TRUE)
input_dir <- args[1]
output_dir <- args[2]

expr = as.data.frame( fread( file.path(input_dir, "EXPR.txt.gz")  , sep="\t" , dec="," , stringsAsFactors=FALSE ))
expr = expr[ !( expr[,1] %in% c("01-mars", "02-mars") ) , ]
rownames(expr)  = expr[,1] 
expr = expr[,-1]

clin = read.csv( file.path(input_dir, "CLIN.txt"), stringsAsFactors=FALSE , sep="\t" , dec=',')
id_patient = clin[ !is.na( clin$RNA_ID ) , "SUBJID" ]
names(id_patient) = clin[ !is.na( clin$RNA_ID ) , "RNA_ID" ]

colnames(expr) = id_patient[ colnames(expr) ]

case = read.csv( file.path(output_dir, "cased_sequenced.csv"), stringsAsFactors=FALSE , sep=";" )
expr = expr[ , colnames(expr) %in% case[ case$expr %in% 1 , ]$patient ]

write.table( expr , file= file.path(output_dir, "EXPR.csv") , quote=FALSE , sep=";" , col.names=TRUE , row.names=TRUE )
