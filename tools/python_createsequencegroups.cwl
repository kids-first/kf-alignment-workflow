cwlVersion: v1.0
class: CommandLineTool
id: python_createsequencegroups
doc: |-
  Splits the reference dict file in a list of interval files. 
  Intervals are determined by the longest SQ length in the dict.
requirements:
  - class: DockerRequirement
    dockerPull: '684194535433.dkr.ecr.us-east-1.amazonaws.com/d3b-healthomics:python-2.7.13'
  - class: InlineJavascriptRequirement
baseCommand: [python, -c]
arguments:
  - position: 0
    shellQuote: true
    valueFrom: >-
      def main():
          with open("$(inputs.ref_dict.path)", "r") as ref_dict_file:
              sequence_tuple_list = []
              longest_sequence = 0
              for line in ref_dict_file:
                  if line.startswith("@SQ"):
                      line_split = line.split(chr(9))
                      sequence_tuple_list.append((line_split[1].split("SN:")[1], int(line_split[2].split("LN:")[1])))
              longest_sequence = sorted(sequence_tuple_list, key=lambda x: x[1], reverse=True)[0][1]
          hg38_protection_tag = ":1+"
          tsv_string = sequence_tuple_list[0][0] + hg38_protection_tag
          temp_size = sequence_tuple_list[0][1]
          i = 0
          for sequence_tuple in sequence_tuple_list[1:]:
              if temp_size + sequence_tuple[1] <= longest_sequence:
                  temp_size += sequence_tuple[1]
                  tsv_string += chr(10) + sequence_tuple[0] + hg38_protection_tag
              else:
                  i += 1
                  pad = "{:0>2d}".format(i)
                  tsv_file_name = "sequence_grouping_" + pad + ".intervals"
                  with open(tsv_file_name, "w") as tsv_file:
                      tsv_file.write(tsv_string)
                      tsv_file.close()
                  tsv_string = sequence_tuple[0] + hg38_protection_tag
                  temp_size = sequence_tuple[1]
          i += 1
          pad = "{:0>2d}".format(i)
          tsv_file_name = "sequence_grouping_" + pad + ".intervals"
          with open(tsv_file_name, "w") as tsv_file:
              tsv_file.write(tsv_string)
              tsv_file.close()

          with open("unmapped.intervals", "w") as tsv_file:
              tsv_file.write("unmapped")
              tsv_file.close()

      if __name__ == "__main__":
          main()

inputs:
  ref_dict: { type: File, doc: "Reference fasta dict file" }
outputs:
  sequence_intervals: { type: 'File[]', outputBinding: { glob: 'sequence_grouping_*.intervals' } }
  sequence_intervals_with_unmapped: { type: 'File[]', outputBinding: { glob: '*.intervals' } }
