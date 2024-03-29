cwlVersion: v1.2
class: Workflow
id: kfdrc_process_pe_set
requirements:
  - class: ScatterFeatureRequirement
  - class: MultipleInputFeatureRequirement
  - class: SubworkflowFeatureRequirement
  - class: InlineJavascriptRequirement
inputs:
  input_pe_reads: File
  input_pe_mates: File
  input_pe_rgs: string
  indexed_reference_fasta:
    type: File
    secondaryFiles: ['.64.amb', '.64.ann', '.64.bwt', '.64.pac', '.64.sa', '.64.alt', '^.dict'] 
  output_basename: { type: 'string?' }
  cutadapt_r1_adapter: { type: 'string?', doc: "If read1 reads have an adapter, provide regular 3' adapter sequence here to remove it from read1" }
  cutadapt_r2_adapter: { type: 'string?', doc: "If read2 reads have an adapter, provide regular 3' adapter sequence here to remove it from read2" }
  cutadapt_min_len: { type: 'int?', doc: "If adapter trimming, discard reads/read-pairs where the read length is less than this value. Set to 0 to turn off" }
  cutadapt_quality_base: { type: 'int?', doc: "If adapter trimming, use this value as the base quality score. Defaults to 33 but very old reads might need this value set to 64" }
  cutadapt_quality_cutoff: { type: 'string?', doc: "If adapter trimming, remove bases from the 3'/5' that fail to meet this cutoff value. If you specify a single cutoff value, the 3' end of each read is trimmed. If you specify two cutoff values separated by a comma, the first value will be trimmed from the 5' and the second value will be trimmed from the 3'" }
  min_alignment_score: int?
outputs:
  unsorted_bams: 
    type: File[]
    outputSource: bwa_mem_split_pe_reads/output
  cutadapt_stats: { type: 'File?', outputSource: cutadapt/cutadapt_stats }

steps:
  cutadapt:
    run: ../tools/cutadapt.cwl
    when: |
      $(inputs.r1_threeprime_adapter != null && inputs.r2_threeprime_adapter != null)
    in:
      input_reads1: input_pe_reads
      input_reads2: input_pe_mates
      interleaved:
        valueFrom: $(1 == 0)
      r1_threeprime_adapter: cutadapt_r1_adapter
      r2_threeprime_adapter: cutadapt_r2_adapter
      minimum_length: cutadapt_min_len
      quality_base: cutadapt_quality_base
      quality_cutoff: cutadapt_quality_cutoff
      outputname_reads1:
        source: input_pe_reads
        valueFrom: TRIMMED.$(self.basename)
      outputname_reads2:
        source: input_pe_mates
        valueFrom: TRIMMED.$(self.basename)
      outputname_stats:
        source: [output_basename, input_pe_rgs]
        valueFrom: |
          ${
            var basename = self[0];
            var rg_id = self[1].match(/ID:[A-Za-z0-9-_/]*?([A-Za-z0-9-_]*)\\t/);
            var reads_name = inputs.input_reads1.basename.replace(/.f(ast)?[aq](\.gz)?$/,"");
            return [basename, (rg_id != null ? rg_id[1] : "UNKNOWN"),  reads_name, "cutadapt_stats.txt"].join('.');
          }
    out: [ trimmed_output, trimmed_paired_output, cutadapt_stats ]

  zcat_split_reads:
    hints:
      - class: 'sbg:AWSInstanceType'
        value: c5.9xlarge
    run: ../tools/fastq_chomp.cwl
    in:
      input_fastq:
        source: [cutadapt/trimmed_output, input_pe_reads]
        pickValue: first_non_null
    out: [output]

  zcat_split_mates:
    hints:
      - class: 'sbg:AWSInstanceType'
        value: c5.9xlarge
    run: ../tools/fastq_chomp.cwl
    in:
      input_fastq:
        source: [cutadapt/trimmed_paired_output, input_pe_mates]
        pickValue: first_non_null
    out: [output]
 
  bwa_mem_split_pe_reads:
    run: ../tools/bwa_mem_naive.cwl
    in:
      ref: indexed_reference_fasta
      reads: zcat_split_reads/output
      mates: zcat_split_mates/output
      rg: input_pe_rgs
      min_alignment_score: min_alignment_score
    scatter: [reads, mates]
    scatterMethod: dotproduct
    out: [output] #+0 Nesting File[]

$namespaces:
  sbg: https://sevenbridges.com
hints:
  - class: 'sbg:maxNumberOfParallelInstances'
    value: 4
