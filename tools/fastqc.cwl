cwlVersion: v1.0
class: CommandLineTool
id: fastqc
doc: "Run fastqc on a set of fastq files"

requirements:
  - class: ShellCommandRequirement
  - class: DockerRequirement
    dockerPull: 'kfdrc/fastqc:v0.11.9'
  - class: ResourceRequirement
    ramMin: 20000
  - class: InlineJavascriptRequirement
  - class: InitialWorkDirRequirement
    listing:
      - entryname: fastqc_params
        entry: |-
          duplication 		ignore 		1
          kmer 				ignore 		1
          n_content 			ignore 		0
          overrepresented 	ignore 		1
          quality_base 		ignore 		0
          sequence 			ignore 		1
          gc_sequence			ignore 		0
          quality_sequence	ignore		1
          tile				ignore		1
          sequence_length		ignore		0
          adapter				ignore		1
          duplication	warn	90
          duplication error	65
          kmer	warn	2
          kmer	error	5
          n_content	warn	10
          n_content	error	20
          overrepresented	warn	0.1
          overrepresented	error	1
          quality_base_lower	warn	10
          quality_base_lower	error	5
          quality_base_median	warn	25
          quality_base_median	error	20
          sequence	warn	10
          sequence	error	20
          gc_sequence	warn	15
          gc_sequence	error	30
          quality_sequence	warn	27
          quality_sequence	error	20
          tile	warn	5
          tile	error	10
          sequence_length	warn	1
          sequence_length	error	1
          adapter	warn	5
          adapter	error	10

        writable: false

baseCommand: [tar, -xzf]

arguments:
  - position: 1
    shellQuote: false
    valueFrom: >-
     $(inputs.sequences.path) &&
     fastqc -l fastqc_params ./$(inputs.sequences.nameroot.split('.')[0])/*

inputs:
  sequences: {type: File, doc: "set of sequences being run can be either fastqs or bams"}
  return_raw_data: {type: boolean?, doc: "TRUE: return zipped raw data folder or FALSE: only return summary HTML"}

outputs:
  output_summarys:
    type:
      type: array
      items: File
    outputBinding:
      glob: "*/*.html"
    doc: "HTML report generated by fastqc"
  data_folders:
    type:
      type: array
      items: File
    outputBinding:
      glob: "*/*.zip"
      outputEval: |-
        ${
          if(inputs.return_raw_data) return self
          else return []
        }
    doc: "Zip folders containing images and data generated by fastqc"
