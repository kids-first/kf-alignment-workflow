cwlVersion: v1.0
class: CommandLineTool
id: gatkv4_baserecalibrator
label: GATK bqsr
doc: Create base score recalibrator score reports
requirements:
  - class: ShellCommandRequirement
  - class: InlineJavascriptRequirement
  - class: DockerRequirement
    dockerPull: 'kfdrc/gatk:4.0.3.0'
  - class: ResourceRequirement
    ramMin: 8000
baseCommand: []
arguments:
  - position: 0
    shellQuote: false
    valueFrom: >-
      ${
        var cmd_pre = "/gatk --QUIET true --verbosity WARNING -F ";
        var index_cmd = "";
        for (fn in inputs.knownsites){
          index_cmd += cmd_pre + fn.path + "\n";
        }
        return index_cmd
      }
      && /gatk BaseRecalibrator --java-options "-Xms4000m
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
  reference_fasta: File
  reference_dict: File
  reference_fai: File

  input_bam: {type: File, secondaryFiles: [^.bai]}
  knownsites:
    type:
      type: array
      items: File
      inputBinding:
        prefix: --known-sites
    inputBinding:
      position: 1
    secondaryFiles: [.tbi]
  sequence_interval: File
outputs:
  output:
    type: File
    outputBinding:
      glob: '*.recal_data.csv'
