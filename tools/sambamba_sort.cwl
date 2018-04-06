cwlVersion: v1.0
class: CommandLineTool
id: sambamba_sort
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
baseCommand:
  - /opt/sambamba_0.6.3/sambamba_v0.6.3
  - sort
arguments:
  - position: 0
    shellQuote: false
    valueFrom: '-o $(inputs.base_file_name).$(inputs.suffix)'
inputs:
  bam:
    type: File
    inputBinding:
      position: 6
      shellQuote: false
    label: BAM files
    doc: Input BAM files.
  num_of_threads:
    type: int?
    inputBinding:
      position: 1
      prefix: '-t'
      shellQuote: false
    label: Number of threads to use
    doc: Number of threads to use for compression/decompression.
  base_file_name:
    type: string
  suffix:
    type: string
outputs:
  sorted_bam:
    doc: Sorted bam.
    label: Sorted bam
    type: File
    outputBinding:
      glob: '*.bam'
    secondaryFiles:
      - .bai
      - ^.bai
    format: BAM
