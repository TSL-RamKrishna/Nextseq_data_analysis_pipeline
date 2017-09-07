## Nextseq_data_analysis_pipeline
The pipeline can be used for analysing Nextseq data obtained after bcl2fastq demultiplexing step. The analysis steps are FASTQC of raw data, Quality trimming using Trimmomatic, reada alignment using Bowtie for DNAseq or TopHat for RNAseq, SAM-BAM convertion, merge the BAM files from same sample, generate sorted BAM and index it.

## Requirements
1. Ruby rake)
2. FASTQC
3. Trimmomatic
4. Bowtie2
5. TopHat
6. Samtools
