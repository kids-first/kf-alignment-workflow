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
  - class: InitialWorkDirRequirement
    listing: |
      ${
        var listing = inputs.knownsites;
        listing.push(inputs.reference_fai);
        listing.push(inputs.reference_fasta);
        listing.push(inputs.reference_dict);
        return listing;
      }
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
      -R $(inputs.reference_fasta.path)
      -I $(inputs.input_bam.path)
      --use-original-qualities
      -O $(inputs.input_bam.nameroot).recal_data.csv
      -L $(inputs.sequence_interval.path)
      ${
        var ks_sites = "";
        for (var i = 0; i < inputs.knownsites.length; i++){
          if (inputs.knownsites[i].nameext == '.gz'){
            ks_sites += " --known-sites " + inputs.knownsites[i].path
          }
        }
      return ks_sites
      }
inputs:
  reference_fasta: File
  reference_dict: File
  reference_fai: File
  input_bam: {type: File, secondaryFiles: [^.bai]}
  knownsites:
    type:
      type: array
      items: File
  sequence_interval: File

outputs:
  output:
    type: File
    outputBinding:
      glob: '*.recal_data.csv'
