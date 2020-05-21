cwlVersion: v1.0
class: Workflow
id: bwa_mem_naive_wf
requirements:
  - class: ScatterFeatureRequirement
  - class: MultipleInputFeatureRequirement
  - class: SubworkflowFeatureRequirement
inputs:
  input_bam_list: ['null', 'File[]']
  input_pe_reads_list: ['null', 'File[]']
  input_pe_mates_list: ['null', 'File[]']
  input_pe_rgs_list: ['null', 'string[]']
  input_se_reads_list: ['null', 'File[]']
  input_se_rgs_list: ['null', 'string[]']
  indexed_reference_fasta:
    type: File
    secondaryFiles: ['.64.amb', '.64.ann', '.64.bwt', '.64.pac', '.64.sa', '.64.alt', '^.dict', '.amb', '.ann', '.bwt', '.pac', '.sa']
  sample_name: string
  output_basename: string
outputs:
  sorted_bam:
    type: File
    outputSource: sambamba_sort/sorted_bam

steps:
  alignment_gate:
    run: ../tools/alignment_gate.cwl
    in:
      bam_list: input_bam_list
      pe_reads_list: input_pe_reads_list
      pe_mates_list: input_pe_mates_list
      pe_rgs_list: input_pe_rgs_list
      se_reads_list: input_se_reads_list
      se_rgs_list: input_se_rgs_list
    out: [scatter_bams,scatter_pe_reads,scatter_pe_mates,scatter_pe_rgs,scatter_se_reads,scatter_se_rgs]

  process_bams:
    run: kfdrc_process_bam.cwl
    in:
      input_bam: alignment_gate/scatter_bams #File[]
      indexed_reference_fasta: indexed_reference_fasta
      sample_name: sample_name
    scatter: input_bam
    out: [unsorted_bams] #+2 Nesting File[][][]

  bwa_mem_naive_pe_reads:
    run: ../tools/bwa_mem_naive.cwl
    in:
      ref: indexed_reference_fasta
      reads: alignment_gate/scatter_pe_reads #File[]
      mates: alignment_gate/scatter_pe_mates #File[]
      rg: alignment_gate/scatter_pe_rgs #string[]
    scatter: [reads, mates, rg]
    scatterMethod: dotproduct
    out: [output] #+0 Nesting File[]

  bwa_mem_naive_se_reads:
    run: ../tools/bwa_mem_naive.cwl
    in:
      ref: indexed_reference_fasta
      reads: alignment_gate/scatter_se_reads #File[]
      rg: alignment_gate/scatter_se_rgs #string[]
    scatter: [reads, rg]
    scatterMethod: dotproduct
    out: [output] #+0 Nesting File[]

  sambamba_merge:
    run: ../tools/sambamba_merge_anylist.cwl
    in:
      bams: 
        source: [process_bams/unsorted_bams, bwa_mem_naive_pe_reads/output, bwa_mem_naive_se_reads/output]
        linkMerge: merge_flattened
      base_file_name: output_basename
    out: [merged_bam]

  sambamba_sort:
    run: ../tools/sambamba_sort.cwl
    in:
      bam: sambamba_merge/merged_bam
      base_file_name: output_basename
    out: [sorted_bam]

$namespaces:
  sbg: https://sevenbridges.com
hints:
  - class: 'sbg:maxNumberOfParallelInstances'
    value: 4
