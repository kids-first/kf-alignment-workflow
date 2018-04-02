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
    'sbg:x': 893.4639892578125
    'sbg:y': 778.28125
  contamination_sites_mu:
    type: File
    'sbg:x': 893.4639892578125
    'sbg:y': 671.46875
  contamination_sites_ud:
    type: File
    'sbg:x': 893.4639892578125
    'sbg:y': 564.65625
  dbsnp_vcf:
    type: File
    'sbg:x': 1184.6514892578125
    'sbg:y': 632.0625
    secondaryFiles:
      - .idx
  indexed_reference_fasta:
    type: File
    'sbg:x': -2.8792666876182453
    'sbg:y': 997.4334564892629
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
    'sbg:x': -4.562143325805664
    'sbg:y': 884.7412719726562
  knownsites:
    type: 'File[]'
    'sbg:x': 0
    'sbg:y': 771.28125
    secondaryFiles:
      - .tbi
  reference_dict:
    type: File
    'sbg:x': 0
    'sbg:y': 664.46875
  wgs_calling_interval_list:
    type: File
    'sbg:x': 0
    'sbg:y': 450.84375
  wgs_coverage_interval_list:
    type: File
    'sbg:x': 0
    'sbg:y': 344.03125
  wgs_evaluation_interval_list:
    type: File
    'sbg:x': 0
    'sbg:y': 237.21875
outputs:
  bqsr_report:
    outputSource:
      - gatk_gatherbqsrreports/output
    type: File
    'sbg:x': 1967.8353271484375
    'sbg:y': 1108.3125
  calculate_readgroup_checksum:
    outputSource:
      - picard_calculatereadgroupchecksum/output
    type: File
    'sbg:x': 2300.08544921875
    'sbg:y': 931.5
  collect_quality_yield_metrics:
    outputSource:
      - picard_collectqualityyieldmetrics/output
    type: 'File[]'
    'sbg:x': 604.9792033249576
    'sbg:y': 64.15863665300334
  collect_readgroupbam_quality_metrics:
    outputSource:
      - picard_collectreadgroupbamqualitymetrics/output1
    type: 'File[]'
    'sbg:x': 2300.08544921875
    'sbg:y': 611.0625
  collect_readgroupbam_quality_pdf:
    outputSource:
      - picard_collectreadgroupbamqualitymetrics/output2
    type: 'File[]'
    'sbg:x': 2300.08544921875
    'sbg:y': 504.25
  collect_unsortedreadgroup_bam_quality_metrics:
    outputSource:
      - picard_collectunsortedreadgroupbamqualitymetrics/output1
    type:
      type: array
      items:
        items: File
        type: array
    'sbg:x': 1184.6514892578125
    'sbg:y': 845.6875
  collect_unsortedreadgroup_bam_quality_metrics_pdf:
    outputSource:
      - picard_collectunsortedreadgroupbamqualitymetrics/output2
    type:
      type: array
      items:
        items: File
        type: array
    'sbg:x': 1184.6514892578125
    'sbg:y': 738.875
  collect_wgs_metrics:
    outputSource:
      - picard_collectwgsmetrics/output
    type: File
    'sbg:x': 2300.08544921875
    'sbg:y': 397.4375
  cram:
    outputSource:
      - samtools_coverttocram/output
    type: File
    'sbg:x': 2300.08544921875
    'sbg:y': 290.625
  gvcf:
    outputSource:
      - picard_mergevcfs/output
    type: File
    'sbg:x': 2658.66357421875
    'sbg:y': 557.65625
  picard_collect_gvcf_calling_metrics:
    outputSource:
      - picard_collectgvcfcallingmetrics/output
    type: 'File[]'
    'sbg:x': 1967.8353271484375
    'sbg:y': 490.25
  verifybamid_output:
    outputSource:
      - verifybamid/output
    type: File
    'sbg:x': 1660.0421142578125
    'sbg:y': 308.9375
  indexed_bam:
    outputSource:
      - sambamba_index/indexed_bam
    type: File?
    'sbg:x': 1184.6514892578125
    'sbg:y': 376.4375
  indexed_bam_1:
    outputSource:
      - picard_gatherbamfiles/output
    type: File?
    'sbg:x': 1967.8353271484375
    'sbg:y': 1001.5
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
    'sbg:x': 499.08453369140625
    'sbg:y': 545.1781600291748
  get_bwa_threads:
    in:
      input_files:
        source:
          - samtools_split/bam_files
    out: [threads]
    run: ../tools/get_bwa_threads.cwl
    label: get_bwa_threads
    'sbg:x': 391.53173828125
    'sbg:y': 389.2275695800781
  checkcontamination:
    in:
      verifybamid_selfsm:
        source:
          - verifybamid/output
    out: [contamination]
    run: ../tools/expression_checkcontamination.cwl
    label: checkcontamination
    'sbg:x': 1660.0421142578125
    'sbg:y': 806.375
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
    'sbg:x': 1192.3004460736213
    'sbg:y': -69.15762573773944
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
    'sbg:x': 1270.1716652364396
    'sbg:y': 493.65019980055854
  gatk_gatherbqsrreports:
    in:
      input_brsq_reports:
        source:
          - gatk_baserecalibrator/output
    out: [output]
    run: ../tools/gatk_gatherbqsrreports.cwl
    label: gatk-gatherbqsrreports
    'sbg:x': 1458.8999145978576
    'sbg:y': 366.1342441593146
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
    'sbg:x': 2058.994875477638
    'sbg:y': -225.0074935902676
  getbasename:
    in:
      input_file:
        source:
          - input_bam
    out: [file_basename]
    run: ../tools/expression_getbasename.cwl
    label: getbasename
    'sbg:x': 273.59375
    'sbg:y': 611.0625
  picard_calculatereadgroupchecksum:
    in:
      input_bam:
        source:
          - picard_gatherbamfiles/output
    out: [output]
    run: ../tools/picard_calculatereadgroupchecksum.cwl
    label: picard-calculatereadgroupchecksum
    'sbg:x': 1967.8353271484375
    'sbg:y': 597.0625
  picard_collectaggregationmetrics:
    in:
      input_bam:
        source:
          - picard_gatherbamfiles/output
    out: [output]
    run: ../tools/picard_calculatereadgroupchecksum.cwl
    label: picard-collectaggregationmetrics
    'sbg:x': 1967.8353271484375
    'sbg:y': 376.4375
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
    'sbg:x': 1466.3223876953125
    'sbg:y': 556.148193359375
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
    'sbg:x': 437.2231892531674
    'sbg:y': 233.69598810451788
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
    'sbg:x': 1967.8353271484375
    'sbg:y': 255.625
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
    'sbg:x': 706.4831063911197
    'sbg:y': 643.2006625867084
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
    'sbg:x': 1967.8353271484375
    'sbg:y': 127.8125
  picard_intervallisttools:
    in:
      interval_list:
        source:
          - wgs_calling_interval_list
    out: [output]
    run: ../tools/picard_intervallisttools.cwl
    label: picard-intervallisttools
    'sbg:x': 268.2514390609516
    'sbg:y': 484.66152655682265
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
    'sbg:x': 2300.08544921875
    'sbg:y': 176.8125
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
    'sbg:x': 1967.8353271484375
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
    'sbg:x': 1228.4080724558287
    'sbg:y': 228.86266323391195
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
    'sbg:x': 265.33909501488614
    'sbg:y': 365.3142842238705
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
    'sbg:x': 659.7952743985788
    'sbg:y': 331.5312208260948
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
    'sbg:x': 1006.7514476552177
    'sbg:y': 77.86111931975942
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
    'sbg:x': 831.9805831013398
    'sbg:y': 194.03217930237457
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
    'sbg:x': 1573.0633544921875
    'sbg:y': -268.5864562988281
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
    'sbg:x': 145.66845703125
    'sbg:y': 390.7940673828125
  python_createsequencegroups:
    in:
      ref_dict:
        source:
          - reference_dict
    out: [out_intervals]
    run: >-
      ../tools/python_createsequencegroups.cwl
    'sbg:x': 392.7905578613281
    'sbg:y': 1064.882568359375
label: kf-alignment-optimized

