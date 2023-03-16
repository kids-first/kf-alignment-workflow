class: CommandLineTool
cwlVersion: v1.2
id: optitype
doc: |
  **OptiType** is a tool designed for precision HLA typing from next-generation sequencing data.
  
  **OptiType** is based on the assumption that the correct HLA genotype
  explains the highest number of mapped reads. Therefore, it searches for the
  best HLA allele combination of up to six major and six minor HLA-I alleles. The
  maximum number of reads potentially originating from one selection under the
  biological constraints that at least one and at most two alleles are selected
  per locus can be conveniently formulated as an ILP. [1]

  All HLA-I alleles are obtained from the IMGT/HLA database ([Release 3.14.0,
  July 2013](https://pubmed.ncbi.nlm.nih.gov/23080122/)) for read mapping
  reference sequence construction. Read mapping is performed by **RazerS3**.
  RNA-Seq data is mapped against the nucleotide CDS reference library and WGS
  data is mapped against the genomic nucleotide reference library. A binary hit
  matrix is constructed from the mapping result for all reads mapped to at least
  one allele of the reference. For paired-end read data, the full hit matrices
  are constructed for both read pairs individually. Based on this hit matrix, an
  ILP will be formulated that optimises the number of explainable reads by
  selecting up to two alleles (columns of the hit matrix) for each HLA-I locus.
  The selected alleles represent the most probable HLA genotypes. [1]
  
  **OptiType** has one required input and one required parameter:
  
  * **Input file(s)** (`--input`) - a FASTQ, FQ, FASTQ.GZ, FQ.GZ, SAM or BAM format file(s) with input data for HLA typing.
  
  * **Type of data** (`--dna`/`--rna`) - parameter for defining the sequence data type.
  
  **OptiType** standard outputs are:
  
  * **HLA 4-digits results** - a TSV format file with the predicted optimal (and if enumerated, sub-optimal) HLA genotype in 4-digit resolution.
  * **HLA 8-digits results** - a TSV format file containing HLA types up to the 8-digit resolution.
  * **HLA Types** - a list of strings containing HLA types.
  * **Log file** - a TXT format tool logs file.
  * **Coverage plot** - a PDF format output containing a coverage plot of the predicted alleles for diagnostic purposes.
  * **Config output** - an INI format configuration content output file.
  
  *A list of **all inputs and parameters** with corresponding descriptions can be found at the bottom of the page.*
  
  ### Common Use Cases ###
  
  **OptiType** is a HLA genotyping algorithm based on integer linear
  programming, capable of producing accurate 4-digit HLA genotyping predictions
  from NGS data by simultaneously selecting all major and minor HLA Class I
  alleles. [2]
  
  It takes reads or alignment input files, and produces TSV format files with
  HLA typing results, as well as PDF format coverage plot, configuration content
  output, alignment BAM files (optional) and TXT format log file.
  
  **OptiType** has one required input and one required parameter:
  
  * **Input file(s)** (`--input`) - a FASTQ, FQ, FASTQ.GZ, FQ.GZ, SAM or BAM format file(s) with input data for HLA typing.
  
  * **Type of data** (`--dna`/`--rna`) - parameter for defining the sequence data type.
  
  ### Changes Introduced by Seven Bridges ###
  
  * Original **OptiType** python script evaluates full resolution HLA types and returns the trimmed allele identifications to 4 digit resolution. Adjustment has been made to the script, so it outputs the HLA alleles both before and after the trimming as separate outputs. Therefore, our tool results in both 4-digit and 8-digit HLA types.
  
  * Additional parameters can be set in order to optimise the mapping step and outputs production:
  
      * **Delete intermediate BAM file** - delete BAM files produced by **RazerS3** after **OptiType** has finished loading them. Default value is **True**. If planning to re-analyse the samples with different settings, disabling this option can be a time-saver, passing the BAM files to **OptiType** directly as input and sparing the expensive read mapping step.
  
      * **Output 8-digit HLA types as strings** - if set to **True**, the **HLA Types** output will port full resolution HLA types as strings. Default value is **False**.
  
      * **Unpaired weight** - in paired-end mode one might want to use reads with just one mapped end (e.g., the other end falls outside the reference region). This setting allows the user to keep the reads with an optionally reduced weight. Default value of **0** means they are discarded for typing, **0.2** means single reads are "worth" 20% of paired reads, and a value of **1** means they are treated as valuable as properly mapped read pairs. Note that unpaired reads will be reported on the result coverage plots for completeness, regardless of this setting.
  
      * **Use discordant read pairs** - a read pair is called discordant if its two ends best-map to two disjoint sets of alleles. Such reads can be either omitted, or either of their ends can be treated as unpaired hits. Default value for this parameter is **False**. Note that discordant read pairs are reported on the coverage plots as unpaired reads, regardless of this setting.
  
      * **Unique HLA types** - outputs only unique HLA types as strings if set to **True**. Default value is **False**.
  
  * As part of the *config.ini* file, the parameters for number of threads used by **RazerS3** and **cbc solver** are set to **8** by default. The original value is **1**. This value can be additionally changed during task execution, using the **CPU per job** parameter.
  
  * **Prefix** parameter is used for naming the outputs when moving them to the current directory. Original argument **prefix** (`--prefix`, `-p`) is not used in the command line.
  
  * **Config** (`--config`) parameter cannot be changed, as the configuration is set to use the path of the *config.ini* file within the wrapper.
  
  * A parameter that specifies the output directory to which all files should be written, (`--outdir`, `-o`), cannot be changed. It is set to the path of the *temp* directory from which the output files will be moved to the current directory and ported to the output port.
  
  
  ### Common Issues and Important Notes ###
  
  
  * **OptiType** might fail to execute with some BAM files. So far it is known that it always accepts BAM files created by the **Yara** aligner.
  
  * **OptiType** depends on **RazerS3** for read mapping. **RazerS3** is designed in such a way that it loads all reads into the memory. This can be the reason for failure of the tool when working with larger files. Depending on the input file size, the tool will require a necessary amount of memory in order to perform well. Please be aware of this when using larger FASTQ files or gunzipped files.
  
  * Some exome kits will not capture reads from the HLA region and might result in missing/empty BAM files. If the exome kit/experiment is inadequate, this will cause the tool to break.
  
  * Note that **OptiType** reports only **Class I** HLA allele types.
  
  * A task example performed using gunzip format inputs has shown that using files in this format can cause the task to fail even though a large instance type was used. The same inputs were decompressed using **SBG Decompressor CWL1.0** and completed successfully.
  
  
  ### Performance Benchmarking ###
  
  **OptiType** is set to use c4.2xlarge instance with 15GB of RAM Memory and 8 CPUs by default. It is fast and memory-efficient when using BAM input files. However, if using FASTQ/FQ/FASTQ.GZ/FQ.GZ inputs, it depends on **RazerS3** for read mapping. **RazerS3** is designed to load all reads into the memory and, depending on the input file size, the tool will require a necessary amount of memory in order to perform well. Please be aware of this when using larger FASTQ files or gunzipped files. It is recommended to set an instance type with the same amount of RAM memory as the size of the FASTQ/FQ input(s) and for FASTQ.GZ/FQ.GZ to set an instance type with at least five times more memory than the size of the input file(s). Be cautious when running a large number of files and test the scaling by closely monitoring the usage of resources before running the analysis as a whole.
  
  The table below shows the results of **OptiType** benchmarking:
  
  | Analysis type | File format | Input size | Running time | Cost | AWS Instance type |
  | ---------------- | ---------- | ---------- | ------------- | -------- | ----- | --------- | ----------------------: |
  | WES |FASTQ | 2 x 7 GB | 9min | $0.08 | c4.2xlarge (on-demand) |
  | RNA-seq | FASTQ| 2 x 17.5 GB | 20min | $0.27 | c5.4xlarge (on-demand)  |
  | WGS | FASTQ | 2 x 200 GB | 1h 40min | $6.95 | r5.16xlarge (on-demand)  |
  | WGS | FASTQ.GZ | 2 x 50 GB | 1h 42min | $7.13 | r5.16xlarge (on-demand)  |
  
  *Cost can be significantly reduced by using **spot instances**. Visit the [Knowledge Center](https://docs.sevenbridges.com/docs/about-spot-instances) for more details.*
  
  ### References
  
  [1] [OptiType paper](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC4441069/)
  [2] [OptiType GitHub](https://github.com/FRED-2/OptiType)

requirements:
- class: ShellCommandRequirement
- class: InlineJavascriptRequirement
  expressionLib:
  - |2-
    var setMetadata = function(file, metadata) {
      if (!('metadata' in file)) {
        file['metadata'] = {}
      }
      for (var key in metadata) {
        file['metadata'][key] = metadata[key];
      }
      return file
    };
    var inheritMetadata = function(o1, o2) {
      var commonMetadata = {};
      if (!o2) {
        return o1;
      };
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
        for (var key in commonMetadata) {
          if (!(key in example)) {
            delete commonMetadata[key]
          }
        }
      }
      if (!Array.isArray(o1)) {
        o1 = setMetadata(o1, commonMetadata)
        if (o1.secondaryFiles) {
          o1.secondaryFiles = inheritMetadata(o1.secondaryFiles, o2)
        }
      } else {
        for (var i = 0; i < o1.length; i++) {
          o1[i] = setMetadata(o1[i], commonMetadata)
          if (o1[i].secondaryFiles) {
            o1[i].secondaryFiles = inheritMetadata(o1[i].secondaryFiles, o2)
          }
        }
      }
      return o1;
    };
- class: DockerRequirement
  dockerPull: images.sbgenomics.com/bojana_smiljanic/optitype-1-3-5:1
- class: ResourceRequirement
  ramMin: $(inputs.ram * 1000) 
  coresMin: $(inputs.cpu) 
- class: EnvVarRequirement
  envDef:
    - envName: FILEBASE
      envValue: |
        ${
          if (inputs.prefix) {
            var filebase=inputs.prefix
          } else {
            var input_files = [].concat(inputs.in_data)
            if (input_files[0].metadata && input_files[0].metadata.sample_id) {
                filebase = input_files[0].metadata.sample_id
            } else {
                filebase = "sample_unknown"
            }
          }
          return filebase;
        }
- class: InitialWorkDirRequirement
  listing:
  - entryname: config.ini
    writable: false
    entry: | 
      [mapping] 
      
      #Absolute path to RazerS3 binary, and number of threads to use for mapping 
      
      razers3=/opt/razers3-3.4.0-Linux-x86_64/bin/razers3
      threads=$(inputs.cpu)
      
      [ilp] 
      
      # A Pyomo-supported ILP solver. The solver must be globally accessible in the
      # environment OptiType is run, so make sure to include it in PATH.
      # Note: this is NOT a path to the solver binary, but a keyword argument for
      # Pyomo. Examples: glpk, cplex, cbc.
      
      solver=cbc 
      threads=$(inputs.cpu)
      
      [behavior] 
      
      # tempdir=/path/to/tempdir  # we may enable this setting later. Not used now.
      
      # Delete intermediate bam files produced by RazerS3 after OptiType finished
      # loading them. If you plan to re-analyze your samples with different settings
      # disabling this option can be a time-saver, as you'll be able to pass the bam
      # files to OptiType directly as input and spare the expensive read mapping
      # step.
      
      deletebam=$(inputs.delete_bam == 'False' ? false : true)
      
      # In paired-end mode one might want to use reads with just one mapped end (e.g.,
      # the other end falls outside the reference region). This setting allows the
      # user to keep them with an optionally reduced weight. A value of 0 means they
      # are discarded for typing, 0.2 means single reads are 'worth' 20% of paired
      # reads, and a value of 1 means they are treated as valuable as properly mapped
      # read pairs. Note: unpaired reads will be reported on the result coverage plots
      # for completeness, regardless of this setting.
      
      unpaired_weight=$(inputs.unpaired_weight ? inputs.unpaired_weight : 0)
      
      # We call a read pair discordant if its two ends best-map to two disjoint sets
      # of alleles. Such reads can be either omitted or either of their ends treated
      # as unpaired hits. Note: discordant read pairs are reported on the coverage
      # plots as unpaired reads, regardless of this setting.
      
      use_discordant=$(inputs.use_discordant ? inputs.use_discordant : false)
      
baseCommand: [python, /opt/OptiType-1.3.5/OptiTypePipeline2.py]
arguments:
  - prefix: "--outdir"
    shellQuote: false
    position: 45
    valueFrom: "./temp/" 
  - prefix: "--config"
    shellQuote: false
    position: 55
    valueFrom: "./config.ini" 
  - prefix: ">"
    shellQuote: false
    position: 60
    valueFrom: "$FILEBASE.command_log.txt"
  - prefix: ''
    shellQuote: false
    position: 65
    valueFrom: >
      && mv ./temp/*/*_result_type.tsv $FILEBASE.result_type.tsv
      && mv ./temp/*/*_coverage_plot.pdf $FILEBASE.coverage_plot.pdf
      && mv ./temp/*/*_result.tsv $FILEBASE.result.tsv
      && mv ./temp/*/*_result_id.tsv $FILEBASE.result_id.tsv
      && mv ./config.ini $FILEBASE_config.ini
      && mv ./temp/*/*_1.bam $FILEBASE_1.bam || :
      && mv ./temp/*/*_2.bam $FILEBASE_2.bam || :
inputs:
  in_data: { type: 'File[]', inputBinding: { prefix: "--input", shellQuote: false, position: 20 }, doc: "FASTQ format file(s) (fished or raw) or BAM files stored for re-use, generated by an earlier OptiType run. One file: single-end mode, two files: paired-end mode.", "sbg:fileTypes": "FQ, FASTQ, BAM, SAM, FQ.GZ, FASTQ.GZ" }
  data_type:
    type:
      type: enum
      symbols:
      - rna
      - dna
      name: data_type
    inputBinding:
      shellQuote: false
      position: 30
      valueFrom: $("--" + self)
    doc: Use with DNA/RNA sequencing data.
  beta: { type: 'float?', inputBinding: { prefix: "--beta", shellQuote: false, position: 35 }, doc: "The beta value for homozygosity detection. Handle with care." }
  enumerate: { type: 'int?', inputBinding: { prefix: "--enumerate", shellQuote: false, position: 40 }, doc: "Number of enumerations. OptiType will output the optimal solution and the top N-1 suboptimal solutions in the results CSV." }
  prefix: { type: 'string?', doc: "Specifies prefix of output files." }
  verbose_mode: { type: 'boolean?', inputBinding: { prefix: "--verbose", shellQuote: false, position: 50 }, doc: "Set verbose mode on." }
  delete_bam:
    type:
    - 'null'
    - type: enum
      symbols:
      - 'True'
      - 'False'
      name: delete_bam
    doc: |
      Delete intermediate BAM files produced by RazerS3 after OptiType finished loading
      them. If planning to re-analyze the samples with different settings, disabling
      this option can be a time-saver, passing the bam files to OptiType directly as
      input and sparing the expensive read mapping step.
  output_8digit_hla_strings: { type: 'boolean?', doc: "Output full resolution HLA types as strings at the HLA Types output port." }
  unpaired_weight:
    type: float?
    doc: |
      In paired-end mode one might want to use reads with just one mapped end (e.g.,
      the other end falls outside the reference region). This setting allows the user
      to keep them with an optionally reduced weight. A value of 0 means they are discarded
      for typing, 0.2 means single reads are "worth" 20% of paired reads, and a value
      of 1 means they are treated as valuable as properly mapped read pairs. Note: unpaired
      reads will be reported on the result coverage plots for completeness, regardless
      of this setting.
  use_discordant:
    type: boolean?
    doc: |
      A read pair is called discordant if its two ends best-map to two disjoint
      sets of alleles. Such reads can be either omitted or either of their ends treated
      as unpaired hits. Note: discordant read pairs are reported on the coverage plots
      as unpaired reads, regardless of this setting.
  unique_hla_types: { type: 'boolean?', doc: "Outputs only unique HLA types as strings." }
  ram: { type: 'int?', default: 12, doc: "GB of RAM to allocate to this task" }
  cpu: { type: 'int?', default: 8, doc: "CPUs to allocate to this task" }
outputs:
  out_4digit_hla:
    doc: Output file with the predicted optimal (and if enumerated, sub-optimal) HLA
      genotype in 4-digit resolution.
    type: File?
    outputBinding:
      glob: "*result.tsv"
      outputEval: "$(inheritMetadata(self, inputs.in_data))"
  out_alignments:
    doc: BAM files produces in the preprocessing step by aligning and filtering reads
      on the HLA FASTA if the Delete intermediate BAM file parameter is set to False.
    type: File[]?
    outputBinding:
      glob: "*.bam"
      outputEval: "$(inheritMetadata(self, inputs.in_data))"
  out_log:
    doc: File containing tool logs which were outputted to the standard output.
    type: File?
    outputBinding:
      glob: "*.txt"
      outputEval: "$(inheritMetadata(self, inputs.in_data))"
  out_coverage_plot:
    doc: A PDF file containing a coverage plot of the predicted alleles for diagnostic
      purposes.
    type: File?
    outputBinding:
      glob: "*.pdf"
      outputEval: "$(inheritMetadata(self, inputs.in_data))"
  out_8digit_hla:
    doc: Output file containing HLA types up to the 8-digit resolution.
    type: File?
    outputBinding:
      glob: "*result_type.tsv"
      outputEval: "$(inheritMetadata(self, inputs.in_data))"
  out_config:
    doc: Config file content.
    type: File?
    outputBinding:
      glob: "*config.ini" 
      outputEval: "$(inheritMetadata(self, inputs.in_data))"
  out_hla_types:
    doc: List of strings containing HLA types.
    type: string?
    outputBinding:
      loadContents: true
      glob: |
        $(inputs.output_8digit_hla_strings ? '*result_type.tsv' : '*result.tsv')
      outputEval: |
        ${
          var rows = self[0].contents.split(/\r?\n/).slice(0,-1);
          var columns = rows[1].split("\t");
          var types = columns.slice(1, -2);
          var out_str = [];
          for (var i=0; i < types.length; i++){
            if (types[i].length > 0) {
               out_str.push('HLA-'.concat(types[i]));
            }
          }
        
          if (inputs.unique_hla_types == true){
            var unique_hla_types = out_str.filter(function(elem, index, self) { return index == self.indexOf(elem); })
            return unique_hla_types;
          } else {
            return out_str;
          }
        }
"$namespaces":
  sbg: https://sevenbridges.com
