cwlVersion: v1.0
class: CommandLineTool
id: tar_list
baseCommand: [tar, tf]
stdout: output.txt
inputs:
  tarfile:
    type: File
    inputBinding:
      position: 1
outputs:
  output: 
    type: stdout
    outputBinding:
      glob: output.txt
