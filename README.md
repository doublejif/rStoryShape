
<!-- README.md is generated from README.Rmd. Please edit that file -->

# rStoryShape

<!-- badges: start -->
<!-- badges: end -->

The goal of rStoryShape is to calculate the speed, volumn and
circuitousness from this paper: [Toubia, O., Berger, J., & Eliashberg,
J. (2021). How quantifying the shape of stories predicts their success.
Proceedings of the National Academy of Sciences, 118(26),
e2011695118.](https://www.pnas.org/doi/epdf/10.1073/pnas.2011695118)

## Installation

You can install the development version of rStoryShape from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("doublejif/rStoryShape")
```

Besides this, you may also need to download this fastText embedding file
in the format of Rdata (4.63G) with the following link:

<https://drive.google.com/uc?export=download&id=1Nq--lnyG_9cLdjcjVPe4tVl3nqyIm8WT>

You may also need to keep the download path in mind.

## Example

To use this package, you need to make sure that your corpus files are
csv files. And the text should have the column name: text (case
sensitive).

### Example 1: your own embedding

If you use your own embedding, you could use this package like the
following examples (for more format about the embedding, please visit
the website: <https://fasttext.cc/docs/en/unsupervised-tutorial.html>,
in the ***Printing word vectors*** sections, click the ***Python***
option).

***Note***: The result shows the error message due to the over-small
size of our testing embedding file. Downloading the large size embedding
file and put it in your local computer would solve this error.

``` r
library(rStoryShape)
## Read your own embedding. It should be a dataframe with the first column names "word", and follows the embedding metrix (n words * 301 dimensions). Like this:
# word X1 X2 X3 X4 ... X299 X300
#---------------------------------------------
#  a   a1 a2 a3 a4 ... a299 a300
#  ,   b1 b2 b3 b4 ... b299 b300
# ...  .. .. .. .. ...  ..   ..
# the  n1 n2 n3 n4 ... n299 n300
load("data/ft_model_test.Rdata")
load("data/corpus.Rdata")
final_return_df <- data.frame()
for (i in seq_len(nrow(corpus))) {
    try_result <- tryCatch(
      {
        df_sin<-as.data.frame(corpus[i,])
        text <- data.frame('text'=corpus[i,'text'])
        
        ## Set the type of windows as sentence and make window_length =1, then we could split the text according to each sentence
        result <- CalculateTextStructure_updatedTSP(text,input_words=new_model,type_of_window = 'sentence',window_length = 1)
        result_combined <- cbind(
          df_sin,
          result[[1]][c('speed', 'volume', 'circuitousness')]
        )
        final_return_df <- rbind(final_return_df, result_combined)
        print(i)
      },
      error = function(err) {
        cat("Error occurred for row", i, ": ", conditionMessage(err), "\n")
      }
    )
    
    if (inherits(try_result, "try-error")) {
      cat("Skipping row", i, "\n")
    }
  }
#> [1] "Windows calculated ..."
#> Error occurred for row 1 :  subscript out of bounds 
#> [1] "Windows calculated ..."
#> Error occurred for row 2 :  subscript out of bounds 
#> [1] "Windows calculated ..."
#> Error occurred for row 3 :  subscript out of bounds 
#> [1] "Windows calculated ..."
#> Error occurred for row 4 :  subscript out of bounds 
#> [1] "Windows calculated ..."
#> Error occurred for row 5 :  subscript out of bounds
  
  # Print or further process the final_return_df
  print(final_return_df)
#> data frame with 0 columns and 0 rows
```

What is special about using `README.Rmd` instead of just `README.md`?
You can include R chunks like so:

``` r
summary(cars)
#>      speed           dist       
#>  Min.   : 4.0   Min.   :  2.00  
#>  1st Qu.:12.0   1st Qu.: 26.00  
#>  Median :15.0   Median : 36.00  
#>  Mean   :15.4   Mean   : 42.98  
#>  3rd Qu.:19.0   3rd Qu.: 56.00  
#>  Max.   :25.0   Max.   :120.00
```

You’ll still need to render `README.Rmd` regularly, to keep `README.md`
up-to-date. `devtools::build_readme()` is handy for this.

You can also embed plots, for example:

<img src="man/figures/README-pressure-1.png" width="100%" />

In that case, don’t forget to commit and push the resulting figure
files, so they display on GitHub and CRAN.
