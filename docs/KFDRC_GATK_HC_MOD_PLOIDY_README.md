# Kids First DRC GATK HaplotypeCaller Modified Ploidy BETA Workflow
This is a research workflow for users wishing to modify the ploidy of certain
regions of their existing GVCF calls.

## Inputs

- input_cram: Input CRAM file
- input_gvcf: GVCF generated in standard workflow
- biospecimen_name: String name of biospcimen
- output_basename: String to use as the base for output filenames
- reference_fasta: FASTA file that was used during alignment. Also need
  corresponding `.fai` and `.dict` files.
- region: Specific region to pull, in format 'chr21' or 'chr3:1-1000'
- dbsnp_vcf: dbSNP vcf file
- dbsnp_idx: dbSNP vcf index file
- contamination: Precalculated contamination value. Providing the value here
  will skip the run of VerifyBAMID and use the provided value as ground truth.
- contamination_sites_bed: .Bed file for markers used in this
  analysis,format(chr\tpos-1\tpos\trefAllele\taltAllele)
- contamination_sites_mu: .mu matrix file of genotype matrix
- contamination_sites_ud: .UD matrix file from SVD result of genotype matrix
- re_calling_interval_list: Interval list to re-call
- wgs_evaluation_interval_list: Target intervals to restrict GVCF metric
  analysis (for VariantCallingMetrics)
- sample_ploidy: If sample/interval is expected to not have ploidy=2, enter expected ploidy

## Outputs

- mixed_ploidy_gvcf: Updated complete GVCF in which the desired region has had its ploidy updated
