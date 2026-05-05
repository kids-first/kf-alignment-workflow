cwlVersion: v1.2
class: CommandLineTool
id: fastp_adapter_detect
label: "fastp v0.23.4 Adapter Detection"
doc: |
  Run fastp to detect adapter sequences and produce JSON and HTML QC reports.
  Trimmed reads are discarded (/tmp); only the reports are used downstream.
  Processes up to 1M reads by default. --detect_adapter_for_pe is added
  automatically when reads2 is provided.
requirements:
  - class: ShellCommandRequirement
  - class: DockerRequirement
    dockerPull: 'quay.io/biocontainers/fastp:0.23.4--h5f740d0_0'
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    coresMin: $(inputs.threads)
    ramMin: 4000

baseCommand: [fastp]

inputs:
  reads1:
    type: File
    doc: "R1 FASTQ (or FASTQ.GZ) file"
    inputBinding:
      prefix: "-i"
      position: 1
  reads2:
    type: 'File?'
    doc: "R2 FASTQ (or FASTQ.GZ) file for paired-end input"
    inputBinding:
      prefix: "-I"
      position: 2
  sample_name:
    type: string
    doc: "Sample name used to name output reports"
  threads:
    type: 'int?'
    default: 4
    inputBinding:
      prefix: "--thread"
      position: 3
  reads_to_process:
    type: 'int?'
    default: 1000000
    doc: "Limit number of reads analysed (speeds up detection)"
    inputBinding:
      prefix: "--reads_to_process"
      position: 4

arguments:
  - position: 5
    shellQuote: false
    valueFrom: $(inputs.reads2 != null ? "--detect_adapter_for_pe" : "")
  - position: 6
    shellQuote: false
    valueFrom: >-
      -h $(inputs.sample_name).fastp.html
      -j $(inputs.sample_name).fastp.json
      -o /tmp/fastp_discard_r1.fastq.gz
      $(inputs.reads2 != null ? "-O /tmp/fastp_discard_r2.fastq.gz" : "")

outputs:
  fastp_json:
    type: File
    doc: "fastp JSON report with detected adapter sequences and QC metrics"
    outputBinding:
      glob: $(inputs.sample_name).fastp.json
  fastp_html:
    type: File
    doc: "fastp HTML report"
    outputBinding:
      glob: $(inputs.sample_name).fastp.html
  r1_adapter:
    type: 'string?'
    doc: "Detected R1 adapter sequence"
    outputBinding:
      glob: $(inputs.sample_name).fastp.json
      loadContents: true
      outputEval: |
        ${
          var ac = JSON.parse(self[0].contents).adapter_cutting || {};
          var v = ac.read1_adapter_sequence || "";
          return v.length > 0 ? v : null;
        }
  r2_adapter:
    type: 'string?'
    doc: "Detected R2 adapter sequence"
    outputBinding:
      glob: $(inputs.sample_name).fastp.json
      loadContents: true
      outputEval: |
        ${
          var ac = JSON.parse(self[0].contents).adapter_cutting || {};
          var v = ac.read2_adapter_sequence || "";
          return v.length > 0 ? v : null;
        }
