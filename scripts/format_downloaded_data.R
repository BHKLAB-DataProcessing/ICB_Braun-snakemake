library(readxl) 
library(data.table)

args <- commandArgs(trailingOnly = TRUE)
work_dir <- args[1]

source('https://raw.githubusercontent.com/BHKLAB-Pachyderm/ICB_Common/main/code/format_excel_functions.R')

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
