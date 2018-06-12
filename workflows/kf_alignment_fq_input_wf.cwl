class: Workflow
cwlVersion: v1.0
id: kf_alignment_fq_input_wf
$namespaces:
  sbg: 'https://sevenbridges.com'
inputs:
  - id: contamination_sites_bed
    type: File
    'sbg:x': 778.8974609375
    'sbg:y': 588.5
  - id: contamination_sites_mu
    type: File
    'sbg:x': 778.8974609375
    'sbg:y': 481.5
  - id: contamination_sites_ud
    type: File
    'sbg:x': 778.8974609375
    'sbg:y': 374.5
  - id: dbsnp_vcf
    type: File
    'sbg:x': 1919.4324951171875
    'sbg:y': 488.5
  - id: files_R1
    type: 'File[]'
    'sbg:x': 0
    'sbg:y': 749
  - id: files_R2
    type: 'File[]'
    'sbg:x': 0
    'sbg:y': 642
  - id: indexed_reference_fasta
    type: File
    'sbg:x': 778.8974609375
    'sbg:y': 267.5
  - id: knownsites
    type: 'File[]'
    'sbg:x': 0
    'sbg:y': 535
  - id: output_basename
    type: string
    'sbg:x': 230.48321533203125
    'sbg:y': -81.9430923461914
  - id: reference_dict
    type: File
    'sbg:x': 0
    'sbg:y': 428
  - id: rgs
    type: 'string[]'
    'sbg:x': 0
    'sbg:y': 321
  - id: wgs_calling_interval_list
    type: File
    'sbg:x': 0
    'sbg:y': 214
  - id: wgs_coverage_interval_list
    type: File
    'sbg:x': 0
    'sbg:y': 107
  - id: wgs_evaluation_interval_list
    type: File
    'sbg:x': 0
    'sbg:y': 0
outputs:
  - id: aggregation_metrics
    outputSource:
      - picard_collectaggregationmetrics/output
    type: 'File[]'
    'sbg:x': 2487.080322265625
    'sbg:y': 535
  - id: bqsr_report
    outputSource:
      - gatk_gatherbqsrreports/output
    type: File
    'sbg:x': 1612.986328125
    'sbg:y': 502.5
  - id: cram
    outputSource:
      - samtools_coverttocram/output
    type: File
    'sbg:x': 2487.080322265625
    'sbg:y': 428
  - id: gvcf
    outputSource:
      - picard_mergevcfs/output
    type: File
    'sbg:x': 2179.287109375
    'sbg:y': 637.5
  - id: gvcf_calling_metrics
    outputSource:
      - picard_collectgvcfcallingmetrics/output
    type: 'File[]'
    'sbg:x': 2487.080322265625
    'sbg:y': 321
  - id: verifybamid_output
    outputSource:
      - verifybamid/output
    type: File
    'sbg:x': 1346.017578125
    'sbg:y': 260.5
  - id: wgs_metrics
    outputSource:
      - picard_collectwgsmetrics/output
    type: File
    'sbg:x': 2487.080322265625
    'sbg:y': 214
steps:
  - id: bwa_mem
    in:
      - id: files_R1
        source:
          - files_R1
      - id: files_R2
        source:
          - files_R2
      - id: ref
        source: indexed_reference_fasta
      - id: rgs
        source:
          - rgs
    out:
      - id: aligned_bams
    run: ../workflows/bwa_mem_fq_subwf.cwl
    'sbg:x': 306.4060363769531
    'sbg:y': 489.4462890625
  - id: checkcontamination
    in:
      - id: verifybamid_selfsm
        source: verifybamid/output
    out:
      - id: contamination
    run: ../tools/expression_checkcontamination.cwl
    'sbg:x': 1346.017578125
    'sbg:y': 488.5
  - id: gatk_applybqsr
    in:
      - id: bqsr_report
        source: gatk_gatherbqsrreports/output
      - id: input_bam
        source: sambamba_sort/sorted_bam
      - id: reference
        source: indexed_reference_fasta
      - id: sequence_interval
        source: python_createsequencegroups/out_intervals
    out:
      - id: recalibrated_bam
    run: ../tools/gatk_applybqsr.cwl
    scatter:
      - sequence_interval
    'sbg:x': 1612.986328125
    'sbg:y': 374.5
  - id: gatk_baserecalibrator
    in:
      - id: input_bam
        source: sambamba_sort/sorted_bam
      - id: knownsites
        source:
          - knownsites
      - id: reference
        source: indexed_reference_fasta
      - id: sequence_interval
        source: python_createsequencegroups/out_intervals
    out:
      - id: output
    run: ../tools/gatk_baserecalibrator.cwl
    scatter:
      - sequence_interval
    'sbg:x': 1027.6739501953125
    'sbg:y': 428
  - id: gatk_gatherbqsrreports
    in:
      - id: input_brsq_reports
        source:
          - gatk_baserecalibrator/output
      - id: output_basename
        source: output_basename
    out:
      - id: output
    run: ../tools/gatk_gatherbqsrreports.cwl
    'sbg:x': 1346.017578125
    'sbg:y': 374.5
  - id: gatk_haplotypecaller
    in:
      - id: contamination
        source: checkcontamination/contamination
      - id: input_bam
        source: picard_gatherbamfiles/output
      - id: interval_list
        source: picard_intervallisttools/output
      - id: reference
        source: indexed_reference_fasta
    out:
      - id: output
    run: ../tools/gatk_haplotypecaller.cwl
    scatter:
      - interval_list
    'sbg:x': 1612.986328125
    'sbg:y': 225.5
  - id: picard_collectaggregationmetrics
    in:
      - id: input_bam
        source: picard_gatherbamfiles/output
      - id: reference
        source: indexed_reference_fasta
    out:
      - id: output
    run: ../tools/picard_collectaggregationmetrics.cwl
    'sbg:x': 2179.287109375
    'sbg:y': 523.5
  - id: picard_collectgvcfcallingmetrics
    in:
      - id: dbsnp_vcf
        source: dbsnp_vcf
      - id: final_gvcf_base_name
        source: output_basename
      - id: input_vcf
        source: picard_mergevcfs/output
      - id: reference_dict
        source: reference_dict
      - id: wgs_evaluation_interval_list
        source: wgs_evaluation_interval_list
    out:
      - id: output
    run: ../tools/picard_collectgvcfcallingmetrics.cwl
    'sbg:x': 2179.287109375
    'sbg:y': 381.5
  - id: picard_collectwgsmetrics
    in:
      - id: input_bam
        source: picard_gatherbamfiles/output
      - id: intervals
        source: wgs_coverage_interval_list
      - id: reference
        source: indexed_reference_fasta
    out:
      - id: output
    run: ../tools/picard_collectwgsmetrics.cwl
    'sbg:x': 2179.287109375
    'sbg:y': 232.5
  - id: picard_gatherbamfiles
    in:
      - id: input_bam
        source:
          - gatk_applybqsr/recalibrated_bam
      - id: output_bam_basename
        source: output_basename
    out:
      - id: output
    run: ../tools/picard_gatherbamfiles.cwl
    'sbg:x': 1919.4324951171875
    'sbg:y': 374.5
  - id: picard_intervallisttools
    in:
      - id: interval_list
        source: wgs_calling_interval_list
    out:
      - id: output
    run: ../tools/picard_intervallisttools.cwl
    'sbg:x': 273.59375
    'sbg:y': 300
  - id: picard_mergevcfs
    in:
      - id: input_vcf
        source:
          - gatk_haplotypecaller/output
      - id: output_vcf_basename
        source: output_basename
    out:
      - id: output
    run: ../tools/picard_mergevcfs.cwl
    'sbg:x': 1919.4324951171875
    'sbg:y': 253.5
  - id: python_createsequencegroups
    in:
      - id: ref_dict
        source: reference_dict
    out:
      - id: out_intervals
    run: ../tools/python_createsequencegroups.cwl
    'sbg:x': 273.59375
    'sbg:y': 193
  - id: sambamba_merge
    in:
      - id: bams
        source:
          - bwa_mem/aligned_bams
      - id: base_file_name
        source: output_basename
    out:
      - id: merged_bam
    run: ../tools/sambamba_merge_one.cwl
    'sbg:x': 547.0738525390625
    'sbg:y': 391.1107482910156
  - id: sambamba_sort
    in:
      - id: bam
        source: sambamba_merge/merged_bam
      - id: base_file_name
        source: output_basename
    out:
      - id: sorted_bam
    run: ../tools/sambamba_sort.cwl
    'sbg:x': 811.4060668945312
    'sbg:y': 107.44630432128906
  - id: samtools_coverttocram
    in:
      - id: input_bam
        source: picard_gatherbamfiles/output
      - id: reference
        source: indexed_reference_fasta
    out:
      - id: output
    run: ../tools/samtools_covert_to_cram.cwl
    'sbg:x': 2179.287109375
    'sbg:y': 104.5
  - id: verifybamid
    in:
      - id: contamination_sites_bed
        source: contamination_sites_bed
      - id: contamination_sites_mu
        source: contamination_sites_mu
      - id: contamination_sites_ud
        source: contamination_sites_ud
      - id: input_bam
        source: sambamba_sort/sorted_bam
      - id: output_basename
        source: output_basename
      - id: ref_fasta
        source: indexed_reference_fasta
    out:
      - id: output
    run: ../tools/verifybamid.cwl
    'sbg:x': 1060.406005859375
    'sbg:y': 216.4093780517578
hints:
  - class: 'sbg:AWSInstanceType'
    value: c4.8xlarge;ebs-gp2;850
  - class: 'sbg:maxNumberOfParallelInstances'
    value: 4
requirements:
  - class: SubworkflowFeatureRequirement
  - class: ScatterFeatureRequirement
