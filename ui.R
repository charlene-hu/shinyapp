library(shiny);
library(shinyIncubator);

shinyUI(fluidPage(
    headerPanel("Classification of Ocean Microbes"),
    sidebarPanel(
        radioButtons("algo", "Learning Algorithm:",
                  c("Bagging" = "bagging",
                    "Random Forest" = "rf",
                    "Support Vector Machine" = "svm")
        ),
        actionButton("runAnalysisUI","Start")
    ),
   
    mainPanel(progressInit(),        
        tabsetPanel(
            tabPanel("Model Results",h3("Confusion Matrix"),tableOutput("trainResultsUI"),h3("Accuracy"), textOutput("accuracy")),
            tabPanel("Raw Data",dataTableOutput("rawDataView")),
            tabPanel("Plot",plotOutput("finalPlotUI")),
            tabPanel("About this app", includeHTML("about.html"))
            ,id="mainTabUI"))
    )
)