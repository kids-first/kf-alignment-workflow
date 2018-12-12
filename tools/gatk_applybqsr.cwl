cwlVersion: v1.0
class: CommandLineTool
id: gatk4_applybqsr
label: GATK apply bqsr
doc: Apply BQSR to aligned, merged, and sorted bam
requirements:
  - class: ShellCommandRequirement
  - class: InlineJavascriptRequirement
  - class: DockerRequirement
    dockerPull: 'kfdrc/gatk:4.0.3.0'
  - class: ResourceRequirement
    ramMin: 4500
baseCommand: [/gatk, ApplyBQSR]
arguments:
  - position: 1
    shellQuote: false
    valueFrom: >-
      --java-options "-Xms3000m
      -XX:+PrintFlagsFinal
      -XX:+PrintGCTimeStamps
      -XX:+PrintGCDateStamps
      -XX:+PrintGCDetails
      -Xloggc:gc_log.log
      -XX:GCTimeLimit=50
      -XX:GCHeapFreeLimit=10"
      --create-output-bam-md5
      --add-output-sam-program-record
      -R $(inputs.reference_fasta.path)
      -I $(inputs.input_bam.path)
      --use-original-qualities
      -O $(inputs.input_bam.nameroot).aligned.duplicates_marked.recalibrated.bam
      -bqsr $(inputs.bqsr_report.path)
      --static-quantized-quals 10 --static-quantized-quals 20 --static-quantized-quals 30
      -L $(inputs.sequence_interval.path)
inputs:
  reference_fasta: File
  reference_dict: File
  reference_fai: File

  input_bam: {type: File, secondaryFiles: [^.bai]}
  bqsr_report: File
  sequence_interval: File
outputs:
  recalibrated_bam:
    type: File
    outputBinding:
      glob: '*bam'
    secondaryFiles: [^.bai, .md5]
