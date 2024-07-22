# Kids First Data Resource Center DNA Short Reads Alignment and Haplotype Calling Workflows

This repository contains the Common Workflow Language (CWL) pipelines for the
Kids First Data Resource Center's (KFDRC) Alignment and Haplotype Calling Workflows.

<p align="center">
  <img src="docs/kids_first_logo.svg" alt="Kids First repository logo" width="660px" />
</p>
<p align="center">
  <a href="https://github.com/kids-first/kf-alignment-workflow/blob/main/LICENSE"><img src="https://img.shields.io/github/license/kids-first/kf-alignment-workflow.svg?style=for-the-badge"></a>
</p>

## KFDRC BWA-GATK Short Reads Alignment and HaplotypeCaller Workflow

This workflow follows the best practices pipeline outlined by the Broad Institute in [Data pre-processing for variant discovery](https://gatk.broadinstitute.org/hc/en-us/articles/360035535912-Data-pre-processing-for-variant-discovery). See our documentation for more details.
- [Documentation](./docs/KFDRC_BWA_GATK_ALIGNMENT_GVCF_WORKFLOW_README.md)
- [CWL Workflow](./workflows/kfdrc_alignment_wf.cwl)
- [CAVATICA public app](https://cavatica.sbgenomics.com/public/apps#cavatica/apps-publisher/kfdrc-alignment-workflow)

## KFDRC Sentieon Short Reads Alignment and Haplotyper Workflow

This workflow is a functionally equivalent implementation of the above written by the team at Sentieon. See our documentation for more details.
- [Documentation](./docs/KFDRC_SENTIEON_ALIGNMENT_GVCF_WORKFLOW_README.md)
- [CWL Workflow](./workflows/kfdrc_sentieon_alignment_wf.cwl)
- [CAVATICA public app](https://cavatica.sbgenomics.com/public/apps/cavatica/apps-publisher/kfdrc-sentieon-alignment-workflow)

## Other workflows

- KFDRC GATK HaplotypeCaller CRAM to gVCF Workflow
   - [Documentation](./docs/KFDRC_GATK_HAPLOTYPECALLER_CRAM_TO_GVCF_WORKFLOW_README.md)
   - [CWL Workflow](./workflows/kfdrc-gatk-haplotypecaller-wf.cwl)
   - [CAVATICA public app](https://cavatica.sbgenomics.com/public/apps/cavatica/apps-publisher/kfdrc-gatk-haplotypecaller-workflow)
- Kids First Data Resource Center Sentieon gVCF Workflow
   - [Documentation](./docs/KFDRC_SENTIEON_GVCF_WORKFLOW_README.md)
   - [CWL Workflow](./workflows/kfdrc_sentieon_gvcf_wf.cwl)
   - [CAVATICA public app](https://cavatica.sbgenomics.com/public/apps/cavatica/apps-publisher/kfdrc_sentieon_gvcf_wf)
