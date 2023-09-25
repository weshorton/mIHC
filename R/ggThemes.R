pie_theme <- function() {
  #' Theme for pie charts
  #' @description Minor changes to theme classic - mainly removing axes.
  #' @export 
  theme_classic() +
    theme(plot.title = element_text(hjust = 0.5, size = 20),
          plot.subtitle = element_text(hjust = 0.5, size = 16),
          axis.text = element_blank(),
          axis.ticks = element_blank(),
          axis.line = element_blank(),
          axis.title = element_blank(),
          legend.text = element_text(size = 16))
}

