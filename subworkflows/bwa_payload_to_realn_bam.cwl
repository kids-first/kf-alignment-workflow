cwlVersion: v1.2
class: Workflow
id: bwa_payload_to_realn_bam
requirements:
  - class: ScatterFeatureRequirement
  - class: InlineJavascriptRequirement
  - class: StepInputExpressionRequirement
inputs:
  sentieon_license: string
  indexed_reference_fasta:
    type: File
    secondaryFiles: [{ pattern: '.fai', required: true }, { pattern: '^.dict', required: true }, { pattern: '.64.amb', required: true }, { pattern: '.64.ann', required: true }, { pattern: '.64.bwt', required: true }, { pattern: '.64.pac', required: true }, { pattern: '.64.sa', required: true }, { pattern: '.64.alt', required: false }]
    sbg:fileTypes: FA, FASTA
  min_alignment_score: int
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
  output_basename: { type: 'string?' }
  cutadapt_r1_adapter: { type: 'string?', doc: "If read1 reads have an adapter, provide regular 3' adapter sequence here to remove it from read1" }
  cutadapt_r2_adapter: { type: 'string?', doc: "If read2 reads have an adapter, provide regular 3' adapter sequence here to remove it from read2" }
  cutadapt_min_len: { type: 'int?', doc: "If adapter trimming, discard reads/read-pairs where the read length is less than this value. Set to 0 to turn off" }
  cutadapt_quality_base: { type: 'int?', doc: "If adapter trimming, use this value as the base quality score. Defaults to 33 but very old reads might need this value set to 64" }
  cutadapt_quality_cutoff: { type: 'string?', doc: "If adapter trimming, remove bases from the 3'/5' that fail to meet this cutoff value. If you specify a single cutoff value, the 3' end of each read is trimmed. If you specify two cutoff values separated by a comma, the first value will be trimmed from the 5' and the second value will be trimmed from the 3'" }
  bwa_cpu: { type: 'int?', doc: "CPUs to allocate to Sentieon BWA MEM." }
  bwa_ram: { type: 'int?', doc: "RAM in GB to allocate to Sentieon BWA MEM." }
outputs:
  realgn_bam:
    type: File
    outputSource: sentieon_bwa_mem/output
  cutadapt_stats: { type: 'File', outputSource: cutadapt/cutadapt_stats }

steps:
  cutadapt:
    run: ../tools/cutadapt.cwl
    when: |
      $(inputs.r1_threeprime_adapter != null && (inputs.r2_threeprime_adapter != null || inputs.input_reads2.mates_file == null) && (inputs.r2_threeprime_adapter != null || !inputs.interleaved.interleaved))
    in:
      input_reads1:
        source: bwa_payload
        valueFrom: $(self.reads_file)
      input_reads2:
        source: bwa_payload
        valueFrom: $(self.mates_file)
      interleaved:
        source: bwa_payload
        valueFrom: $(self.interleaved)
      r1_threeprime_adapter: cutadapt_r1_adapter
      r2_threeprime_adapter: cutadapt_r2_adapter
      minimum_length: cutadapt_min_len
      quality_base: cutadapt_quality_base
      quality_cutoff: cutadapt_quality_cutoff
      outputname_reads1:
        source: bwa_payload
        valueFrom: TRIMMED.$(self.reads_file.basename)
      outputname_reads2:
        source: bwa_payload
        valueFrom: |
          $(self.mates_file != null ? "TRIMMED." + self.mates_file.basename : null)
      outputname_stats:
        source: [output_basename, bwa_payload]
        valueFrom: |
          ${
            var basename = self[0];
            var rg_id = self[1].rg_str.match(/ID:[A-Za-z0-9-_/]*?([A-Za-z0-9-_]*)\\t/);
            var reads_name = self[1].reads_file.basename.replace(/.f(ast)?[aq](\.gz)?$/,"");
            return [basename, (rg_id != null ? rg_id[1] : "UNKNOWN"),  reads_name, "cutadapt_stats.txt"].join('.');
          }
    out: [ trimmed_output, trimmed_paired_output, cutadapt_stats ]

  sentieon_bwa_mem:
    run: ../tools/sentieon_bwa_sort.cwl
    in:
      sentieon_license: sentieon_license
      reference: indexed_reference_fasta
      reads_forward:
        source: [cutadapt/trimmed_output, bwa_payload]
        valueFrom: |
          $(self[0] != null ? self[0] : self[1].reads_file)
      reads_mate:
        source: [cutadapt/trimmed_paired_output, bwa_payload]
        valueFrom: |
          $(self[0] != null ? self[0] : self[1].mates_file)
      rg:
        source: bwa_payload
        valueFrom: $(self.rg_str)
      interleaved:
        source: bwa_payload
        valueFrom: $(self.interleaved)
      min_alignment_score: min_alignment_score
      chunk_size:
        valueFrom: $(100000000)
      cpu_per_job: bwa_cpu
      mem_per_job: bwa_ram
    out: [output]

$namespaces:
  sbg: https://sevenbridges.com
