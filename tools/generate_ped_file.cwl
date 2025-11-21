cwlVersion: v1.2
class: CommandLineTool
id: generate_ped_file
doc: |-
  Generates a ped file by parsing the sex ration output file
requirements:
  - class: DockerRequirement
    dockerPull: 'python:3.12.9'
  - class: ShellCommandRequirement
  - class: ResourceRequirement
    ramMin: ${return inputs.ram * 1000}
    coresMin: $(inputs.threads)
  - class: InlineJavascriptRequirement
  - class: InitialWorkDirRequirement
    listing:
      - writable: false
        entryname: "generate_ped_file.py"
        entry:
          $include: ../scripts/generate_ped_file.py
baseCommand: []
arguments:
  - position: 0
    shellQuote: false
    valueFrom: |
      python generate_ped_file.py
inputs:
  output_basename: { type: 'string', doc: "Prefix string for output file name.", inputBinding: { position: 1, prefix: "-o"} }
  sample_id: { type: 'string', doc: "Input sample id.", inputBinding: { position: 1, prefix: "-s"} }
  ratio_file: { type: 'File', doc: "Input sex ratio file.", inputBinding: { position: 1, prefix: "-r"} }
  threads: { type: 'int?', default: 2 }
  ram: { type: 'int?', default: 3 }
outputs:
  ped_file: { type: 'File', outputBinding: { glob: '*.ped' } }
