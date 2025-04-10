# Kids First DRC GATK HaplotypeCaller Modified Ploidy BETA Workflow
This is a research workflow for users wishing to modify the ploidy of certain
regions of their existing GVCF calls. This uses the `coalescent` genotype model, equivalent to GATK 3.8
from Sentieon, a close analog of the original production workflow GATK 3.5 (via 4beta).

## Inputs
### Ploidy-related
- input_gvcf: GVCF generated in standard workflow
- region: Specific region to pull, in format 'chr21' or 'chr3:1-1000'
- re_calling_interval_list: Interval list to re-call __in GATK Picard-style Interval List format__
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
- contamination: Precalculated contamination value. 
  **Strongly recommend using `0` or value ascertained when running sample as pure diploid.**
  Otherwise a high value using chr21 only will result in very few triploid calls and mostly diploid calls despite obvious AF.
- contamination_sites_bed: .Bed file for markers used in this
  analysis,format(chr\tpos-1\tpos\trefAllele\taltAllele)
- contamination_sites_mu: .mu matrix file of genotype matrix
- contamination_sites_ud: .UD matrix file from SVD result of genotype matrix
- wgs_evaluation_interval_list: Target intervals to restrict GVCF metric
  analysis (for VariantCallingMetrics)

## Outputs
- mixed_ploidy_gvcf: Updated complete GVCF in which the desired region has had its ploidy updated
- mixed_ploidy_genotyped_vcf: mixed_ploidy_gvcf run through GVCFtyper
