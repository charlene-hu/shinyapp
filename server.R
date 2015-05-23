library(caret)
library(shiny)
library(shinyIncubator)
library(gbm)
library(e1071)
library(randomForest)
library(glmnet)

options(shiny.trace=TRUE)
options(shiny.error=traceback)
options(shiny.error=browser) 
df <- read.csv("data/seaflow_21min.csv")
set.seed(1)
trainIndex <- createDataPartition(df$pop, p = .5, list = FALSE, times = 1)
dfTrain <- df[trainIndex,]
dfTest <- df[-trainIndex,]
fol <- formula(pop ~ fsc_small + fsc_perp + fsc_big + pe + chl_big + chl_small)

shinyServer(function(input,output,session)
{    
    output$rawDataView = renderDataTable({
        if(is.null(df))
            return()
        df
    })
    
    output$finalPlotUI = renderPlot({
        if(is.null(df))
            return()
        a <- ggplot(data = dfTrain, aes(x = pe, y = chl_small, col = pop))
        a <- a + geom_point()
        a <- a + xlab("phycoerythrin fluorescence") + ylab("Forward scatter small") + ggtitle("particles ")
        a
    })
    
    bagging <- reactive({
        model <- randomForest(fol, data=dfTrain, method="class", mtry=6)
        result <- predict(model, newdata=dfTest, type="class")
        return (result)
    })
    rf <- reactive({
        model <- randomForest(fol, data=dfTrain, method="class")
        result <- predict(model, newdata=dfTest, type="class")
        return (result)
    })
    svector <- reactive({
        model <- svm(fol, data=dfTrain)
        result <- predict(model, newdata=dfTest, type="class")
        return (result)
    })
    
    #this is the function that responds to the clicking of the button
    predictResults <- reactive({
        #input$runAnalysisUI;
        if(input$runAnalysisUI == 0)
            return()
        alg = isolate(input$algo)

        results = NULL
        
        results = withProgress(session, min=1, max=2, {
            setProgress(message = "Calculation in progress", 
                        detail = "This may take a while...")
            setProgress(value = 1)
            set.seed(1)
            if(alg == "bagging"){
                predict <- bagging()
            }
            else if(alg == "rf"){
                predict <- rf()
            }
            else if(alg =="svm") {
                predict <- svector()
           }

            return (predict)
            setProgress(value = 2)
        })
    })

    output$trainResultsUI = renderTable({
        data = predictResults()
        if(is.null(data))
            return()
        confusionMatrix <- table(pred = data, true = dfTest$pop)
        return (confusionMatrix)
    })
    
    output$accuracy = renderText({
        data = predictResults()
        if(is.null(data))
            return()
        v <- data == dfTest$pop
        ratio <- length(v[v==TRUE])/nrow(dfTest)
        return (ratio)
    })
})