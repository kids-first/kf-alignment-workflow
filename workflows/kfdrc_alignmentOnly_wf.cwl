class: Workflow
cwlVersion: v1.0
id: kf_alignment_optimized_wf
inputs:
  - id: contamination_sites_bed
    type: File
    'sbg:x': 1026.720458984375
    'sbg:y': 434.0625
  - id: contamination_sites_mu
    type: File
    'sbg:x': 1026.720458984375
    'sbg:y': 327.296875
  - id: contamination_sites_ud
    type: File
    'sbg:x': 1026.720458984375
    'sbg:y': 220.53125
  - id: indexed_reference_fasta
    type: File
    'sbg:x': 0
    'sbg:y': 327.296875
  - id: input_reads
    type: File
    'sbg:x': 0
    'sbg:y': 220.53125
  - id: knownsites
    type: 'File[]'
    'sbg:x': 1026.720458984375
    'sbg:y': 113.765625
  - id: output_basename
    type: string
    'sbg:x': 456.40155029296875
    'sbg:y': 153.1484375
  - id: reference_dict
    type: File
    'sbg:x': 0
    'sbg:y': 113.765625
  - id: wgs_coverage_interval_list
    type: File
    'sbg:x': 2134.750732421875
    'sbg:y': 160.1484375
  - id: sample_name
    type: string
    'sbg:x': 247.3125
    'sbg:y': 220.53125
outputs:
  - id: aggregation_metrics
    outputSource:
      - picard_collectaggregationmetrics/output
    type: 'File[]'
    'sbg:x': 2600.26171875
    'sbg:y': 327.296875
  - id: bqsr_report
    outputSource:
      - gatk_gatherbqsrreports/output
    type: File
    'sbg:x': 1828.304443359375
    'sbg:y': 273.9140625
  - id: cram
    outputSource:
      - samtools_coverttocram/output
    type: File
    'sbg:x': 2600.26171875
    'sbg:y': 220.53125
  - id: verifybamid_output
    outputSource:
      - verifybamid/output
    type: File
    'sbg:x': 1593.840576171875
    'sbg:y': 160.1484375
  - id: wgs_metrics
    outputSource:
      - picard_collectwgsmetrics/output
    type: File
    'sbg:x': 2600.26171875
    'sbg:y': 113.765625
steps:
  - id: bwa_mem
    in:
      - id: indexed_reference_fasta
        source:
          - indexed_reference_fasta
      - id: input_reads
        source:
          - samtools_split/bam_files
      - id: sample_name
        source:
          - sample_name
    out:
      - id: aligned_bams
    run: ../workflows/kfdrc_bwamem_subwf.cwl
    scatter:
      - input_reads
    'sbg:x': 456.40155029296875
    'sbg:y': 273.9140625
  - id: gatk_applybqsr
    in:
      - id: bqsr_report
        source:
          - gatk_gatherbqsrreports/output
      - id: input_bam
        source:
          - sambamba_sort/sorted_bam
      - id: reference
        source:
          - indexed_reference_fasta
      - id: sequence_interval
        source:
          - python_createsequencegroups/out_intervals
    out:
      - id: recalibrated_bam
    run: ../tools/gatk_applybqsr.cwl
    scatter:
      - sequence_interval
    'sbg:x': 1828.304443359375
    'sbg:y': 146.1484375
  - id: gatk_baserecalibrator
    in:
      - id: input_bam
        source:
          - sambamba_sort/sorted_bam
      - id: knownsites
        source:
          - knownsites
      - id: reference
        source:
          - indexed_reference_fasta
      - id: sequence_interval
        source:
          - python_createsequencegroups/out_intervals
    out:
      - id: output
    run: ../tools/gatk_baserecalibrator.cwl
    scatter:
      - sequence_interval
    'sbg:x': 1275.496826171875
    'sbg:y': 273.9140625
  - id: gatk_gatherbqsrreports
    in:
      - id: input_brsq_reports
        source:
          - gatk_baserecalibrator/output
      - id: output_basename
        source:
          - output_basename
    out:
      - id: output
    run: ../tools/gatk_gatherbqsrreports.cwl
    'sbg:x': 1593.840576171875
    'sbg:y': 273.9140625
  - id: picard_collectaggregationmetrics
    in:
      - id: input_bam
        source:
          - picard_gatherbamfiles/output
      - id: reference
        source:
          - indexed_reference_fasta
    out:
      - id: output
    run: ../tools/picard_collectaggregationmetrics.cwl
    'sbg:x': 2400.235107421875
    'sbg:y': 341.296875
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
    'sbg:x': 2400.235107421875
    'sbg:y': 213.53125
  - id: picard_gatherbamfiles
    in:
      - id: input_bam
        source:
          - gatk_applybqsr/recalibrated_bam
      - id: output_bam_basename
        source:
          - output_basename
    out:
      - id: output
    run: ../tools/picard_gatherbamfiles.cwl
    'sbg:x': 2134.750732421875
    'sbg:y': 273.9140625
  - id: python_createsequencegroups
    in:
      - id: ref_dict
        source:
          - reference_dict
    out:
      - id: out_intervals
    run: ../tools/python_createsequencegroups.cwl
    'sbg:x': 247.3125
    'sbg:y': 327.296875
  - id: sambamba_merge
    in:
      - id: bams
        source:
          - bwa_mem/aligned_bams
      - id: base_file_name
        source:
          - output_basename
    out:
      - id: merged_bam
    run: ../tools/sambamba_merge.cwl
    'sbg:x': 770.8032836914062
    'sbg:y': 213.53125
  - id: sambamba_sort
    in:
      - id: bam
        source:
          - sambamba_merge/merged_bam
      - id: base_file_name
        source:
          - output_basename
    out:
      - id: sorted_bam
    run: ../tools/sambamba_sort.cwl
    'sbg:x': 1026.720458984375
    'sbg:y': 0
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
    'sbg:x': 2400.235107421875
    'sbg:y': 85.765625
  - id: samtools_split
    in:
      - id: input_bam
        source:
          - input_reads
      - id: reference
        source:
          - indexed_reference_fasta
    out:
      - id: bam_files
    run: ../tools/samtools_split.cwl
    'sbg:x': 247.3125
    'sbg:y': 106.76561737060547
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
          - sambamba_sort/sorted_bam
      - id: output_basename
        source:
          - output_basename
      - id: ref_fasta
        source:
          - indexed_reference_fasta
    out:
      - id: output
    run: ../tools/verifybamid.cwl
    'sbg:x': 1275.496826171875
    'sbg:y': 111.1484375
hints:
  - class: 'sbg:AWSInstanceType'
    value: c4.8xlarge;ebs-gp2;850
  - class: 'sbg:maxNumberOfParallelInstances'
    value: 4
$namespaces:
  sbg: 'https://sevenbridges.com'
requirements:
  - class: ScatterFeatureRequirement
  - class: MultipleInputFeatureRequirement
  - class: SubworkflowFeatureRequirement
