cwlVersion: v1.0
class: Workflow
id: bwa_mem_naive2_wf
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
  run_bam_processing: boolean
  run_pe_reads_processing: boolean
  run_se_reads_processing: boolean
outputs:
  sorted_bam:
    type: File
    outputSource: sambamba_sort/sorted_bam

steps:
  alignment_gate:
    run: ../tools/alignment_gate_bool.cwl
    in:
      run_bam_processing: run_bam_processing
      run_pe_reads_processing: run_pe_reads_processing
      run_se_reads_processing: run_se_reads_processing
    out: [scatter_bams,scatter_pe_reads,scatter_se_reads]

  process_bams:
    run: kfdrc_process_bamlist.cwl
    in:
      input_bam_list: input_bam_list 
      indexed_reference_fasta: indexed_reference_fasta
      sample_name: sample_name
      conditional_run: alignment_gate/scatter_bams
    scatter: conditional_run
    out: [unsorted_bams] #+2 Nesting File[][][]

  process_pe_reads:
    run: kfdrc_process_pe_readslist.cwl 
    in:
      indexed_reference_fasta: indexed_reference_fasta
      input_pe_reads_list: input_pe_reads_list 
      input_pe_mates_list: input_pe_mates_list 
      input_pe_rgs_list: input_pe_rgs_list 
      conditional_run: alignment_gate/scatter_pe_reads
    scatter: conditional_run 
    out: [unsorted_bams] #+0 Nesting File[]

  process_se_reads:
    run: kfdrc_process_se_readslist.cwl
    in:
      indexed_reference_fasta: indexed_reference_fasta
      input_se_reads_list: input_se_reads_list 
      input_se_rgs_list: input_se_rgs_list 
      conditional_run: alignment_gate/scatter_se_reads
    scatter: conditional_run 
    out: [unsorted_bams] #+0 Nesting File[]

  sambamba_merge:
    hints:
      - class: sbg:AWSInstanceType
        value: c5.9xlarge;ebs-gp2;2048
    run: ../tools/sambamba_merge_anylist.cwl
    in:
      bams: 
        source: [process_bams/unsorted_bams, process_pe_reads/unsorted_bams, process_se_reads/unsorted_bams]
        linkMerge: merge_flattened
      base_file_name: output_basename
    out: [merged_bam]

  sambamba_sort:
    hints:
      - class: sbg:AWSInstanceType
        value: c5.9xlarge;ebs-gp2;2048
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
