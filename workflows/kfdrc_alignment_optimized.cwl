cwlVersion: v1.0
class: Workflow
id: kf_alignment_wf_optimized
requirements:
  - class: ScatterFeatureRequirement
  - class: MultipleInputFeatureRequirement
hints:
  - class: 'sbg:AWSInstanceType'
    value: c5.9xlarge;ebs-gp2;768
  - class: 'sbg:maxNumberOfParallelInstances'
    value: 4
inputs:
  contamination_sites_bed:
    type: File
  contamination_sites_mu:
    type: File
  contamination_sites_ud:
    type: File
  dbsnp_vcf:
    type: File
    secondaryFiles:
      - .idx
  indexed_reference_fasta:
    type: File
    secondaryFiles:
      - .64.amb
      - .64.ann
      - .64.bwt
      - .64.pac
      - .64.sa
      - .64.alt
      - ^.dict
      - .amb
      - .ann
      - .bwt
      - .pac
      - .sa
      - .fai
  input_bam:
    type: File
  knownsites:
    type: 'File[]'
    'sbg:x': 0
    secondaryFiles:
      - .tbi
  reference_dict:
    type: File
    'sbg:x': 0
  wgs_calling_interval_list:
    type: File
    'sbg:x': 0
  wgs_coverage_interval_list:
    type: File
    'sbg:x': 0
  wgs_evaluation_interval_list:
    type: File
    'sbg:x': 0
outputs:
  bqsr_report:
    outputSource:
      - gatk_gatherbqsrreports/output
    type: File
  calculate_readgroup_checksum:
    outputSource:
      - picard_calculatereadgroupchecksum/output
    type: File
  collect_quality_yield_metrics:
    outputSource:
      - picard_collectqualityyieldmetrics/output
    type: 'File[]'
  collect_readgroupbam_quality_metrics:
    outputSource:
      - picard_collectreadgroupbamqualitymetrics/output1
    type: 'File[]'
  collect_readgroupbam_quality_pdf:
    outputSource:
      - picard_collectreadgroupbamqualitymetrics/output2
    type: 'File[]'
  collect_unsortedreadgroup_bam_quality_metrics:
    outputSource:
      - picard_collectunsortedreadgroupbamqualitymetrics/output1
    type:
      type: array
      items:
        items: File
        type: array
  collect_unsortedreadgroup_bam_quality_metrics_pdf:
    outputSource:
      - picard_collectunsortedreadgroupbamqualitymetrics/output2
    type:
      type: array
      items:
        items: File
        type: array
  collect_wgs_metrics:
    outputSource:
      - picard_collectwgsmetrics/output
    type: File
  cram:
    outputSource:
      - samtools_coverttocram/output
    type: File
  gvcf:
    outputSource:
      - picard_mergevcfs/output
    type: File
  picard_collect_gvcf_calling_metrics:
    outputSource:
      - picard_collectgvcfcallingmetrics/output
    type: 'File[]'
  verifybamid_output:
    outputSource:
      - verifybamid/output
    type: File
  indexed_bam:
    outputSource:
      - sambamba_index/indexed_bam
    type: File?
  indexed_bam_1:
    outputSource:
      - picard_gatherbamfiles/output
    type: File?
steps:
  bwa_mem:
    in:
      indexed_reference_fasta:
        source:
          - indexed_reference_fasta
      input_bam:
        source:
          - samtools_split/bam_files
      threads:
        source:
          - get_bwa_threads/threads
    out: [output, rg]
    run: ../tools/bwa_mem_samblaster_sambamba.cwl
    label: bwa-mem
    scatter:
      - input_bam
  get_bwa_threads:
    in:
      input_files:
        source:
          - samtools_split/bam_files
    out: [threads]
    run: ../tools/get_bwa_threads.cwl
    label: get_bwa_threads
  checkcontamination:
    in:
      verifybamid_selfsm:
        source:
          - verifybamid/output
    out: [contamination]
    run: ../tools/expression_checkcontamination.cwl
    label: checkcontamination
  gatk_applybqsr:
    in:
      bqsr_report:
        source:
          - gatk_gatherbqsrreports/output
      input_bam:
        source:
          - sambamba_index/indexed_bam
      reference:
        source:
          - indexed_reference_fasta
      sequence_interval:
        source:
          - python_createsequencegroups/out_intervals
    out: [recalibrated_bam ]
    run: ../tools/gatk_applybqsr.cwl
    label: gatk-applybqsr
    scatter:
      - sequence_interval
  gatk_baserecalibrator:
    in:
      input_bam:
        source:
          - sambamba_index/indexed_bam
      knownsites:
        source:
          - knownsites
      reference:
        source:
          - indexed_reference_fasta
      sequence_interval:
        source:
          - python_createsequencegroups/out_intervals
    out: [output]
    run: ../tools/gatk_baserecalibrator.cwl
    label: gatk-baserecalibrator
    scatter:
      - sequence_interval
  gatk_gatherbqsrreports:
    in:
      input_brsq_reports:
        source:
          - gatk_baserecalibrator/output
    out: [output]
    run: ../tools/gatk_gatherbqsrreports.cwl
    label: gatk-gatherbqsrreports
  gatk_haplotypecaller:
    in:
      contamination:
        source:
          - checkcontamination/contamination
      input_bam:
        source:
          - picard_gatherbamfiles/output
      interval_list:
        source:
          - picard_intervallisttools/output
      reference:
        source:
          - indexed_reference_fasta
    out: [output]
    run: ../tools/gatk_haplotypecaller_35.cwl
    label: gatk-haplotypecaller
    scatter:
      - interval_list
  getbasename:
    in:
      input_file:
        source:
          - input_bam
    out: [file_basename]
    run: ../tools/expression_getbasename.cwl
    label: getbasename
  picard_calculatereadgroupchecksum:
    in:
      input_bam:
        source:
          - picard_gatherbamfiles/output
    out: [output]
    run: ../tools/picard_calculatereadgroupchecksum.cwl
    label: picard-calculatereadgroupchecksum
  picard_collectaggregationmetrics:
    in:
      input_bam:
        source:
          - picard_gatherbamfiles/output
    out: [output]
    run: ../tools/picard_calculatereadgroupchecksum.cwl
    label: picard-collectaggregationmetrics
  picard_collectgvcfcallingmetrics:
    in:
      dbsnp_vcf:
        source:
          - dbsnp_vcf
      final_gvcf_base_name:
        source:
          - getbasename/file_basename
      input_vcf:
        source:
          - picard_mergevcfs/output
      reference_dict:
        source:
          - reference_dict
      wgs_evaluation_interval_list:
        source:
          - wgs_evaluation_interval_list
    out: [output]
    run: ../tools/picard_collectgvcfcallingmetrics.cwl
    label: picard-collectgvcfcallingmetrics
  picard_collectqualityyieldmetrics:
    in:
      input_bam:
        source:
          - samtools_split/bam_files
    out: [output]
    run: ../tools/picard_collectqualityyieldmetrics.cwl
    label: picard-collectqualityyieldmetrics
    scatter:
      - input_bam
  picard_collectreadgroupbamqualitymetrics:
    in:
      input_bam:
        source:
          - picard_gatherbamfiles/output
      reference:
        source:
          - indexed_reference_fasta
    out: [output1, output2]
    run: ../tools/picard_collectreadgroupbamqualitymetrics.cwl
    label: picard-collectreadgroupbamqualitymetrics
  picard_collectunsortedreadgroupbamqualitymetrics:
    in:
      input_bam:
        source:
          - bwa_mem/output
    out: [output1, output2]
    run: ../tools/picard_collectunsortedreadgroupbamqualitymetrics.cwl
    label: picard-collectunsortedreadgroupbamqualitymetrics
    scatter:
      - input_bam
  picard_collectwgsmetrics:
    in:
      input_bam:
        source:
          - picard_gatherbamfiles/output
      intervals:
        source:
          - wgs_coverage_interval_list
      reference:
        source:
          - indexed_reference_fasta
    out: [output]
    run: ../tools/picard_collectwgsmetrics.cwl
    label: picard-collectwgsmetrics
  picard_intervallisttools:
    in:
      interval_list:
        source:
          - wgs_calling_interval_list
    out: [output]
    run: ../tools/picard_intervallisttools.cwl
    label: picard-intervallisttools
  picard_mergevcfs:
    in:
      input_vcf:
        source:
          - gatk_haplotypecaller/output
      output_vcf_basename:
        source:
          - getbasename/file_basename
    out: [output]
    run: ../tools/picard_mergevcfs.cwl
    label: picard-mergevcfs
  samtools_coverttocram:
    in:
      input_bam:
        source:
          - picard_gatherbamfiles/output
      reference:
        source:
          - indexed_reference_fasta
    out: [output]
    run: ../tools/samtools_covert_to_cram.cwl
    label: samtools-coverttocram
    'sbg:y': 0
  verifybamid:
    in:
      contamination_sites_bed:
        source:
          - contamination_sites_bed
      contamination_sites_mu:
        source:
          - contamination_sites_mu
      contamination_sites_ud:
        source:
          - contamination_sites_ud
      input_bam:
        source:
          - sambamba_index/indexed_bam
      ref_fasta:
        source:
          - indexed_reference_fasta
    out: [output]
    run: ../tools/verifybamid.cwl
    label: verifybamid
  samtools_split:
    in:
      input_bam:
        source:
          - samtools_cram2bam/bam_file
      threads:
        default: 36
    out: [bam_files]
    run: ../tools/samtools_split.cwl
    label: Samtools split
  sambamba_merge:
    in:
      bams:
        source:
          - bwa_mem/output
      base_file_name:
        source:
          - getbasename/file_basename
      num_of_threads:
        default: 36
      suffix:
        default: aligned.duplicates_marked.sorted.bam
    out: [merged_bam]
    run: ../tools/sambamba_merge.cwl
    label: Sambamba Merge
  sambamba_index:
    in:
      bam:
        source:
          - sambamba_sort/sorted_bam
      num_of_threads:
        default: 36
    out: [indexed_bam]
    run: ../tools/sambamba_index.cwl
    label: Sambamba Index
  sambamba_sort:
    in:
      bam:
        source:
          - sambamba_merge/merged_bam
      base_file_name:
        source:
          - getbasename/file_basename
      num_of_threads:
        default: 36
      suffix:
        default: aligned.duplicates_marked.sorted.bam
    out: [sorted_bam]
    run: ../tools/sambamba_sort.cwl
    label: Sambamba Sort
  picard_gatherbamfiles:
    in:
      input_bam:
        source:
          - gatk_applybqsr/recalibrated_bam
      output_bam_basename:
        source:
          - getbasename/file_basename
    out: [output]
    run: ../tools/picard_gatherbamfiles.cwl
    label: picard-gatherbamfiles
  samtools_cram2bam:
    in:
      input_reads:
        source:
          - input_bam
      reference:
        source:
          - indexed_reference_fasta
      threads:
        default: 33
    out: [bam_file]
    run: ../tools/samtools_cram2bam.cwl
    label: Samtools Cram2Bam
  python_createsequencegroups:
    in:
      ref_dict:
        source:
          - reference_dict
    out: [out_intervals]
    run: >-
      ../tools/python_createsequencegroups.cwl
label: kf-alignment-optimized

