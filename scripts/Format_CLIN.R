args <- commandArgs(trailingOnly = TRUE)
input_dir <- args[1]
output_dir <- args[2]

source("https://raw.githubusercontent.com/BHKLAB-Pachyderm/ICB_Common/main/code/Get_Response.R")
source("https://raw.githubusercontent.com/BHKLAB-Pachyderm/ICB_Common/main/code/format_clin_data.R")

clin_original = read.csv( file.path(input_dir, "CLIN.txt"), stringsAsFactors=FALSE , sep="\t" , dec=',')
clin = clin_original[ clin_original$Arm %in% "NIVOLUMAB" , ]

selected_cols <- c( "SUBJID" , "ORR" , "Sex" , "Age" , "OS" , "OS_CNSR" , "PFS" , "PFS_CNSR" )
clin = cbind( clin[ , selected_cols ] , "PD-1/PD-L1" , "Kidney" , NA , NA , NA , NA , NA , NA )
colnames(clin) = c( "patient" , "recist" , "sex"  ,"age"  , "t.os" , "os" , "t.pfs" , "pfs" , "drug_type" , "primary" , "response" , "response.other.info" , "histo" , "stage" , "dna" , "rna")

clin$sex = ifelse(clin$sex %in% "Male" , "M" , "F" )

clin$recist = ifelse( clin$recist %in% "CRPR" , "PR" ,
				ifelse( clin$recist %in% "NE" , NA ,
				ifelse( clin$recist %in% "NEVER TREATED" , NA , 
				ifelse( clin$recist %in% "EARLY DISCONTINUATION DUE TO TOXICITY" , NA , clin$recist ) ) ) )
 
clin$response = Get_Response( data=clin )


case = read.csv( file.path(output_dir, "cased_sequenced.csv"), stringsAsFactors=FALSE , sep=";" )
clin$rna[ clin$patient %in% case[ case$expr %in% 1 , ]$patient ] = "tpm"
clin$dna[ clin$patient %in% case[ case$snv %in% 1 , ]$patient ] = "wes"

rownames(clin) = clin$patient
clin = clin[ case$patient , c("patient" , "sex" , "age" , "primary" , "histo" , "stage" , "response.other.info" , "recist" , "response" , "drug_type" , "dna" , "rna" , "t.pfs" , "pfs" , "t.os" , "os" ) ]

clin = format_clin_data(clin_original, "SUBJID", selected_cols, clin)

write.table( clin , file=file.path(output_dir, "CLIN.csv") , quote=FALSE , sep=";" , col.names=TRUE , row.names=FALSE )

