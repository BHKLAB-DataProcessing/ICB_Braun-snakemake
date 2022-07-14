library(readxl) 
library(data.table)

args <- commandArgs(trailingOnly = TRUE)
work_dir <- args[1]

format_excel_and_save <- function(input_path, output_path, sheetname, compress=FALSE){
  df <- read_excel(input_path, sheet=sheetname)
  colnames(df) <- df[1, ]
  df <- df[-1, ]
  if(compress){
    gz <- gzfile(output_path, "w")
    write.table( df , file=gz , quote=FALSE , sep="\t" , col.names=TRUE , row.names=FALSE )
    close(gz)
  }else{
    write.table( df , file=output_path , quote=FALSE , sep="\t" , col.names=TRUE , row.names=FALSE )
  }
  rm(df)
}

format_excel_and_save(
  input_path=file.path(work_dir, '41591_2020_839_MOESM2_ESM.xlsx'),
  output_path=file.path(work_dir, 'CLIN.txt'),
  sheetname='S1_Clinical_and_Immune_Data'
)

format_excel_and_save(
  input_path=file.path(work_dir, '41591_2020_839_MOESM2_ESM.xlsx'),
  output_path=file.path(work_dir, 'EXPR.txt.gz'),
  sheetname='S4A_RNA_Expression',
  compress=TRUE
)

format_excel_and_save(
  input_path=file.path(work_dir, '41591_2020_839_MOESM2_ESM.xlsx'),
  output_path=file.path(work_dir, 'SNV.txt.gz'),
  sheetname='S2_WES_Data',
  compress=TRUE
)
