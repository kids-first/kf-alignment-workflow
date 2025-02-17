# Dockers of kfdrc_sentieon_alignment_wf.cwl

TOOL|DOCKER
-|-
biobambam_bamtofastq.cwl|pgc-images.sbgenomics.com/d3b-bixu/bwa-bundle:dev
clt_flatten_filelist.cwl|None
clt_prepare_bwa_payload.cwl|None
cutadapt.cwl|quay.io/biocontainers/cutadapt:4.6--py310h4b81fae_1
expression_preparerg.cwl|None
gatk_indexfeaturefile.cwl|pgc-images.sbgenomics.com/d3b-bixu/gatk:4.1.7.0R
picard_collectgvcfcallingmetrics.cwl|pgc-images.sbgenomics.com/d3b-bixu/picard:2.18.9R
samtools_head.cwl|staphb/samtools:1.15
samtools_idxstats_xy_ratio.cwl|pgc-images.sbgenomics.com/d3b-bixu/samtools:1.9
samtools_split.cwl|pgc-images.sbgenomics.com/d3b-bixu/samtools:1.9
sentieon_HsMetricAlgo.cwl|pgc-images.sbgenomics.com/hdchen/sentieon:202112_hifi_patched
sentieon_ReadWriter.cwl|pgc-images.sbgenomics.com/hdchen/sentieon:202112_hifi_patched
sentieon_WgsMetricsAlgo.cwl|pgc-images.sbgenomics.com/hdchen/sentieon:202112_hifi_patched
sentieon_bqsr.cwl|pgc-images.sbgenomics.com/hdchen/sentieon:202112_hifi_patched
sentieon_bwa_sort.cwl|pgc-images.sbgenomics.com/hdchen/sentieon:202112_hifi_patched
sentieon_dedup.cwl|pgc-images.sbgenomics.com/hdchen/sentieon:202112_hifi_patched
sentieon_haplotyper.cwl|pgc-images.sbgenomics.com/hdchen/sentieon:202112_hifi_patched
sentieon_run_agg_metrics.cwl|pgc-images.sbgenomics.com/hdchen/sentieon:202112_hifi_patched
t1k.cwl|pgc-images.sbgenomics.com/d3b-bixu/t1k:v1.0.5
tabix_index.cwl|pgc-images.sbgenomics.com/d3b-bixu/samtools:1.9
untar_indexed_reference_2.cwl|None
verifybamid_contamination_conditional.cwl|pgc-images.sbgenomics.com/d3b-bixu/verifybamid:1.0.2
