cwlVersion: v1.0
class: Workflow
id: kf-cram2gvcf-custom
requirements:
  - class: ScatterFeatureRequirement
  - class: MultipleInputFeatureRequirement
  - class: SubworkflowFeatureRequirement

inputs:
  input_cram: File
  biospecimen_name: string
  output_basename: string
  indexed_reference_fasta: File
  dbsnp_vcf: File
  reference_dict: File
  contamination: float
  wgs_calling_interval_list: File
  wgs_evaluation_interval_list: File

outputs:
  gvcf: {type: File, outputSource: picard_mergevcfs_python_renamesample/output}
  gvcf_calling_metrics: {type: 'File[]', outputSource: picard_collectgvcfcallingmetrics/output}

steps:
  picard_intervallisttools:
    run: ../tools/picard_intervallisttools.cwl
    in:
      interval_list: wgs_calling_interval_list
    out: [output]
  samtools_cram_to_bam:
    run: ../tools/samtools_cram_to_bam.cwl
    in:
      input_cram: input_cram
      output_basename: output_basename
      reference: indexed_reference_fasta
    out: [output]
  gatk_haplotypecaller:
    run: ../tools/gatk_haplotypecaller.cwl
    in:
      contamination: contamination
      input_bam: samtools_cram_to_bam/output
      interval_list: picard_intervallisttools/output
      reference: indexed_reference_fasta
    scatter: [interval_list]
    out: [output]

  picard_mergevcfs_python_renamesample:
    run: ../tools/picard_mergevcfs_python_renamesample.cwl
    in:
      input_vcf: gatk_haplotypecaller/output
      output_vcf_basename: output_basename
      biospecimen_name: biospecimen_name
    out: [output]

  picard_collectgvcfcallingmetrics:
    run: ../tools/picard_collectgvcfcallingmetrics.cwl
    in:
      dbsnp_vcf: dbsnp_vcf
      final_gvcf_base_name: output_basename
      input_vcf: picard_mergevcfs_python_renamesample/output
      reference_dict: reference_dict
      wgs_evaluation_interval_list: wgs_evaluation_interval_list
    out: [output]

$namespaces:
  sbg: https://sevenbridges.com
hints:
  - class: 'sbg:AWSInstanceType'
    value: c4.8xlarge;ebs-gp2;400
  - class: 'sbg:maxNumberOfParallelInstances'
    value: 4
