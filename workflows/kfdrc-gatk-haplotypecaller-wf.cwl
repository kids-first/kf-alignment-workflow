cwlVersion: v1.2
class: Workflow
id: kfdrc-gatk-haplotypecaller-workflow
label: Kids First DRC GATK HaplotypeCaller CRAM to gVCF Workflow
doc: |
  # KFDRC GATK HaplotypeCaller CRAM to gVCF Workflow

  This workflow taks a CRAM file, converts it to a BAM, determines a
  contamination value, then runs GATK HaplotypeCaller to generate a gVCF, gVCF
  calling metrics, and, if no contamination value is provided, the VerifyBAMID
  output. Additionally, if the user sets the `run_sex_metrics` input to true, two
  additional outputs from samtools idxstats will be provided.

  This workflow is the current production workflow, equivalent to this [Cavatica public app](https://cavatica.sbgenomics.com/public/apps#cavatica/apps-publisher/kfdrc-gatk-haplotypecaller-workflow).

  ## Inputs

  - input_cram: Input CRAM file
  - biospecimen_name: String name of biospcimen
  - output_basename: String to use as the base for output filenames
  - reference_tar: Tar file containing a reference fasta and, optionally, its
    complete set of associated indexes (samtools, bwa, and picard)
  - dbsnp_vcf: dbSNP vcf file
  - dbsnp_idx: dbSNP vcf index file
  - contamination: Precalculated contamination value. Providing the value here
    will skip the run of VerifyBAMID and use the provided value as ground truth.
  - contamination_sites_bed: .Bed file for markers used in this
    analysis,format(chr\tpos-1\tpos\trefAllele\taltAllele)
  - contamination_sites_mu: .mu matrix file of genotype matrix
  - contamination_sites_ud: .UD matrix file from SVD result of genotype matrix
  - wgs_calling_interval_list: WGS interval list used to aid scattering Haplotype
    caller
  - wgs_evaluation_interval_list: Target intervals to restrict gvcf metric
    analysis (for VariantCallingMetrics)
  - run_sex_metrics: idxstats will be collected and X/Y ratios calculated


  ## Outputs

  - gvcf: The germline variants calls in VCF format
  - gvcf_calling_metrics: Various metrics from the creation of the gVCF
  - verifybamid_output: If contamination is calculated rather than handed in by
    the user, the workflow will provide the output from verifybamid
  - idxstats: idxstats of the realigned BAM file
  - xy_ratio: Text file containing X and Y reads statistics generated from
    idxstats

  ### Running Modes

  Two inputs optional inputs can signficantly alter the function and outputs of this pipeline:

  1. Custom Contamination: Contamination values are normally determined using
  VerifyBamID. If the user already has contamination values for the sample or
  does not want to use the contamination value from VerifyBamID, they can provide
  their own value in the `contamination` input. Providing this value will result
  in VerifyBamID not being run. This also has the effect of saving on cost as
  VerifyBamID will not be run.
  1. Sex Metrics: In default running, sex metrics are not generated by this
  workflow. However, if the user sets `run_sex_metrics` to true, samtools
  idxstats will be run on the input reads to generate the sex metrics outputs
  `idxstats` and `xy_ratio`.

  ### Tips for running:

  1. For contamination input, either populate the `contamination` field or provide the three contamination
     files: `contamination_sites_bed`, `contamination_sites_mu`, and `contamination_sites_ud`. Failure to
     provide one of these groups will result in a failed run.
  1. Suggested reference inputs (available from the [Broad Resource Bundle](https://console.cloud.google.com/storage/browser/genomics-public-data/resources/broad/hg38/v0)):
      - contamination_sites_bed: Homo_sapiens_assembly38.contam.bed
      - contamination_sites_mu: Homo_sapiens_assembly38.contam.mu
      - contamination_sites_ud: Homo_sapiens_assembly38.contam.UD
      - dbsnp_vcf: Homo_sapiens_assembly38.dbsnp138.vcf
      - reference_tar: Homo_sapiens_assembly38.tgz
  1. The input for the reference_tar must be a tar file containing the reference fasta along with its indexes.
     The required indexes are `[.64.ann,.64.amb,.64.bwt,.64.pac,.64.sa,.dict,.fai]` and are generated by bwa, picard, and samtools.
     Additionally, an `.64.alt` index is recommended.
  1. If you are making your own bwa indexes make sure to use the `-6` flag to obtain the `.64` version of the
     indexes. Indexes that do not match this naming schema will cause a failure in certain runner ecosystems.
  1. Should you decide to create your own reference indexes and omit the ALT index file from the reference,
     or if its naming structure mismatches the other indexes, then your alignments will be equivalent to the results you would
     obtain if you run BWA-MEM with the -j option.
requirements:
- class: ScatterFeatureRequirement
- class: MultipleInputFeatureRequirement
- class: SubworkflowFeatureRequirement
inputs:
  input_cram: {type: 'File', doc: "Input CRAM file"}
  biospecimen_name: {type: 'string', doc: "String name of biospcimen"}
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
  wgs_calling_interval_list: {type: 'File', doc: "WGS interval list used to aid scattering\
      \ Haplotype caller", "sbg:suggestedValue": {class: File, path: 60639018357c3a53540ca7df,
      name: wgs_calling_regions.hg38.interval_list}}
  wgs_evaluation_interval_list: {type: 'File', doc: "Target intervals to restrict\
      \ gvcf metric analysis (for VariantCallingMetrics)", "sbg:suggestedValue": {
      class: File, path: 60639017357c3a53540ca7d3, name: wgs_evaluation_regions.hg38.interval_list}}
  run_sex_metrics: {type: 'boolean?', default: false, doc: "idxstats will be collected\
      \ and X/Y ratios calculated"}
outputs:
  gvcf: {type: File, outputSource: generate_gvcf/gvcf}
  gvcf_calling_metrics: {type: 'File[]', outputSource: generate_gvcf/gvcf_calling_metrics}
  verifybamid_output: {type: 'File?', outputSource: generate_gvcf/verifybamid_output}
  idxstats: {type: 'File?', outputSource: samtools_idxstats_xy_ratio/output, doc: "samtools\
      \ idxstats of the realigned BAM file."}
  xy_ratio: {type: 'File?', outputSource: samtools_idxstats_xy_ratio/ratio, doc: "Text\
      \ file containing X and Y reads statistics generated from idxstats."}
steps:
  untar_reference:
    run: ../tools/untar_indexed_reference_2.cwl
    in:
      reference_tar: reference_tar
    out: [indexed_fasta, dict]
  samtools_cram_to_bam:
    run: ../tools/samtools_cram_to_bam.cwl
    in:
      input_cram: input_cram
      output_basename: output_basename
      reference: untar_reference/indexed_fasta
    out: [output]
  samtools_idxstats_xy_ratio:
    run: ../tools/samtools_idxstats_xy_ratio.cwl
    in:
      run_idxstats: run_sex_metrics
      input_bam: samtools_cram_to_bam/output
    out: [output, ratio]
  generate_gvcf:
    run: ../subworkflows/kfdrc_bam_to_gvcf.cwl
    in:
      contamination_sites_ud: contamination_sites_ud
      contamination_sites_mu: contamination_sites_mu
      contamination_sites_bed: contamination_sites_bed
      input_bam: samtools_cram_to_bam/output
      indexed_reference_fasta: untar_reference/indexed_fasta
      output_basename: output_basename
      dbsnp_vcf: dbsnp_vcf
      dbsnp_idx: dbsnp_idx
      reference_dict: untar_reference/dict
      wgs_calling_interval_list: wgs_calling_interval_list
      wgs_evaluation_interval_list: wgs_evaluation_interval_list
      conditional_run:
        valueFrom: $(1)
      contamination: contamination
      biospecimen_name: biospecimen_name
    out: [verifybamid_output, gvcf, gvcf_calling_metrics]
$namespaces:
  sbg: https://sevenbridges.com
hints:
- class: 'sbg:maxNumberOfParallelInstances'
  value: 4
sbg:license: Apache License 2.0
sbg:publisher: KFDRC
sbg:categories:
- CRAM
- DNASEQ
- GATK
- GVCF
- HAPLOTYPECALLER
- WGS
sbg:links:
- id: 'https://github.com/kids-first/kf-alignment-workflow/releases/tag/v2.9.0'
  label: github-release
