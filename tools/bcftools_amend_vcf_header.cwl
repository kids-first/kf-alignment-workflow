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

          awk 'NR == FNR && $line ~ /^##GATKCommandLine.HaplotypeCaller/ {sub(/Caller,/, "Caller_rpt_subset,"); newcmd=$line}; NR != FNR; NR != FNR && $line ~ /^##GATKCommandLine.HaplotypeCaller/ {print newcmd}' <(bcftools head $2) <(bcftools head $1) > header_build.txt

baseCommand: []
arguments:
  - position: 0
    shellQuote: false
    valueFrom: >-
      /bin/bash amend_header.sh
  - position: 3
    shellQuote: false
    valueFrom: >-
      && bcftools reheader --threads $(inputs.threads) -h header_build.txt $(inputs.input_vcf.path) > $(inputs.output_basename).ploidy_mod.g.vcf.gz
      && tabix $(inputs.output_basename).ploidy_mod.g.vcf.gz

inputs:
  input_vcf: { type: File, secondaryFiles: ['.tbi'], doc: "Reconstituted VCF with modified ploidy region calls",
    inputBinding: { position: 1 } }
  mod_vcf: { type: File, secondaryFiles: ['.tbi'], doc: "VCF with modified region calls only. Header will be used to modify input_vcf",
    inputBinding: { position: 2 } }
  threads: { type: 'int?', default: 4 }
  output_basename: string
outputs:
  header_amended_vcf:
    type: File
    outputBinding:
      glob: "*.{v,b}cf{,.gz}"
    secondaryFiles: ['.tbi?']
