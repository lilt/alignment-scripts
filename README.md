# alignment-scripts
Scripts to preprocess training and test data and to run fast_align and giza

# Goals
* Make preprocessing of training corpora automatic, easy to use and reproducible
* Standardize format (talp=pharao format, utf8, ...) for alignments
* Define consistent naming schemes for the files of each language pair
* Combined these goals should save time for running more experiments for the paper and we can possibly open source most of it to let other researchers compare more directly to our alignment approach, which hopefully leads to more improvements

# Optional Dependencies
- [MosesDecoder](https://github.com/moses-smt/mosesdecoder)
- [Fastalign](https://github.com/clab/fast_align)
- [Mgiza](https://github.com/moses-smt/mgiza/)
- [Sentencepiece](https://github.com/google/sentencepiece)

# Results
All results are in percent in the format: AER (Precision/Recall)

## German to English ##
| Method | DeEn | EnDe | Grow-Diag | GrowDiagFinal |
| --- | ---- | --- | ---- | --------- |
| Fastalign | x.xx | x.xx | x.xx | x.xx |
| Mgiza | x.xx | x.xx | x.xx | x.xx |


## Romanian to English ##
| Method | RoEn | EnRo | Grow-Diag | GrowDiagFinal |
| --- | ---- | --- | ---- | --------- |
| Fastalign | 33.8 (71.8/61.3) | 35.5 (70.6/59.4) | 32.1 (85.1/56.5) | 32.2 (81.4/58.1) |
| Mgiza | x.xx | x.xx | x.xx | x.xx |

## English to French ##
| Method | EnFr | FrEn | Grow-Diag | GrowDiagFinal |
| --- | ---- | --- | ---- | --------- |
| Fastalign | 16.4 (80.0/90.1) | 15.9 (81.3/88.7) | 10.5 (90.8/87.8) | 12.1 (87.7/88.3) |
| Mgiza | x.xx | x.xx | x.xx | x.xx |
