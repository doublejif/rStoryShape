#' Speed, volume and circuitousness calculation for one single row of text
#'
#' @param corpus This includes the file you want to analysis, one row only. The text must be contained in column "text" (or it woundn't work)
#' @param input_words This is the embedding you want to use. Default embedding could be downloaded with this link <https://drive.google.com/uc?export=download&id=1Nq--lnyG_9cLdjcjVPe4tVl3nqyIm8WT>. If you want to create your own embedding, the first column must be "word" and contain the actual words, and follows the embedding matrix. You could take a look at the standard format of embedding by running View()
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
#' load("data/ft_model_test.Rdata")
#' load("data/corpus.Rdata")
#' final_return_df <- data.frame()
#' for (i in seq_len(nrow(last_sheet_data))) {
#'   try_result <- tryCatch(
#'     {
#'       df_sin <- as.data.frame(last_sheet_data[i, ])
#'       text <- as.data.frame(last_sheet_data[i, 2])
#'       result <- CalculateTextStructure_updatedTSP(text, input_words = ft_model, type_of_window = "length", window_length = 10)
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
CalculateTextStructure_updatedTSP <- function(corpus, input_words, type_of_window = "sentence", window_length = 250, include_extension_speed = FALSE, include_extension_volume = FALSE) {
  ## --------------------Annotation created by Jia Li Begin--------------------##
  # Function is based on the code written by Matthijs Meire. Jia Li write an extra function for the Traveler Salesman Problem part (global_TSP function) under the guidance of Olivier Toubia.
  # The original code created by Matthijs Meire just use TSP() function in R solved the general TSP problem. So Jia created a function to sove the TSP problem under the condition that the first and last city is fixed.
  ## --------------------Annotation created by Matthijs Meire End---------------------##

  ## --------------------Original annotation created by Matthijs Meire Begin--------------------##
  # Function written by Matthijs Meire, based on original Matlab code by Olivier Toubia
  # corpus: specifies the documents/texts to analyze. This should be a dataframe where the column with text to analyze is named "text"
  # input_words: specifies the word vectors to use; this can be an entire set of vectors (eg GloVe or Word2Vec), but it may be faster if this is already preprocessed to only contain the relevant words; First column should be labeled "word", and contain the actual words; next columns should specify the embeddings
  # type_of_window: which window structure should be taken? Currently implemented are 'sentence' and 'length'. (Sentence uses the sentences as windows, length uses a specified numnber of words in window_length)
  # window_length: specifies the length of the window to use if type_of_window is 'length'
  # include_extension_speed, include_extension_volume: whether to include the extensions for speed and volume ('variation', 'trend' and 'end'). TRUE or FALSE (this may slow down the function considerably, especially for the measures related to volume)
  ## --------------------Original annotation created by Matthijs Meire End_--------------------##

  # define default delimiters
  # others can also be implemented
  delimiter_sentences <- c("1\\. |2\\. |3\\. |4\\. |5\\. |6\\. |7\\. |8\\. |9\\. |0\\. |\\? |! |\\. ")
  delimiter <- c(' - | |,|;|:|""|\\.|\\\\f|\\\\n|\\\\r|\\\\t|\\\\v')

  #---------------------------------------------------------------------------------------------------
  # perform checks
  if (type_of_window != "length" & type_of_window != "sentence") {
    print("This type of window selection is not recognized. Please choose between 'length' and 'sentence'")
  }

  #
  #######
  #### 1. Get the word embeddings per window
  #######
  # 1

  D <- nrow(corpus)
  ndim_emb <- dim(input_words)[2] - 1
  shapes <- corpus
  shapes[, "nsentences"] <- 0
  shapes[, "nwords"] <- 0
  shapes[, "nwords_found"] <- 0
  shapes[, "nwindows"] <- 0
  shapes[, "speed"] <- 0
  shapes[, "volume"] <- 0
  shapes[, "circuitousness"] <- 0

  shapes2 <- list()


  for (d in 1:D) {
    if (type_of_window == "length") {
      resolution <- window_length

      sentences <- strsplit(shapes[d, "text"], delimiter_sentences)
      shapes[d, "nsentences"] <- length(sentences[[1]])
      sentences <- unlist(sentences)
      #### New words length
      all_words <- c()
      for (i in sentences) {
        sin_words <- unlist(strsplit(i, delimiter))
        all_words <- c(all_words, sin_words)
      }
      # Your input list
      word_list <- all_words

      # Define a function to combine every 5 consecutive words into a single element
      combine_words <- function(words, n) {
        result <- character(0)
        for (i in seq(1, length(words), by = n)) {
          result <- c(result, paste(words[i:min(i + n - 1, length(words))], collapse = " "))
        }
        return(result)
      }

      # Specify the number of words to combine
      n <- window_length

      # Combine the words
      combined_list <- combine_words(word_list, n)

      sentences <- combined_list
      shapes[d, "nsentences"] <- length(sentences)


      # placeholder:
      nwindows <- length(sentences)

      shapes2[[d]] <- list()

      # word2vec position in each window (nwindows x 300)
      shapes2[[d]]$position_window <- matrix(0, nrow = nwindows, ncol = ndim_emb)
      shapes2[[d]]$nwords_window <- as.vector(rep(0, nwindows))
      shapes2[[d]]$nsentences_window <- as.vector(rep(0, nwindows))
      shapes2[[d]]$nwords_found_window <- as.vector(rep(0, nwindows))
      shapes2[[d]]$speed <- as.vector(rep(0, nwindows))

      # handle empty sentences:
      indsout_window <- vector()

      last_window <- 0

      # first window:
      ind_sentence <- 1
      nsentences_window <- 1
      words <- unlist(strsplit(sentences[ind_sentence], delimiter))
      window_size2 <- length(words)

      while (window_size2 < resolution & ind_sentence < nwindows) {
        ind_sentence <- ind_sentence + 1
        nsentences_window <- nsentences_window + 1
        new_words <- unlist(strsplit(sentences[ind_sentence], delimiter))
        window_size2 <- window_size2 + length(new_words)
        words <- c(words, new_words)
      }

      win <- 0
      if (ind_sentence == nwindows) {
        last_window <- 1
      }
      while (ind_sentence < nwindows) {
        win <- win + 1

        nwords_found <- 0
        nwords_notfound <- 0
        ind_sentence <- ind_sentence + 1
        next_nsentences_window <- 1
        next_words <- unlist(strsplit(sentences[ind_sentence], delimiter))
        next_window_size2 <- length(next_words)

        while (next_window_size2 < resolution & ind_sentence < nwindows) {
          ind_sentence <- ind_sentence + 1
          next_nsentences_window <- next_nsentences_window + 1
          new_words <- unlist(strsplit(sentences[ind_sentence], delimiter))
          next_window_size2 <- next_window_size2 + length(new_words)
          next_words <- c(next_words, new_words)
        }

        # merge last two windows if last window is too short
        if (ind_sentence == nwindows & next_window_size2 < resolution) {
          words <- c(words, next_words)
          window_size2 <- window_size2 + next_window_size2
          nsentences_window <- nsentences_window + next_nsentences_window
        } else {
          if (ind_sentence == nwindows) last_window <- 1
        }

        shapes[d, "nwords"] <- shapes[d, "nwords"] + window_size2
        shapes2[[d]]$nwords_window[win] <- window_size2
        shapes2[[d]]$nsentences_window[win] <- nsentences_window

        if (window_size2 > 0) {
          newposition <- matrix(0, nrow = window_size2, ncol = ndim_emb)
          indsout <- vector()

          words <- tolower(words)
          words <- gsub("\\.|\\?|!|,|;|:| ", "", words)
          words <- words[words != ""]
          words <- as.data.frame(words)

          words_found <- merge(words, input_words, by.x = "words", by.y = "word")
          nwords_found <- nrow(words_found)
          newposition_window <- apply(words_found[, 2:(ndim_emb + 1)], 2, mean)

          shapes2[[d]]$position_window[win, ] <- newposition_window

          shapes2[[d]]$nwords_found_window[win] <- nwords_found

          if (nwords_found == 0) {
            indsout_window <- c(indsout_window, win)
          }
        } else {
          indsout_window <- c(indsout_window, win)
        }

        words <- next_words
        window_size2 <- next_window_size2
        nsentences_window <- next_nsentences_window
      }

      # last window:
      if (last_window == 1) {
        last_window <- 0
        win <- win + 1
        nwords_found <- 0

        shapes[d, "nwords"] <- shapes[d, "nwords"] + window_size2
        shapes2[[d]]$nwords_window[win] <- window_size2
        shapes2[[d]]$nsentences_window[win] <- nsentences_window

        if (window_size2 > 0) {
          newposition <- matrix(0, nrow = window_size2, ncol = ndim_emb)
          indsout <- vector()
          words <- tolower(words)
          words <- gsub("\\.|\\?|!|,|;|:| ", "", words)
          words <- words[words != ""]
          words <- as.data.frame(words)
          words_found <- merge(words, input_words, by.x = "words", by.y = "word")
          nwords_found <- nrow(words_found)
          newposition_window <- apply(words_found[, 2:(ndim_emb + 1)], 2, mean)

          shapes2[[d]]$position_window[win, ] <- newposition_window
          shapes2[[d]]$nwords_found_window[win] <- nwords_found



          if (nwords_found == 0) {
            indsout_window <- c(indsout_window, win)
          }
        } else {
          indsout_window <- c(indsout_window, win)
        }
      }

      indsout_window <- c(indsout_window, ((win + 1):nwindows))

      shapes2[[d]]$position_window <- shapes2[[d]]$position_window[-indsout_window, ]
      shapes2[[d]]$nwords_found_window <- shapes2[[d]]$nwords_found_window[-indsout_window]
      shapes2[[d]]$nwords_window <- shapes2[[d]]$nwords_window[-indsout_window]
      shapes2[[d]]$nsentences_window <- shapes2[[d]]$nsentences_window[-indsout_window]

      shapes[d, "nwords_found"] <- sum(shapes2[[d]]$nwords_found_window)
      nwindows <- length(shapes2[[d]]$nwords_found_window)
      shapes[d, "nwindows"] <- nwindows
    }

    if (type_of_window == "sentence") {
      resolution <- window_length

      sentences <- strsplit(shapes[d, "text"], delimiter_sentences)
      shapes[d, "nsentences"] <- length(sentences[[1]])
      sentences <- unlist(sentences)
      #### New words length
      all_words <- c()
      for (i in sentences) {
        sin_words <- unlist(strsplit(i, delimiter))
        all_words <- c(all_words, sin_words)
      }
      # Your input list
      word_list <- all_words

      # Define a function to combine every 5 consecutive words into a single element
      combine_words <- function(words, n) {
        result <- character(0)
        for (i in seq(1, length(words), by = n)) {
          result <- c(result, paste(words[i:min(i + n - 1, length(words))], collapse = " "))
        }
        return(result)
      }

      # Specify the number of words to combine
      n <- window_length

      # Combine the words
      combined_list <- combine_words(word_list, n)

      sentences <- combined_list
      shapes[d, "nsentences"] <- length(sentences)


      # placeholder:
      nwindows <- length(sentences)

      shapes2[[d]] <- list()

      # word2vec position in each window (nwindows x 300)
      shapes2[[d]]$position_window <- matrix(0, nrow = nwindows, ncol = ndim_emb)
      shapes2[[d]]$nwords_window <- as.vector(rep(0, nwindows))
      shapes2[[d]]$nsentences_window <- as.vector(rep(0, nwindows))
      shapes2[[d]]$nwords_found_window <- as.vector(rep(0, nwindows))
      shapes2[[d]]$speed <- as.vector(rep(0, nwindows))

      # handle empty sentences:
      indsout_window <- vector()

      last_window <- 0

      # first window:
      ind_sentence <- 1
      nsentences_window <- 1
      words <- unlist(strsplit(sentences[ind_sentence], delimiter))
      window_size2 <- length(words)

      while (window_size2 < resolution & ind_sentence < nwindows) {
        ind_sentence <- ind_sentence + 1
        nsentences_window <- nsentences_window + 1
        new_words <- unlist(strsplit(sentences[ind_sentence], delimiter))
        window_size2 <- window_size2 + length(new_words)
        words <- c(words, new_words)
      }

      win <- 0
      if (ind_sentence == nwindows) {
        last_window <- 1
      }
      while (ind_sentence < nwindows) {
        win <- win + 1

        nwords_found <- 0
        nwords_notfound <- 0
        ind_sentence <- ind_sentence + 1
        next_nsentences_window <- 1
        next_words <- unlist(strsplit(sentences[ind_sentence], delimiter))
        next_window_size2 <- length(next_words)

        while (next_window_size2 < resolution & ind_sentence < nwindows) {
          ind_sentence <- ind_sentence + 1
          next_nsentences_window <- next_nsentences_window + 1
          new_words <- unlist(strsplit(sentences[ind_sentence], delimiter))
          next_window_size2 <- next_window_size2 + length(new_words)
          next_words <- c(next_words, new_words)
        }

        # merge last two windows if last window is too short
        if (ind_sentence == nwindows & next_window_size2 < resolution) {
          words <- c(words, next_words)
          window_size2 <- window_size2 + next_window_size2
          nsentences_window <- nsentences_window + next_nsentences_window
        } else {
          if (ind_sentence == nwindows) last_window <- 1
        }

        shapes[d, "nwords"] <- shapes[d, "nwords"] + window_size2
        shapes2[[d]]$nwords_window[win] <- window_size2
        shapes2[[d]]$nsentences_window[win] <- nsentences_window

        if (window_size2 > 0) {
          newposition <- matrix(0, nrow = window_size2, ncol = ndim_emb)
          indsout <- vector()

          words <- tolower(words)
          words <- gsub("\\.|\\?|!|,|;|:| ", "", words)
          words <- words[words != ""]
          words <- as.data.frame(words)

          words_found <- merge(words, input_words, by.x = "words", by.y = "word")
          nwords_found <- nrow(words_found)
          newposition_window <- apply(words_found[, 2:(ndim_emb + 1)], 2, mean)

          shapes2[[d]]$position_window[win, ] <- newposition_window

          shapes2[[d]]$nwords_found_window[win] <- nwords_found

          if (nwords_found == 0) {
            indsout_window <- c(indsout_window, win)
          }
        } else {
          indsout_window <- c(indsout_window, win)
        }

        words <- next_words
        window_size2 <- next_window_size2
        nsentences_window <- next_nsentences_window
      }

      # last window:
      if (last_window == 1) {
        last_window <- 0
        win <- win + 1
        nwords_found <- 0

        shapes[d, "nwords"] <- shapes[d, "nwords"] + window_size2
        shapes2[[d]]$nwords_window[win] <- window_size2
        shapes2[[d]]$nsentences_window[win] <- nsentences_window

        if (window_size2 > 0) {
          newposition <- matrix(0, nrow = window_size2, ncol = ndim_emb)
          indsout <- vector()
          words <- tolower(words)
          words <- gsub("\\.|\\?|!|,|;|:| ", "", words)
          words <- words[words != ""]
          words <- as.data.frame(words)
          words_found <- merge(words, input_words, by.x = "words", by.y = "word")
          nwords_found <- nrow(words_found)
          newposition_window <- apply(words_found[, 2:(ndim_emb + 1)], 2, mean)

          shapes2[[d]]$position_window[win, ] <- newposition_window
          shapes2[[d]]$nwords_found_window[win] <- nwords_found



          if (nwords_found == 0) {
            indsout_window <- c(indsout_window, win)
          }
        } else {
          indsout_window <- c(indsout_window, win)
        }
      }

      indsout_window <- c(indsout_window, ((win + 1):nwindows))

      shapes2[[d]]$position_window <- shapes2[[d]]$position_window[-indsout_window, ]
      shapes2[[d]]$nwords_found_window <- shapes2[[d]]$nwords_found_window[-indsout_window]
      shapes2[[d]]$nwords_window <- shapes2[[d]]$nwords_window[-indsout_window]
      shapes2[[d]]$nsentences_window <- shapes2[[d]]$nsentences_window[-indsout_window]

      shapes[d, "nwords_found"] <- sum(shapes2[[d]]$nwords_found_window)
      nwindows <- length(shapes2[[d]]$nwords_found_window)
      shapes[d, "nwindows"] <- nwindows
    }
  }

  print("Windows calculated ...")

  #######
  #### 2. Get speed
  ######

  distances <- as.vector(rep(0, D)) # use distance for circuitousness as well

  for (d in 1:D) {
    #####
    # compute story-level metrics based on window-level position:
    nwindows <- shapes[d, "nwindows"]
    # speed and distance covered
    if (nwindows <= 1) {
      nwindows <- 2
    }
    speed <- as.vector(rep(0, nwindows - 1))

    if (nwindows == 1 | nwindows == 0) {
      shapes2[[d]]$speed <- NA
    } else {
      for (window in 1:(nwindows - 1)) {
        speed[window] <- norm(shapes2[[d]]$position_window[window + 1, ] - shapes2[[d]]$position_window[window, ], type = "2") # calculate Eucledean distance
        # can be changed to the dist function in R, which allows to easily include other distance measures
      }
      shapes[d, "speed"] <- sum(speed)
      distances[d] <- shapes[d, "speed"]
      shapes2[[d]]$speed <- speed
    }

    if (include_extension_speed) {
      if (shapes[d, "nwindows"] > 1) {
        shapes[d, "average_speeds"] <- mean(shapes2[[d]]$speed)
        shapes[d, "cv_speeds"] <- std(shapes2[[d]]$speed) / mean(shapes2[[d]]$speed)
        shapes[d, "std_speeds"] <- std(shapes2[[d]]$speed)
      } else {
        shapes[d, "average_speeds"] <- NA
        shapes[d, "cv_speeds"] <- NA
        shapes[d, "std_speeds"] <- NA
      }

      if (shapes[d, "nwindows"] > 2) {
        #############
        # print(length(shapes2[[d]]$speed))
        # print(length(1:(shapes[d,"nwindows"]-1)))
        #############
        t <- cor(shapes2[[d]]$speed, (1:(shapes[d, "nwindows"] - 1)))
        # t=cor(shapes2[[d]]$speed,(1:(shapes[d,"nwindows"])))
        shapes[d, "trend_speeds"] <- t
      } else {
        shapes[d, "trend_speeds"] <- NA
      }

      if (shapes[d, "nwindows"] > 1) {
        shapes[d, "end_speeds"] <- shapes2[[d]]$speed[length(shapes2[[d]]$speed) - 1]
      } else {
        shapes[d, "end_speeds"] <- NA
      }
    }
  }

  print("Speed calculated ...")
  #######
  #### 3. Get volume
  ######

  for (d in 1:D) {
    nwindows <- shapes[d, "nwindows"]

    if (nwindows > 1) {
      ndim <- rankMatrix(shapes2[[d]]$position_window)

      if (ndim < ndim_emb | (ndim == ndim_emb & nrow(shapes2[[d]]$position_window) <= ndim_emb)) {
        tra2 <- as.matrix(shapes2[[d]]$position_window[1, ])

        if (nrow(shapes2[[d]]$position_window) == 2) {
          tra1 <- shapes2[[d]]$position_window[-1, ]
        } else {
          tra1 <- t(shapes2[[d]]$position_window[-1, ])
        }

        svd1 <- svd(tra1 - tra2 %*% matrix(1, nrow = 1, ncol = nwindows - 1))
        S1 <- svd1$u[, 1:ndim - 1]
        S1 <- as.matrix(S1)
        minvol <- MinVolEllipse(cbind(t(S1) %*% (tra1 - tra2 %*% matrix(1, nrow = 1, ncol = nwindows - 1)), as.vector(rep(0, ndim - 1))), 0.00001)
      } else {
        minvol <- MinVolEllipse(t(shapes2[[d]]$position_window), 0.00001)
      }

      svdfinal <- svd(minvol$matrix)
      D2 <- sqrt(svdfinal$d)

      shapes[d, "volume"] <- 1 / exp(mean(log(D2)))
    } else {
      shapes[d, "volume"] <- NA
    }

    if (include_extension_volume) {
      nwindows <- shapes[d, "nwindows"]

      speed2 <- as.vector(rep(0, nwindows - 1))
      sumspeed2 <- 1

      logsumspeed2 <- 0
      if (!nwindows == 1) {
        for (window in 1:(nwindows - 1)) {
          ndim <- rankMatrix(shapes2[[d]]$position_window[1:(window + 1), ])

          if (ndim < ndim_emb | (ndim == ndim_emb & nrow(shapes2[[d]]$position_window[1:(window + 1), ]) <= ndim_emb)) {
            if (window == 1) {
              tra1 <- as.matrix(shapes2[[d]]$position_window[2:(window + 1), ])
            } else {
              tra1 <- t(as.matrix(shapes2[[d]]$position_window[2:(window + 1), ]))
            }
            tra2 <- as.matrix(shapes2[[d]]$position_window[1, ])

            svd1 <- svd(tra1 - tra2 %*% matrix(1, nrow = 1, ncol = window)) # 'is the conjugate transpose; however we do not have complex numbers so I translate this as the normal transpose
            S1 <- svd1$u[, 1:ndim - 1]
            S1 <- as.matrix(S1)
            minvol <- MinVolEllipse(cbind(as.matrix(t(S1) %*% (tra1 - tra2 %*% matrix(1, nrow = 1, ncol = window))), as.vector(rep(0, ndim - 1))), 0.00001)
          } else {
            minvol <- MinVolEllipse(t(shapes2[[d]]$position_window[1:window + 1, ]), 0.00001)
          }

          svdfinal <- svd(minvol$matrix)
          D2 <- sqrt(svdfinal$d)

          speed2[window] <- exp(-sum(log(D2)) - logsumspeed2)

          sumspeed2 <- 1 / prod(D2)
          logsumspeed2 <- -sum(log(D2))
        }
        shapes2[[d]]$speed2 <- speed2
      }


      if (shapes[d, "nwindows"] > 1) {
        shapes[d, "average_speeds2"] <- mean(shapes2[[d]]$speed2)
        shapes[d, "cv_speeds2"] <- std(shapes2[[d]]$speed2) / mean(shapes2[[d]]$speed2)
        shapes[d, "std_speeds2"] <- std(shapes2[[d]]$speed2)
      } else {
        shapes[d, "average_speeds2"] <- NA
        shapes[d, "cv_speeds2"] <- NA
        shapes[d, "std_speeds2"] <- NA
      }


      if (shapes[d, "nwindows"] > 2) {
        t <- cor(shapes2[[d]]$speed2, (1:(shapes[d, "nwindows"] - 1)))
        shapes[d, "trend_speeds2"] <- t
      } else {
        shapes[d, "trend_speeds2"] <- NA
      }

      if (shapes[d, "nwindows"] > 1) {
        ###### Note
        shapes[d, "end_speeds2"] <- shapes2[[d]]$speed2[length(shapes2[[d]]$speed2) - 1]
      } else {
        shapes[d, "end_speeds2"] <- NA
      }
    }
  }
  print("Volume calculated ...")


  #######
  #### 4. Get Circuitousness
  ######

  # first, defines the minimum traveling distance for every observation
  # we take the minimum of all the methods listed below. if this takes too long, one of them can be chosen.

  methods <- c(
    "nearest_insertion", "farthest_insertion", "cheapest_insertion",
    "arbitrary_insertion", "nn", "repetitive_nn", "two_opt"
  )
  tsps <- as.vector(rep(0, D))
  for (d in 1:D) {
    if (shapes[d, "nwindows"] > 2) {
      set.seed(2)
      # di <- dist(shapes2[[d]]$position_window)
      # tsp <- TSP(di)

      # tsps[d]=min(sapply(methods,function(m) tour_length(solve_TSP(tsp,method = m))))
      tsp_global_result <- global_TSP(shapes2[[d]]$position_window)[[2]]
      tsps[d] <- tsp_global_result
    } else {
      if (shapes[d, "nwindows"] == 2) {
        tsps[d] <- shapes[d, "speed"] # speed is the same as distance covered.
      } else {
        tsps[d] <- NA
      }
    }

    # calculate the efficiency (or circuitousness)
    shapes[d, "circuitousness"] <- log(distances[d] / tsps[d])
    ### Efficiency3(test)
    shapes[d, "Efficiency3"] <- log(tsps[d] / (shapes[d, "nwindows"] - 1))
  }
  print("Circuitousness calculated ...")


  return(list(shapes, shapes2))
}
