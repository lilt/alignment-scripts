# alignment-scripts
Scripts to preprocess training and test data for alignment experiments and to run fast_align and giza

# Goals
* Make preprocessing of training corpora automatic, easy to use and reproducible
* Standardize format (talp=pharao format, utf8, ...) for alignments
* Define consistent naming schemes for the files of each language pair
* Combined these goals should save time for running more experiments for the paper and we can possibly open source most of it to let other researchers compare more directly to our alignment approach, which hopefully leads to more improvements

# Dependencies
* Python3
* [MosesDecoder](https://github.com/moses-smt/mosesdecoder): Used during preprocessing
* [Sentencepiece](https://github.com/google/sentencepiece): Used during preprocessing
* [Fastalign](https://github.com/clab/fast_align): Only used for Fastalign
* [Mgiza](https://github.com/moses-smt/mgiza/): Only used for Mgiza

# Usage Instructions
* Install all necessary dependencies
* Export install locations for dependencies: `export {MOSES_DIR,FASTALIGN_DIR,MGIZA_DIR}=/foo/bar`
* Create folder for your test data: `mkdir -p test`
* Download [Test Data for German-English](https://www-i6.informatik.rwth-aachen.de/goldAlignment/) and move it into the folder `test`
* Run preprocessing: `./preprocess/run.sh`
* Run Fastalign: `./scripts/run_fast_align.sh`

# Results
All results are in percent in the format: AER (Precision/Recall)

## German to English ##
| Method | DeEn | EnDe | Grow-Diag | GrowDiagFinal |
| --- | ---- | --- | ---- | --------- |
| Fastalign | 28.4% (71.3%/71.8%) | 32.0% (69.7%/66.4%) | 27.0% (84.6%/64.1%) | 27.7% (80.7%/65.5%) |
| Mgiza | x.xx | x.xx | x.xx | x.xx |


## Romanian to English ##
| Method | RoEn | EnRo | Grow-Diag | GrowDiagFinal |
| --- | ---- | --- | ---- | --------- |
| Fastalign | 33.8% (71.8%/61.3%) | 35.5% (70.6%/59.4%) | 32.1% (85.1%/56.5%) | 32.2% (81.4%/58.1%) |
| Mgiza | 28.7% (82.7%/62.6%) | 32.2% (79.5%/59.1%) | 27.9% (94.0%/58.5%) | 26.4% (90.9%/61.8%) |

## English to French ##
| Method | EnFr | FrEn | Grow-Diag | GrowDiagFinal |
| --- | ---- | --- | ---- | --------- |
| Fastalign | 16.4% (80.0%/90.1%) | 15.9% (81.3%/88.7%) | 10.5% (90.8%/87.8%) | 12.1% (87.7%/88.3%) |
| Mgiza | 8.0% (91.4%/92.9%) | 9.8% (91.6%/88.3%) | 5.9% (97.5%/89.7%) | 6.2% (95.5%/91.6%) |

# Known Issues
Tokenization of the Canadian Hansards seems to be wrong when accents are present in the English text:
E.g.: `Ms. H é l è ne Alarie`, `Mr. Andr é Harvey :`, `Mr. R é al M é nard`
