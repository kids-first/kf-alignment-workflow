#!/usr/bin/env bash
# script to use bcftools to amend the header in ploidy-adjusted file
set -xeo pipefail

input_vcf=$1
mod_vcf=$2
awk 'NR == FNR && $line ~ /^##GATKCommandLine.HaplotypeCaller/ {sub(/Caller,/, "Caller_rpt_subset,") newcmd=$line}; NR != FNR; NR != FNR && $line ~ /^##GATKCommandLine.HaplotypeCaller/ {print newcmd}' <(bcftools head $mod_vcf) <(bcftools head $input_vcf) > header_build.txt
