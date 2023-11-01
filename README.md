
<!-- README.md is generated from README.Rmd. Please edit that file -->

# rStoryShape

<!-- badges: start -->
<!-- badges: end -->

The `rStoryShape` R package is designed to calculate key storytelling
metrics, including speed, volume, and circuitousness, based on the
research conducted in the paper titled [How quantifying the shape of
stories predicts their
success](https://www.pnas.org/doi/epdf/10.1073/pnas.2011695118) by
Toubia, O., Berger, J., & Eliashberg (2021) published in the Proceedings
of the National Academy of Sciences.

This package provides a set of functions and tools to help you analyze
and quantify the shape of stories, allowing you to gain insights into
their potential success. Whether you’re a researcher, storyteller, or
data analyst, `rStoryShape` empowers you to apply storytelling metrics
in your work, enhancing your ability to craft and evaluate compelling
narratives.

Key features: - Calculate storytelling speed, volumn, and
circuitousness. - Apply storytelling metrics to assess narrative
impact. - Empower your storytelling research and analysis.

With `rStoryShape`, you can harness the science of storytelling to
create more engaging and impactful narratives.

## Installation

To use the `rStoryShape` R package, follow these steps:

### Step 1: Install devtools (if not already installed)

Before you can install `rStoryShape`, you may need to install the
`devtools` package if you haven’t already. You can do this by running
the following command in your R environment:

``` r
install.packages("devtools")
```

### Step 2: Install rStoryShape

With devtools installed, you can proceed to install rStoryShape from our
GitHub repository. Use the following R code:

``` r
devtools::install_github("doublejif/rStoryShape")
```

### Step 3: Download the FastText Embedding File

To make the most of rStoryShape, you’ll need to download the fastText
embedding file in RData format. This file is quite large (approximately
4.63GB), so make sure you have sufficient disk space. You can download
it using the following link:

[Download rStoryShape FastText Embedding
File](https://drive.google.com/uc?export=download&id=1Nq--lnyG_9cLdjcjVPe4tVl3nqyIm8WT)

Please keep track of the download path on your local system, as you’ll
need it during the package usage.

With these steps, you’ll be fully equipped to quantify storytelling
metrics, gain valuable insights into your narratives, and make the most
of rStoryShape for your projects.

### Note: Package Reading Problems

Before using the `rStoryShape` package, ensure that you have the
following R packages installed to avoid any reading problems:

``` r
library(slam)
library(Rglpk)
library(Matrix)
```

These packages are essential for the proper functioning of rStoryShape
and for avoiding any issues when working with storytelling metrics.

## Usage with Your Own Embedding

If you wish to use your own embedding with the `rStoryShape` package,
please follow these guidelines:

1.  **Data Format**: Ensure that your corpus files are in CSV format.
    Each CSV file should have a column named “text” (case sensitive)
    containing the text data you want to analyze.

2.  **Embedding Format**: If you intend to use your own embedding,
    please make sure it follows the standard format as specified
    [here](https://drive.google.com/uc?export=download&id=1koC_c7U2vXJQyl1jAtUa8W7holN1WmLf).
    Specifically, the first column in your embedding file should be
    named “word” (case sensitive).

3.  **Embedding File Format**: Your embedding file can be in either CSV
    or Rdata format (files end with “.csv” or “.Rdata”). Ensure that
    your embedding data adheres to the required structure.

By following these steps, you can seamlessly use your own embeddings
with the `rStoryShape` package, allowing for customized analysis of
storytelling metrics.

For more details and examples, refer to the package documentation.

### A Simple Example

``` r
library(rStoryShape)
## Read your own embedding. It should be a dataframe with the first column names "word", and follows the embedding metrix (n words * 301 dimensions). Like this:
# word X1 X2 X3 X4 ... X299 X300
#---------------------------------------------
#  a   a1 a2 a3 a4 ... a299 a300
#  ,   b1 b2 b3 b4 ... b299 b300
# ...  .. .. .. .. ...  ..   ..
# the  n1 n2 n3 n4 ... n299 n300

## You could replace the path here with the path you save your embedding
path_for_emb<-"data/ft_model_test.Rdata"
path_for_corpus<-"data/corpus.Rdata"
result<-get_the_data(path_for_corpus, path_for_emb, own_emb=FALSE,type_of_window = "length", window_length = 10)
#> [1] "Windows calculated ..."
#> [1] "Speed calculated ..."
#> [1] "Volume calculated ..."
#> [1] "Circuitousness calculated ..."
#> [1] 1
#> [1] "Windows calculated ..."
#> [1] "Speed calculated ..."
#> [1] "Volume calculated ..."
#> [1] "Circuitousness calculated ..."
#> [1] 2
#> [1] "Windows calculated ..."
#> [1] "Speed calculated ..."
#> [1] "Volume calculated ..."
#> [1] "Circuitousness calculated ..."
#> [1] 3
#> [1] "Windows calculated ..."
#> [1] "Speed calculated ..."
#> [1] "Volume calculated ..."
#> [1] "Circuitousness calculated ..."
#> [1] 4
#> [1] "Windows calculated ..."
#> [1] "Speed calculated ..."
#> [1] "Volume calculated ..."
#> [1] "Circuitousness calculated ..."
#> [1] 5
print(result)
#>                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   corpus[i, ]
#> 1               In a dusty, old attic of her family's century-old house, young Emily discovered a mysterious key with an intricate design. The key had been hidden inside a long-forgotten chest. It was made of an unknown metal, with peculiar symbols etched into it.\nEmily's curiosity got the best of her. As she embarked on a journey to uncover the key's origins, she stumbled upon a hidden door tucked away in the attic's corner. The key, it turned out, was the missing piece of the puzzle.\nUpon turning the key in the lock, a portal emerged, and Emily stepped into an entirely different world—a realm of enchantment, magical creatures, and breathtaking landscapes. She found herself in a place where reality blended with fantasy.\nThere, she made friends with talking animals, met mythical beings, and even learned to cast spells. Emily's life had transformed into a wondrous adventure she could have never imagined.\nYet, her newfound world was not without challenges. She soon discovered that an evil sorcerer sought the key for his nefarious purposes, and it was up to Emily to protect the key, her new friends, and the magical world from his dark intentions.
#> 2                                                                                                                                                    Amelia, a shy artist, had always felt like an outsider in the bustling city. One day, while working in her cluttered studio, she noticed a scruffy stray cat outside her window. Instead of chasing the cat away, she felt an inexplicable connection.\nAmelia started leaving food and water for the cat, and over time, it became a regular visitor to her studio. What was unusual, though, was that this cat seemed to understand her in a way no human ever had. They would sit together for hours, and it was as if the cat could feel her emotions.\nAs Amelia opened up to her newfound feline friend, they began going on adventures around the city. The cat, who she named Whiskers, led her to hidden places, introduced her to kind-hearted people, and helped her break out of her shell.\nTheir unusual friendship taught her that connections can be found in the most unexpected places and that the quietest voices often have the most to say. Amelia realized that she had found a lifelong friend who accepted her just as she was.
#> 3                                                                                                                                                                        In the attic of their family home, Mark discovered an old, leather-bound diary. It had belonged to a distant ancestor, and as he started reading, he realized it was no ordinary diary. Whenever he wrote a date and an entry, he was transported to that moment in history.\nWith the diary in hand, Mark visited the roaring '20s, witnessed pivotal moments of history, and even met some of his heroes. He was amazed by the incredible power this diary held, but he soon realized that it came with great responsibility.\nAs he explored different time periods, he uncovered secrets about his family, the diary's creation, and its potential consequences. The diary's magic was not to be taken lightly.\nMark was faced with dilemmas of whether to change the past or simply observe, ultimately questioning what made him travel through time in the first place. Through his adventures, he learned the value of appreciating the present and that the past, even with its flaws, had shaped the world he knew today.
#> 4 Dr. Elizabeth Grant, a passionate archaeologist, stumbled upon an ancient map in an old library. The map pointed to a long-lost city deep within an uncharted jungle, a place believed to be the stuff of legends.\nWith a team of researchers and explorers, she set out on an expedition to find the fabled city. As they trekked through dense foliage, deciphered cryptic clues, and faced treacherous terrain, the team began to question if the city was a mere myth.\nBut their determination and the unwavering belief in their mission led them onward. As they got closer to their destination, they encountered unexpected challenges—hostile wildlife, unforgiving weather, and mysterious phenomena that defied explanation.\nAs they finally reached the hidden city, they realized that the legends were not mere stories. The city held secrets, relics, and technologies that could change the course of history. But they also discovered that they were not the first to find it; another expedition, led by Dr. Grant's longtime rival, had followed their every move.\nNow, they faced a race against time to unlock the secrets of the lost city before it fell into the wrong hands.
#> 5   Samantha, a struggling writer, stumbled upon a quaint, old bookstore tucked away in a hidden corner of the city. This wasn't just any bookstore—it was known to appear only when one truly needed it.\nInside, she found shelves filled with books that, when opened, had the power to make the characters and worlds come to life. The stories she read would materialize before her eyes, and Samantha soon realized the immense potential of this bookstore.\nHowever, as she delved deeper into the magical books, she discovered that these stories were not mere fantasies—they had real consequences beyond the pages. Her words and decisions in the stories began to affect her life and the lives of those around her.\nSamantha had to navigate a fine line between her dreams and reality, learning that the power of storytelling was a responsibility. The magical bookstore not only brought stories to life but revealed the power of words, imagination, and the ability to shape her own destiny.\nThese stories are starting points for your imagination. Feel free to expand upon them, develop characters, and explore the worlds they inhabit to create your own unique narratives.
#>       speed      volume circuitousness
#> 1 0.2837922 0.009686199     0.08965507
#> 2 0.2707053 0.009876095     0.13611780
#> 3 0.2625805 0.010010524     0.09157344
#> 4 0.2609159 0.009834105     0.08974452
#> 5 0.2344426 0.009301359     0.10763818
```
