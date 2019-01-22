# kfdrc alignment workflow

Kids First Data Resource Center Alignment and Haplotype Calling Workflow (bam-to-cram-to-gVCF). This pipeline follows
Broad best practices outlined in [Data pre-processing for variant discovery.](https://software.broadinstitute.org/gatk/best-practices/workflow?id=11165)
It uses bam input and aligns/re-aligns to a bwa-indexed reference fasta, version hg38.  Resultant bam is de-dupped and 
base score recalibrated.  Contamination is calculated and a gVCF is created using GATK4 Haplotype caller. Inputs from 
this can be used later on for further analysis in joint trio genotyping and subsequent refinement and deNovo variant analysis.

## basic info
- pipeline flowchart: 
  - [cwl-viewer](https://view.commonwl.org/workflows/github.com/kids-first/kf-alignment-workflow/blob/mb-publish-bam-align/workflows/kfdrc_alignment_wf.cwl) 
  - [draw.io](https://tinyurl.com/y952jek2)
- tool images: https://hub.docker.com/r/kfdrc/
- dockerfiles: https://github.com/d3b-center/bixtools
- tested with
  - rabix-v1.0.5: https://github.com/rabix/bunny/releases/tag/v1.0.5
  - cwltool: https://github.com/common-workflow-language/cwltool/releases/tag/1.0.20171107133715

## references:
- https://console.cloud.google.com/storage/browser/broad-references/hg38/v0/
- kfdrc bucket: s3://kids-first-seq-data/broad-references/
- cavatica: https://cavatica.sbgenomics.com/u/yuankun/kf-reference/

## inputs:
```yaml
  input_bam: input.bam
  indexed_reference_fasta: Homo_sapiens_assembly38.fasta
  reference_dict: Homo_sapiens_assembly38.dict
  sequence_grouping_tsv: sequence_grouping.txt
  knownsites:
  - 1000G_omni2.5.hg38.vcf.gz
  - 1000G_phase1.snps.high_confidence.hg38.vcf.gz
  - Homo_sapiens_assembly38.known_indels.vcf.gz
  - Mills_and_1000G_gold_standard.indels.hg38.vcf.gz
  dbsnp_vcf: Homo_sapiens_assembly38.dbsnp138.vcf
  wgs_calling_interval_list: wgs_calling_regions.hg38.interval_list
  wgs_coverage_interval_list: wgs_coverage_regions.hg38.interval_list
  wgs_evaluation_interval_list: wgs_evaluation_regions.hg38.interval_list
  contamination_sites_bed: Homo_sapiens_assembly38.contam.bed
  contamination_sites_mu: Homo_sapiens_assembly38.contam.mu
  contamination_sites_ud: Homo_sapiens_assembly38.contam.UD
```
- [sequence_grouping_tsv](examples/sequence_grouping.txt), generated by `bin/CreateSequenceGroupingTSV.py`
- [example-inputs.json](examples/example-inputs.json)

![Alt text](./kfdrc_alignment_wf.png?raw=true "Workflow diagram")