library(data.table)
args <- commandArgs(trailingOnly = TRUE)
input_dir <- args[1]
output_dir <- args[2]

################################################################################################
################################################################################################

snv = as.data.frame( fread( file.path(input_dir, "SNV.txt.gz") , sep="\t" , stringsAsFactors=FALSE  ))

data = cbind( snv[ , c("Tumor_Sample_Barcode" , "Hugo_Symbol" , "Chromosome" , "Start_position" , "Reference_Allele" , "Tumor_Seq_Allele2" , "Variant_Classification" ) ] )

colnames(data) = c( "Sample" , "Gene" , "Chr" , "Pos" , "Ref" , "Alt" , "Effect" )

data = cbind ( data , apply( data[ , c( "Ref", "Alt" ) ] , 1 , function(x){ ifelse( nchar(x[1]) != nchar(x[2]) , "INDEL", "SNV") } ) )
colnames(data) = c( "Sample" , "Gene" , "Chr" , "Pos" , "Ref" , "Alt" , "Effect" , "MutType" )

data$Chr = paste( "chr" , data$Chr , sep="")

clin = read.csv( file.path(input_dir, "CLIN.txt"), stringsAsFactors=FALSE , sep="\t" , dec=',')
id_patient = clin[ !is.na( clin$MAF_Tumor_ID ) , "SUBJID" ]
names(id_patient) = clin[ !is.na( clin$MAF_Tumor_ID ) , "MAF_Tumor_ID" ]

for(i in 1:length(id_patient)){
	data$Sample[ data$Sample %in% names(id_patient)[i] ] = id_patient[ i ]
}

snv_patient = sort( unique( data$Sample ) )

################################################################################################
################################################################################################

expr = as.data.frame( fread( file.path(input_dir, "EXPR.txt.gz")  , sep="\t" , dec="," , stringsAsFactors=FALSE ))
expr = expr[ !( expr[,1] %in% c("01-mars", "02-mars") ) , ]
rownames(expr)  = expr[,1] 
expr = expr[,-1]

clin = read.csv( file.path(input_dir, "CLIN.txt"), stringsAsFactors=FALSE , sep="\t" , dec=',')
id_patient = clin[ !is.na( clin$RNA_ID ) , "SUBJID" ]
names(id_patient) = clin[ !is.na( clin$RNA_ID ) , "RNA_ID" ]

colnames(expr) = id_patient[ colnames(expr) ]

expr_patient = sort( unique( colnames(expr) ) )

################################################################################################
################################################################################################

clin = read.csv( file.path(input_dir, "CLIN.txt"), stringsAsFactors=FALSE , sep="\t" )
rownames(clin) = clin$SUBJID

clin = clin[ clin$Arm %in% "NIVOLUMAB" , ]

clin_patient = sort( unique( clin$SUBJID ) )

patient = sort( unique( c( clin_patient , snv_patient , expr_patient ) ) )

case = as.data.frame( cbind( patient , rep( 0 , length(patient) ) , rep( 0 , length(patient) ) , rep( 0 , length(patient) ) ) )
colnames(case) = c( "patient" , "snv" , "cna" , "expr" )
rownames(case) = patient

case$snv = as.numeric( as.character( case$snv ) )
case$cna = as.numeric( as.character( case$cna ) )
case$expr = as.numeric( as.character( case$expr ) )


for( i in 1:nrow(case)){
	if( rownames(case)[i] %in% snv_patient ){
		case$snv[i] = 1
	}
	if( rownames(case)[i] %in% expr_patient ){
		case$expr[i] = 1
	}
}
case = case[ rowSums( case[ , 2:4 ] ) > 0 , ]

write.table( case , file=file.path(output_dir, "cased_sequenced.csv") , quote=FALSE , sep=";" , col.names=TRUE , row.names=FALSE )


