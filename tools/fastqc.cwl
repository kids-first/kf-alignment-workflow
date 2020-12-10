cwlVersion: v1.0
class: CommandLineTool
id: fastqc
doc: "Run fastqc on a set of fastq files"

requirements:
  - class: ShellCommandRequirement
  - class: DockerRequirement
    dockerPull: 'pgc-images.sbgenomics.com/d3b-bixu/fastqc:v0.11.9'
  - class: ResourceRequirement
    ramMin: ${return inputs.ram * 1000}
    coresMin: ${return Math.min(inputs.sequences.length, inputs.max_cpu)}
  - class: InlineJavascriptRequirement

baseCommand: [fastqc]

arguments:
  - position: 1
    shellQuote: false
    valueFrom: >-
     -t ${return Math.min(inputs.sequences.length, inputs.max_cpu)} -o .

inputs:
  sequences: {type: 'File[]', inputBinding: {position: 99}, doc: "set of sequences being run can be either fastqs or bams"}
  return_raw_data: {type: boolean?, doc: "TRUE: return zipped raw data folder or FALSE: only return summary HTML"}
  ram: {type: ['null', int], default: 2, doc: "In GB"}
  max_cpu: {type: ['null', int], default: 8, doc: "Maximum number of CPUs to request"}
  fastqc_params: {type: 'File?', inputBinding: {position: 1, prefix: -l}, doc: "fastqc parameter file to use"}

outputs:
  output_summarys:
    type:
      type: array
      items: File
    outputBinding:
      glob: "*.html"
    doc: "HTML report generated by fastqc"

  data_folders:
    type: 'File[]?'
    outputBinding:
      glob: "*.zip"
      outputEval: |-
        ${
          if(inputs.return_raw_data) return self
          else return null
        }
    doc: "Zip folders containing images and data generated by fastqc"
