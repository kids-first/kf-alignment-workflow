"""Parse sex ratio file and create ped file."""

import argparse


def get_args():
    """Parse the arguments"""
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "-o", "--output-basename", required=True, help="Base name for ped file"
    )
    parser.add_argument("-s", "--sample-id", required=True, help="Input sample id")
    parser.add_argument(
        "-r", "--ratio-file", required=True, help="Path to the ratio file."
    )

    return parser.parse_args()


def main(args):
    """Main, take args, run script."""

    sex_estimate = 0

    with open(args.ratio_file, "r") as file:
        lines = file.readlines()
        last_line = lines[-1].strip()
        if last_line.split(" ")[-1] == "M":
            sex_estimate = 1
        elif last_line.split(" ")[-1] == "F":
            sex_estimate = 2

    ped_line = f"0\t{args.sample_id}\t0\t0\t{sex_estimate}\t2"
    out_file = f"{args.output_basename}.ped"

    with open(out_file, 'w') as out:
        out.write(ped_line)


if __name__ == "__main__":
    # execute only if run as a script
    args = get_args()
    main(args)
