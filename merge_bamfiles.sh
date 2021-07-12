#!/bin/bash
#program to merge sample bam files
source samtools-1.3.1

sampleid=$1
reference=$2
bamfiles=$(echo results/${sampleid}_*/*_alignedSorted.bam)

for filename in $bamfiles; do
  if [ ! -e $filename ]; then
    echo "$filename does not exist. Cannot do bam merge."
    exit 1
  fi
done


cmd="samtools merge -r -u -f -c --reference $reference results/${sampleid}/aligned_merged.bam $bamfiles"
echo $cmd
$cmd
