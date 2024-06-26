# KFDRC GATK HaplotypeCaller CRAM to gVCF Workflow

This workflow taks a CRAM file, converts it to a BAM, determines a
contamination value, then runs GATK HaplotypeCaller to generate a gVCF, gVCF
calling metrics, and, if no contamination value is provided, the VerifyBAMID
output. Additionally, if the user sets the `run_sex_metrics` input to true, two
additional outputs from samtools idxstats will be provided.

This workflow is the current production workflow, equivalent to this [CAVATICA public app](https://cavatica.sbgenomics.com/public/apps#cavatica/apps-publisher/kfdrc-gatk-haplotypecaller-workflow).

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
1. Suggested reference inputs (available from the [Broad Resource Bundle](https://console.cloud.google.com/storage/browser/gcp-public-data--broad-references/hg38/v0)):
    - contamination_sites_bed: Homo_sapiens_assembly38.contam.bed
    - contamination_sites_mu: Homo_sapiens_assembly38.contam.mu
    - contamination_sites_ud: Homo_sapiens_assembly38.contam.UD
    - dbsnp_vcf: Homo_sapiens_assembly38.dbsnp138.vcf
    - reference_tar: Homo_sapiens_assembly38.tgz
    - wgs_calling_interval_list: wgs_coverage_regions.hg38.interval_list
    - wgs_evaluation_interval_list: wgs_evaluation_regions.hg38.interval_list
1. The input for the reference_tar must be a tar file containing the reference fasta along with its indexes.
   The required indexes are `[.64.ann,.64.amb,.64.bwt,.64.pac,.64.sa,.dict,.fai]` and are generated by bwa, picard, and samtools.
   Additionally, an `.64.alt` index is recommended.
1. If you are making your own bwa indexes make sure to use the `-6` flag to obtain the `.64` version of the
   indexes. Indexes that do not match this naming schema will cause a failure in certain runner ecosystems.
1. Should you decide to create your own reference indexes and omit the ALT index file from the reference,
   or if its naming structure mismatches the other indexes, then your alignments will be equivalent to the results you would
   obtain if you run BWA-MEM with the -j option.
