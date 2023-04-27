cwlVersion: v1.2
class: Workflow
id: kfdrc-gatk-haplotypecaller-ploidy-mod-workflow
label: Kids First DRC GATK HaplotypeCaller Modified Ploidy Workflow
doc: "This workflow re-runs a subset of regions with a different expected ploidy and re-integrates those results into existing results"

requirements:
- class: ScatterFeatureRequirement
- class: MultipleInputFeatureRequirement
- class: SubworkflowFeatureRequirement
inputs:
  input_cram: {type: 'File', doc: "Input CRAM file"}
  input_gvcf: { type: File, secondaryFiles: ['.tbi'], doc: "gVCF generated in standard workflow"}
  biospecimen_name: {type: 'string', doc: "String name of biospecimen"}
  output_basename: {type: 'string', doc: "String to use as the base for output filenames"}
  reference_tar: {type: 'File', doc: "Tar file containing a reference fasta and, optionally,\
      \ its complete set of associated indexes (samtools, bwa, and picard)", "sbg:suggestedValue": {
      class: File, path: 5f4ffff4e4b0370371c05153, name: Homo_sapiens_assembly38.tgz}}
  dbsnp_vcf: {type: 'File', doc: "dbSNP vcf file", "sbg:suggestedValue": {class: File,
      path: 6063901f357c3a53540ca84b, name: Homo_sapiens_assembly38.dbsnp138.vcf}}
  dbsnp_idx: {type: 'File?', doc: "dbSNP vcf index file", "sbg:suggestedValue": {
      class: File, path: 6063901e357c3a53540ca834, name: Homo_sapiens_assembly38.dbsnp138.vcf.idx}}
  contamination: {type: 'float?', doc: "Precalculated contamination value. Providing\
      \ the value here will skip the run of VerifyBAMID and use the provided value\
      \ as ground truth."}
  contamination_sites_bed: {type: 'File?', doc: ".Bed file for markers used in this\
      \ analysis,format(chr\tpos-1\tpos\trefAllele\taltAllele)", "sbg:suggestedValue": {
      class: File, path: 6063901e357c3a53540ca833, name: Homo_sapiens_assembly38.contam.bed}}
  contamination_sites_mu: {type: 'File?', doc: ".mu matrix file of genotype matrix",
    "sbg:suggestedValue": {class: File, path: 60639017357c3a53540ca7cd, name: Homo_sapiens_assembly38.contam.mu}}
  contamination_sites_ud: {type: 'File?', doc: ".UD matrix file from SVD result of\
      \ genotype matrix", "sbg:suggestedValue": {class: File, path: 6063901f357c3a53540ca84f,
      name: Homo_sapiens_assembly38.contam.UD}}
  re_calling_interval_list: {type: 'File', doc: "Interval list to re-call" }
  wgs_evaluation_interval_list: {type: 'File', doc: "Target intervals to restrict\
      \ gvcf metric analysis (for VariantCallingMetrics)", "sbg:suggestedValue": {
      class: File, path: 60639017357c3a53540ca7d3, name: wgs_evaluation_regions.hg38.interval_list}}
  run_sex_metrics: {type: 'boolean?', default: false, doc: "idxstats will be collected\
      \ and X/Y ratios calculated"}
  sample_ploidy: { type: 'int?', doc: "If sample/interval is expected to not have ploidy=2, enter expected ploidy" }

outputs:
  mixed_ploidy_gvcf: {type: File, outputSource: generate_gvcf/gvcf}

steps:
  gatk_intervallisttools:
    run: ../tools/gatk_intervallisttool.cwl
    in:
      interval_list: re_calling_interval_list
      reference_dict: prepare_reference/reference_dict
      exome_flag: choose_defaults/out_exome_flag
      scatter_ct:
        valueFrom: ${return 50}
      bands:
        valueFrom: ${return 80000000}
    out: [output]