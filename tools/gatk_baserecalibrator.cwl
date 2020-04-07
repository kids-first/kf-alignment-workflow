cwlVersion: v1.0
class: CommandLineTool
id: gatkv4_baserecalibrator
doc: |-
  Perform baserecalibration on a BAM.
  Programs run in this tool:
    - GATK BaseRecalibrator
requirements:
  - class: ShellCommandRequirement
  - class: InlineJavascriptRequirement
  - class: DockerRequirement
    dockerPull: 'kfdrc/gatk:4.0.3.0'
  - class: ResourceRequirement
    ramMin: 8000
baseCommand: [/gatk, BaseRecalibrator]
arguments:
  - position: 0
    shellQuote: false
    valueFrom: >-
      --java-options "-Xms4000m
      -XX:GCTimeLimit=50
      -XX:GCHeapFreeLimit=10
      -XX:+PrintFlagsFinal
      -XX:+PrintGCTimeStamps
      -XX:+PrintGCDateStamps
      -XX:+PrintGCDetails
      -Xloggc:gc_log.log"
      -R $(inputs.reference.path)
      -I $(inputs.input_bam.path)
      --use-original-qualities
      -O $(inputs.input_bam.nameroot).recal_data.csv
      -L $(inputs.sequence_interval.path)
inputs:
  reference: {type: File, secondaryFiles: [^.dict, .fai], doc: "Reference fasta with dict and fai indexes"}
  input_bam: {type: File, secondaryFiles: [^.bai], doc: "Input bam file"}
  knownsites:
    type:
      type: array
      items: File
      inputBinding:
        prefix: --known-sites
    inputBinding:
      position: 1
    secondaryFiles: [.tbi]
    doc: "List of files and indexes containing known polymorphic sites used to exclude regions around known polymorphisms from analysis"
  sequence_interval: { type: File, doc: "File containing one or more genomic intervals over which to operate" }
outputs:
  output:
    type: File
    outputBinding:
      glob: '*.recal_data.csv'
