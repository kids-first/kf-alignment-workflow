cwlVersion: v1.0
class: CommandLineTool
id: samtools_index_stats_xy_ratio
requirements:
  - class: ShellCommandRequirement
  - class: ResourceRequirement
    ramMin: ${return inputs.ram * 1000}
    coresMin: $(inputs.threads)
  - class: DockerRequirement
    dockerPull: '684194535433.dkr.ecr.us-east-1.amazonaws.com/d3b-healthomics:samtools'
  - class: InlineJavascriptRequirement
    expressionLib:
    - |2-

      var setMetadata = function(file, metadata) {
          if (!('metadata' in file))
              file['metadata'] = metadata;
          else {
              for (var key in metadata) {
                  file['metadata'][key] = metadata[key];
              }
          }
          return file
      };

      var inheritMetadata = function(o1, o2) {
          var commonMetadata = {};
          if (!Array.isArray(o2)) {
              o2 = [o2]
          }
          for (var i = 0; i < o2.length; i++) {
              var example = o2[i]['metadata'];
              for (var key in example) {
                  if (i == 0)
                      commonMetadata[key] = example[key];
                  else {
                      if (!(commonMetadata[key] == example[key])) {
                          delete commonMetadata[key]
                      }
                  }
              }
          }
          if (!Array.isArray(o1)) {
              o1 = setMetadata(o1, commonMetadata)
          } else {
              for (var i = 0; i < o1.length; i++) {
                  o1[i] = setMetadata(o1[i], commonMetadata)
              }
          }
          return o1;
      };
baseCommand: []
arguments:
  - position: 0
    shellQuote: false
    valueFrom: |
      $(inputs.run_idxstats ? '' : 'echo "idxstats not run" 1>&2 && exit 0;')
  - position: 1
    shellQuote: false
    valueFrom: |
      samtools idxstats $(inputs.input_bam.path) > $(inputs.input_bam.nameroot).idxstats.txt
  - position: 2
    shellQuote: false
    valueFrom: |
      && /bin/bash -c
  - position: 3
    shellQuote: true
    valueFrom: >
      set -eo pipefail;
      cat $(inputs.input_bam.nameroot+".idxstats.txt")
      | awk '{if($1=="chrX") {x_rat = $3/$2; X_reads=$3;}; if($1=="chrY") {y_rat = $3/$2; Y_reads = $3;}}END
      {printf "Y_reads_fraction %f\nX:Y_ratio %f\nX_norm_reads %f\nY_norm_reads %f\nY_norm_reads_fraction %f", Y_reads/(X_reads+Y_reads), x_rat/y_rat, x_rat, y_rat, y_rat/(x_rat+y_rat)}'
      > $(inputs.input_bam.nameroot).ratio.txt
inputs:
  run_idxstats: { type: 'boolean' }
  input_bam: { type: 'File', secondaryFiles: [^.bai] }
  threads: { type: 'int?', default: 2 }
  ram: { type: 'int?', default: 3 }
outputs:
  output: { type: 'File?', outputBinding: { glob: "*idxstats.txt", outputEval: "$(inheritMetadata(self, inputs.input_bam))" } }
  ratio: { type: 'File?', outputBinding: { glob: "*ratio.txt", outputEval: "$(inheritMetadata(self, inputs.input_bam))" } }
