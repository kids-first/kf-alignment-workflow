cwlVersion: v1.0
class: CommandLineTool
id: gatkv4_baserecalibrator
requirements:
  - class: ShellCommandRequirement
  - class: InlineJavascriptRequirement
  - class: DockerRequirement
    dockerPull: 'kfdrc/gatk:4.beta.1'
baseCommand: [/gatk-launch, BaseRecalibrator]
arguments:
  - position: 0
    shellQuote: false
    valueFrom: >-
      --javaOptions "-Xms4000m
      -XX:GCTimeLimit=50
      -XX:GCHeapFreeLimit=10
      -XX:+PrintFlagsFinal
      -XX:+PrintGCTimeStamps
      -XX:+PrintGCDateStamps
      -XX:+PrintGCDetails
      -Xloggc:gc_log.log"
      -R $(inputs.reference.path)
      -I $(inputs.input_bam.path)
      --useOriginalQualities
      -O $(inputs.input_bam.nameroot).grp
inputs:
  reference:
    type: File
    secondaryFiles: [^.dict, .fai]
  input_bam:
    type: File
    secondaryFiles: [^.bai]
  knownsites:
    type:
      type: array
      items: File
      inputBinding:
        prefix: -knownSites
    inputBinding:
      position: 1
    secondaryFiles: [.tbi]
  sequence_interval:
    type:
      type: array
      items: File
      inputBinding:
        prefix: -L
    inputBinding:
      position: 2
outputs:
  output:
    type: File
    outputBinding:
      glob: '*.grp'

