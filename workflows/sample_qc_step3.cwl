cwlVersion: v1.0
class: Workflow
id: paired_sample_qc_step3
requirements:
  - class: ScatterFeatureRequirement
  - class: MultipleInputFeatureRequirement
inputs:
  input_gvcf: File
  reference_dict: File
  final_gvcf_base_name: string
  dbsnp_vcf: File
  wgs_evaluation_interval_list: File
  reference: File
  wgs_calling_interval_list: File

outputs:
  picard_collect_gvcfcalling_metrics:
    type: File[]
    outputSource: picard_collectgvcfcallingmetrics/output
steps:
 picard_collectgvcfcallingmetrics:
    run: ../tools/picard_collectgvcfcallingmetrics.cwl
    in:
      input_vcf: input_gvcf
      reference_dict: reference_dict
      final_gvcf_base_name: final_gvcf_base_name
      dbsnp_vcf: dbsnp_vcf
      wgs_evaluation_interval_list: wgs_evaluation_interval_list
    out: [output]
 gatk_validategvcf:
    run: ../tools/gatk_validategvcf.cwl
    in:
      input_vcf: input_gvcf
      reference: reference
      wgs_calling_interval_list: wgs_calling_interval_list
      dbsnp_vcf: dbsnp_vcf
    out: []
