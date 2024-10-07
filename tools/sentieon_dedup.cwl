cwlVersion: v1.2
class: CommandLineTool
label: Sentieon Dedup
doc: |-
  This tool marks duplicates on the BAM file after alignment and sorting.
  
  ### Inputs:
  - ``Reference``: Location of the reference FASTA file (Required)
  - ``Input alignments``: An array of sorted file (Required)
  
  * Outputs are named based on the **prefix** input parameter. If a value for it is not provided, the base name of the provided **Input alignments** inputs is used to name the outputs.
  * The **Output format** input parameter was added to allow the users to select the format of the created output file.
   
  ### Common Issues and Important Notes
  * The default value of **Optical duplicate pixel distance** input parameter (100) is appropriate for unpatterned Illumina platforms; however, for patterned flowcell models 2500 is more appropriate [1].

requirements:
- class: ShellCommandRequirement
- class: ResourceRequirement
  coresMin: $(inputs.cpu_per_job)
  ramMin: $(inputs.mem_per_job * 1000)
- class: DockerRequirement
  dockerPull: pgc-images.sbgenomics.com/hdchen/sentieon:202112.01_hifi
- class: EnvVarRequirement
  envDef:
  - envName: SENTIEON_LICENSE
    envValue: $(inputs.sentieon_license)
- class: InlineJavascriptRequirement

inputs:
- id: sentieon_license
  label: Sentieon license
  doc: License server host and port
  type: string
- id: reference
  label: Reference
  doc: Reference fasta file with associated indexes
  type: File
  secondaryFiles:
  - pattern: .fai
    required: true
  - pattern: ^.dict
    required: true
  sbg:fileTypes: FA, FASTA
- id: remove_duplicates
  label: Remove duplicates
  doc: |-
    If true do not write duplicates to the output file instead of writing them with appropriate flags set. Default: false.
  type:
  - 'null'
  - name: remove_duplicates
    type: enum
    symbols:
    - 'true'
    - 'false'
  default: 'false'
  sbg:toolDefaultValue: 'false'
- id: output_type
  label: Output format
  doc: |-
    Since Sentieon tools can output both BAM and CRAM files, the users can choose the format of the output file.
  type:
  - 'null'
  - name: output_type
    type: enum
    symbols:
    - BAM
    - CRAM
    - SAME AS INPUT
  sbg:toolDefaultValue: SAME AS INPUT
- id: optical_duplicate_pixel_distance
  label: Optical duplicate pixel distance
  doc: |-
    The maximum offset between two duplicate clusters in order to consider them optical duplicates. The default is appropriate for unpatterned versions of the Illumina platform. For the patterned flowcell models, 2500 is more appropriate. For other platforms and models, users should experiment to find what works best. Default: 100.
  type: int?
  sbg:toolDefaultValue: '100'
- id: in_alignments
  label: Input alignments
  doc: This parameter indicates one or more input BAM files to analyze.
  type: File[]
  sbg:fileTypes: BAM, CRAM
  secondaryFiles: 
    - pattern: .bai
      required: true
    - pattern: .crai
      required: false
- id: prefix
  label: Basename for output files
  doc: Basename for the output files that are to be written.
  type: string?
- id: cpu_per_job
  type: int?
  default: 32
- id: mem_per_job
  type: int?
  default: 32

outputs:
- id: metrics_file
  label: Metrics file
  doc: File to which the duplication metrics will be written.
  type: File?
  outputBinding:
    glob: '*.metrics'
  sbg:fileTypes: METRICS
- id: out_alignments
  label: Deduped alignments file
  doc: The output file to which marked records will be written.
  type: File?
  secondaryFiles:
  - pattern: .bai
    required: true
  - pattern: .crai
    required: false
  outputBinding:
    glob: '*.duplicates_marked.*am'
  sbg:fileTypes: BAM, CRAM

arguments:
- prefix: ''
  position: 0
  valueFrom: |-
    ${
        var files = [].concat(inputs.in_alignments);
        files.sort()
        
        var filenames = []
        for (var i = 0; i < files.length; i++) {
            filenames.push(files[i].path)
        }
        var cmd_driver = "sentieon driver -r ".concat(inputs.reference.path)
        cmd_driver = cmd_driver.concat(" -i ").concat(filenames.join(" -i "))
        
        /* figuring out output file type */
        var ext = inputs.output_type
        if (ext === "BAM") 
        {
            var out_extension = ".duplicates_marked.bam"
        } 
        else if (ext === "CRAM") 
        {
            var out_extension = ".duplicates_marked.cram"
        } 
        else 
        {
            var out_extension = ".duplicates_marked".concat(files[0].nameext.toLowerCase())
        }
        
        if(inputs.prefix)
        {   
            var metrics_name = inputs.prefix.concat('.metrics');
            var output_name = inputs.prefix.concat(out_extension);
        }
        else{
            var filename = files[0].nameroot;
            var metrics_name = filename.concat('.metrics');
            var output_name = filename.concat(out_extension);
        }
        var dedup_args = ""
        if (inputs.remove_duplicates === "true")
        {
            dedup_args = dedup_args.concat(" --rmdup")
        }
        if (inputs.optical_duplicate_pixel_distance)
        {
            dedup_args = dedup_args.concat(" --optical_dup_pix_dist ").concat(inputs.optical_duplicate_pixel_distance)
        }
        var cmd1 = cmd_driver.concat(" --algo LocusCollector --fun score_info tmp_score.gz")
        var cmd2 = cmd_driver.concat(" --algo Dedup").concat(dedup_args).concat(" --score_info tmp_score.gz --output_dup_read_name --metrics ").concat(metrics_name).concat(" tmp_dup_qname.txt.gz")
        var cmd3 = cmd_driver.concat(" --algo Dedup").concat(dedup_args).concat(" --dup_read_name tmp_dup_qname.txt.gz ").concat(output_name)
        return cmd1.concat(" && ").concat(cmd2).concat(" && ").concat(cmd3)
    }
  shellQuote: false

$namespaces:
  sbg: https://sevenbridges.com
