cwlVersion: v1.0
class: Workflow
id: kfdrc_bam_to_gvcf
requirements:
  - class: ScatterFeatureRequirement
  - class: MultipleInputFeatureRequirement
  - class: SubworkflowFeatureRequirement

inputs:
  biospecimen_name: string
  contamination: float?
  contamination_sites_bed: File
  contamination_sites_mu: File
  contamination_sites_ud: File
  input_bam: { type: File, secondaryFiles: ['^.bai'] }
  indexed_reference_fasta: { type: File, secondaryFiles: ['.fai', '^.dict'] }
  output_basename: string
  wgs_calling_interval_list: File
  dbsnp_vcf: File
  dbsnp_idx: File?
  reference_dict: File
  wgs_evaluation_interval_list: File
  conditional_run: int
  sample_ploidy: { type: 'int?', doc: "If sample/interval is expected to not have ploidy=2, enter expected ploidy" }

outputs:
  verifybamid_output: {type: File, outputSource: verifybamid_checkcontam_conditional/output}
  gvcf: {type: File, outputSource: picard_mergevcfs_python_renamesample/output}
  gvcf_calling_metrics: {type: 'File[]', outputSource: picard_collectgvcfcallingmetrics/output}

steps:
  index_dbsnp:
    run: ../tools/gatk_indexfeaturefile.cwl
    in:
      input_file: dbsnp_vcf
      input_index: dbsnp_idx
    out: [output]

  verifybamid_checkcontam_conditional:
    run: ../tools/verifybamid_contamination_conditional.cwl
    in:
      contamination_sites_bed: contamination_sites_bed
      contamination_sites_mu: contamination_sites_mu
      contamination_sites_ud: contamination_sites_ud
      precalculated_contamination: contamination
      input_bam: input_bam
      ref_fasta: indexed_reference_fasta
      output_basename: output_basename
    out: [output,contamination]

  picard_intervallisttools:
    run: ../tools/picard_intervallisttools.cwl
    in:
      interval_list: wgs_calling_interval_list
    out: [output]

  gatk_haplotypecaller:
    hints:
      - class: sbg:AWSInstanceType
        value: c5.4xlarge
    run: ../tools/gatk_haplotypecaller.cwl
    in:
      contamination: verifybamid_checkcontam_conditional/contamination
      input_bam: input_bam
      interval_list: picard_intervallisttools/output
      reference: indexed_reference_fasta
      sample_ploidy: sample_ploidy
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
      dbsnp_vcf: index_dbsnp/output
      final_gvcf_base_name: output_basename
      input_vcf: picard_mergevcfs_python_renamesample/output
      reference_dict: reference_dict
      wgs_evaluation_interval_list: wgs_evaluation_interval_list
    out: [output]

$namespaces:
  sbg: https://sevenbridges.com
hints:
  - class: 'sbg:maxNumberOfParallelInstances'
    value: 4
