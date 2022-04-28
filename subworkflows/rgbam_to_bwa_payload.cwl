cwlVersion: v1.2
class: Workflow
id: rgbam_to_bwa_payload
requirements:
  - class: ScatterFeatureRequirement
  - class: InlineJavascriptRequirement
  - class: StepInputExpressionRequirement
inputs:
  input_rgbam: File
  sample_name: string
outputs:
  bwa_payload:
    type:
      type: record
      fields:
        reads_file:
          type: File
        mates_file:
          type: File?
        rg_str:
          type: string
        interleaved:
          type: boolean
    outputSource: expression_prepare_bwa_payload/bwa_payload

steps:
  samtools_head_rg:
    run: ../tools/samtools_head.cwl
    in:
      input_bam: input_rgbam
      line_filter:
        valueFrom: "^@RG"
    out: [header_file]

  expression_updatergsample:
    run: ../tools/expression_preparerg.cwl
    in:
      rg: samtools_head_rg/header_file
      sample: sample_name
    out: [rg_str]

  bamtofastq:
    run: ../tools/biobambam_bamtofastq.cwl
    in:
      input_bam: input_rgbam
    out: [output]

  expression_prepare_bwa_payload:
    run: ../tools/clt_prepare_bwa_payload.cwl
    in:
      reads: bamtofastq/output
      rg_str: expression_updatergsample/rg_str
      interleaved:
        valueFrom: $(1 == 1)
    out: [bwa_payload]


$namespaces:
  sbg: https://sevenbridges.com
hints:
  - class: 'sbg:maxNumberOfParallelInstances'
    value: 4
