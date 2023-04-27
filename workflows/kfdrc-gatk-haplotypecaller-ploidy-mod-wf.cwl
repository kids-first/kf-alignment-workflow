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
  reference_fasta: {type: 'File', "sbg:suggestedValue": {class: File, path: 60639014357c3a53540ca7a3,
      name: Homo_sapiens_assembly38.fasta, secondaryFiles: [{class: File, path: 60639016357c3a53540ca7af, name: Homo_sapiens_assembly38.fasta.fai}, {class: File, path: 60639019357c3a53540ca7e7,
      name: Homo_sapiens_assembly38.dict}]},
    secondaryFiles: ['.fai', '^.dict']} 
  reference_dict: {type: 'File?', "sbg:suggestedValue": {class: File, path: 60639019357c3a53540ca7e7,
      name: Homo_sapiens_assembly38.dict}}
  region: { type: 'string?', doc: "Specific region to pull, in format 'chr21' or 'chr3:1-1000'" }
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
  sample_ploidy: { type: 'int?', doc: "If sample/interval is expected to not have ploidy=2, enter expected ploidy" }

outputs:
  mixed_ploidy_gvcf: {type: File, outputSource: picard_mergevcfs_python_renamesample/output}

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
      reference_dict: reference_dict
      wgs_calling_interval_list: re_calling_interval_list
      wgs_evaluation_interval_list: wgs_evaluation_interval_list
      conditional_run:
        valueFrom: $(1)
      contamination: contamination
      biospecimen_name: biospecimen_name
      sample_ploidy: sample_ploidy
    out: [verifybamid_output, gvcf, gvcf_calling_metrics]
  picard_mergevcfs_python_renamesample:
    run: ../tools/picard_mergevcfs_python_renamesample.cwl
    in:
      input_vcf:
        source: [bedtools_intersect/intersected_vcf, generate_gvcf/gvcf]
      output_vcf_basename: output_basename
      biospecimen_name: biospecimen_name
    out: [output]

$namespaces:
  sbg: https://sevenbridges.com
hints:
- class: 'sbg:maxNumberOfParallelInstances'
  value: 4
