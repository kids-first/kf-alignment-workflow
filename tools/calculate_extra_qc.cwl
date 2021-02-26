cwlVersion: v1.0
class: CommandLineTool
id: calculate_extra_qc
doc: "Calculate QC metrics that aren't produced by default"

requirements:
  - class: ShellCommandRequirement
  - class: DockerRequirement
    dockerPull: 'python:3.9.1'
  - class: InlineJavascriptRequirement
  - class: InitialWorkDirRequirement
    listing:
      - entryname: calculate_extra_qc.py
        entry: |-
          '''Calculate QC metrics that fastqc doesn't explicitly provide.'''
          import sys
          import os
          import re
          import argparse
          import zipfile

          def unzip_fastqc_dir(zipped_file):
              '''Unzip fastqc raw directory and return data file.'''
              zip_base = os.path.basename(zipped_file)
              unzip_dir = os.path.splitext(zip_base)[0]
              with zipfile.ZipFile(zipped_file, 'r') as zip_ref:
                  zip_ref.extractall()
              file = unzip_dir + "/fastqc_data.txt"
              #if the file doesn't exist, remove _\d_
              #_\d_ added by cavatica to handle multiple files of the same name
              if not os.path.exists(file):
                  file = re.sub(r'^_\d_', '', file)
              return os.path.abspath(file)

          def main(args):
              '''Main, take args, run script.'''

              #print header of output file
              print("sample_name,percent Q20,percent Q30")

              all_bases = 0
              all_q20 = 0
              all_q30 = 0

              #parse args
              files_to_process = args
              files_to_process.pop(0)
              for zipped_file in files_to_process:
                  sample_temp = os.path.basename(zipped_file)
                  sample_temp = os.path.splitext(sample_temp)[0]
                  #remove '_fastqc' and _\d_ to get original sample name
                  sample_temp = sample_temp.replace('_fastqc', '')
                  sample_name = re.sub(r'^_\d+_', '', sample_temp)

                  #unzip file
                  file = unzip_fastqc_dir(zipped_file)

                  process = 0 #flag to determine if we're in the right secion
                  total_base = 1.0
                  base_q30 = 0.0
                  base_q20 = 0.0

                  #lines where per base quality section starts and ends
                  per_base_start = '>>Per sequence quality scores'
                  per_base_stop = '>>END_MODULE'
                  with open(file) as f:
                      for line in f:
                          #if in the correct section, start processing line
                          if per_base_start in line:
                              #turn processing on
                              process = 1
                          elif per_base_stop in line and process == 1:
                              #stop processing at section end
                              break
                          elif process == 1:
                              #process the line
                              line = line.rstrip()
                              if 'Quality' not in line:
                                  quality, count = line.split('\t')
                                  quality = float(quality)
                                  count = float(count)
                                  total_base += count
                                  if quality >= 30.0:
                                      base_q30 += count
                                  if quality >= 20.0:
                                      base_q20 += count

                  #return output
                  perc_20 = base_q20 / total_base
                  perc_30 = base_q30 / total_base
                  print("%s,%s,%s" % (sample_name, perc_20, perc_30))

                  #add to totals
                  all_bases = all_bases + total_base
                  all_q20 = all_q20 + base_q20
                  all_q30 = all_q30 + base_q30

              #ouput total result
              overall_perc_20 = all_q20 / all_bases
              overall_perc_30 = all_q30 / all_bases
              print("TOTAL,%s,%s" % (overall_perc_20, overall_perc_30))

          if __name__ == "__main__":
              # execute only if run as a script
              main(sys.argv)

        writable: false

baseCommand: [python]

arguments:
  - position: 1
    shellQuote: false
    valueFrom: >-
      calculate_extra_qc.py ${
        var arr = [];
        for (var i=0; i<inputs.fastqc_data.length; i++)
          arr = arr.concat(inputs.fastqc_data[i].path)
        return (arr.join(' '))
        } > $(inputs.output_basename).extra_metrics.csv

inputs:
  fastqc_data: {type: 'File[]', doc: "Zipped file containing fastqc raw data output"}
  output_basename: {type: string, doc: "Output file basename"}

outputs:
  metrics_file:
    type: File
    outputBinding:
      glob: $(inputs.output_basename).extra_metrics.csv
    doc: "Csv file containing calculated metrics"
