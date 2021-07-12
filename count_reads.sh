#!/bin/bash

# File:    report_number_of_reads.sh


report=reads_count.csv

# ----------------------------------------------------------------------
# Function: usage
# Purpose:  Print usage text
# ----------------------------------------------------------------------
function usage
{
cat << EOF
usage: $0  -p dir < -n report>

Creates PDF of FASTQC report.

Options:
    -h  Show this message
    -p  Project directory name containing projectname folder and undetermined data
    -s	sample sheet
    -n	filename for report

EOF
}


# ----------------------------------------------------------------------
# Main program
# ----------------------------------------------------------------------

# Loop through command line options
while getopts n:p:s:h OPTION
do
    case $OPTION in
        h) usage ; exit 1 ;;
        p) project_dir=$OPTARG;;
	      s) samplesheetname=$OPTARG;;
        n) report=$OPTARG;;
    esac
done

report=${project_dir}/reads_count.txt
echo -e "Filename\tTotalReadCount" > $report

cd $project_dir

pwd

sample_project_column=`sed -ne '/Sample_ID/, $ p' $samplesheetname | head -n 1 | awk 'BEGIN{ FS=","} { for(fn=1;fn<=NF;fn++) {print fn"= "$fn;}; exit; }' | grep -i sample_project | sed 's/=/ /' | awk '{print $1}'`

for sample_project_dir in `sed -e '1,/Sample_ID/ d' $samplesheetname | awk -v col=$sample_project_column -F "," '{for(fn=1;fn<=NF;fn++) {if(fn==col){print $fn}};}' | sort | uniq `; do
	cd $sample_project_dir
	for fastq in `find . -type f -name *_R?_???.fastq.gz | sort`; do
		total_lines=$(zcat $fastq | wc -l )
		total_reads=$((total_lines/4))
		#filename=`basename $fastq | sed 's/_S[0-9]_/ /' | awk '{print $1}'`
		filename=`basename $fastq`
		echo -e ${filename}"\t"${total_lines} >> $report

	done
	cd ..

done
cd ..

exit 0
