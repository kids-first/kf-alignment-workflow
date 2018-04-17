class: CommandLineTool
cwlVersion: v1.0
id: bogdang_kf_alignment_wf_optimization_bwa_mem_58
baseCommand:
  - /opt/samtools-1.7/samtools
inputs:
  - id: indexed_reference_fasta
    type: File
    secondaryFiles:
      - .64.amb
      - .64.ann
      - .64.bwt
      - .64.pac
      - .64.sa
      - .64.alt
      - ^.dict
      - .amb
      - .ann
      - .bwt
      - .pac
      - .sa
  - id: input_bam
    type: File
  - id: threads
    type: int?
    label: Threads
    doc: Threads to use.
outputs:
  - id: output
    type: File
    outputBinding:
      glob: '*.bam'
  - id: rg
    type: File?
    outputBinding:
      glob: RGINFO
label: bwa-mem
arguments:
  - position: 0
    shellQuote: false
    valueFrom: |-
      ${ 
          picard_cmd = "java -Xms5000m -jar /picard.jar SamToFastq INPUT=" + inputs.input_bam.path + " FASTQ=/dev/stdout INTERLEAVE=true NON_PF=true"
          threads = inputs.threads ? inputs.threads : 16
          biobambam2 = "/opt/biobambam2/2.0.87-release-20180301132713/x86_64-etch-linux-gnu/bin/bamtofastq tryoq=1 filename=" + inputs.input_bam.path + " > /dev/stdout"
          return "view -H " + inputs.input_bam.path + " | grep ^@RG > RGINFO && sed -i 's/ /\\t/g' RGINFO && >&2 cat RGINFO && " + biobambam2 + " | bwa mem -R $(awk 'BEGIN {ORS=\"\"} {print $1} { for (i=2; i<=NF; i++) print \"\\\\t\"$i}' RGINFO) -K 100000000 -p -v 3 -t " + threads + "  -Y " + inputs.indexed_reference_fasta.path + " - | /opt/samblaster/samblaster -i /dev/stdin -o /dev/stdout | /opt/sambamba_0.6.3/sambamba_v0.6.3 view -t " + threads + " -f bam -l 0 -S /dev/stdin | /opt/sambamba_0.6.3/sambamba_v0.6.3 sort -t " + threads + " --natural-sort -m 5GiB --tmpdir ./ -o " + inputs.input_bam.nameroot + ".aligned.unsorted.bam -l 5 /dev/stdin"
      }
requirements:
  - class: ShellCommandRequirement
  - class: ResourceRequirement
    ramMin: 14000
    coresMin: |-
      ${
          threads = inputs.threads ? inputs.threads : 16
          return threads
      }
  - class: DockerRequirement
    dockerPull: 'images.sbgenomics.com/bogdang/bwa-kf-bundle:0.1.17'
  - class: InlineJavascriptRequirement
