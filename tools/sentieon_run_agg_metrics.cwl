cwlVersion: v1.2
class: CommandLineTool
label: Sentieon_run_agg_metrics
doc: |-
  Run Sentieon QC tools.
  This tool performs the following QC tasks:
  AlignmentStat, BaseDistributionByCycle, GCBias, InsertSizeMetricAlgo, MeanQualityByCycle, QualDistribution, QualityYield, SequenceArtifactMetricsAlgo
  
  | Sentieon tool               	| GATK pipeline tool                      	| Description                                                                           	|
  |-----------------------------	|-----------------------------------------	|---------------------------------------------------------------------------------------	|
  | AlignmentStat               	| Picard CollectAlignmentSummaryMetrics   	| statistics on the alignment of the reads                                              	|
  | BaseDistributionByCycle     	| Picard CollectBaseDistributionByCycle   	| nucleotide distribution per sequencer cycle                                           	|
  | GCBias                      	| Picard CollectGcBiasMetrics             	| GC bias in the reference and the sample                                               	|
  | InsertSizeMetricAlgo        	| Picard CollectInsertSizeMetrics         	| statistics on the distribution of insert sizes                                        	|
  | MeanQualityByCycle          	| Picard MeanQualityByCycle               	| mean base quality score for each sequencing cycle                                     	|
  | QualDistribution            	| Picard QualityScoreDistribution         	| statistics on the distribution of bases with a specific base quality   score          	|
  | QualityYield                	| Picard CollectQualityYieldMetrics       	| metrics related to reads that pass quality thresholds and   Illumina-specific filters 	|
  | SequenceArtifactMetricsAlgo 	| Picard CollectSequencingArtifactMetrics 	| single-base sequencing artifacts and OxoG artifacts                                   	|
  
  ### Inputs:
  #### Required for all tools
  - ``Reference``: Location of the reference FASTA file.
  - ``Input BAM``: Location of the BAM/CRAM input file.
  ##### Optional for all tools
  - ``Interval``: interval in the reference that will be used in all tools. This argument can be specified as:
    -  ``BED_FILE``: location of the BED file containing the intervals. 
    -  ``PICARD_INTERVAL_FILE``: location of the file containing the intervals, following the Picard interval standard.
    -  ``VCF_FILE``: location of VCF containing variant records whose genomic coordinates will be used as intervals.
  - ``Quality recalibration table``: location of the quality recalibration table output from the BQSR stage.
  #### Optional for ``SequenceArtifactMetricsAlgo``
  - ``dbSNP``: location of the Single Nucleotide Polymorphism database (dbSNP) used to exclude regions around known polymorphisms.

$namespaces:
  sbg: https://sevenbridges.com

requirements:
- class: ShellCommandRequirement
- class: ResourceRequirement
  coresMin: |-
    ${
        if (inputs.cpu_per_job)
        {
            return inputs.cpu_per_job
        }
        else
        {
            return 32
        }
    }
  ramMin: |-
    ${
        if (inputs.mem_per_job)
        {
            return inputs.mem_per_job
        }
        else
        {
            return 32000
        }
    }
- class: DockerRequirement
  dockerPull: pgc-images.sbgenomics.com/hdchen/sentieon:202112.01_hifi
- class: EnvVarRequirement
  envDef:
  - envName: SENTIEON_LICENSE
    envValue: $(inputs.sentieon_license)
- class: InlineJavascriptRequirement

inputs:
- id: sentieon_license
  label: Sentieon license
  doc: License server host and port
  type: string
- id: reference
  label: Reference
  doc: Reference fasta with associated fai index
  type: File
  secondaryFiles:
  - pattern: .fai
    required: true
  - pattern: ^.dict
    required: true
  inputBinding:
    prefix: -r
    position: 0
    shellQuote: false
  sbg:fileTypes: FA, FASTA
- id: input_bam
  label: Input BAM
  doc: Input BAM file
  type: File
  secondaryFiles:
  - pattern: ^.bai
    required: false
  - pattern: ^.crai
    required: false
  - pattern: .bai
    required: false
  - pattern: .crai
    required: false
  inputBinding:
    prefix: -i
    position: 1
    shellQuote: false
  sbg:fileTypes: BAM, CRAM
- id: interval
  label: Interval
  doc: |-
    An option for interval in the reference that will be used in the software.
  type: File?
  inputBinding:
    prefix: --interval
    position: 5
    shellQuote: false
  sbg:fileTypes: BED, VCF, interval_list
- id: recal_table
  label: Quality recalibration table
  doc: |-
    Location of the quality recalibration table output from the BQSR stage. 
    Do not use this option if the input BAM has already been recalibrated.
  type: File?
  inputBinding:
    prefix: -q
    position: 2
    shellQuote: false
- id: adapter_seq
  label: Adapter sequences (AlignmentStat)
  doc: |-
    Comma separated list of adapters (default: 6 illumina adapters).
  type: string?
  sbg:category: AlignmentStat
- id: aligned_reads_only
  label: Aligned reads only (BaseDistributionByCycle)
  doc: |-
    Calculate the base distribution over aligned reads only (default: false)
  type: boolean?
  sbg:category: BaseDistributionByCycle
- id: pf_reads_only
  label: PF reads only (BaseDistributionByCycle)
  doc: |- 
    Calculate the base distribution over PF reads only (default: false)
  type: boolean?
  sbg:category: BaseDistributionByCycle
- id: accum_level_gc_bias
  label: Accumulation levels (GCBias)
  doc: |- 
    accumulation levels, possible values {ALL_READS, SAMPLE, LIBRARY, READ_GROUP}
  type: string?
  sbg:category: GCBias
- id: also_ignore_duplicates
  label: Ignore duplicates (GCBias)
  doc: output metrics when only unique reads are used
  type: boolean?
  sbg:category: GCBias
- id: include_secondary
  label: Include secondary (QualityYield)
  doc: |- 
    Include bases from secondary alignments in metrics (default: false)
  type: boolean?
  sbg:category: QualityYield
- id: include_supplementary
  label: Include supplementary (QualityYield)
  doc: |- 
    Include bases from supplementary alignments in metrics (default: false)
  type: boolean?
  sbg:category: QualityYield
- id: dbsnp
  label: dbSNP (SequenceArtifactMetricsAlgo)
  doc: Exclude regions around known polymorphisms.
  type: File?
  secondaryFiles:
  - pattern: .tbi
    required: false
  - pattern: .idx
    required: false
  sbg:fileTypes: VCF, VCF.GZ
  sbg:category: SequenceArtifactMetricsAlgo
- id: min_base_qual
  label: Minimum base quality score (SequenceArtifactMetricsAlgo)
  doc: |- 
    Minimum base quality score for a base to be included (default: 20)
  type: int?
  sbg:category: SequenceArtifactMetricsAlgo
- id: min_map_qual
  label: Minimum mapping quality (SequenceArtifactMetricsAlgo)
  doc: |- 
    Minimum mapping quality to include a read (default: 30)
  type: int?
  sbg:category: SequenceArtifactMetricsAlgo
- id: min_insert_size
  label: Minimum insert size (SequenceArtifactMetricsAlgo)
  doc: |- 
    Minimum insert size to include a read (default: 60)
  type: int?
  sbg:category: SequenceArtifactMetricsAlgo
- id: max_insert_size
  label: Maximum insert size (SequenceArtifactMetricsAlgo)
  doc: |- 
    Maximum insert size to include a read (default: 600)
  type: int?
  sbg:category: SequenceArtifactMetricsAlgo
- id: include_unpaired
  label: Include unpaired (SequenceArtifactMetricsAlgo)
  doc: |- 
    Include unpaired reads (default: false)
  type: boolean?
  sbg:category: SequenceArtifactMetricsAlgo
- id: include_duplicates
  label: Include duplicates (SequenceArtifactMetricsAlgo)
  doc: |- 
    Include duplicate reads (default: false)
  type: boolean?
  sbg:category: SequenceArtifactMetricsAlgo
- id: include_non_pf_reads
  label: Include non-PF reads (SequenceArtifactMetricsAlgo)
  doc: |- 
    Include non-PF reads (default: false)
  type: boolean?
  sbg:category: SequenceArtifactMetricsAlgo
- id: tandem_reads
  label: Tandem reads (SequenceArtifactMetricsAlgo)
  doc: |- 
    If mate pairs are being sequenced from the same strand (default: false)
  type: boolean?
  sbg:category: SequenceArtifactMetricsAlgo
- id: context_size
  label: Context size (SequenceArtifactMetricsAlgo)
  doc: |- 
    Number of context bases to include on each side (default: 1)
  type: int?
  sbg:category: SequenceArtifactMetricsAlgo
- id: cpu_per_job
  label: CPU per job
  doc: CPU per job
  type: int?
- id: mem_per_job
  label: Memory per job
  doc: Memory per job[MB].
  type: int?

outputs:
- id: as_output
  type: File
  outputBinding:
    glob: '*.alignmentsummary_metrics'
- id: sama_bait_bias_detail_metrics
  type: File
  outputBinding:
    glob: '*.artifact_metrics.bait_bias_detail_metrics'
- id: sama_bait_bias_summary_metrics
  type: File
  outputBinding:
    glob: '*.artifact_metrics.bait_bias_summary_metrics'
- id: sama_error_summary_metrics
  type: File
  outputBinding:
    glob: '*.artifact_metrics.error_summary_metrics'
- id: sama_oxog_metrics
  type: File
  outputBinding:
    glob: '*.artifact_metrics.oxog_metrics'
- id: sama_pre_adapter_detail_metrics
  type: File
  outputBinding:
    glob: '*.artifact_metrics.pre_adapter_detail_metrics'
- id: sama_pre_adapter_summary_metrics
  type: File
  outputBinding:
    glob: '*.artifact_metrics.pre_adapter_summary_metrics'
- id: bdbc_output
  type: File
  outputBinding:
    glob: '*.base_dist_by_cycle_metrics.txt'
- id: gc_bias_chart
  type: File
  outputBinding:
    glob: '*.gc_bias_metrics.pdf'
- id: gc_bias_detail
  type: File
  outputBinding:
    glob: '*.gc_bias_metrics.txt'
- id: gc_bias_summary
  type: File
  outputBinding:
    glob: '*.gc_bias_summary_metrics.txt'
- id: is_metrics
  type: File
  outputBinding:
    glob: '*.insert_size_metrics.txt'
- id: is_plot
  type: File
  outputBinding:
    glob: '*.insert_size_Histogram.pdf'
- id: mqbc_output
  type: File
  outputBinding:
    glob: '*.mean_qual_by_cycle.txt'
- id: mqbc_plot
  type: File
  outputBinding:
    glob: '*.mean_qual_by_cycle.pdf'
- id: qd_chart
  type: File
  outputBinding:
    glob: '*.qual_score_dist.pdf'
- id: qd_metrics
  type: File
  outputBinding:
    glob: '*.qual_score_dist.txt'
- id: qy_output
  type: File
  outputBinding:
    glob: '*.qual_yield_metrics.txt'

baseCommand:
- sentieon
- driver
arguments:
- prefix: '--algo'
  position: 10
  valueFrom: |-
    ${
        var AlignmentStat_opt = ""
        if (inputs.adapter_seq) AlignmentStat_opt = "--adapter_seq " + inputs.adapter_seq + " "
        return "AlignmentStat " + AlignmentStat_opt + inputs.input_bam.nameroot + ".alignmentsummary_metrics"
    }
  shellQuote: false
- prefix: '--algo'
  position: 20
  valueFrom: |-
    ${
        var BaseDistributionByCycle_opt = ""
        if (inputs.aligned_reads_only) BaseDistributionByCycle_opt = "--aligned_reads_only true "
        if (inputs.pf_reads_only) BaseDistributionByCycle_opt = BaseDistributionByCycle_opt + "--pf_reads_only true "
        return "BaseDistributionByCycle " + BaseDistributionByCycle_opt + inputs.input_bam.nameroot + ".base_dist_by_cycle_metrics.txt"
    }
  shellQuote: false
- prefix: '--algo'
  position: 30
  valueFrom: |-
    ${
        var GCBias_opt = ""
        if (inputs.accum_level_gc_bias) GCBias_opt = "--accum_level " + inputs.accum_level_gc_bias + " "
        if (inputs.also_ignore_duplicates) GCBias_opt = GCBias_opt + "--also_ignore_duplicates "
        return "GCBias --summary " + inputs.input_bam.nameroot + ".gc_bias_summary_metrics.txt " + GCBias_opt + inputs.input_bam.nameroot + ".gc_bias_metrics.txt"
    }
  shellQuote: false
- prefix: '--algo'
  position: 40
  valueFrom: MeanQualityByCycle $(inputs.input_bam.nameroot).mean_qual_by_cycle.txt
  shellQuote: false
- prefix: '--algo'
  position: 50
  valueFrom: QualDistribution $(inputs.input_bam.nameroot).qual_score_dist.txt
  shellQuote: false
- prefix: '--algo'
  position: 60
  valueFrom: |-
    ${
        var QualityYield_opt = ""
        if (inputs.include_secondary) QualityYield_opt = "--include_secondary true "
        if (inputs.include_supplementary) QualityYield_opt = QualityYield_opt + "--include_supplementary true "
        return "QualityYield " + QualityYield_opt + inputs.input_bam.nameroot + ".qual_yield_metrics.txt"
    }
  shellQuote: false
- prefix: '--algo'
  position: 70
  valueFrom: |-
    ${
        var dbsnp_arg = ""
        if (inputs.dbsnp) {
            dbsnp_arg = "--dbsnp " + inputs.dbsnp.path + " "
        }
        var SA_opt = ""
        if (inputs.min_base_qual) SA_opt = "--min_base_qual " + inputs.min_base_qual + " "
        if (inputs.min_map_qual) SA_opt = SA_opt + "--min_map_qual " + inputs.min_map_qual + " "
        if (inputs.min_insert_size) SA_opt = SA_opt + "--min_insert_size " + inputs.min_insert_size + " "
        if (inputs.max_insert_size) SA_opt = SA_opt + "--max_insert_size " + inputs.max_insert_size + " "
        if (inputs.include_unpaired) SA_opt = SA_opt + "--include_unpaired true "
        if (inputs.include_duplicates) SA_opt = SA_opt + "--include_duplicates true "
        if (inputs.include_non_pf_reads) SA_opt = SA_opt + "--include_non_pf_reads true "
        if (inputs.tandem_reads) SA_opt = SA_opt + "--tandem_reads true "
        if (inputs.context_size) SA_opt = SA_opt + "--context_size " + inputs.context_size + " "
        return "SequenceArtifactMetricsAlgo " + dbsnp_arg + SA_opt + inputs.input_bam.nameroot + ".artifact_metrics"
    }
  shellQuote: false
- prefix: '--algo'
  position: 80
  valueFrom: InsertSizeMetricAlgo $(inputs.input_bam.nameroot).insert_size_metrics.txt
  shellQuote: false
- prefix: ''
  position: 110
  valueFrom: |-
    ; sentieon plot GCBias -o $(inputs.input_bam.nameroot).gc_bias_metrics.pdf $(inputs.input_bam.nameroot).gc_bias_metrics.txt
  shellQuote: false
- prefix: ''
  position: 120
  valueFrom: |-
    ; sentieon plot QualDistribution -o $(inputs.input_bam.nameroot).qual_score_dist.pdf $(inputs.input_bam.nameroot).qual_score_dist.txt
  shellQuote: false
- prefix: ''
  position: 130
  valueFrom: |-
    ; sentieon plot InsertSizeMetricAlgo -o $(inputs.input_bam.nameroot).insert_size_Histogram.pdf $(inputs.input_bam.nameroot).insert_size_metrics.txt
  shellQuote: false
- prefix: ''
  position: 140
  valueFrom: |-
    ; sentieon plot MeanQualityByCycle -o $(inputs.input_bam.nameroot).mean_qual_by_cycle.pdf $(inputs.input_bam.nameroot).mean_qual_by_cycle.txt
  shellQuote: false
