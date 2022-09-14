library(data.table)
library(R.utils)
args <- commandArgs(trailingOnly = TRUE)
input_dir <- args[1]
output_dir <- args[2]
annot_dir <- args[3]

load(file.path(annot_dir, 'Gencode.v19.annotation.RData'))

expr = as.data.frame( fread( file.path(input_dir, "EXPR.txt.gz")  , sep="\t" , dec="," , stringsAsFactors=FALSE ))
expr = expr[ !( expr[,1] %in% c("43525", "43526") ) , ]
rownames(expr)  = expr[,1] 
expr = expr[,-1]

clin = read.csv( file.path(input_dir, "CLIN.txt"), stringsAsFactors=FALSE , sep="\t" , dec=',')
id_patient = clin[ !is.na( clin$RNA_ID ) , "SUBJID" ]
names(id_patient) = clin[ !is.na( clin$RNA_ID ) , "RNA_ID" ]

colnames(expr) = id_patient[ colnames(expr) ]

case = read.csv( file.path(output_dir, "cased_sequenced.csv"), stringsAsFactors=FALSE , sep=";" )
expr = expr[ , colnames(expr) %in% case[ case$expr %in% 1 , ]$patient ]
rows <- rownames(expr)
expr <- sapply(expr, as.numeric)
rownames(expr) <- rows

# replace gene names with gene id
expr <- data.frame(expr[rownames(expr) %in% features_gene$gene_name, ])
gene_ids <- unlist(lapply(rownames(expr), function(assay_row){
  vals <- rownames(features_gene[features_gene$gene_name == assay_row, ])
  if(length(vals) > 1){
    return(vals[1])
  }else{
    return(vals)
  }
}))
rownames(expr) <- gene_ids
expr <- expr[order(rownames(expr)), ]

## Compute TPM data
genes <- features_gene[rownames(features_gene) %in% rownames(expr), c('start', 'end', 'gene_id')]
genes <- genes[order(rownames(genes)), ]
size <- genes$end - genes$start
names(size) <- rownames(genes)

expr <- round(expr, digits=0)

GetTPM <- function(counts,len) {
  x <- counts/len
  return(t(t(x)*1e6/colSums(x)))
}

expr <- GetTPM(expr, size)

# tpm <- (2 ^ expr) - 1
tpm <- log2(GetTPM(expr, size) + 0.001)

write.table( tpm , file= file.path(output_dir, "EXPR.csv") , quote=FALSE , sep=";" , col.names=TRUE , row.names=TRUE )
