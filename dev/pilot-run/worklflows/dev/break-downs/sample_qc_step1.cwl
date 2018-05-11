cwlVersion: v1.0
class: Workflow
id: paired_sample_qc_step1
requirements:
  - class: ScatterFeatureRequirement
  - class: MultipleInputFeatureRequirement
inputs:
  input_bam: File
  indexed_reference_fasta: File
  base_file_name: string
  contamination_sites_ud: File
  contamination_sites_mu: File
  contamination_sites_bed: File

outputs:
  duplicates_marked_bam:
    type: File
    outputSource: picard_markduplicates/output_markduplicates_bam
  sorted_bam:
    type: File
    outputSource: picard_sortsam/output_sorted_bam
  collect_quality_yield_metrics:
    type: File[]
    outputSource: picard_collectqualityyieldmetrics/output
  collect_unsortedreadgroup_bam_quality_metrics:
    type: 
      type: array
      items:
        type: array
        items: File
    outputSource: picard_collectunsortedreadgroupbamqualitymetrics/output1
  collect_unsortedreadgroup_bam_quality_metrics_pdf:
    type:
      type: array
      items:
        type: array
        items: File
    outputSource: picard_collectunsortedreadgroupbamqualitymetrics/output2
  verify_bam_id:
    type: File
    outputSource: verifybamid/output

steps:
  picard_revertsam:
    run: ../tools/picard_revertsam.cwl
    in:
      input_bam: input_bam
    out: [output]

  picard_collectqualityyieldmetrics:
    run: ../tools/picard_collectqualityyieldmetrics.cwl
    in:
      input_bam: picard_revertsam/output
    scatter: [input_bam]
    out: [output]

  bwa_mem:
    run: ../tools/bwa_mem.cwl
    in:
      indexed_reference_fasta: indexed_reference_fasta
      input_bam: picard_revertsam/output
    scatter: [input_bam]
    out: [output]

  picard_collectunsortedreadgroupbamqualitymetrics:
    run: ../tools/picard_collectunsortedreadgroupbamqualitymetrics.cwl
    in:
      input_bam: bwa_mem/output
    scatter: [input_bam]
    out: [output1, output2]
  
  picard_markduplicates:
    run: ../tools/picard_markduplicates.cwl
    in:
      base_file_name: base_file_name
      input_bams: bwa_mem/output
    out: [output_markduplicates_bam]

  picard_sortsam:
    run: ../tools/picard_sortsam.cwl
    in:
      base_file_name: base_file_name
      input_bam: picard_markduplicates/output_markduplicates_bam
    out: [output_sorted_bam]

  verifybamid:
    run: ../tools/verifybamid.cwl
    in:
      input_bam: picard_sortsam/output_sorted_bam
      ref_fasta: indexed_reference_fasta
      contamination_sites_ud: contamination_sites_ud
      contamination_sites_mu: contamination_sites_mu
      contamination_sites_bed: contamination_sites_bed
    out: [output]
