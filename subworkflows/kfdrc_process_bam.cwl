cwlVersion: v1.0
class: Workflow
id: kfdrc_process_bam
requirements:
  - class: ScatterFeatureRequirement
  - class: SubworkflowFeatureRequirement
inputs:
  input_bam: File
  indexed_reference_fasta:
    type: File
    secondaryFiles: ['.64.amb', '.64.ann', '.64.bwt', '.64.pac', '.64.sa', '.64.alt', '^.dict']
  sample_name: string
  min_alignment_score: int?
outputs:
  unsorted_bams:
    type:
      type: array
      items:
        type: array
        items: File
    outputSource: realign_split_bam/unsorted_bams

steps:
  samtools_split:
    run: ../tools/samtools_split.cwl
    in:
      input_bam: input_bam
      reference: indexed_reference_fasta
    out: [bam_files] #+1 Nesting File[]

  realign_split_bam:
    run: kfdrc_rgbam_to_realnbam.cwl
    in:
      indexed_reference_fasta: indexed_reference_fasta
      sample_name: sample_name
      input_rgbam: samtools_split/bam_files
      min_alignment_score: min_alignment_score
    scatter: [input_rgbam]
    out: [unsorted_bams] #+1 Nesting File[][]
