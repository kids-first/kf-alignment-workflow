import sys

def main():
    with open(sys.argv[1], "r") as ref_dict_file:
        sequence_tuple_list = []
        longest_sequence = 0
        for line in ref_dict_file:
            if line.startswith("@SQ"):
                line_split = line.split("\t")
                sequence_tuple_list.append((line_split[1].split("SN:")[1], int(line_split[2].split("LN:")[1])))
        longest_sequence = sorted(sequence_tuple_list, key=lambda x: x[1], reverse=True)[0][1]
    hg38_protection_tag = ":1+"
    tsv_string = sequence_tuple_list[0][0] + hg38_protection_tag
    temp_size = sequence_tuple_list[0][1]
    i = 0
    for sequence_tuple in sequence_tuple_list[1:]:
        if temp_size + sequence_tuple[1] <= longest_sequence:
            temp_size += sequence_tuple[1]
            tsv_string += "\n" + sequence_tuple[0] + hg38_protection_tag
        else:
            i += 1
            tsv_file_name = "sequence_grouping_" + str(i) + ".intervals"
            with open(tsv_file_name, "w") as tsv_file:
                tsv_file.write(tsv_string)
                tsv_file.close()
            tsv_string = sequence_tuple[0] + hg38_protection_tag
            temp_size = sequence_tuple[1]
    i += 1
    tsv_file_name = "sequence_grouping_" + str(i) + ".intervals"
    with open(tsv_file_name, "w") as tsv_file:
        tsv_file.write(tsv_string)
        tsv_file.close()

if __name__ == "__main__":
    main()
