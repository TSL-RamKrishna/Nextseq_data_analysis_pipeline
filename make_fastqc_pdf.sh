#!/bin/bash

# File:    make_fastqc_pdf.sh
# Purpose: Make a PDF containing all the FASTQC graphs and summary information
source texlive-20170414

# ----------------------------------------------------------------------
# Function: usage
# Purpose:  Print usage text
# ----------------------------------------------------------------------
function usage
{
cat << EOF
usage: $0  -p dir

Creates PDF of FASTQC report.

Options:
    -h  Show this message
    -l  LaTeX output filename (.tex)
    -p  Project directory

EOF
}

# ----------------------------------------------------------------------
# Function: output_latex_header
# Purpose:  Ouput preamble to LaTeX file
# ----------------------------------------------------------------------
function output_latex_header
{
    echo "\\documentclass[a4paper,11pt,oneside]{article}" > ${latex_file}
    echo "\\usepackage{graphicx}" >> ${latex_file}
    echo "\\usepackage{multicol}" >> ${latex_file}
    echo "\\usepackage{url}" >> ${latex_file}
    echo "\\usepackage{subfig}" >> ${latex_file}
    echo "\\usepackage{rotating}" >> ${latex_file}
    echo "\\usepackage{color}" >> ${latex_file}
    echo "\\usepackage[portrait,top=1cm, bottom=2cm, left=1cm, right=1cm]{geometry}" >> ${latex_file}
    echo "\\begin{document}" >> ${latex_file}
    echo "\\renewcommand*{\familydefault}{\sfdefault}" >> ${latex_file}
}

# ----------------------------------------------------------------------
# Function: output_latex_footer
# Purpose:  End LaTeX document
# ----------------------------------------------------------------------
function output_latex_footer
{
    echo "\\end{document}" >> ${latex_file}
}

# ----------------------------------------------------------------------
# Function: output_latex_for_dir
# Purpose:  Output the LaTeX markup for a specific FASTQC directory
# ----------------------------------------------------------------------
function output_latex_for_dir
{
    header_prefix=$1

    for fastqc_data in `find ${project_dir} -type f -name fastqc_data.txt`; do
      echo $fastqc_data
      images_dir=`dirname $fastqc_data`/Images
      gz_filename=`grep -w ^Filename $fastqc_data | awk '{print $2}' | sed 's*_*\\\_*g'`


      echo "\\section*{\large{${header_prefix}${gz_filename}}}" >> ${latex_file}

      echo "\\begin{figure}[h!]" >> ${latex_file}
      echo "\\centering" >> ${latex_file}

      for file in per_base_quality.png per_tile_quality.png per_sequence_quality.png per_base_sequence_content.png per_sequence_gc_content.png per_base_n_content.png duplication_levels.png adapter_content.png
      do
          if [ ! -f ${images_dir}/${file} ] ; then
              echo "Warning: can't find ${images_dir}/${file}"
          else
              echo "\subfigure" >> ${latex_file}
              echo "{" >> ${latex_file}
              echo "    \\includegraphics[width=8cm]{${images_dir}/${file}}" >> ${latex_file}
              echo "}" >> ${latex_file}
          fi
      done

      echo "\\end{figure}" >> ${latex_file}

      echo "\\section*{\large{${header_prefix}${gz_filename}}}" >> ${latex_file}

      echo "\\subsection*{Kmer content}" >> ${latex_file};

      echo "\\begin{figure}[h!]" >> ${latex_file}
      echo "\\centering" >> ${latex_file}

      if [ ! -f ${images_dir}/kmer_profiles.png ] ; then
              echo "Warning: can't find ${images_dir}/kmer_profiles.png "
  	    echo "No overrepresented kmer data to display" >> ${latex_file}
      else
              echo "\begin{multicols}{2}" >> ${latex_file}
  	    echo "\subfigure" >> ${latex_file}
              echo "{" >> ${latex_file}
              echo "    \\includegraphics[width=8cm]{${images_dir}/kmer_profiles.png}" >> ${latex_file}
              echo "}" >> ${latex_file}
  	    echo "{\\footnotesize" >> ${latex_file}
  	    echo "\\begin{tabular}{l l l l l}" >> ${latex_file}
  	    awk '/Kmer Content/,/END_MODULE/ {print}' ${fastqc_data} | head -n 2 | tail -n 1 | perl -nae 'my @arr=split(/\t/); print "\\textbf{", $arr[0], "} & \\textbf{", $arr[1],"} & \\textbf{", $arr[2], "} & \\textbf{", $arr[3], "} & ", $arr[4], "\\\\\n"' | sed 's/Max\ Obs\/Exp\ Position$/\\textbf\{Position\}/g' >> ${latex_file}
  	    awk '/Kmer Content/,/END_MODULE/ {print}' ${fastqc_data} | tail -n +2 | head -n -1 | head -n 20 | grep -v "^#Sequence" | perl -nae 'my @arr=split(/\t/); printf ("%s,%s,%.5f,%.5f,%s", $arr[0], $arr[1], $arr[2], $arr[3], $arr[4])' | perl -nae 'my @arr=split(/,/); print $arr[0], " & ", $arr[1]," & ", $arr[2], " & ", $arr[3], " & ", $arr[4], "\\\\\n"' >> ${latex_file}
  	    echo "\\end{tabular}" >> ${latex_file}
  	    echo "}" >> ${latex_file}
  	    echo "\end{multicols}" >> ${latex_file}
      fi

      echo "\\end{figure}" >> ${latex_file}

      echo "\\subsection*{Summary}" >> ${latex_file};
      echo "\\begin{table}[h!]" >> ${latex_file}
      echo "{\\footnotesize" >> ${latex_file}
      echo "\\begin{tabular}{l l}" >> ${latex_file}
      grep -A 8 'Basic Statistics' ${fastqc_data} | grep -A 7 'Filename' | perl -nae 'my @arr=split(/\t/); print $arr[0], " & ", $arr[1], "\\\\\n"' | sed 's/\%/\\%/g' | sed 's/_/\\_/g' >> ${latex_file}
      echo "\\end{tabular}" >> ${latex_file}
      echo "}" >> ${latex_file}
      echo "\\end{table}" >> ${latex_file}

      echo "\\subsection*{Module summary}" >> ${latex_file};
      echo "\\begin{table}[h!]" >> ${latex_file}
      echo "{\\footnotesize" >> ${latex_file}
      echo "\\begin{tabular}{l l l l}" >> ${latex_file}
      cat ${fastqc_data} | grep '>>' | grep -v 'END_MODULE' | sed 's/>>//' | perl -nae 'my @arr=split(/\t/); $arr[1]=~s/\n//; print $arr[0], " & ", $arr[1], " \\\\\n";' >> ${latex_file}
      echo "\\end{tabular}" >> ${latex_file}
      echo "}" >> ${latex_file}
      echo "\\end{table}" >> ${latex_file}

      echo "\\subsection*{Overrepresented sequences}" >> ${latex_file};
      echo "\\begin{table}[h!]" >> ${latex_file}
      echo "{\\tiny" >> ${latex_file}
      echo "\\begin{tabular}{l l l l}" >> ${latex_file}
      awk '/Overrepresented sequences/,/END_MODULE/ {print}' ${fastqc_data} | tail -n +3 | head -n -1 | head -n 45 | perl -nae 'my @arr=split(/\t/); print $arr[0], " & ", $arr[1]," & ", $arr[2], " & ", $arr[3], "\\\\\n"' | sed 's/\%/\\%/g' >> ${latex_file}
      echo "\\end{tabular}" >> ${latex_file}
      echo "}" >> ${latex_file}
      echo "\\end{table}" >> ${latex_file}
      echo "\\clearpage" >> ${latex_file}
    done
}

# ----------------------------------------------------------------------
# Function: make_pdf
# Purpose:  Run pdflatex
# ----------------------------------------------------------------------
function make_pdf
{
    echo "--- Making PDF ---"
    pdflatex --file-line-error --shell-escape --output-directory ${output_dir} --interaction=nonstopmode ${latex_file}
    pdf_file=`echo ${latex_file} | sed s/.tex/.pdf/`
    echo "Written PDF file ${pdf_file}"
}


# ----------------------------------------------------------------------
# Function: email_summary
# Purpose:  Email summary report
# ----------------------------------------------------------------------
function email_summary
{
    echo "FASTQC summary PDF attached." | mail -s "${jiraid}" tgac.jira@tgac.ac.uk -- -f tgacpap@tgac
}

# ----------------------------------------------------------------------
# Main program
# ----------------------------------------------------------------------

# Loop through command line options
while getopts l:p:s:h OPTION
do
    case $OPTION in
        h) usage ; exit 1 ;;
        l) latex_file=$OPTARG;;
        p) project_dir=$OPTARG;;
        s) samplesheet=`pwd`/$OPTARG;;
    esac
done

latex_file=${project_dir}/fastqc_report.tex

# Either output one FASTQC directory, or a whole run's worth


output_latex_header
output_latex_for_dir "" "${fastqc_dir}"
output_latex_footer
make_pdf
