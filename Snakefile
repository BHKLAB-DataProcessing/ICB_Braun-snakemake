from snakemake.remote.S3 import RemoteProvider as S3RemoteProvider
S3 = S3RemoteProvider(
    access_key_id=config["key"], 
    secret_access_key=config["secret"],
    host=config["host"],
    stay_on_remote=False
)
prefix = config["prefix"]
filename = config["filename"]
data_source  = config["preprocessed"]

rule get_MultiAssayExp:
    output:
        S3.remote(prefix + filename)
    input:
        S3.remote(prefix + "processed/CLIN.csv"),
        S3.remote(prefix + "processed/EXPR.csv"),
        S3.remote(prefix + "processed/SNV.csv"),
        S3.remote(prefix + "processed/cased_sequenced.csv")
    shell:
        """
        Rscript -e \
        '
        source("https://raw.githubusercontent.com/BHKLAB-Pachyderm/ICB_Common/main/code/get_MultiAssayExp.R");
        saveRDS(
            get_MultiAssayExp(study = "Braun", input_dir = paste0("{prefix}", "processed")), 
            "{prefix}{filename}"
        );
        '
        """

rule format_clin:
    output:
        S3.remote(prefix + "processed/CLIN.csv")
    input:
        S3.remote(prefix + "processed/cased_sequenced.csv"),
        S3.remote(prefix + "download/CLIN.txt")
    shell:
        """
        Rscript scripts/Format_CLIN.R \
        {prefix}download \
        {prefix}processed \
        """

rule format_expr:
    output:
        S3.remote(prefix + "processed/EXPR.csv")
    input:
        S3.remote(prefix + "download/EXPR.txt.gz"),
        S3.remote(prefix + "processed/cased_sequenced.csv"),
        S3.remote(prefix + "download/CLIN.txt")
    shell:
        """
        Rscript scripts/Format_EXPR.R \
        {prefix}download \
        {prefix}processed \
        """

rule format_snv:
    output:
        S3.remote(prefix + "processed/SNV.csv")
    input:
        S3.remote(prefix + "download/SNV.txt.gz"),
        S3.remote(prefix + "processed/cased_sequenced.csv"),
        S3.remote(prefix + "download/CLIN.txt")
    shell:
        """
        Rscript scripts/Format_SNV.R \
        {prefix}download \
        {prefix}processed \
        """

rule format_cased_sequenced:
    output:
        S3.remote(prefix + "processed/cased_sequenced.csv")
    input:
        S3.remote(prefix + "download/CLIN.txt"),
        S3.remote(prefix + "download/EXPR.txt.gz"),
        S3.remote(prefix + "download/SNV.txt.gz")
    shell:
        """
        Rscript scripts/Format_cased_sequenced.R \
        {prefix}download \
        {prefix}processed \
        """

rule download_data:
    output:
        S3.remote(prefix + "download/CLIN.txt"),
        S3.remote(prefix + "download/EXPR.txt.gz"),
        S3.remote(prefix + "download/SNV.txt.gz")
    shell:
        """
        wget -O {prefix}download/CLIN.txt {data_source}CLIN.txt
        wget -O {prefix}download/EXPR.txt.gz {data_source}EXPR.txt.gz
        wget -O {prefix}download/SNV.txt.gz {data_source}SNV.txt.gz
        """ 