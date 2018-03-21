class: CommandLineTool
cwlVersion: v1.0
id: bogdang_kf_alignment_wf_optimization_samtools_cram2bam_3
baseCommand: []
inputs:
  - format: BAM
    id: input_reads
    type: File
    inputBinding:
      position: 2
      shellQuote: false
    label: Input file
    doc: Input reads file.
  - id: threads
    type: int?
    inputBinding:
      position: 1
      prefix: '-@'
      shellQuote: false
  - id: reference
    type: File
    inputBinding:
      position: 1
      prefix: '--reference'
      shellQuote: false
outputs:
  - id: bam_file
    doc: Output BAM files.
    label: Output BAM files
    type: File?
    outputBinding:
      glob: '*.bam'
      outputEval: |-
        ${
            if(inputs.input_reads.nameext == '.cram') return self
            else return inputs.input_reads
        }
    format: DICT
label: Samtools Cram2Bam
arguments:
  - position: 0
    shellQuote: false
    valueFrom: |-
      ${
          if (inputs.input_reads.nameext == '.cram')
           return "samtools view -b "
          else return "echo"
      }
requirements:
  - class: ShellCommandRequirement
  - class: DockerRequirement
    dockerPull: 'images.sbgenomics.com/bogdang/samtools:1.7'
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
stdout: $(inputs.input_reads.nameroot).bam
'sbg:categories':
  - SAM/BAM-Processing
'sbg:license': 'BSD License, MIT License'
'sbg:links':
  - id: 'http://www.htslib.org'
    label: Homepage
  - id: 'https://github.com/samtools/'
    label: Source code
  - id: 'https://sourceforge.net/projects/samtools/files/samtools/'
    label: Download
  - id: 'http://www.ncbi.nlm.nih.gov/pubmed/19505943'
    label: Publication
  - id: 'http://www.htslib.org/doc/samtools.html'
    label: Documentation
  - id: 'http://www.htslib.org/doc/samtools.html'
    label: Wiki
'sbg:toolAuthor': >-
  Heng Li/Sanger Institute,  Bob Handsaker/Broad Institute, James
  Bonfield/Sanger Institute,
'sbg:toolkit': SAMtools
'sbg:toolkitVersion': v1.7
