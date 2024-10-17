cwlVersion: v1.0
class: CommandLineTool
id: bedtools_intersect
doc: "Subset VCF with bedtools intersect. Can add -v flag for negative selection"
requirements:
  - class: ShellCommandRequirement
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    ramMin: 8000
    coresMin: 4
  - class: DockerRequirement
    dockerPull: 'pgc-images.sbgenomics.com/d3b-bixu/vcfutils:latest'

baseCommand: [/bin/bash -c]
arguments:
  - position: 1
    shellQuote: false
    valueFrom: >-
        'set -eo pipefail; bedtools intersect -wa -header
  - position: 3
    shellQuote: false
    valueFrom: >-
      | bgzip -c -@ 4 > $(inputs.output_basename).bed_intersect.vcf.gz'
  - position: 4
    shellQuote: false
    valueFrom: >-
      && tabix $(inputs.output_basename).bed_intersect.vcf.gz

inputs:
    input_vcf: { type: File, secondaryFiles: ['.tbi'], doc: "Input VCF file.",
      inputBinding: { position: 2, prefix: "-a" } }
    input_bed_file: { type: File, doc: "bed intervals to intersect with.",
      inputBinding: { position: 2, prefix: "-b" } }
    output_basename: string
    inverse: {type: 'boolean?', doc: "Select whatever is NOT in the interval bed file",
      inputBinding: { position: 2, prefix: "-v"} }

outputs:
  intersected_vcf:
    type: File
    outputBinding:
      glob: '*.bed_intersect.vcf.gz'
    secondaryFiles: ['.tbi']
