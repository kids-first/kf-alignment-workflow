cwlVersion: v1.0
class: Workflow
id: kfdrc-alignment-bam2cram2gvcf
label: Kids First DRC Alignment Workflow
doc: "Kids First Data Resource Center Alignment and Haplotype Calling Workflow (bam-to-cram-to-gVCF). This pipeline follows Broad best practices outlined in [Data pre-processing for variant discovery.](https://software.broadinstitute.org/gatk/best-practices/workflow?id=11165)  It uses bam input and aligns/re-aligns to a bwa-indexed reference fasta, version hg38.  Resultant bam is de-dupped and base score recalibrated.  Contamination is calculated and a gVCF is created using GATK4 Haplotype caller. Inputs from this can be used later on for further analysis in joint trio genotyping and subsequent refinement and deNovo variant analysis."
requirements:
  - class: ScatterFeatureRequirement
  - class: MultipleInputFeatureRequirement
  - class: SubworkflowFeatureRequirement

inputs:
  input_bam: {type: File, doc: 'input bam file with aligned or unaligned reads'}
  biospecimen_name: {type: string, doc: 'biospecimen ID'}
  output_basename: {type: string, doc: 'output file base name all outputs'}
  reference_fasta: {type: File, doc: 'Homo_sapiens_assembly38.fasta, human genome reference file', sbg:suggestedValue: {class: 'File', path: '5c12d579e4b06d3a6d2145ff', name: 'Homo_sapiens_assembly38.fasta'}}
  bwa_index_tar: {type: File, doc: 'bwa-generated index files created from `reference_fasta`', sbg:suggestedValue: {class: 'File', path: '5c12d579e4b06d3a6d2145f6', name: 'Homo_sapiens_assembly38.fasta.bwa-0.7.17.tar'}}
  dbsnp_vcf: {type: File, doc: 'Homo_sapiens_assembly38.dbsnp138.vcf', sbg:suggestedValue: {class: 'File', path: '5c12d579e4b06d3a6d214600', name: 'Homo_sapiens_assembly38.dbsnp138.vcf'}}
  dbsnp_vcf_index: {type: File, doc: 'Homo_sapiens_assembly38.dbsnp138.vcf.idx', sbg:suggestedValue: {class: 'File', path: '5c13d202e4b06d3aabf9cf33', name: 'Homo_sapiens_assembly38.dbsnp138.vcf.idx'}}
  knownsites: {type: 'File[]', doc: '1000G_omni2.5.hg38.vcf.gz, 1000G_phase1.snps.high_confidence.hg38.vcf.gz, Homo_sapiens_assembly38.known_indels.vcf.gz, Mills_and_1000G_gold_standard.indels.hg38.vcf.gz',
              sbg:suggestedValue: [{class: 'File', path: '5c12d579e4b06d3a6d2145f3', name: '1000G_omni2.5.hg38.vcf.gz'},
                                   {class: 'File', path: '5c12d579e4b06d3a6d2145fa', name: '1000G_phase1.snps.high_confidence.hg38.vcf.gz'},
                                   {class: 'File', path: '5c12d579e4b06d3a6d2145ed', name: 'Homo_sapiens_assembly38.known_indels.vcf.gz'},
                                   {class: 'File', path: '5c12d579e4b06d3a6d2145f9', name: 'Mills_and_1000G_gold_standard.indels.hg38.vcf.gz'}]}
  reference_dict: {type: File, doc: 'Homo_sapiens_assembly38.dict', sbg:suggestedValue: {class: 'File', path: '5c12d579e4b06d3a6d214604', name: 'Homo_sapiens_assembly38.dict'}}
  reference_fai: {type: File, doc: 'Homo_sapiens_assembly38.fasta.fai, fasta index file', sbg:suggestedValue: {class: 'File', path: '5c12d579e4b06d3a6d2145ee', name: 'Homo_sapiens_assembly38.fai'}}
  contamination_sites_bed: {type: File, doc: 'Homo_sapiens_assembly38.contam.bed', sbg:suggestedValue: {class: 'File', path: '5c12d579e4b06d3a6d2145fd', name: 'Homo_sapiens_assembly38.contam.bed'}}
  contamination_sites_mu: {type: File, doc: 'Homo_sapiens_assembly38.contam.mu', sbg:suggestedValue: {class: 'File', path: '5c12d579e4b06d3a6d214603', name: 'Homo_sapiens_assembly38.contam.mu'}}
  contamination_sites_ud: {type: File, doc: 'Homo_sapiens_assembly38.contam.UD', sbg:suggestedValue: {class: 'File', path: '5c12d579e4b06d3a6d2145f5', name: 'Homo_sapiens_assembly38.contam.UD'}}
  wgs_calling_interval_list: {type: File, doc: 'wgs_calling_regions.hg38.interval_list', sbg:suggestedValue: {class: 'File', path: '5c12d579e4b06d3a6d2145f1', name: 'wgs_calling_regions.hg38.interval_list'}}
  wgs_coverage_interval_list: {type: File, doc: 'wgs_coverage_regions.hg38.interval_list', sbg:suggestedValue: {class: 'File', path: '5c12d579e4b06d3a6d2145eb', name: 'wgs_coverage_regions.hg38.interval_list'}}
  wgs_evaluation_interval_list: {type: File, doc: 'wgs_evaluation_regions.hg38.interval_list', sbg:suggestedValue: {class: 'File', path: '5c12d579e4b06d3a6d214607', name: 'wgs_evaluation_regions.hg38.interval_list'}}

outputs:
  cram: {type: File, outputSource: samtools_converttocram/output, doc: 'Final aligned cram file output'}
  gvcf: {type: File, outputSource: picard_mergevcfs/output, doc: 'Final haplotype-called gVCF output'}
  verifybamid_output: {type: File, outputSource: verifybamid/output, doc: 'contamination check results'}
  bqsr_report: {type: File, outputSource: gatk_gatherbqsrreports/output, doc: 'base quality score recalibration reports'}
  gvcf_calling_metrics: {type: 'File[]', outputSource: picard_collectgvcfcallingmetrics/output, doc: 'snp and indel metrics in gVCF'}
  aggregation_metrics: {type: 'File[]', outputSource: picard_collectaggregationmetrics/output, doc: 'picard metric outputs from CollectAlignmentSummaryMetrics, CollectInsertSizeMetrics, CollectSequencingArtifactMetrics, CollectGcBiasMetrics, QualityScoreDistribution'}
  wgs_metrics: {type: File, outputSource: picard_collectwgsmetrics/output, doc: 'detailed whole genome sequencing metrics including read counts, depth, insert size, pcr duplication, etc'}

steps:
  samtools_split:
    run: ../tools/samtools_split.cwl
    label: Samtools split bam
    doc: Use samtools 1.9 to split bam into smaller alignment jobs and untar bwa index for next steps
    in:
      input_bam: input_bam
      bwa_index_tar: bwa_index_tar
      reference: reference_fasta
    out: [bam_files, bwa_index]

  bwa_mem:
    run: ../workflows/kfdrc_bwamem_subwf.cwl
    label: BWA-MEM
    doc: Run bwa-mem v0.7.17 and create custom RG info on temporarily split input reads
    in:
      input_reads: samtools_split/bam_files
      bwa_index: samtools_split/bwa_index
      sample_name: biospecimen_name
    scatter: [input_reads]
    out: [aligned_bams]

  sambamba_merge:
    run: ../tools/sambamba_merge.cwl
    label: Sambamba merge bams
    doc: Merge aligned split bams and mark duplicates
    in:
      bams: bwa_mem/aligned_bams
      base_file_name: output_basename
    out: [merged_bam]

  sambamba_sort:
    run: ../tools/sambamba_sort.cwl
    label: Sambamba sort bam
    doc: Coordinate sort bam
    in:
      bam: sambamba_merge/merged_bam
      base_file_name: output_basename
    out: [sorted_bam]

  python_createsequencegroups:
    run: ../tools/python_createsequencegroups.cwl
    label: Create intervals
    doc: Create interval files to parallelize BQSR
    in:
      reference_dict: reference_dict
    out: [out_intervals]

  tabix_prep_knownsites:
    run: ../tools/tabix_prep_knownsites.cwl
    label: Tabix ks prep
    doc: Index known sites files for bqsr and feed to bqsr tool
    in:
      knownsites: knownsites
    out: [ks_indexed]

  gatk_baserecalibrator:
    run: ../tools/gatk_baserecalibrator.cwl
    label: GATK bqsr
    doc: Create base score recalibrator score reports
    in:
      input_bam: sambamba_sort/sorted_bam
      knownsites: tabix_prep_knownsites/ks_indexed
      reference_fasta: reference_fasta
      reference_dict: reference_dict
      reference_fai: reference_fai
      sequence_interval: python_createsequencegroups/out_intervals
    scatter: [sequence_interval]
    out: [output]

  gatk_gatherbqsrreports:
    run: ../tools/gatk_gatherbqsrreports.cwl
    label: GATK gather bqsr
    doc: Combine scattered BQSR reports
    in:
      input_brsq_reports: gatk_baserecalibrator/output
      output_basename: output_basename
    out: [output]

  gatk_applybqsr:
    run: ../tools/gatk_applybqsr.cwl
    label: GATK apply bqsr
    doc: Apply BQSR to aligned, merged, and sorted bam
    in:
      bqsr_report: gatk_gatherbqsrreports/output
      input_bam: sambamba_sort/sorted_bam
      reference_fasta: reference_fasta
      reference_dict: reference_dict
      reference_fai: reference_fai
      sequence_interval: python_createsequencegroups/out_intervals
    scatter: [sequence_interval]
    out: [recalibrated_bam]

  picard_gatherbamfiles:
    run: ../tools/picard_gatherbamfiles.cwl
    label: Picard gather bam
    doc: Merge BQSR recalibrated bams
    in:
      input_bam: gatk_applybqsr/recalibrated_bam
      output_bam_basename: output_basename
    out: [output]

  picard_collectaggregationmetrics:
    run: ../tools/picard_collectaggregationmetrics.cwl
    label: Picard multi-metrics
    doc: 'Collect metrics using picard tools: CollectAlignmentSummaryMetrics, CollectInsertSizeMetrics, CollectSequencingArtifactMetrics, CollectGcBiasMetrics, QualityScoreDistribution'
    in:
      input_bam: picard_gatherbamfiles/output
      reference_fasta: reference_fasta
      reference_dict: reference_dict
      reference_fai: reference_fai
    out: [output]

  picard_collectwgsmetrics:
    run: ../tools/picard_collectwgsmetrics.cwl
    label: Picard WGS metrics
    doc: Picard tool get whole genome sequencing metrics
    in:
      input_bam: picard_gatherbamfiles/output
      intervals: wgs_coverage_interval_list
      reference_fasta: reference_fasta
      reference_fai: reference_fai
    out: [output]

  picard_intervallisttools:
    run: ../tools/picard_intervallisttools.cwl
    label: Picard interval list
    doc: Create separate interval list files for WGS haplotype calling (HC)
    in:
      interval_list: wgs_calling_interval_list
    out: [output]

  verifybamid:
    run: ../tools/verifybamid.cwl
    label: Verify bam
    doc: Calculate contamination metrics measuring sample purity to help guide HC
    in:
      contamination_sites_bed: contamination_sites_bed
      contamination_sites_mu: contamination_sites_mu
      contamination_sites_ud: contamination_sites_ud
      input_bam: sambamba_sort/sorted_bam
      reference_fasta: reference_fasta
      reference_fai: reference_fai
      output_basename: output_basename
    out: [output]

  checkcontamination:
    run: ../tools/expression_checkcontamination.cwl
    label: Check contamination
    doc: Calculate contamination constant for HC
    in:
      verifybamid_selfsm: verifybamid/output
    out: [contamination]

  gatk_haplotypecaller:
    run: ../tools/gatk_haplotypecaller.cwl
    label: GATK haplotype caller
    doc: Run gatk haplotype caller on recalibrated bam
    in:
      contamination: checkcontamination/contamination
      input_bam: picard_gatherbamfiles/output
      interval_list: picard_intervallisttools/output
      reference_fasta: reference_fasta
      reference_dict: reference_dict
      reference_fai: reference_fai
    scatter: [interval_list]
    out: [output]

  picard_mergevcfs:
    run: ../tools/picard_mergevcfs.cwl
    label: Merge vcfs
    doc: Merge resultant vcfs from HC output
    in:
      input_vcf: gatk_haplotypecaller/output
      output_vcf_basename: output_basename
    out: [output]

  picard_collectgvcfcallingmetrics:
    run: ../tools/picard_collectgvcfcallingmetrics.cwl
    label: Picard gvcf metrics
    doc: Calculate gVCF calling metrics
    in:
      dbsnp_vcf: dbsnp_vcf
      dbsnp_vcf_index: dbsnp_vcf_index
      final_gvcf_base_name: output_basename
      input_vcf: picard_mergevcfs/output
      reference_dict: reference_dict
      wgs_evaluation_interval_list: wgs_evaluation_interval_list
    out: [output]

  samtools_converttocram:
    run: ../tools/samtools_convert_to_cram.cwl
    label: Samtools bam2cram
    doc: Converts final resultant bam to cram format
    in:
      input_bam: picard_gatherbamfiles/output
      reference_fasta: reference_fasta
      reference_fai: reference_fai
    out: [output]

$namespaces:
  sbg: https://sevenbridges.com
hints:
  - class: 'sbg:AWSInstanceType'
    value: c4.8xlarge;ebs-gp2;850
  - class: 'sbg:maxNumberOfParallelInstances'
    value: 4
