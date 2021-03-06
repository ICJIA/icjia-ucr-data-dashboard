.compute_percent_change <- function(data, category, year1, year2, keep_na) {
  sum2 <- if (keep_na) function(...) sum(..., na.rm = TRUE) else sum

  data %>%
    rename(p1 = person_crime, p2 = property_crime) %>%
    list(y1 = filter(., year == year1), y2 = filter(., year == year2)) %>%
    with({
      if (category == "Person") list(y1 = sum2(y1$p1), y2 = sum2(y2$p1))
      else if (category == "Property") list(y1 = sum2(y1$p2), y2 = sum2(y2$p2))
      else list(y1 = sum2(y1$p1, y1$p2), y2 = sum2(y2$p1, y2$p2))
    }) %>%
    with({ (y2 - y1) / y1 * 100 })
}

kpi_1 <- function(input, output, data_reactive) {
  output$kpi_1 <- renderUI({
    data <- data_reactive()
    sum2 <-
      if (input$county == "All") function(...) sum(..., na.rm = TRUE)
      else sum

    value <-
      {
        if (input$category == "Person") sum2(data$person_crime)
        else if (input$category == "Property") sum2(data$property_crime)
        else sum2(data$person_crime, data$property_crime)
      } %>%
      {
        if (is.na(.)) .
        else {
          if (input$unit == "Count")
            if (. > 10000) paste0(round(. / 1000), "K") else .
          else apply_rate(., sum2(data$population, na.rm = TRUE))
        }
      }

    desc <-
      { if (input$unit == "Count") "Offenses in" else "Crime rate in" } %>%
      paste(input$range[2]) 

    tagList(
      tags$h1(value),
      tags$p(
        icon("bar-chart"),
        desc,
        style="font-size:1.1em;"
      )
    )
  })
}

kpi_2 <- function(input, output, data_reactive) {
  output$kpi_2 <- renderUI({
    value <-
      data_reactive() %>%
      .compute_percent_change(
        category = input$category,
        year1 = input$range[2] - 1,
        year2 = input$range[2],
        keep_na = input$county == "All"
      ) %>%
      round(1) %>%
      paste0("%")

    tagList(
      tags$h1(value),
      tags$p(
        icon("sort"),
        paste0("Change, ", input$range[2] - 1, "-", input$range[2]),
        style="font-size:1.1em;"
      )
    )
  })
}

kpi_3 <- function(input, output, data_reactive) {
  output$kpi_3 <- renderUI({
    value <-
      data_reactive() %>%
      .compute_percent_change(
        category = input$category,
        year1 = input$range[1],
        year2 = input$range[2],
        keep_na = input$county == "All"
      ) %>%
      round(1) %>%
      paste0("%")

    tagList(
      tags$h1(value),
      tags$p(
        icon("sort"),
        paste0("Change, ", input$range[1], "-", input$range[2]),
        style = "font-size:1.1em;"
      )
    )
  })
}
