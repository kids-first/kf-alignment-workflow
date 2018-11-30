cwlVersion: v1.0
class: Workflow
id: kf_alignment_optimized_wf
requirements:
  - class: ScatterFeatureRequirement
  - class: MultipleInputFeatureRequirement
  - class: SubworkflowFeatureRequirement

inputs:
  input_reads: {type: File, doc: 'input bam file with aligned or unaligned reads'}
  biospecimen_name: {type: string, doc: 'biospecimen ID'}
  output_basename: {type: string, doc: 'output file base name all outputs'}
  indexed_reference_fasta: {type: File, doc: 'Homo_sapiens_assembly38.fasta'}
  dbsnp_vcf: {type: File, doc: 'Homo_sapiens_assembly38.dbsnp138.vcf'}
  knownsites: {type: File[], doc: '1000G_omni2.5.hg38.vcf.gz, 1000G_phase1.snps.high_confidence.hg38.vcf.gz, Homo_sapiens_assembly38.known_indels.vcf.gz, Mills_and_1000G_gold_standard.indels.hg38.vcf.gz'}
  reference_dict: {type: File, doc: 'Homo_sapiens_assembly38.dict'}
  contamination_sites_bed: {type: File, doc: 'Homo_sapiens_assembly38.contam.bed'}
  contamination_sites_mu: {type: File, doc: 'Homo_sapiens_assembly38.contam.mu'}
  contamination_sites_ud: {type: File, doc: 'Homo_sapiens_assembly38.contam.UD'}
  wgs_calling_interval_list: {type: File, doc: 'wgs_calling_regions.hg38.interval_list'}
  wgs_coverage_interval_list: {type: File, doc: 'wgs_coverage_regions.hg38.interval_list'}
  wgs_evaluation_interval_list: {type: File, doc: 'wgs_evaluation_regions.hg38.interval_list'}

outputs:
  cram: {type: File, outputSource: samtools_coverttocram/output, doc: 'Final aligned cram file output'}
  gvcf: {type: File, outputSource: picard_mergevcfs/output, doc: 'Final haplotype-called gVCF output'}
  verifybamid_output: {type: File, outputSource: verifybamid/output, doc: 'contamination check results'}
  bqsr_report: {type: File, outputSource: gatk_gatherbqsrreports/output, doc: 'base quality score recalibration reports'}
  gvcf_calling_metrics: {type: 'File[]', outputSource: picard_collectgvcfcallingmetrics/output, doc: 'snp and indel metrics in gVCF'}
  aggregation_metrics: {type: 'File[]', outputSource: picard_collectaggregationmetrics/output, doc: 'picard metric outputs from CollectAlignmentSummaryMetrics, CollectInsertSizeMetrics, CollectSequencingArtifactMetrics, CollectGcBiasMetrics, QualityScoreDistribution'}
  wgs_metrics: {type: File, outputSource: picard_collectwgsmetrics/output, doc: 'detailed whole genome sequencing metrics including read counts, depth, insert size, pcr duplication, etc'}

steps:
  samtools_split:
    run: ../tools/samtools_split.cwl
    in:
      input_bam: input_reads
      reference: indexed_reference_fasta
    out: [bam_files]

  bwa_mem:
    run: ../workflows/kfdrc_bwamem_subwf.cwl
    in:
      input_reads: samtools_split/bam_files
      indexed_reference_fasta: indexed_reference_fasta
      sample_name: biospecimen_name
    scatter: [input_reads]
    out: [aligned_bams]

  sambamba_merge:
    run: ../tools/sambamba_merge.cwl
    in:
      bams: bwa_mem/aligned_bams
      base_file_name: output_basename
    out: [merged_bam]

  sambamba_sort:
    run: ../tools/sambamba_sort.cwl
    in:
      bam: sambamba_merge/merged_bam
      base_file_name: output_basename
    out: [sorted_bam]

  python_createsequencegroups:
    run: ../tools/python_createsequencegroups.cwl
    in:
      ref_dict: reference_dict
    out: [out_intervals]

  gatk_baserecalibrator:
    run: ../tools/gatk_baserecalibrator.cwl
    in:
      input_bam: sambamba_sort/sorted_bam
      knownsites: knownsites
      reference: indexed_reference_fasta
      sequence_interval: python_createsequencegroups/out_intervals
    scatter: [sequence_interval]
    out: [output]

  gatk_gatherbqsrreports:
    run: ../tools/gatk_gatherbqsrreports.cwl
    in:
      input_brsq_reports: gatk_baserecalibrator/output
      output_basename: output_basename
    out: [output]

  gatk_applybqsr:
    run: ../tools/gatk_applybqsr.cwl
    in:
      bqsr_report: gatk_gatherbqsrreports/output
      input_bam: sambamba_sort/sorted_bam
      reference: indexed_reference_fasta
      sequence_interval: python_createsequencegroups/out_intervals
    scatter: [sequence_interval]
    out: [recalibrated_bam]

  picard_gatherbamfiles:
    run: ../tools/picard_gatherbamfiles.cwl
    in:
      input_bam: gatk_applybqsr/recalibrated_bam
      output_bam_basename: output_basename
    out: [output]

  picard_collectaggregationmetrics:
    run: ../tools/picard_collectaggregationmetrics.cwl
    in:
      input_bam: picard_gatherbamfiles/output
      reference: indexed_reference_fasta
    out: [output]

  picard_collectwgsmetrics:
    run: ../tools/picard_collectwgsmetrics.cwl
    in:
      input_bam: picard_gatherbamfiles/output
      intervals: wgs_coverage_interval_list
      reference: indexed_reference_fasta
    out: [output]

  picard_intervallisttools:
    run: ../tools/picard_intervallisttools.cwl
    in:
      interval_list: wgs_calling_interval_list
    out: [output]

  verifybamid:
    run: ../tools/verifybamid.cwl
    in:
      contamination_sites_bed: contamination_sites_bed
      contamination_sites_mu: contamination_sites_mu
      contamination_sites_ud: contamination_sites_ud
      input_bam: sambamba_sort/sorted_bam
      ref_fasta: indexed_reference_fasta
      output_basename: output_basename
    out: [output]

  checkcontamination:
    run: ../tools/expression_checkcontamination.cwl
    in:
      verifybamid_selfsm: verifybamid/output
    out: [contamination]

  gatk_haplotypecaller:
    run: ../tools/gatk_haplotypecaller.cwl
    in:
      contamination: checkcontamination/contamination
      input_bam: picard_gatherbamfiles/output
      interval_list: picard_intervallisttools/output
      reference: indexed_reference_fasta
    scatter: [interval_list]
    out: [output]

  picard_mergevcfs:
    run: ../tools/picard_mergevcfs.cwl
    in:
      input_vcf: gatk_haplotypecaller/output
      output_vcf_basename: output_basename
    out: [output]

  picard_collectgvcfcallingmetrics:
    run: ../tools/picard_collectgvcfcallingmetrics.cwl
    in:
      dbsnp_vcf: dbsnp_vcf
      final_gvcf_base_name: output_basename
      input_vcf: picard_mergevcfs/output
      reference_dict: reference_dict
      wgs_evaluation_interval_list: wgs_evaluation_interval_list
    out: [output]

  samtools_coverttocram:
    run: ../tools/samtools_covert_to_cram.cwl
    in:
      input_bam: picard_gatherbamfiles/output
      reference: indexed_reference_fasta
    out: [output]

$namespaces:
  sbg: https://sevenbridges.com
hints:
  - class: 'sbg:AWSInstanceType'
    value: c4.8xlarge;ebs-gp2;850
  - class: 'sbg:maxNumberOfParallelInstances'
    value: 4
