cwlVersion: v1.0
class: Workflow
id: kfdrc_process_pe_readslist2 
requirements:
  - class: ScatterFeatureRequirement
  - class: MultipleInputFeatureRequirement
  - class: SubworkflowFeatureRequirement
inputs:
  input_pe_reads_list: File[]
  input_pe_mates_list: File[]
  input_pe_rgs_list: string[]
  conditional_run: int
  indexed_reference_fasta:
    type: File
    secondaryFiles: ['.64.amb', '.64.ann', '.64.bwt', '.64.pac', '.64.sa', '^.dict', '.fai']
  cutadapt_r1_adapter: { type: 'string?', doc: "If read1 reads have an adapter, provide regular 3' adapter sequence here to remove it from read1" }
  cutadapt_r2_adapter: { type: 'string?', doc: "If read2 reads have an adapter, provide regular 3' adapter sequence here to remove it from read2" }
  cutadapt_min_len: { type: 'int?', doc: "If adapter trimming, discard reads/read-pairs where the read length is less than this value. Set to 0 to turn off" }
  cutadapt_quality_base: { type: 'int?', doc: "If adapter trimming, use this value as the base quality score. Defaults to 33 but very old reads might need this value set to 64" }
  cutadapt_quality_cutoff: { type: 'string?', doc: "If adapter trimming, remove bases from the 3'/5' that fail to meet this cutoff value. If you specify a single cutoff value, the 3' end of each read is trimmed. If you specify two cutoff values separated by a comma, the first value will be trimmed from the 5' and the second value will be trimmed from the 3'" }
  min_alignment_score: int?
outputs:
  unsorted_bams: 
    type:
      type: array
      items:
        type: array
        items: File 
    outputSource: process_pe_set/unsorted_bams
  cutadapt_stats: { type: 'File[]?', outputSource: process_pe_set/cutadapt_stats }

steps:
  process_pe_set:
    run: kfdrc_process_pe_set.cwl
    in:
      indexed_reference_fasta: indexed_reference_fasta
      input_pe_reads: input_pe_reads_list
      input_pe_mates: input_pe_mates_list
      input_pe_rgs: input_pe_rgs_list
      cutadapt_r1_adapter: cutadapt_r1_adapter
      cutadapt_r2_adapter: cutadapt_r2_adapter
      cutadapt_min_len: cutadapt_min_len
      cutadapt_quality_base: cutadapt_quality_base
      cutadapt_quality_cutoff: cutadapt_quality_cutoff
      min_alignment_score: min_alignment_score
    scatter: [input_pe_reads, input_pe_mates, input_pe_rgs]
    scatterMethod: dotproduct
    out: [unsorted_bams, cutadapt_stats]

$namespaces:
  sbg: https://sevenbridges.com
hints:
  - class: 'sbg:maxNumberOfParallelInstances'
    value: 4
