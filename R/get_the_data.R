#' Calculate the characteristics summary of speed, volume, and circuitousness for the given text corpus.
#'
#' @param path_for_corpus The path of your corpus. It should be in CSV format with a "text" column.
#' @param path_for_emb If own_emb=FALSE, it means you are using the provided embedding. In this case, this parameter should be the path to the downloaded RData file (link: <https://drive.google.com/uc?export=download&id=1Nq--lnyG_9cLdjcjVPe4tVl3nqyIm8WT>). If own_emb=TRUE, you are using your own embedding. Please prepare the embedding (CSV file) in a standard format. You can download a sample embedding with the standard format from this link <https://drive.google.com/uc?export=download&id=1koC_c7U2vXJQyl1jAtUa8W7holN1WmLf>.
#' @param own_emb Default=FALSE. Set to TRUE to use your own embedding.
#' @param type_of_window Default="sentence". There are two alternative values: "sentence" or "length." Use "length" if you want to divide the text by a specified word length. "sentence" ensures that the function doesn't break sentences in the middle but finishes them.
#' @param window_length Integer. When type_of_window="length," it divides the text into windows of this specified word length. You can set the length of windows to 1 and type_of_window to "length" to separate the text into individual sentences.
#' @param include_extension_speed Include additional result or not. Default=False. (If True, program execution may be slower)
#' @param include_extension_volume Include additional volume or not. Default=False. (If True, program execution may be slower)
#'
#' @return A dataset containing the calculated speed, volume, and circuitousness of the text.
#'
#' @export
#'
#' @examples
#' library(rStoryShape)
#' path_for_emb <- "data/ft_model_test.Rdata"
#' path_for_corpus <- "data/corpus.Rdata"
#' result <- get_the_data(path_for_corpus, path_for_emb, own_emb=FALSE, type_of_window = "length", window_length = 10)
#' print(result)
#'
#'

get_the_data <- function(path_for_corpus, path_for_emb,own_emb=FALSE,type_of_window = "sentence", window_length = 250, include_extension_speed = FALSE, include_extension_volume = FALSE) {
  if (endsWith(path_for_corpus,".Rdata")){
    corpus<-get(load(path_for_corpus))
  }
  else if(endsWith(path_for_corpus,".csv")){
    corpus<-read.csv(path_for_corpus)
  }
  else{
    print("Your corpus must be csv file or Rdata file.")
    return(0)
  }
  if(own_emb){
    ft_model<-read.csv(path_for_emb)
  }
  else{
  ft_model<-get(load(path_for_emb))
  }
  final_return_df <- data.frame()
  for (i in seq_len(nrow(corpus))) {
   try_result <- tryCatch(
     {
       df_sin <- as.data.frame(corpus[i, ])
       colnames(df_sin)<-names(corpus)
       text <- data.frame('text'=corpus[i, 'text'])
       result <- CalculateTextStructure_updatedTSP(text, ft_model, type_of_window = type_of_window, window_length = window_length,include_extension_speed = include_extension_speed,include_extension_volume = include_extension_volume)
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

   if (inherits(try_result, "try-error")) {
     cat("Skipping row", i, "\n")
   }
  }
  return(final_return_df)
}
