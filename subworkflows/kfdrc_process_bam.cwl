cwlVersion: v1.2
class: Workflow
id: kfdrc_process_bam
requirements:
  - class: ScatterFeatureRequirement
  - class: SubworkflowFeatureRequirement
  - class: InlineJavascriptRequirement
inputs:
  input_bam: File
  indexed_reference_fasta:
    type: File
    secondaryFiles: ['.64.amb', '.64.ann', '.64.bwt', '.64.pac', '.64.sa', '.64.alt', '^.dict']
  sample_name: string
  output_basename: { type: 'string?' }
  cutadapt_r1_adapter: { type: 'string?', doc: "If read1 reads have an adapter, provide regular 3' adapter sequence here to remove it from read1" }
  cutadapt_r2_adapter: { type: 'string?', doc: "If read2 reads have an adapter, provide regular 3' adapter sequence here to remove it from read2" }
  cutadapt_min_len: { type: 'int?', doc: "If adapter trimming, discard reads/read-pairs where the read length is less than this value. Set to 0 to turn off" }
  cutadapt_quality_base: { type: 'int?', doc: "If adapter trimming, use this value as the base quality score. Defaults to 33 but very old reads might need this value set to 64" }
  cutadapt_quality_cutoff: { type: 'string?', doc: "If adapter trimming, remove bases from the 3'/5' that fail to meet this cutoff value. If you specify a single cutoff value, the 3' end of each read is trimmed. If you specify two cutoff values separated by a comma, the first value will be trimmed from the 5' and the second value will be trimmed from the 3'" }
  min_alignment_score: int?
  cram_reference: { type: 'File?', doc: "If aligning from cram, need to provided reference used to generate that cram" }
  bamtofastq_cpu: { type: 'int?', doc: "CPUs to allocate to bamtofastq" }

outputs:
  unsorted_bams:
    type:
      type: array
      items:
        type: array
        items: File
    outputSource: realign_split_bam/unsorted_bams
  cutadapt_stats:
    type:
      - 'null'
      - type: array
        items:
          type: array
          items: File
    outputSource: realign_split_bam/cutadapt_stats

steps:
  samtools_split:
    run: ../tools/samtools_split.cwl
    in:
      input_bam: input_bam
      reference:
        source: [cram_reference, indexed_reference_fasta]
        pickValue: first_non_null
    out: [bam_files] #+1 Nesting File[]

  realign_split_bam:
    run: kfdrc_rgbam_to_realnbam.cwl
    in:
      indexed_reference_fasta: indexed_reference_fasta
      sample_name: sample_name
      input_rgbam: samtools_split/bam_files
      output_basename: output_basename
      cutadapt_r1_adapter: cutadapt_r1_adapter
      cutadapt_r2_adapter: cutadapt_r2_adapter
      cutadapt_min_len: cutadapt_min_len
      cutadapt_quality_base: cutadapt_quality_base
      cutadapt_quality_cutoff: cutadapt_quality_cutoff
      min_alignment_score: min_alignment_score
      cram_reference: cram_reference
      bamtofastq_cpu: bamtofastq_cpu
    scatter: [input_rgbam]
    out: [unsorted_bams, cutadapt_stats] #+1 Nesting File[][]
