library(data.table)
args <- commandArgs(trailingOnly = TRUE)
input_dir <- args[1]
output_dir <- args[2]

snv = as.data.frame( fread( file.path(input_dir, "SNV.txt.gz") , sep="\t" , stringsAsFactors=FALSE  ))

data = cbind( snv[ , c("Tumor_Sample_Barcode" , "Hugo_Symbol" , "Chromosome" , "Start_position" , "Reference_Allele" , "Tumor_Seq_Allele2" , "Variant_Classification" ) ] )
colnames(data) = c( "Sample" , "Gene" , "Chr" , "Pos" , "Ref" , "Alt" , "Effect" )
data$Ref = ifelse( data$Ref %in% "-" , "" , data$Ref )
data$Alt = ifelse( data$Alt %in% "-" , "" , data$Alt )


data = cbind( data , apply( data[ , c("Ref" , "Alt") ] , 1 , function(x){ ifelse( nchar(x[1]) != nchar(x[2]) , "INDEL", "SNV") } ) )

colnames(data) = c( "Sample" , "Gene" , "Chr" , "Pos" , "Ref" , "Alt" , "Effect" , "MutType" )

data$Chr = paste( "chr" , data$Chr , sep="")

clin = read.csv( file.path(input_dir, "CLIN.txt"), stringsAsFactors=FALSE , sep="\t" , dec=',')
id_patient = clin[ !is.na( clin$MAF_Tumor_ID ) , "SUBJID" ]
names(id_patient) = clin[ !is.na( clin$MAF_Tumor_ID ) , "MAF_Tumor_ID" ]

for(i in 1:length(id_patient)){
	data$Sample[ data$Sample %in% names(id_patient)[i] ] = id_patient[ i ]
}

case = read.csv( file.path(output_dir, "cased_sequenced.csv"), stringsAsFactors=FALSE , sep=";" )
data = data[ data$Sample %in% case[ case$snv %in% 1 , ]$patient , c( "Sample" , "Gene" , "Chr" , "Pos" , "Ref" , "Alt" , "Effect" , "MutType" ) ]

write.table( data , file=file.path(output_dir, "SNV.csv") , quote=FALSE , sep=";" , col.names=TRUE , row.names=FALSE )
