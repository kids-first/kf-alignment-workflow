# Dockers of kfdrc_alignment_wf.cwl

TOOL|DOCKER
-|-
bamtofastq_chomp.cwl|pgc-images.sbgenomics.com/d3b-bixu/bwa-bundle:dev
bundle_secondaryfiles.cwl|None
bwa_mem_naive.cwl|pgc-images.sbgenomics.com/d3b-bixu/bwa-kf-bundle:0.1.17
cutadapt.cwl|quay.io/biocontainers/cutadapt:4.6--py310h4b81fae_1
expression_preparerg.cwl|None
fastq_chomp.cwl|pgc-images.sbgenomics.com/d3b-bixu/bwa-bundle:dev
gatekeeper.cwl|pgc-images.sbgenomics.com/d3b-bixu/ubuntu:18.04
gatk_applybqsr.cwl|pgc-images.sbgenomics.com/d3b-bixu/gatk:4.0.3.0
gatk_baserecalibrator.cwl|pgc-images.sbgenomics.com/d3b-bixu/gatk:4.0.3.0
gatk_gatherbqsrreports.cwl|pgc-images.sbgenomics.com/d3b-bixu/gatk:4.0.3.0
gatk_haplotypecaller.cwl|pgc-images.sbgenomics.com/d3b-bixu/gatk:4.beta.1-3.5
gatk_indexfeaturefile.cwl|pgc-images.sbgenomics.com/d3b-bixu/gatk:4.1.7.0R
picard_collectalignmentsummarymetrics_conditional.cwl|pgc-images.sbgenomics.com/d3b-bixu/picard:2.18.9R
picard_collectgcbiasmetrics_conditional.cwl|pgc-images.sbgenomics.com/d3b-bixu/picard:2.18.9R
picard_collectgvcfcallingmetrics.cwl|pgc-images.sbgenomics.com/d3b-bixu/picard:2.18.9R
picard_collecthsmetrics_conditional.cwl|pgc-images.sbgenomics.com/d3b-bixu/picard:2.18.9R
picard_collectinsertsizemetrics_conditional.cwl|pgc-images.sbgenomics.com/d3b-bixu/picard:2.18.9R
picard_collectsequencingartifactmetrics_conditional.cwl|pgc-images.sbgenomics.com/d3b-bixu/picard:2.18.9R
picard_collectwgsmetrics_conditional.cwl|pgc-images.sbgenomics.com/d3b-bixu/picard:2.18.9R
picard_gatherbamfiles.cwl|pgc-images.sbgenomics.com/d3b-bixu/picard:2.18.9R
picard_intervallisttools.cwl|pgc-images.sbgenomics.com/d3b-bixu/picard:2.18.9R
picard_mergevcfs_python_renamesample.cwl|pgc-images.sbgenomics.com/d3b-bixu/picard:2.18.9R
picard_qualityscoredistribution_conditional.cwl|pgc-images.sbgenomics.com/d3b-bixu/picard:2.18.9R
python_createsequencegroups.cwl|pgc-images.sbgenomics.com/d3b-bixu/python:2.7.13
sambamba_merge_anylist.cwl|images.sbgenomics.com/bogdang/sambamba:0.6.3
samtools_bam_to_cram.cwl|pgc-images.sbgenomics.com/d3b-bixu/samtools:1.8-dev
samtools_idxstats_xy_ratio.cwl|pgc-images.sbgenomics.com/d3b-bixu/samtools:1.9
samtools_split.cwl|pgc-images.sbgenomics.com/d3b-bixu/samtools:1.9
t1k.cwl|pgc-images.sbgenomics.com/d3b-bixu/t1k:v1.0.5
tabix_index.cwl|pgc-images.sbgenomics.com/d3b-bixu/samtools:1.9
untar_indexed_reference.cwl|None
verifybamid_contamination_conditional.cwl|pgc-images.sbgenomics.com/d3b-bixu/verifybamid:1.0.2
