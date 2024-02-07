cwlVersion: v1.0
class: CommandLineTool
id: sambamba_merge_anylist
doc: |-
  Takes a list of BAMs, flattens that list, then merges the items of the list.
  This tool runs the following programs:
    - sambamba merge && rm
requirements:
  - class: ShellCommandRequirement
  - class: ResourceRequirement
    ramMin: 2024
    coresMin: 36
  - class: DockerRequirement
    dockerPull: '684194535433.dkr.ecr.us-east-1.amazonaws.com/d3b-healthomics:sambamba'
  - class: InlineJavascriptRequirement
    expressionLib:
      - |-
        //https://stackoverflow.com/a/27267762
        var flatten = function flatten(ary) {
            var ret = [];
            for(var i = 0; i < ary.length; i++) {
                if(Array.isArray(ary[i])) {
                    ret = ret.concat(flatten(ary[i]));
                } else {
                    ret.push(ary[i]);
                }
            }
            return ret;
        }
baseCommand: []
arguments:
  - position: 0
    shellQuote: false
    valueFrom: |-
      ${
        var flatin = flatten(inputs.bams);
        var arr = [];
        for (var i=0; i<flatin.length; i++) {
          arr = arr.concat(flatin[i].path);
        }
        if (arr.length > 1) {
          return "/opt/sambamba_0.6.3/sambamba_v0.6.3 merge -t 36 " + inputs.base_file_name + ".aligned.duplicates_marked.unsorted.bam " + arr.join(' ');
        } else {
          return "cp " + arr.join(' ') + " " + inputs.base_file_name + ".aligned.duplicates_marked.unsorted.bam";
        }
      }
inputs:
  bams: { type: 'File[]', doc: "List of BAM files" }
  base_file_name: { type: string, doc: "String to be used in naming the output bam" }
outputs:
  merged_bam: { type: File, outputBinding: { glob: '*.bam' }, format: BAM }
