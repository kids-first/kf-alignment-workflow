cwlVersion: v1.0
class: CommandLineTool
id: sambamba_merge
requirements:
  - class: ShellCommandRequirement
  - class: ResourceRequirement
    ramMin: 2024
    coresMin: 36
  - class: DockerRequirement
    dockerPull: 'images.sbgenomics.com/bogdang/sambamba:0.6.3'
  - class: InlineJavascriptRequirement
    expressionLib:
      - |-
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
    separate: false
    shellQuote: false
    valueFrom: |-
      ${
          var in_var = []
          if (inputs.bams instanceof Array) { // VK
              if (inputs.bams[0] instanceof Array) {
                  // Support for input received as list of one-element-lists 
                  for (var i = 0; i < inputs.bams.length; i++)
                      in_var = in_var.concat(inputs.bams[i]);
              } else {
                  in_var = [].concat(inputs.bams)
              }
          } else {
              in_var = [].concat(inputs.bams)
          }
          var comm = ''
          if (in_var instanceof Array) // Always true
          {
              if (in_var.length == 1) {
                  comm += 'cp '
              } else if (in_var.length > 1) {
                  comm += '/opt/sambamba_0.6.3/sambamba_v0.6.3 merge '
                  if (inputs.num_of_threads) {
                      comm += ' -t '
                      comm += inputs.num_of_threads
                  }
                  if (inputs.compression_level) {
                      comm += ' -l '
                      comm += inputs.compression_level
                  }
              }
          }
          return comm
      }
  - position: 11
    shellQuote: false
    valueFrom: |-
      ${
          var in_var = []
          if (inputs.bams instanceof Array) { // VK
              if (inputs.bams[0] instanceof Array) {
                  // Support for input received as list of one-element-lists 
                  for (var i = 0; i < inputs.bams.length; i++)
                      in_var = in_var.concat(inputs.bams[i]);
              } else {
                  in_var = [].concat(inputs.bams)
              }
          } else {
              in_var = [].concat(inputs.bams)
          }
          var comm = ''
          if (in_var.length == 1) {
              comm += '. '
              if (in_var[0].secondaryFiles != undefined && in_var[0].secondaryFiles.length > 0) {
                  comm += '| cp '
                  comm += in_var[0].secondaryFiles[0].path
                  comm += ' . '
              }
          }
          return comm
      }
  - position: 6
    shellQuote: false
    valueFrom: |-
      ${
          var in_var = []
          if (inputs.bams instanceof Array) { // VK
              if (inputs.bams[0] instanceof Array) {
                  // Support for input received as list of one-element-lists 
                  for (var i = 0; i < inputs.bams.length; i++)
                      in_var = in_var.concat(inputs.bams[i]);
              } else {
                  in_var = [].concat(inputs.bams)
              }
          } else {
              in_var = [].concat(inputs.bams)
          }
          if(in_var.length == 1) return '' 
          else return inputs.base_file_name + '.' + inputs.suffix
      }
inputs:
  bams:
    type:
      type: array
      items:
        type: array
        items: File
    inputBinding:
      position: 6
      shellQuote: false
  compression_level: int?
  base_file_name: string
  suffix:
    type: string
    default: aligned.duplicates_marked.unsorted.bam
outputs:
  merged_bam:
    type: File
    outputBinding:
      glob: '*.bam'
      outputEval: ${return inheritMetadata(self, inputs.bams)}
    secondaryFiles: [.bai, ^.bai]
    format: BAM
