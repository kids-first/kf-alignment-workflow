cwlVersion: v1.2
class: Workflow
id: kfdrc-gatk-haplotypecaller-ploidy-mod-workflow
label: Kids First DRC GATK HaplotypeCaller Modified Ploidy BETA Workflow
doc: |
  # Kids First DRC GATK HaplotypeCaller Modified Ploidy BETA Workflow
  This is a research workflow for users wishing to modify the ploidy of certain
  regions of their existing GVCF calls.

  ## Inputs
  ### Ploidy-related
  - input_gvcf: GVCF generated in standard workflow
  - region: Specific region to pull, in format 'chr21' or 'chr3:1-1000'
  - re_calling_interval_list: Interval list to re-call
  - sample_ploidy: If sample/interval is expected to not have ploidy=2, enter expected ploidy
  > For example, for trisomy 21, one might do:
  >- region = chr21
  >- sample_ploidy = 3
  >- re_calling_interval_list = the regions of chr21 that are expected to be ploidy = 3
  ### Typical haplotype calling
  - input_cram: Input CRAM file
  - biospecimen_name: String name of biospcimen
  - output_basename: String to use as the base for output filenames
  - reference_fasta: FASTA file that was used during alignment. Also need
    corresponding `.fai` and `.dict` files.
  - dbsnp_vcf: dbSNP vcf file
  - dbsnp_idx: dbSNP vcf index file
  - contamination: Precalculated contamination value. Providing the value here
    will skip the run of VerifyBAMID and use the provided value as ground truth.
  - contamination_sites_bed: .Bed file for markers used in this
    analysis,format(chr\tpos-1\tpos\trefAllele\taltAllele)
  - contamination_sites_mu: .mu matrix file of genotype matrix
  - contamination_sites_ud: .UD matrix file from SVD result of genotype matrix
  - wgs_evaluation_interval_list: Target intervals to restrict GVCF metric
    analysis (for VariantCallingMetrics)

  ## Outputs

  - mixed_ploidy_gvcf: Updated complete GVCF in which the desired region has had its ploidy updated


requirements:
- class: ScatterFeatureRequirement
- class: MultipleInputFeatureRequirement
- class: SubworkflowFeatureRequirement
- class: InlineJavascriptRequirement
- class: StepInputExpressionRequirement
inputs:
  input_cram: {type: File, doc: "Input CRAM file", secondaryFiles: ['.crai']}
  input_gvcf: {type: File, secondaryFiles: ['.tbi'], doc: "gVCF generated in standard workflow"}
  biospecimen_name: {type: 'string', doc: "String name of biospecimen"}
  output_basename: {type: 'string', doc: "String to use as the base for output filenames"}
  reference_fasta: {type: 'File', "sbg:suggestedValue": {class: File, path: 60639014357c3a53540ca7a3, name: Homo_sapiens_assembly38.fasta,
      secondaryFiles: [{class: File, path: 60639016357c3a53540ca7af, name: Homo_sapiens_assembly38.fasta.fai}, {class: File, path: 60639019357c3a53540ca7e7,
          name: Homo_sapiens_assembly38.dict}]}, secondaryFiles: ['.fai', '^.dict']}
  region: {type: 'string?', doc: "Specific region to pull, in format 'chr21' or 'chr3:1-1000'"}
  dbsnp_vcf: {type: 'File', doc: "dbSNP vcf file", "sbg:suggestedValue": {class: File, path: 6063901f357c3a53540ca84b, name: Homo_sapiens_assembly38.dbsnp138.vcf}}
  dbsnp_idx: {type: 'File?', doc: "dbSNP vcf index file", "sbg:suggestedValue": {class: File, path: 6063901e357c3a53540ca834, name: Homo_sapiens_assembly38.dbsnp138.vcf.idx}}
  contamination: {type: 'float?', doc: "Precalculated contamination value. Providing the value here will skip the run of VerifyBAMID
      and use the provided value as ground truth."}
  contamination_sites_bed: {type: 'File?', doc: ".Bed file for markers used in this analysis,format(chr\tpos-1\tpos\trefAllele\taltAllele)",
    "sbg:suggestedValue": {class: File, path: 6063901e357c3a53540ca833, name: Homo_sapiens_assembly38.contam.bed}}
  contamination_sites_mu: {type: 'File?', doc: ".mu matrix file of genotype matrix", "sbg:suggestedValue": {class: File, path: 60639017357c3a53540ca7cd,
      name: Homo_sapiens_assembly38.contam.mu}}
  contamination_sites_ud: {type: 'File?', doc: ".UD matrix file from SVD result of genotype matrix", "sbg:suggestedValue": {class: File,
      path: 6063901f357c3a53540ca84f, name: Homo_sapiens_assembly38.contam.UD}}
  re_calling_interval_list: {type: 'File', doc: "Interval list to re-call"}
  wgs_evaluation_interval_list: {type: 'File', doc: "Target intervals to restrict gvcf metric analysis (for VariantCallingMetrics)",
    "sbg:suggestedValue": {class: File, path: 60639017357c3a53540ca7d3, name: wgs_evaluation_regions.hg38.interval_list}}
  sample_ploidy: {type: 'int?', doc: "If sample/interval is expected to not have ploidy=2, enter expected ploidy"}

outputs:
  mixed_ploidy_gvcf: {type: File, outputSource: bcftools_amend_header/header_amended_vcf}

steps:
  gatk_intervallist_to_bed:
    run: ../tools/gatk_intervallist_to_bed.cwl
    in:
      interval_list: re_calling_interval_list
    out: [output]
  bedtools_intersect:
    run: ../tools/bedtools_intersect.cwl
    in:
      input_vcf: input_gvcf
      input_bed_file: gatk_intervallist_to_bed/output
      output_basename: output_basename
      inverse:
        valueFrom: ${ return 1==1 }
    out: [intersected_vcf]
  samtools_cram_to_bam:
    run: ../tools/samtools_cram_to_bam.cwl
    in:
      input_cram: input_cram
      output_basename: output_basename
      reference: reference_fasta
      region: region
      threads:
        valueFrom: ${ return 16 }
    out: [output]
  generate_gvcf:
    run: ../subworkflows/kfdrc_bam_to_gvcf.cwl
    in:
      contamination_sites_ud: contamination_sites_ud
      contamination_sites_mu: contamination_sites_mu
      contamination_sites_bed: contamination_sites_bed
      input_bam: samtools_cram_to_bam/output
      indexed_reference_fasta: reference_fasta
      output_basename: output_basename
      dbsnp_vcf: dbsnp_vcf
      dbsnp_idx: dbsnp_idx
      reference_dict:
        source: reference_fasta
        valueFrom: "$(self.secondaryFiles.filter(function(e) {return e.nameext == '.dict'})[0])"
      wgs_calling_interval_list: re_calling_interval_list
      wgs_evaluation_interval_list: wgs_evaluation_interval_list
      conditional_run:
        valueFrom: $(1)
      contamination: contamination
      biospecimen_name: biospecimen_name
      sample_ploidy: sample_ploidy
    out: [verifybamid_output, gvcf, gvcf_calling_metrics]
  picard_mergevcfs:
    run: ../tools/picard_mergevcfs.cwl
    hints:
    - class: 'sbg:AWSInstanceType'
      value: c6i.2xlarge
    in:
      input_vcf:
        source: [bedtools_intersect/intersected_vcf, generate_gvcf/gvcf]
      output_vcf_basename: output_basename
    out: [output]
  bcftools_amend_header:
    run: ../tools/bcftools_amend_vcf_header.cwl
    hints:
    - class: 'sbg:AWSInstanceType'
      value: c6i.2xlarge
    in:
      input_vcf: picard_mergevcfs/output
      mod_vcf: generate_gvcf/gvcf
      output_basename: output_basename
    out: [header_amended_vcf]

$namespaces:
  sbg: https://sevenbridges.com
hints:
- class: 'sbg:maxNumberOfParallelInstances'
  value: 4
sbg:license: Apache License 2.0
sbg:publisher: KFDRC
