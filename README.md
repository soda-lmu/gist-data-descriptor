# GIST Data Descriptor
This repository accompanies a Data Descriptor paper titled "Addressing Data Gaps in Sustainability Reporting:  A Benchmark Dataset for Greenhouse Gas Emission Extraction", currently under review by Nature Scientific Data. 

The repository describes the annotation data analysis process, detailed in the paper, and can be used for replication purposes. The final datasets can be found on [Zenodo](https://zenodo.org/records/14356664).

## Annotation data analysis process
Annotation of pipeline output was done in 3 phases:
1. Annotation by non-experts
2. Annotation by experts
3. Discussion by experts

The templates for each annotation phase can be found `data/templates`. `data/raw` contains the templates filled by the respective group depending on the annotation phase. `data/processed` contains intermediate outputs from each phase of the annotation data analysis. 

The `src` folder is also structured according to the phases of the annotation process. Each script is in RMarkdown format and numbered accordingly. To replicate the data analysis, start with the scripts `01`-`03` in `non_expert_annotations`, move on to `04`-`06` in `expert_annotations`, then `07`-`08` in `expert_discussion` and finally `09`-`12` in combining_all_annotations to recreate the gold standard dataset and annotation dataset, uploaded to Zenodo. 
`src/data_analysis` contains descriptive statistics presented in the paper and the codebooks, available in the Zenodo repository. 

