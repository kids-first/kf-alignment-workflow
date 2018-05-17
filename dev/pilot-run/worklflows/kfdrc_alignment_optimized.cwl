cwlVersion: v1.0
class: Workflow
id: kf_alignment_optimized_wf
requirements:
  - class: ScatterFeatureRequirement
  - class: MultipleInputFeatureRequirement

inputs:
  input_bam: File
  output_basename: string
  contamination_sites_bed: File
  contamination_sites_mu: File
  contamination_sites_ud: File
  dbsnp_vcf: File
  indexed_reference_fasta: File
  knownsites: File[]
  reference_dict: File
  wgs_calling_interval_list: File
  wgs_coverage_interval_list: File
  wgs_evaluation_interval_list: File

outputs:
  indexed_bam: {type: File, outputSource: picard_gatherbamfiles/output}
  cram: {type: File, outputSource: samtools_coverttocram/output}
  gvcf: {type: File, outputSource: picard_mergevcfs/output}
  verifybamid_output: {type: File, outputSource: verifybamid/output}
  bqsr_report: {type: File, outputSource: gatk_gatherbqsrreports/output}
  picard_collect_gvcf_calling_metrics: {type: 'File[]', outputSource: picard_collectgvcfcallingmetrics/output}
  calculate_readgroup_checksum: {type: File, outputSource: picard_calculatereadgroupchecksum/output}
  collect_quality_yield_metrics: {type: 'File[]', outputSource: picard_collectqualityyieldmetrics/output}
  collect_readgroupbam_quality_metrics: {type: 'File[]', outputSource: picard_collectreadgroupbamqualitymetrics/output}
  collect_collect_aggregation_metrics: {type: 'File[]', outputSource: picard_collectaggregationmetrics/output}
  collect_wgs_metrics: {type: File, outputSource: picard_collectwgsmetrics/output}

steps:
  samtools_cram2bam:
    run: ../tools/samtools_cram2bam.cwl
    in:
      input_reads: input_bam
      reference: indexed_reference_fasta
      threads: {default: 33}
    out: [bam_file]

  samtools_split:
    run: ../tools/samtools_split.cwl
    in:
      input_bam: samtools_cram2bam/bam_file
      threads: {default: 36}
    out: [bam_files]

  picard_collectqualityyieldmetrics:
    run: ../tools/picard_collectqualityyieldmetrics.cwl
    in:
      input_bam: samtools_split/bam_files
      output_basename: output_basename
    scatter: [input_bam]
    out: [output]

  get_bwa_threads:
    run: ../tools/get_bwa_threads.cwl
    in:
      input_files: samtools_split/bam_files
    out: [threads]

  bwa_mem:
    run: ../tools/bwa_mem_samblaster_sambamba.cwl
    in:
      indexed_reference_fasta: indexed_reference_fasta
      input_bam: samtools_split/bam_files
      threads: get_bwa_threads/threads
    scatter: [input_bam]
    out: [output, rg]

  sambamba_merge:
    run: ../tools/sambamba_merge.cwl
    in:
      bams: bwa_mem/output
      base_file_name: output_basename
      num_of_threads: {default: 36}
      suffix: {default: aligned.duplicates_marked.sorted.bam}
    out: [merged_bam]

  sambamba_sort:
    run: ../tools/sambamba_sort.cwl
    in:
      bam: sambamba_merge/merged_bam
      base_file_name: output_basename
      num_of_threads: {default: 36}
      suffix: {default: aligned.duplicates_marked.sorted.bam}
    out: [sorted_bam]

  sambamba_index:
    run: ../tools/sambamba_index.cwl
    in:
      bam: sambamba_sort/sorted_bam
      num_of_threads: {default: 36}
    out: [indexed_bam]

  python_createsequencegroups:
    run: ../tools/python_createsequencegroups.cwl
    in:
      ref_dict: reference_dict
    out: [out_intervals]

  gatk_baserecalibrator:
    run: ../tools/gatk_baserecalibrator.cwl
    in:
      input_bam: sambamba_index/indexed_bam
      knownsites: knownsites
      reference: indexed_reference_fasta
      sequence_interval: python_createsequencegroups/out_intervals
    scatter: [sequence_interval]
    out: [output]

  gatk_gatherbqsrreports:
    run: ../tools/gatk_gatherbqsrreports.cwl
    in:
      input_brsq_reports: gatk_baserecalibrator/output
      output_basename: output_basename
    out: [output]

  gatk_applybqsr:
    run: ../tools/gatk_applybqsr.cwl
    in:
      bqsr_report: gatk_gatherbqsrreports/output
      input_bam: sambamba_index/indexed_bam
      reference: indexed_reference_fasta
      sequence_interval: python_createsequencegroups/out_intervals
    scatter: [sequence_interval]
    out: [recalibrated_bam]

  picard_gatherbamfiles:
    run: ../tools/picard_gatherbamfiles.cwl
    in:
      input_bam: gatk_applybqsr/recalibrated_bam
      output_bam_basename: output_basename
    out: [output]

  picard_calculatereadgroupchecksum:
    run: ../tools/picard_calculatereadgroupchecksum.cwl
    in:
      input_bam: picard_gatherbamfiles/output
    out: [output]

  picard_collectaggregationmetrics:
    run: ../tools/picard_calculatereadgroupchecksum.cwl
    in:
      input_bam: picard_gatherbamfiles/output
    out: [output]

  picard_collectreadgroupbamqualitymetrics:
    run: ../tools/picard_collectreadgroupbamqualitymetrics.cwl
    in:
      input_bam: picard_gatherbamfiles/output
      reference: indexed_reference_fasta
    out: [output]

  picard_collectwgsmetrics:
    run: ../tools/picard_collectwgsmetrics.cwl
    in:
      input_bam: picard_gatherbamfiles/output
      intervals: wgs_coverage_interval_list
      reference: indexed_reference_fasta
    out: [output]

  picard_intervallisttools:
    run: ../tools/picard_intervallisttools.cwl
    in:
      interval_list: wgs_calling_interval_list
    out: [output]

  verifybamid:
    run: ../tools/verifybamid.cwl
    in:
      contamination_sites_bed: contamination_sites_bed
      contamination_sites_mu: contamination_sites_mu
      contamination_sites_ud: contamination_sites_ud
      input_bam: sambamba_index/indexed_bam
      ref_fasta: indexed_reference_fasta
      output_basename: output_basename
    out: [output]

  checkcontamination:
    run: ../tools/expression_checkcontamination.cwl
    in:
      verifybamid_selfsm: verifybamid/output
    out: [contamination]

  gatk_haplotypecaller:
    run: ../tools/gatk_haplotypecaller.cwl
    in:
      contamination: checkcontamination/contamination
      input_bam: picard_gatherbamfiles/output
      interval_list: picard_intervallisttools/output
      reference: indexed_reference_fasta
    scatter: [interval_list]
    out: [output]

  picard_mergevcfs:
    run: ../tools/picard_mergevcfs.cwl
    in:
      input_vcf: gatk_haplotypecaller/output
      output_vcf_basename: output_basename
    out: [output]

  picard_collectgvcfcallingmetrics:
    run: ../tools/picard_collectgvcfcallingmetrics.cwl
    in:
      dbsnp_vcf: dbsnp_vcf
      final_gvcf_base_name: output_basename
      input_vcf: picard_mergevcfs/output
      reference_dict: reference_dict
      wgs_evaluation_interval_list: wgs_evaluation_interval_list
    out: [output]

  samtools_coverttocram:
    run: ../tools/samtools_covert_to_cram.cwl
    in:
      input_bam: picard_gatherbamfiles/output
      reference: indexed_reference_fasta
    out: [output]

$namespaces:
  sbg: https://sevenbridges.com
hints:
  - class: 'sbg:AWSInstanceType'
    value: c5.9xlarge;ebs-gp2;768
  - class: 'sbg:maxNumberOfParallelInstances'
    value: 4