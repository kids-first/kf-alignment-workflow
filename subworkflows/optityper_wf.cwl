cwlVersion: v1.2
class: Workflow
id: optitpyer_workflow
doc: "Workflow to run optityper from an aligned reads file"
requirements:
- class: ScatterFeatureRequirement
- class: MultipleInputFeatureRequirement
- class: SubworkflowFeatureRequirement
inputs:
  input_reads: { type: 'File', secondaryFiles: [{ pattern: '.bai', required: false }, { pattern: '^.bai', required: false }, { pattern: '.crai', required: false }, { pattern: '^.crai', required: false }], doc: "BAM/CRAM file" }
  indexed_reference_fasta: {type: 'File', secondaryFiles: [{pattern: ".fai", required: true}], doc: "Reference fasta and fai index" }
outputs:

steps:
  samtools_collate_fastq:
    run: ../tools/samtools_collate_fastq.cwl
    in:
      input_reads:
      reference:
      print_stdout:
        valueFrom: $(1 == 1)
      uncompressed_bamout:
        valueFrom: $(1 == 1)
      outfile_r1:
        valueFrom: "reads_1.fq"
      outfile_r2:
        valueFrom: "reads_2.fq"
      donot_append_rnames:
        valueFrom: $(1 == 1)
    out: [reads_1, reads_2]

  rasers3
    scatter: [input_fastq]

  samtools_fastq:
    scatter: [input_reads]

  optityper:
