library(tidyverse)
library(sysfonts)

#View(font_files())
sysfonts::font_add(
  family = "Highway Gothic",
  #regular = "Highway Gothic/HWYGOTH.TTF"
  #regular = "Highway Gothic/HWYGEXPD.TTF"
  regular = "Highway Gothic/HWYGWDE.TTF"
  )

bg <-
  ggplot(data.frame(x=-1, y=-1), aes(x=x, y=y)) +
    geom_blank() +
    labs(x="", y="") +
    theme(
      # panel.background = element_rect(fill="#FECF00"),
      # plot.background = element_rect(fill="#FECF00"),
      # axis.line = element_line(color="#FECF00"),
      panel.background = element_blank(),
      plot.background = element_blank(),
      axis.line = element_blank(),
      panel.grid.major = element_blank(),
      panel.grid.minor = element_blank(),
      panel.border = element_blank(),
      axis.text = element_blank(),
      axis.ticks = element_blank()
      )

hexSticker::sticker(
  # Background
    subplot = bg,
    s_width = 1,
    s_height = 1,
    #white_around_sticker = TRUE,
    h_fill = "#FECF00",
  # Title
    package = "rfars",
    p_color = "black",
    p_y = 1,
    p_family = "Highway Gothic",
    p_size = 60,
  # Border
    h_color = "black",
    h_size = 1,
  # Output
    filename = "man/figures/logo.png",
    dpi = 600
)
