cwlVersion: v1.0
class: Workflow
id: scatter_haplotypecaller
requirements:
  - class: ScatterFeatureRequirement
hints:
  - class: sbg:AWSInstanceType
    value: m2.2xlarge
  - class: sbg:maxNumberOfParallelInstances
    value: 15
inputs:
  verifybamid_selfsm: File
  picard_gatherbamfiles_output:
    type: File
    secondaryFiles: [^.bai]
  base_file_name: string
  indexed_reference_fasta:
    type: File
    secondaryFiles: [.64.amb, .64.ann, .64.bwt, .64.pac, .64.sa,
    ^.dict, .amb, .ann, .bwt, .pac, .sa, .fai]
  wgs_coverage_interval_list: File
  wgs_calling_interval_list: File
  reference_dict: File
  wgs_evaluation_interval_list: File
  dbsnp_vcf:
    type: File
    secondaryFiles: [.idx]
outputs:
  gvcf:
    type: File
    outputSource: picard_mergevcfs/output
  cram:
    type: File
    outputSource: samtools_coverttocram/output
  collect_collect_aggregation_metrics:
    type: File[]
    outputSource: picard_collectaggregationmetrics/output1
  collect_collect_aggregation_pdf:
    type: File[]
    outputSource: picard_collectaggregationmetrics/output2
  collect_wgs_metrics:
    type: File
    outputSource: picard_collectwgsmetrics/output
  collect_readgroupbam_quality_metrics:
    type: File[]
    outputSource: picard_collectreadgroupbamqualitymetrics/output1
  collect_readgroupbam_quality_pdf:
    type: File[]
    outputSource: picard_collectreadgroupbamqualitymetrics/output2
  picard_collect_gvcf_calling_metrics:
    type: File[]
    outputSource: picard_collectgvcfcallingmetrics/output
steps:
  picard_collectaggregationmetrics:
    run: ../tools_withsrc/picard_collectaggregationmetrics.cwl
    in:
      input_bam: picard_gatherbamfiles_output
      reference: indexed_reference_fasta
    out: [output1, output2]

  picard_collectreadgroupbamqualitymetrics:
    run: ../tools_withsrc/picard_collectreadgroupbamqualitymetrics.cwl
    in:
      input_bam: picard_gatherbamfiles_output
      reference: indexed_reference_fasta
    out: [output1, output2]

  picard_collectwgsmetrics:
    run: ../tools_withsrc/picard_collectwgsmetrics.cwl
    in:
      input_bam: picard_gatherbamfiles_output
      reference: indexed_reference_fasta
      intervals: wgs_coverage_interval_list
    out: [output]

  samtools_coverttocram:
    run: ../tools_withsrc/samtools_covert_to_cram.cwl
    in:
      input_bam: picard_gatherbamfiles_output
      reference: indexed_reference_fasta
    out: [output]

  picard_intervallisttools:
    run: ../tools_withsrc/picard_intervallisttools.cwl
    in:
      interval_list: wgs_calling_interval_list
    out: [output]

  checkcontamination:
    run: ../tools_withsrc/expression_checkcontamination.cwl
    in: 
      verifybamid_selfsm: verifybamid_selfsm
    out: [contamination]

  gatk_haplotypecaller:
    run: ../tools_withsrc/gatk_haplotypecaller.cwl
    in:
      reference: indexed_reference_fasta
      input_bam: picard_gatherbamfiles_output
      interval_list: picard_intervallisttools/output
      contamination: checkcontamination/contamination
    scatter: [interval_list]
    out: [output]

  picard_mergevcfs:
    run: ../tools_withsrc/picard_mergevcfs.cwl
    in:
      input_vcf: gatk_haplotypecaller/output
      output_vcf_basename: base_file_name
    out:
      [output]

  picard_collectgvcfcallingmetrics:
    run: ../tools_withsrc/picard_collectgvcfcallingmetrics.cwl
    in:
      input_vcf: picard_mergevcfs/output
      reference_dict: reference_dict
      final_gvcf_base_name: base_file_name
      dbsnp_vcf: dbsnp_vcf
      wgs_evaluation_interval_list: wgs_evaluation_interval_list
    out: [output]

  gatk_validategvcf:
    run: ../tools_withsrc/gatk_validategvcf.cwl
    in:
      input_vcf: picard_mergevcfs/output
      reference: indexed_reference_fasta
      wgs_calling_interval_list: wgs_calling_interval_list
      dbsnp_vcf: dbsnp_vcf
    out: []
