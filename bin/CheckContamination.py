import csv
import sys
with open(sys.argv[1]) as selfSM:
  reader = csv.DictReader(selfSM, delimiter='\t')
  i = 0
  for row in reader:
    if float(row["FREELK0"])==0 and float(row["FREELK1"])==0:
      sys.stderr.write("Found zero likelihoods. Bam is either very-very shallow, or aligned to the wrong reference (relative to the vcf).")
      sys.exit(1)
    print(float(row["FREEMIX"])/0.75)
    i = i + 1
    if i != 1:
      sys.stderr.write("Found %d rows in .selfSM file. Was expecting exactly 1. This is an error"%(i))
      sys.exit(2)
