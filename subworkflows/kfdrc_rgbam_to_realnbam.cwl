cwlVersion: v1.2
class: Workflow
id: kfdrc_rgbam_to_realnbam
requirements:
  - class: ScatterFeatureRequirement
  - class: InlineJavascriptRequirement
  - class: MultipleInputFeatureRequirement
inputs:
  input_rgbam: File
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
    type: File[]
    outputSource: bwa_mem_naive_bam/output
  cutadapt_stats: { type: 'File[]?', outputSource: cutadapt/cutadapt_stats }

steps:
  bamtofastq_chomp:
    run: ../tools/bamtofastq_chomp.cwl
    in:
      input_align: input_rgbam
      reference: cram_reference
      cpu: bamtofastq_cpu
    out: [output, rg_string]

  expression_updatergsample:
    run: ../tools/expression_preparerg.cwl
    in:
      rg: bamtofastq_chomp/rg_string
      sample: sample_name
    out: [rg_str]

  cutadapt:
    run: ../tools/cutadapt.cwl
    when: |
      $(inputs.r1_threeprime_adapter != null && inputs.r2_threeprime_adapter != null)
    scatter: [input_reads1]
    in:
      input_reads1: bamtofastq_chomp/output
      interleaved:
        valueFrom: $(1 == 1)
      r1_threeprime_adapter: cutadapt_r1_adapter
      r2_threeprime_adapter: cutadapt_r2_adapter
      minimum_length: cutadapt_min_len
      quality_base: cutadapt_quality_base
      quality_cutoff: cutadapt_quality_cutoff
      outputname_reads1:
        valueFrom: TRIMMED.$(inputs.input_reads1.basename)
      outputname_stats:
        source: [output_basename, expression_updatergsample/rg_str]
        valueFrom: |
          ${
            var basename = self[0];
            var rg_id = self[1].match(/ID:[A-Za-z0-9-_/]*?([A-Za-z0-9-_]*)\\t/);
            var reads_name = inputs.input_reads1.basename.replace(/.f(ast)?[aq](\.gz)?$/,"");
            return [basename, (rg_id != null ? rg_id[1] : "UNKNOWN"),  reads_name, "cutadapt_stats.txt"].join('.');
          }
    out: [ trimmed_output, trimmed_paired_output, cutadapt_stats ]

  expression_pick_filelist:
    hints:
    - class: "sbg:AWSInstanceType"
      value: c5.9xlarge
    run:
      class: ExpressionTool
      requirements:
        InlineJavascriptRequirement: {}
      inputs:
        in_filelist: { type: 'File[]' }
      outputs:
        out_filelist: { type: 'File[]' }
      expression: |
        $({"out_filelist": inputs.in_filelist})
    in:
      in_filelist:
        source: [cutadapt/trimmed_output, bamtofastq_chomp/output]
        pickValue: first_non_null
    out: [out_filelist]

  bwa_mem_naive_bam:
    run: ../tools/bwa_mem_naive.cwl
    in:
      ref: indexed_reference_fasta
      reads: expression_pick_filelist/out_filelist
      interleaved:
        default: true
      rg: expression_updatergsample/rg_str
      min_alignment_score: min_alignment_score
    scatter: [reads]
    out: [output]

$namespaces:
  sbg: https://sevenbridges.com
hints:
  - class: 'sbg:maxNumberOfParallelInstances'
    value: 4
