class: CommandLineTool
cwlVersion: v1.0
id: bwa_mem_split_sambamba
requirements:
  - class: ShellCommandRequirement
  - class: ResourceRequirement
    ramMin: 25000
    coresMin: 18
  - class: DockerRequirement
    dockerPull: 'images.sbgenomics.com/bogdang/bwa-kf-bundle:0.1.17'
  - class: InlineJavascriptRequirement
baseCommand: []
arguments:
  - position: 0
    shellQuote: false
    valueFrom: >-
      >&2 date
      && >&2 echo "Start align"
      && bwa mem -K 100000000 -p -v 3 -t 18 -Y $(inputs.ref.path) -R '$(inputs.rg)' $(inputs.reads.path) | /opt/sambamba_0.6.3/sambamba_v0.6.3 view -t 18 -f bam -l 0 -S /dev/stdin > $(inputs.reads.nameroot).bwa.bam
      && >&2 date
      && >&2 echo "Finished align"
      && /opt/sambamba_0.6.3/sambamba_v0.6.3 sort -t 18 -m 15GiB --tmpdir ./ -o $(inputs.reads.nameroot).sorted.bam -l 5 $(inputs.reads.nameroot).bwa.bam
      && >&2 date
      && >&2 echo "Finished coord sort"
inputs:
  ref:
    type: File
    secondaryFiles: [.64.amb, .64.ann, .64.bwt, .64.pac,
      .64.sa, .64.alt, ^.dict, .amb, .ann, .bwt, .pac, .sa]
  reads: File
  rg: string

outputs:
  output: { type: File, outputBinding: { glob: '*.sorted.bam' } }
