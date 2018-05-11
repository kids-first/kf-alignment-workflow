cwlVersion: v1.0
class: Workflow
id: scatter_bqsrbam2hc
requirements:
  - class: ScatterFeatureRequirement

inputs:
  input_bam: File
  indexed_reference_fasta: File
  wgs_calling_interval_list: File
  base_file_name: string

outputs:
  gvcf:
    type: File
    outputSource: picard_mergevcfs/output

steps:
  picard_intervallisttools:
    run: picard_intervallisttools.cwl
    in:
      interval_list: wgs_calling_interval_list
    out: [output]

  gatk_haplotypecaller:
    run: gatk_haplotypecaller.cwl
    in:
      reference: indexed_reference_fasta
      input_bam: input_bam
      interval_list: picard_intervallisttools/output
    scatter: [interval_list]
    out: [output]

  picard_mergevcfs:
    run: ../tools/picard_mergevcfs.cwl
    in:
      input_vcf: gatk_haplotypecaller/output
      output_vcf_basename: base_file_name
    out:
      [output]