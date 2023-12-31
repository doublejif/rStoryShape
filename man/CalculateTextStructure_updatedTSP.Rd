% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/CalculateTextStructure_updatedTSP.R
\name{CalculateTextStructure_updatedTSP}
\alias{CalculateTextStructure_updatedTSP}
\title{Calculate the speed, volume, and circuitousness for a single row of text.}
\usage{
CalculateTextStructure_updatedTSP(
  corpus,
  input_words,
  type_of_window = "sentence",
  window_length = 250,
  include_extension_speed = FALSE,
  include_extension_volume = FALSE
)
}
\arguments{
\item{corpus}{A data frame containing the text you want to analyze in a single row. The text must be in a column named "text."}

\item{input_words}{The embedding to use. You can download the default embedding from this link: \url{https://drive.google.com/uc?export=download&id=1Nq--lnyG_9cLdjcjVPe4tVl3nqyIm8WT}. If you want to create your own embedding, the first column must be named "word" and contain the actual words, followed by the embedding matrix. You can examine the standard format of the embedding by running View().}

\item{type_of_window}{Default="sentence". Choose between "sentence" or "length." "length" divides the text by the specified word length, while 'sentence' ensures that sentences are not split in the middle but finished instead.}

\item{window_length}{An integer used when type_of_window="length" to divide the text into segments of the specified word length. You can set the length of windows to 1 and type_of_window to "length" to separate the text by each sentence.}

\item{include_extension_speed}{Include additional results or not. Default=False. (If True, program execution may be slower)}

\item{include_extension_volume}{Include additional results or not. Default=False. (If True, program execution may be slower)}
}
\value{
A data frame containing the calculated speed, volume, and circuitousness of the text.
}
\description{
Calculate the speed, volume, and circuitousness for a single row of text.
}
\examples{
library(rStoryShape)
load("data/ft_model_test.Rdata")
load("data/corpus.Rdata")
final_return_df <- data.frame()
for (i in seq_len(nrow(last_sheet_data))) {
  try_result <- tryCatch(
    {
      df_sin <- as.data.frame(corpus[i, ],col.names=names(corpus))
      text <- data.frame('text'=last_sheet_data[i, 'text'])
      result <- CalculateTextStructure_updatedTSP(text, input_words = ft_model, type_of_window = "length", window_length = 10)
      result_combined <- cbind(
        df_sin,
        result[[1]][c("speed", "volume", "circuitousness")]
      )
      final_return_df <- rbind(final_return_df, result_combined)
      print(i)
    },
    error = function(err) {
      cat("Error occurred for row", i, ": ", conditionMessage(err), "\n")
    }
  )
  print(final_return_df[,ncol(corpus):ncol(final_return_df)])

  if (inherits(try_result, "try-error")) {
    cat("Skipping row", i, "\n")
  }
}


}
