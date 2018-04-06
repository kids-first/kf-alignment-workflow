cwlVersion: v1.0
class: CommandLineTool
id: sambamba_merge
requirements:
  - class: ShellCommandRequirement
  - class: ResourceRequirement
    ramMin: |-
      ${
          if (inputs.mem_mb) {

              return inputs.mem_mb

          } else {

              return 1024

          }

      }
    coresMin: |-
      ${
          if (inputs.num_of_threads) {

              return inputs.num_of_threads

          } else {

              return 1
          }

      }
  - class: DockerRequirement
    dockerPull: 'images.sbgenomics.com/bogdang/sambamba:0.6.3'
  - class: InitialWorkDirRequirement
    listing: []
  - class: InlineJavascriptRequirement
    expressionLib:
      - |-
        var updateMetadata = function(file, key, value) {
            file['metadata'][key] = value;
            return file;
        };


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

        var toArray = function(file) {
            return [].concat(file);
        };

        var groupBy = function(files, key) {
            var groupedFiles = [];
            var tempDict = {};
            for (var i = 0; i < files.length; i++) {
                var value = files[i]['metadata'][key];
                if (value in tempDict)
                    tempDict[value].push(files[i]);
                else tempDict[value] = [files[i]];
            }
            for (var key in tempDict) {
                groupedFiles.push(tempDict[key]);
            }
            return groupedFiles;
        };

        var orderBy = function(files, key, order) {
            var compareFunction = function(a, b) {
                if (a['metadata'][key].constructor === Number) {
                    return a['metadata'][key] - b['metadata'][key];
                } else {
                    var nameA = a['metadata'][key].toUpperCase();
                    var nameB = b['metadata'][key].toUpperCase();
                    if (nameA < nameB) {
                        return -1;
                    }
                    if (nameA > nameB) {
                        return 1;
                    }
                    return 0;
                }
            };

            files = files.sort(compareFunction);
            if (order == undefined || order == "asc")
                return files;
            else
                return files.reverse();
        };
baseCommand: []
arguments:
  - position: 0
    separate: false
    shellQuote: false
    valueFrom: |-
      ${
          if (inputs.bams instanceof Array) { // VK
              if (inputs.bams[0] instanceof Array) {

                  // Support for input received as list of one-element-lists 
                  in_var = []
                  for (i = 0; i < inputs.bams.length; i++)
                      in_var = in_var.concat(inputs.bams[i]);

              } else {
                  in_var = [].concat(inputs.bams)
              }


          } else {
              in_var = [].concat(inputs.bams)
          }
          comm = ''
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
          if (inputs.bams instanceof Array) { // VK
              if (inputs.bams[0] instanceof Array) {

                  // Support for input received as list of one-element-lists 
                  in_var = []
                  for (i = 0; i < inputs.bams.length; i++)
                      in_var = in_var.concat(inputs.bams[i]);

              } else {
                  in_var = [].concat(inputs.bams)
              }


          } else {
              in_var = [].concat(inputs.bams)
          }

          comm = ''
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
          if(inputs.bams.length == 1) return '' 
          else return inputs.base_file_name+ '.' + inputs.suffix
      }
inputs:
  bams:
    type: 'File[]'
    inputBinding:
      position: 6
      shellQuote: false
    label: BAM files
    doc: Input BAM files.
  compression_level:
    type: int?
    label: Compression level
    doc: 'Level of compression for merged BAM file, number from 0 to 9.'
  mem_mb:
    type: int?
    label: Memory in MB
    doc: Memory in MB.
  num_of_threads:
    type: int?
    label: Number of threads to use
    doc: Number of threads to use for compression/decompression.
  base_file_name:
    type: string
  suffix:
    type: string
outputs:
  merged_bam:
    doc: Merged bam.
    label: Merged bam
    type: File
    outputBinding:
      glob: '*.bam'
      outputEval: |-
        ${
            return inheritMetadata(self, inputs.bams)

        }
    secondaryFiles:
      - .bai
      - ^.bai
    format: BAM
doc: >-
  Sambamba Merge is used for merging several sorted BAM files into one. The
  sorting order of all the files must be the same, and it is maintained in the
  output file.

