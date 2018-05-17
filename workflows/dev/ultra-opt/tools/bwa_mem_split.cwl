class: CommandLineTool
cwlVersion: v1.0
id: bwa_mem_split
requirements:
  - class: ShellCommandRequirement
  - class: ResourceRequirement
    ramMin: 50000
    coresMin: 18
  - class: DockerRequirement
    dockerPull: 'images.sbgenomics.com/bogdang/bwa-kf-bundle:0.1.17'
  - class: InlineJavascriptRequirement
baseCommand: []
arguments:
  - position: 0
    shellQuote: false
    valueFrom: >-
      if [ $(inputs.reads.nameext) = ".bam" ]; then
        CMD='/opt/biobambam2/2.0.87-release-20180301132713/x86_64-etch-linux-gnu/bin/bamtofastq tryoq=1 filename=$(inputs.reads.path)'
      else
        CMD='cat $(inputs.reads.path)'
      fi

      $CMD | bwa mem -K 100000000 -p -v 3 -t 18
      -Y $(inputs.ref.path)
      -R '$(inputs.rg)' -
      | /opt/samblaster/samblaster -i /dev/stdin -o /dev/stdout
      | /opt/sambamba_0.6.3/sambamba_v0.6.3 view -t 18 -f bam -l 0 -S /dev/stdin
      | /opt/sambamba_0.6.3/sambamba_v0.6.3 sort -t 18 --natural-sort -m 35GiB --tmpdir ./
      -o $(inputs.reads.nameroot).unsorted.bam -l 5 /dev/stdin
inputs:
  ref:
    type: File
    secondaryFiles: [.64.amb, .64.ann, .64.bwt, .64.pac,
      .64.sa, .64.alt, ^.dict, .amb, .ann, .bwt, .pac, .sa]
  reads: File
  rg: string

outputs:
  output: { type: File, outputBinding: { glob: '*.bam' } }
