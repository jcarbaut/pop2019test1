ui <- fluidPage(
  useShinyjs(),
  extendShinyjs(text = js_code, functions = "browseURL"),
  sidebarLayout(
    sidebarPanel(
      selectInput("reg", "Région", choices = regs),
      numericInput("nmax", "Nombre de communes les plus peuplées à afficher", 5, min = 1),
      actionButton("click", "Ouvrir le tableau")
    ),
    mainPanel(
      plotOutput("popdep")
    )
  )
)
