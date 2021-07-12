#!/bin/bash

source bowtie2-2.2.9

sampleid=$1
sample=$2
reference=$3
R1_basename=$4
R2_basename=$5


if [ -e results/${sample}/${R1_basename}_paired.fastq ] && [ -e results/${sample}/${R2_basename}_paired.fastq ]; then
  bowtie2 -q --phred33 -k 1 --reorder --very-sensitive-local --no-unal --rg-id $sampleid --rg "platform:Illumina" --rg "sequencer:JIC" -x ${reference} -1 results/${sample}/${R1_basename}_paired.fastq -2 results/${sample}/${R2_basename}_paired.fastq -S results/${sample}/${sampleid}_aligned.sam 2> results/${sample}/${sampleid}_aligned.log;

elif [ -e results/${sample}/${R1_basename}_paired.fastq ]; then
  bowtie2 -q --phred33 -k 1 --reorder --very-sensitive-local --no-unal --rg-id $sampleid --rg "platform:Illumina" --rg "sequencer:JIC" --un results/${sample}/${R1_basename}_unaligned.fastq -x ${reference} -U  results/${sample}/${R1_basename}_paired.fastq  -S results/${sample}/${sampleid}_aligned.sam 2> results/${sample}/${sampleid}_aligned.log;

else
  echo "Single or Paired end data not confirmed"
fi
