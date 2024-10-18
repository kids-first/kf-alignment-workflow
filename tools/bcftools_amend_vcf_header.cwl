cwlVersion: v1.2
class: CommandLineTool
id: bcftools-amend-vcf-header
doc: "A specialized tool to make clear that GATK HC was run again"
requirements:
  - class: ShellCommandRequirement
  - class: DockerRequirement
    dockerPull: 'pgc-images.sbgenomics.com/d3b-bixu/bcftools:1.20'
  - class: ResourceRequirement
    ramMin: 16000
    coresMin: 8
  - class: InlineJavascriptRequirement
  - class: InitialWorkDirRequirement
    listing:
      - entryname: "amend_header.sh"
        entry: |
          #!/usr/bin/env bash
          set -xeo pipefail

          bcftools head $(inputs.input_vcf.path) | head -n -1 > header_build.txt
          bcftools head $(inputs.mod_vcf.path) | grep GATK | sed 's/Caller,/Caller_rpt_subset,/' >> header_build.txt
          bcftools head $(inputs.input_vcf.path) | tail -n 1 >> header_build.txt
          bcftools reheader --threads $(inputs.threads) -h header_build.txt $(inputs.input_vcf.path) > $(inputs.output_basename).ploidy_mod.g.vcf.gz

baseCommand: []
arguments:
  - position: 0
    shellQuote: false
    valueFrom: >-
      /bin/bash amend_header.sh

inputs:
  input_vcf: { type: File, secondaryFiles: ['.tbi'], doc: "Reconstituted VCF with modified ploidy region calls" }
  mod_vcf: { type: File, secondaryFiles: ['.tbi'], doc: "VCF with modified region cals only. Header will be used to modift input_vcf" }
  threads: { type: 'int?', default: 4 }
  output_basename: string
outputs:
  header_amended_vcf:
    type: File
    outputBinding:
      glob: "*.{v,b}cf{,.gz}"
    secondaryFiles: ['.tbi?']
