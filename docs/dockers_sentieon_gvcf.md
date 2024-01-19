# Dockers of kfdrc_sentieon_gvcf_wf.cwl

TOOL|DOCKER
-|-
gatk_indexfeaturefile.cwl|pgc-images.sbgenomics.com/d3b-bixu/gatk:4.1.7.0R
picard_collectgvcfcallingmetrics.cwl|pgc-images.sbgenomics.com/d3b-bixu/picard:2.18.9R
samtools_idxstats_xy_ratio.cwl|pgc-images.sbgenomics.com/d3b-bixu/samtools:1.9
sentieon_ReadWriter.cwl|pgc-images.sbgenomics.com/hdchen/sentieon:202112.01_hifi
sentieon_haplotyper.cwl|pgc-images.sbgenomics.com/hdchen/sentieon:202112.01_hifi
untar_indexed_reference_2.cwl|None
verifybamid_contamination_conditional.cwl|pgc-images.sbgenomics.com/d3b-bixu/verifybamid:1.0.2
