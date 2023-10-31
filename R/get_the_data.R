#' The main runner for the code. Get the charateristics summary of speed, volumne and circuitousness
#'
#' @param path_for_corpus The path of your corpus. It should be an csv file with your text column be named as "text"
#' @param path_for_emb If own_emb=FALSE, it means that you would use the embedding we provided.Then this parameter should be the path you put the downloaded Rdata (link: <https://drive.google.com/uc?export=download&id=1Nq--lnyG_9cLdjcjVPe4tVl3nqyIm8WT>). If own_emb=TRUE, it means that you would use the your own embedding. Please prepare the embedding (csv file) with standard format. You could download the sample embedding with standard format with this link<https://drive.google.com/uc?export=download&id=1koC_c7U2vXJQyl1jAtUa8W7holN1WmLf>.
#' @param own_emb Default=FALSE. Use your own embedding or not
#' @param type_of_window Default="sentence". Two alternative values, "sentence" or "length". "length" means that you want to divide the text with exactly the length of words. And 'sentence' means that your dividing never break a sentence in the middle point but finish the sentences instead.
#' @param window_length Int, While type_of_window="length", it will divided the text with the length of exactly this value. Here you could set the length of windows=1 and type_of_window="length" to seperate the text with each sentence
#' @param include_extension_speed Include additional result or not. Default=False.(If True, then speed of program may be slow)
#' @param include_extension_volume Include additional volumn or not. Default=False.(If True, then speed of program may be slow)
#'
#' @return The speed, volume and circuitousness of the text.
#' @export
#'
#' @examples
#' library(rStoryShape)
#' path_for_emb <- "data/ft_model_test.Rdata"
#' path_for_corpus <- "data/corpus.Rdata"
#' load(path_for_corpus)
#' for (i in seq_len(nrow(corpus))) {
#'   try_result <- tryCatch(
#'     {
#'       df_sin <- as.data.frame(corpus[i, ])
#'       text <- data.frame('text'=corpus[i, 2])
#'       result <- get_the_data(text, path_for_emb, type_of_window = "length", window_length = 10)
#'       result_combined <- cbind(
#'         df_sin,
#'         result[[1]][c("speed", "volume", "circuitousness")]
#'       )
#'       final_return_df <- rbind(final_return_df, result_combined)
#'       print(i)
#'     },
#'     error = function(err) {
#'       cat("Error occurred for row", i, ": ", conditionMessage(err), "\n")
#'     }
#'   )
#'   print(final_return_df)
#'
#'   if (inherits(try_result, "try-error")) {
#'     cat("Skipping row", i, "\n")
#'   }
#' }
get_the_data <- function(path_for_corpus, path_for_emb,own_emb=FALSE,type_of_window = "sentence", window_length = 250, include_extension_speed = FALSE, include_extension_volume = FALSE) {
  if (endsWith(path_for_corpus,".Rdata")){
    corpus<-load(path_for_corpus)
    corpus<-get(corpus)
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
  ft_model <- load(path_for_emb)
  ft_model<-get(ft_model)
  }
  final_return_df <- data.frame()
  for (i in seq_len(nrow(corpus))) {
   try_result <- tryCatch(
     {
       df_sin <- as.data.frame(corpus[i, ])
       text <- data.frame('text'=corpus[i, 'text'])
       result <- get_the_data(text, ft_model, type_of_window = type_of_window, window_length = window_length,include_extension_speed = include_extension_speed,include_extension_volume = include_extension_volume)
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
