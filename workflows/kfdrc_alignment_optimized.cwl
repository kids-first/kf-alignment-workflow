class: Workflow
cwlVersion: v1.0
id: bogdang_kf_alignment_wf_optimization_kf_alignment_46
label: kf-alignment-optimized
inputs:
  - id: contamination_sites_bed
    type: File
    'sbg:x': 893.4639892578125
    'sbg:y': 778.28125
  - id: contamination_sites_mu
    type: File
    'sbg:x': 893.4639892578125
    'sbg:y': 671.46875
  - id: contamination_sites_ud
    type: File
    'sbg:x': 893.4639892578125
    'sbg:y': 564.65625
  - id: dbsnp_vcf
    type: File
    'sbg:x': 1184.6514892578125
    'sbg:y': 632.0625
    secondaryFiles:
      - .idx
  - id: indexed_reference_fasta
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
  - id: input_bam
    type: File
    'sbg:x': -4.562143325805664
    'sbg:y': 884.7412719726562
  - id: knownsites
    type: 'File[]'
    'sbg:x': 0
    'sbg:y': 771.28125
    secondaryFiles:
      - .tbi
  - id: reference_dict
    type: File
    'sbg:x': 0
    'sbg:y': 664.46875
  - id: sequence_grouping_tsv
    type: File
    'sbg:x': 0
    'sbg:y': 557.65625
  - id: wgs_calling_interval_list
    type: File
    'sbg:x': 0
    'sbg:y': 450.84375
  - id: wgs_coverage_interval_list
    type: File
    'sbg:x': 0
    'sbg:y': 344.03125
  - id: wgs_evaluation_interval_list
    type: File
    'sbg:x': 0
    'sbg:y': 237.21875
outputs:
  - id: bqsr_report
    outputSource:
      - gatk_gatherbqsrreports/output
    type: File
    'sbg:x': 1967.8353271484375
    'sbg:y': 1108.3125
  - id: calculate_readgroup_checksum
    outputSource:
      - picard_calculatereadgroupchecksum/output
    type: File
    'sbg:x': 2300.08544921875
    'sbg:y': 931.5
  - id: collect_collect_aggregation_metrics
    outputSource:
      - picard_collectaggregationmetrics/output1
    type: 'File[]'
    'sbg:x': 2300.08544921875
    'sbg:y': 824.6875
  - id: collect_collect_aggregation_pdf
    outputSource:
      - picard_collectaggregationmetrics/output2
    type: 'File[]'
    'sbg:x': 2300.08544921875
    'sbg:y': 717.875
  - id: collect_quality_yield_metrics
    outputSource:
      - picard_collectqualityyieldmetrics/output
    type: 'File[]'
    'sbg:x': 604.9792033249576
    'sbg:y': 64.15863665300334
  - id: collect_readgroupbam_quality_metrics
    outputSource:
      - picard_collectreadgroupbamqualitymetrics/output1
    type: 'File[]'
    'sbg:x': 2300.08544921875
    'sbg:y': 611.0625
  - id: collect_readgroupbam_quality_pdf
    outputSource:
      - picard_collectreadgroupbamqualitymetrics/output2
    type: 'File[]'
    'sbg:x': 2300.08544921875
    'sbg:y': 504.25
  - id: collect_unsortedreadgroup_bam_quality_metrics
    outputSource:
      - picard_collectunsortedreadgroupbamqualitymetrics/output1
    type:
      type: array
      items:
        items: File
        type: array
    'sbg:x': 1184.6514892578125
    'sbg:y': 845.6875
  - id: collect_unsortedreadgroup_bam_quality_metrics_pdf
    outputSource:
      - picard_collectunsortedreadgroupbamqualitymetrics/output2
    type:
      type: array
      items:
        items: File
        type: array
    'sbg:x': 1184.6514892578125
    'sbg:y': 738.875
  - id: collect_wgs_metrics
    outputSource:
      - picard_collectwgsmetrics/output
    type: File
    'sbg:x': 2300.08544921875
    'sbg:y': 397.4375
  - id: cram
    outputSource:
      - samtools_coverttocram/output
    type: File
    'sbg:x': 2300.08544921875
    'sbg:y': 290.625
  - id: gvcf
    outputSource:
      - picard_mergevcfs/output
    type: File
    'sbg:x': 2658.66357421875
    'sbg:y': 557.65625
  - id: picard_collect_gvcf_calling_metrics
    outputSource:
      - picard_collectgvcfcallingmetrics/output
    type: 'File[]'
    'sbg:x': 1967.8353271484375
    'sbg:y': 490.25
  - id: verifybamid_output
    outputSource:
      - verifybamid/output
    type: File
    'sbg:x': 1660.0421142578125
    'sbg:y': 308.9375
  - id: indexed_bam
    outputSource:
      - sambamba_index/indexed_bam
    type: File?
    'sbg:x': 1184.6514892578125
    'sbg:y': 376.4375
  - id: indexed_bam_1
    outputSource:
      - picard_gatherbamfiles/output
    type: File?
    'sbg:x': 1967.8353271484375
    'sbg:y': 1001.5
steps:
  - id: bwa_mem
    in:
      - id: indexed_reference_fasta
        source:
          - indexed_reference_fasta
      - id: input_bam
        source:
          - samtools_split/bam_files
      - id: threads
        source:
          - get_bwa_threads/threads
    out:
      - id: output
      - id: rg
    run: ../tools/bwa_mem_samblaster_sambamba.cwl
    label: bwa-mem
    scatter:
      - input_bam
    'sbg:x': 499.08453369140625
    'sbg:y': 545.1781600291748
  - id: get_bwa_threads
    in:
      - id: input_files
        source:
          - samtools_split/bam_files
    out:
      - id: threads
    run: ../tools/get_bwa_threads.cwl
    label: get_bwa_threads
    'sbg:x': 386.3835754394531
    'sbg:y': 829.1324462890625
  - id: checkcontamination
    in:
      - id: verifybamid_selfsm
        source:
          - verifybamid/output
    out:
      - id: contamination
    run: ../tools/expression_checkcontamination.cwl
    label: checkcontamination
    'sbg:x': 1660.0421142578125
    'sbg:y': 806.375
  - id: createsequencegrouping
    in:
      - id: sequence_grouping_tsv
        source:
          - sequence_grouping_tsv
    out:
      - id: sequence_grouping_array
    run: ../tools/expression_createsequencegrouping.cwl
    label: createsequencegrouping
    'sbg:x': 275.37452031301615
    'sbg:y': 723.2173109390484
  - id: gatk_applybqsr
    in:
      - id: bqsr_report
        source:
          - gatk_gatherbqsrreports/output
      - id: input_bam
        source:
          - sambamba_index/indexed_bam
      - id: reference
        source:
          - indexed_reference_fasta
      - id: sequence_interval
        source:
          - createsequencegrouping/sequence_grouping_array
    out:
      - id: recalibrated_bam
    run: ../tools/gatk_applybqsr.cwl
    label: gatk-applybqsr
    scatter:
      - sequence_interval
    'sbg:x': 1192.3004460736213
    'sbg:y': -69.15762573773944
  - id: gatk_baserecalibrator
    in:
      - id: input_bam
        source:
          - sambamba_index/indexed_bam
      - id: knownsites
        source:
          - knownsites
      - id: reference
        source:
          - indexed_reference_fasta
      - id: sequence_interval
        source:
          - createsequencegrouping/sequence_grouping_array
    out:
      - id: output
    run: ../tools/gatk_baserecalibrator.cwl
    label: gatk-baserecalibrator
    scatter:
      - sequence_interval
    'sbg:x': 1270.1716652364396
    'sbg:y': 493.65019980055854
  - id: gatk_gatherbqsrreports
    in:
      - id: input_brsq_reports
        source:
          - gatk_baserecalibrator/output
    out:
      - id: output
    run: ../tools/gatk_gatherbqsrreports.cwl
    label: gatk-gatherbqsrreports
    'sbg:x': 1458.8999145978576
    'sbg:y': 366.1342441593146
  - id: gatk_haplotypecaller
    in:
      - id: contamination
        source:
          - checkcontamination/contamination
      - id: input_bam
        source:
          - picard_gatherbamfiles/output
      - id: interval_list
        source:
          - picard_intervallisttools/output
      - id: reference
        source:
          - indexed_reference_fasta
    out:
      - id: output
    run: ../tools/gatk_haplotypecaller_35.cwl
    label: gatk-haplotypecaller
    scatter:
      - interval_list
    'sbg:x': 2058.994875477638
    'sbg:y': -225.0074935902676
  - id: getbasename
    in:
      - id: input_file
        source:
          - input_bam
    out:
      - id: file_basename
    run: ../tools/expression_getbasename.cwl
    label: getbasename
    'sbg:x': 273.59375
    'sbg:y': 611.0625
  - id: picard_calculatereadgroupchecksum
    in:
      - id: input_bam
        source:
          - picard_gatherbamfiles/output
    out:
      - id: output
    run: ../tools/picard_calculatereadgroupchecksum.cwl
    label: picard-calculatereadgroupchecksum
    'sbg:x': 1967.8353271484375
    'sbg:y': 597.0625
  - id: picard_collectaggregationmetrics
    in:
      - id: input_bam
        source:
          - picard_gatherbamfiles/output
    out:
      - id: output
    run: ../tools/picard_calculatereadgroupchecksum.cwl
    label: picard-collectaggregationmetrics
    'sbg:x': 1967.8353271484375
    'sbg:y': 376.4375
  - id: picard_collectgvcfcallingmetrics
    in:
      - id: dbsnp_vcf
        source:
          - dbsnp_vcf
      - id: final_gvcf_base_name
        source:
          - getbasename/file_basename
      - id: input_vcf
        source:
          - picard_mergevcfs/output
      - id: reference_dict
        source:
          - reference_dict
      - id: wgs_evaluation_interval_list
        source:
          - wgs_evaluation_interval_list
    out:
      - id: output
    run: ../tools/picard_collectgvcfcallingmetrics.cwl
    label: picard-collectgvcfcallingmetrics
    'sbg:x': 1466.3223876953125
    'sbg:y': 556.148193359375
  - id: picard_collectqualityyieldmetrics
    in:
      - id: input_bam
        source:
          - samtools_split/bam_files
    out:
      - id: output
    run: ../tools/picard_collectqualityyieldmetrics.cwl
    label: picard-collectqualityyieldmetrics
    scatter:
      - input_bam
    'sbg:x': 437.2231892531674
    'sbg:y': 233.69598810451788
  - id: picard_collectreadgroupbamqualitymetrics
    in:
      - id: input_bam
        source:
          - picard_gatherbamfiles/output
      - id: reference
        source:
          - indexed_reference_fasta
    out:
      - id: output1
      - id: output2
    run: ../tools/picard_collectreadgroupbamqualitymetrics.cwl
    label: picard-collectreadgroupbamqualitymetrics
    'sbg:x': 1967.8353271484375
    'sbg:y': 255.625
  - id: picard_collectunsortedreadgroupbamqualitymetrics
    in:
      - id: input_bam
        source:
          - bwa_mem/output
    out:
      - id: output1
      - id: output2
    run: ../tools/picard_collectunsortedreadgroupbamqualitymetrics.cwl
    label: picard-collectunsortedreadgroupbamqualitymetrics
    scatter:
      - input_bam
    'sbg:x': 706.4831063911197
    'sbg:y': 643.2006625867084
  - id: picard_collectwgsmetrics
    in:
      - id: input_bam
        source:
          - picard_gatherbamfiles/output
      - id: intervals
        source:
          - wgs_coverage_interval_list
      - id: reference
        source:
          - indexed_reference_fasta
    out:
      - id: output
    run: ../tools/picard_collectwgsmetrics.cwl
    label: picard-collectwgsmetrics
    'sbg:x': 1967.8353271484375
    'sbg:y': 127.8125
  - id: picard_intervallisttools
    in:
      - id: interval_list
        source:
          - wgs_calling_interval_list
    out:
      - id: output
    run: ../tools/picard_intervallisttools.cwl
    label: picard-intervallisttools
    'sbg:x': 268.2514390609516
    'sbg:y': 484.66152655682265
  - id: picard_mergevcfs
    in:
      - id: input_vcf
        source:
          - gatk_haplotypecaller/output
      - id: output_vcf_basename
        source:
          - getbasename/file_basename
    out:
      - id: output
    run: ../tools/picard_mergevcfs.cwl
    label: picard-mergevcfs
    'sbg:x': 2300.08544921875
    'sbg:y': 176.8125
  - id: samtools_coverttocram
    in:
      - id: input_bam
        source:
          - picard_gatherbamfiles/output
      - id: reference
        source:
          - indexed_reference_fasta
    out:
      - id: output
    run: ../tools/samtools_covert_to_cram.cwl
    label: samtools-coverttocram
    'sbg:x': 1967.8353271484375
    'sbg:y': 0
  - id: verifybamid
    in:
      - id: contamination_sites_bed
        source:
          - contamination_sites_bed
      - id: contamination_sites_mu
        source:
          - contamination_sites_mu
      - id: contamination_sites_ud
        source:
          - contamination_sites_ud
      - id: input_bam
        source:
          - sambamba_index/indexed_bam
      - id: ref_fasta
        source:
          - indexed_reference_fasta
    out:
      - id: output
    run: ../tools/verifybamid.cwl
    label: verifybamid
    'sbg:x': 1228.4080724558287
    'sbg:y': 228.86266323391195
  - id: samtools_split
    in:
      - id: input_bam
        source:
          - samtools_cram2bam/bam_file
      - id: threads
        default: 36
    out:
      - id: bam_files
    run: ../tools/samtools_split.cwl
    label: Samtools split
    'sbg:x': 265.33909501488614
    'sbg:y': 365.3142842238705
  - id: sambamba_merge
    in:
      - id: bams
        source:
          - bwa_mem/output
      - id: num_of_threads
        default: 36
      - id: base_file_name
        source:
          - getbasename/file_basename
      - id: suffix
        default: aligned.duplicates_marked.sorted.bam
    out:
      - id: merged_bam
    run: ../tools/sambamba_merge.cwl
    label: Sambamba Merge
    'sbg:x': 659.7952743985788
    'sbg:y': 331.5312208260948
  - id: sambamba_index
    in:
      - id: bam
        source:
          - sambamba_sort/indexed_bam
      - id: num_of_threads
        default: 36
    out:
      - id: indexed_bam
    run: ../tools/sambamba_index.cwl
    label: Sambamba Index
    'sbg:x': 1006.7514476552177
    'sbg:y': 77.86111931975942
  - id: sambamba_sort
    in:
      - id: bam
        source:
          - sambamba_merge/merged_bam
      - id: num_of_threads
        default: 36
      - id: base_file_name
        source:
          - getbasename/file_basename
      - id: suffix
        default: aligned.duplicates_marked.sorted.bam
    out:
      - id: indexed_bam
    run: ../tools/sambamba_sort.cwl
    label: Sambamba Sort
    'sbg:x': 831.9805831013398
    'sbg:y': 194.03217930237457
  - id: picard_gatherbamfiles
    in:
      - id: input_bam
        source:
          - gatk_applybqsr/recalibrated_bam
      - id: output_bam_basename
        source:
          - getbasename/file_basename
    out:
      - id: output
    run: ../tools/picard_gatherbamfiles.cwl
    label: picard-gatherbamfiles
    'sbg:x': 1573.0633544921875
    'sbg:y': -268.5864562988281
  - id: samtools_cram2bam
    in:
      - id: input_reads
        source:
          - input_bam
      - id: threads
        default: 36
      - id: reference
        source:
          - indexed_reference_fasta
    out:
      - id: bam_file
    run: ../tools/samtools_cram2bam.cwl
    label: Samtools Cram2Bam
    'sbg:x': 145.66845703125
    'sbg:y': 390.7940673828125
hints:
  - class: 'sbg:AWSInstanceType'
    value: c4.8xlarge;ebs-gp2;1024
  - class: 'sbg:maxNumberOfParallelInstances'
    value: 4
requirements:
  - class: ScatterFeatureRequirement
