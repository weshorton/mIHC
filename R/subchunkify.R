subchunkify <- function(g, fig_height=7, fig_width=5, id = NULL) {
  #' Code taken from stack overflow
  #' https://stackoverflow.com/questions/15365829/dynamic-height-and-width-for-knitr-plots/47339394#47339394
  #' References a blog post by Michael J Williams, but link is broken
  #' Addition of ID from this post: https://stackoverflow.com/questions/61620768/rmarkdown-explicitly-specify-the-figure-size-of-a-plot-within-a-chunk
  #' Had to modify the paste0() call for sub_chunk because r markdown was giving warnings about mismatched ticks for some reason.
  #' Function to output variable figure sizes
  #'
  g_deparsed <- paste0(deparse(
    function() {g}
  ), collapse = '')

  sub_chunk <- paste0("\n ```{r sub_chunk_", id, "_", floor(runif(1) * 10000000), ", fig.height=", fig_height, ", fig.width=", fig_width, ", echo=FALSE}",
                      "\n(", g_deparsed, ")()", "\n ```\n")

  cat(trimws(knitr::knit(text = knitr::knit_expand(text = sub_chunk), quiet = TRUE)))
}

