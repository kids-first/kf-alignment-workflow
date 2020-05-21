cwlVersion: v1.0
class: CommandLineTool
id: sambamba_merge_anylist
doc: |-
  Takes any list, flattens that list, then merges the items of the list.
  This tool runs the following programs:
    - sambamba merge && rm
requirements:
  - class: ShellCommandRequirement
  - class: ResourceRequirement
    ramMin: 2024
    coresMin: 36
  - class: DockerRequirement
    dockerPull: 'images.sbgenomics.com/bogdang/sambamba:0.6.3'
  - class: InlineJavascriptRequirement
baseCommand: []
arguments:
  - position: 0
    shellQuote: false
    valueFrom: |-
      ${
        var flatin = [].concat.apply([],inputs.bams);
        var arr = [];
        for (var i=0; i<flatin.length; i++)
          arr = arr.concat(flatin[i].path)
        if (arr.length > 1) {
          return "/opt/sambamba_0.6.3/sambamba_v0.6.3 merge -t 36 " + inputs.base_file_name + ".aligned.duplicates_marked.unsorted.bam " + arr.join(' ')
        } else {
          return "cp " + arr.join(' ') + " " + inputs.base_file_name + ".aligned.duplicates_marked.unsorted.bam"
        }
      }
inputs:
  bams: { type: 'Any[]', doc: "Input will be a combination of File[] and deeply nested File[]. Any[] is flexible enough to accomodate the different types" }
  base_file_name: { type: string, doc: "String to be used in naming the output bam" }
outputs:
  merged_bam: { type: File, outputBinding: { glob: '*.bam' }, format: BAM }
