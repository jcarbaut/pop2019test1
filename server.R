server <- function(input, output, session) {
  popreg <- reactive({
    pop %>%
      filter(reg == input$reg)
  })

  last.name <- reactiveVal()

  output$popdep <- renderPlot(
    popreg() %>%
      filter(reg == input$reg) %>%
      group_by(dep) %>%
      summarize(pop = sum(pop)) %>%
      left_join(tbl_dep, by = "dep") %>%
      ggplot(aes(x = reorder(libdep, -pop), y = pop)) +
        geom_bar(stat = "identity", color = "forestgreen", fill = "lightgreen") +
      xlab("Département") +
      ylab("Population") +
      scale_y_continuous(labels = ~format(., big.mark = " ", scientific = F)) +
      theme_minimal()
  )

  observeEvent(input$click, {
    # On commence par effacer le fichier précédent
    name <- last.name()
    if (!is.null(name)) {
      cat("Delete: ", name, "\n")
      unlink(name)
    }
    base <- tempname()
    name <- file.path("www", "output", base)

    # Nom de la région
    libreg <- tbl_reg %>%
      filter(reg == input$reg) %>%
      pull(libreg)

    # Autre façon de faire :
    # libreg <- names(regs[regs == input$reg])

    popmax <- popreg() %>%
      group_by(dep) %>%
      arrange(desc(pop), .by_group = T) %>%     # Tri par population en respectant les groupes
      slice_head(n = input$nmax) %>%            # n premières lignes par groupe
      ungroup() %>%                             # Dégrouper sinon le select ne fonctionne pas
      left_join(com, by = "depcom") %>%
      left_join(tbl_dep, by = "dep") %>%
      select(libdep, libcom, pop)

    # On knite le fichier Rmd, en passant en paramètre le code région.
    rmarkdown::render("popcom.Rmd",
                      output_file = name,
                      params = list(pop = popmax,
                                    nmax = input$nmax,
                                    libreg = libreg))

    # Mise-à-jour du nom du dernier fichier créé
    last.name(name)
    cat("Create: ", name, "\n")

    # On ouvre le fichier : remarquer la différence entre l'URL dans
    # le navigateur et le nom du fichier sur la machine.
    url <- file.path("output", base)
    js$browseURL(url)
  })

  session$onSessionEnded(function() {
    # A la fin de la session on efface le dernier fichier.
    cat("End of session\n")

    # Cette fonction n'est pas dans un contexte réactif, il faut donc
    # isoler la réactivité de last.name (sinon erreur à l'exécution).
    name <- isolate(last.name())
    if (!is.null(name)) {
      cat("Delete: ", name, "\n")
      unlink(name)
    }
  })
}
