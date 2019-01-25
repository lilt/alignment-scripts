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
