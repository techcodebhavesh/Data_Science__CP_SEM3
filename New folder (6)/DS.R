  
    library(cluster)
    library(readr)
    library(dplyr)
    library(readxl)
    library(ggplot2)
    
    data<-read_excel("C:/Users/bhave/Downloads/New folder/Copy of GDP_and_Major_Industrial_Sectors_of_Economy_Dataset(1).xlsx")
    
  #CLUSTERING
    # data preprocessing
    data_clean <- data %>% 
      select(-Financial_Year, -Population) %>% 
      mutate_all(function(x) gsub(",", "", x)) %>% 
      mutate_all(function(x) as.numeric(gsub("[^0-9.-]", "", x)))
    
    # k-means algorithm
    cluster_data <- data_clean[, 2:15]
    kmeans_result <- kmeans(cluster_data, centers = 4)
    
  
    data_with_clusters <- bind_cols(data, cluster = kmeans_result$cluster)
    
    # Analyze
    cluster_summary <- data_with_clusters %>%
      group_by(cluster) %>%
      summarize(
        average_GDP = mean(Gross_Domestic_Product_at_200405_Prices),
        max_GDP = max(Gross_Domestic_Product_at_200405_Prices),
        min_GDP = min(Gross_Domestic_Product_at_200405_Prices),
        average_GDP_Growth_Rate = mean(GDP_Growth_Rate),
        max_GDP_Growth_Rate = max(GDP_Growth_Rate),
        min_GDP_Growth_Rate = min(GDP_Growth_Rate)
      )
    

    print(cluster_summary)
    
    library(ggplot2)
    
   
    
    # k-means algorithm
    cluster_data <- data_with_clusters[, c("cluster", "Gross_Domestic_Product_at_200405_Prices", "GDP_Growth_Rate")]
    
    # Visualization - Scatter plot
    ggplot(cluster_data, aes(x = Gross_Domestic_Product_at_200405_Prices, y = GDP_Growth_Rate, color = factor(cluster))) +
      geom_point() +
      labs(title = "Clustering of Financial Years",
           x = "Gross Domestic Product",
           y = "GDP Growth Rate",
           color = "Cluster") +
      theme_minimal()
    

    
    # Number of clusters
    num_clusters <- 4
    
    #cluster contents
    ggplot(data_with_clusters, aes(x = Financial_Year, y = Gross_Domestic_Product_at_200405_Prices, color = factor(cluster))) +
      geom_point() +
      geom_line() +
      labs(title = "GDP Trends by Cluster",
           x = "Financial Year",
           y = "Gross Domestic Product",
           color = "Cluster") +  
      theme_minimal()
    
    # Visualization - Line chart for GDP growth rate
    ggplot(data_with_clusters, aes(x = Financial_Year, y = GDP_Growth_Rate, color = factor(cluster))) +
      geom_point() +
      geom_line() +
      labs(title = "GDP Growth Rate Trends by Cluster",
           x = "Financial Year",
           y = "GDP Growth Rate",
           color = "Cluster") +   geom_line(aes(group = 1), color = "orange")  # Line chart
      theme_minimal()

      
      
      
#GDP POPULATION CLUSTERING
  library(dplyr)
  library(ggplot2)
  
  
  data_for_clustering <- data %>% select(Gross_Domestic_Product_at_200405_Prices, Population)
  
  k <- 4

  set.seed(123) 
  kmeans_result <- kmeans(data_for_clustering, centers = k)
  
  data$Cluster <- as.factor(kmeans_result$cluster)

  ggplot(data, aes(Population, Gross_Domestic_Product_at_200405_Prices, color = Cluster)) +
    geom_point(size = 1) +
    scale_color_manual(values = c("red", "blue", "green", "purple")) +  # Customize cluster colors
    labs(
      title = "K-means Clustering of Regions by GDP and Population",
      x = "Population",
      y = "GDP"
    ) +
    theme_minimal()
  

  cluster_summary <-data %>% 
    group_by(Cluster) %>%
    summarize(
      Avg_GDP = mean(Gross_Domestic_Product_at_200405_Prices),
      Avg_Population = mean(Population),
      Num_Regions = n()
    )
  
  print(cluster_summary)
  # Show which years are classified in each cluster
  for (cluster_id in 1:k) {
    cat("Cluster ", cluster_id, " includes years:\n")
    cluster_years <- data$Financial_Year[data$Cluster == cluster_id]
    print(cluster_years)
    cat("\n")
  }
    
 #CORRELATION MATRIX
  
  # Load required libraries
  library(readxl)
  library(dplyr)
  library(corrplot)
  
  # Step 1: Import and Preprocess Data
  data <- read_excel("C:/Users/bhave/Downloads/New folder/Copy of GDP_and_Major_Industrial_Sectors_of_Economy_Dataset(1).xlsx")
  
  # Calculate the correlation matrix
  correlation_matrix <- cor(data[, c("Gross_Domestic_Product_at_200405_Prices", "Population", "GDP_Growth_Rate")])
  
  # heatmap
  corrplot(correlation_matrix, method = "color", type = "full", tl.col = "black", tl.srt = 45)
  
  
  ###ARIMA###
  
    library(ggplot2)
    
    library(forecast)
    library(readxl)
    
    
    
    # Prepare the time series data
    ts_data <- ts(data$Gross_Domestic_Product_at_200405_Prices, frequency = 1)
    autoplot(ts_data)
    adf.test(ts_data, k = 1)
    acf(ts_data)
    
    ts_data_d1<- diff(ts_data, differences=1)
    adf.test(ts_data_d1,k=1)
    ts_data_d2<- diff(ts_data, differences=2)
    adf.test(ts_data_d2,k=1)
    Pacf(ts_data_d2)
    Acf(ts_data_d2)
    ts_model<- Arima(y=ts_data,order=c(1,2,2))
    print(ts_model)
    forecast(ts_model,h=10)
    autoplot( forecast(ts_model,h=10))
  
  
 #ARIMA-GDP GROWTH RATE(AUTO.ARIMA)
      library(forecast)
      library(tseries)
      library(readxl)
      
      # Step 1: Import and Preprocess Data
      data<-read_excel("C:/Users/bhave/Downloads/New folder/Copy of GDP_and_Major_Industrial_Sectors_of_Economy_Dataset(1).xlsx")
      
      
      # Prepare the time series data
      ts_data_g <- ts(data$GDP_Growth_Rate, frequency = 1)
      autoplot( ts_data_g)
      adf.test( ts_data_g ,k=1)
      acf(ts_data_g)
      
      # Perform ARIMA modeling
      model_g <- auto.arima(ts_data_g)
      ?auto.arima
      
      
      # Forecast future values
      forecast_data_g <- forecast(model_g, h = 10)
      
      # Create a dataframe for the forecasted values
      forecast_df_g <- data.frame(Year = c(data$Financial_Year, 2013:2022),  GDP_Growth_Rate= c(data$GDP_Growth_Rate, forecast_data_g$mean))
      
      
      ggplot(forecast_df_g, aes(x = Year, y =   GDP_Growth_Rate)) +
        geom_point(color = ifelse(forecast_df_g$Year > 2012, "red", "blue")) +
        geom_line(aes(group = 1), color = "green") +  # Line chart
        labs(title = "GDP_Growth_Rate Over the Years", x = "Year", y = "GDP_Growth_Rate")
      ljung_box_test <- Box.test(residuals(model_g), lag = 5, type = "Ljung-Box")
      print(ljung_box_test)
   
    
  
    #ARIMA-POPULATION
    library(forecast)
    library(tseries)
    library(readxl)
    
   
    
    
    # Prepare the time series data
    ts_data_p <- ts(data$Population, frequency = 1)
    autoplot( ts_data_p)
    adf.test( ts_data_p ,k=1)
    acf(ts_data_p)
    pacf(ts_data_p)
  
    # Perform ARIMA modeling
    model_p <- auto.arima(ts_data_p)
    ?auto.arima
    
    
    # Forecast future values
    forecast_data_p <- forecast(model_p, h = 10)
    
    # Create a dataframe for the forecasted values
    forecast_df_p <- data.frame(Year = c(data$Financial_Year, 2013:2022), Population = c(data$Population, forecast_data_p$mean))
    
    # Plot the GDP for all years
    # Plot the GDP for all years with both scatter and line charts
    ggplot(forecast_df_p, aes(x = Year, y = Population)) +
      geom_point(color = ifelse(forecast_df_p$Year > 2012, "red", "blue")) +
     
      labs(title = "Population Over the Years", x = "Year", y = "Population")
  
    ljung_box_test <- Box.test(residuals(model_p), lag =5, type = "Ljung-Box")
    print(ljung_box_test)
    
  
    
    
    
    
   ######
    library(autoplot)
    
    ts_data_aa <- ts(data$AgriAllied_ServicesGrowthRate, frequency = 1)
    autoplot(ts_data_aa)
    adf.test(ts_data_aa, k = 1)
    acf(ts_data_aa)
    
    # Perform ARIMA modeling
    model_aa <- auto.arima(ts_data_aa)
    ?auto.arima
    
    # Forecast future values
    forecast_data_aa <- forecast(model_aa, h = 10)
    
    # Create a dataframe for the forecasted values
    forecast_df_aa <- data.frame(Year = c(data$Financial_Year, 2013:2022), AgriAllied_ServicesGrowthRate = c(data$AgriAllied_ServicesGrowthRate, forecast_data_g$mean))
    
    # Plot the AgriAllied_ServicesGrowthRate for all years
    # Plot the AgriAllied_ServicesGrowthRate for all years with both scatter and line charts
    ggplot(forecast_df_aa, aes(x = Year, y = AgriAllied_ServicesGrowthRate)) +
      geom_point(color = ifelse(forecast_df_g$Year > 2012, "red", "blue")) +
      geom_line(aes(group = 1), color = "green") +  # Line chart
      labs(title = "AgriAllied_ServicesGrowthRate Over the Years", x = "Year", y = "AgriAllied_ServicesGrowthRate")
    
    ljung_box_test <- Box.test(residuals(model_aa), lag = 5, type = "Ljung-Box")
    print(ljung_box_test)
    
    
    ######
    
  
    


    library(forecast)
    library(TSA)
    
    # Assuming you have a time series ts_data_ass
    ts_data_ass <- ts(data$AgriAllied_Services_ShareTotalGDP, frequency = 1)
    
    # Visualize the original time series
    autoplot(ts_data_ass)
    
    # Augmented Dickey-Fuller Test to check for stationarity
    adf_test_original <- adf.test(ts_data_ass, k = 1)
    print(adf_test_original)
    
    # 1.differencing
    differenced_ts <- diff(ts_data_ass)
    adf_test_differenced <- adf.test(differenced_ts, k = 1)
    print(adf_test_differenced)
    
   
    ts_data_ass <- ts(data$AgriAllied_Services_ShareTotalGDP, frequency = 1)
    autoplot(differenced_ts)
   
    acf(differenced_ts)
  
    autoplot(differenced_ts)  
    
    
    # Perform ARIMA modeling
    model_ass <- auto.arima(differenced_ts)
  
    
    
    forecast_data_ass <- forecast(model_ass, h = 10)
    
   
    forecast_df_ass <- data.frame(Year = c(data$Financial_Year, 2013:2022), AgriAllied_Services_ShareTotalGDP = c(data$AgriAllied_Services_ShareTotalGDP, forecast_data_ass$mean))
    
    
    ggplot(forecast_df_ass, aes(x = Year, y = AgriAllied_Services_ShareTotalGDP)) +
      geom_point(color = ifelse(forecast_df_ass$Year > 2012, "red", "blue")) +
      geom_line(aes(group = 1), color = "green") +  # Line chart
      labs(title = "AgriAllied_Services_ShareTotalGDP Over the Years", x = "Year", y = "AgriAllied_Services_ShareTotalGDP")
    
    ljung_box_test <- Box.test(residuals(model_ass), lag = 5, type = "Ljung-Box")
    print(ljung_box_test)
   
    
   #########
    
  
    
    # Prepare the time series data
    ts_data_ass <- ts(data$AgriAllied_Services_ShareTotalGDP, frequency = 1)
    autoplot(ts_data_ass)
    adf.test(ts_data_ass, k = 1)
    acf(ts_data_ass)
    
    ts_data_d1<- diff(ts_data_ass, differences=1)
    adf.test(ts_data_d1,k=1)
    
    Pacf(ts_data_d1)
    Acf(ts_data_d1)
    ts_model_ass<- Arima(y=ts_data_ass,order=c(2,1,2))
    print(ts_model_ass)
    forecast(ts_model_ass,h=10)
    autoplot( forecast(ts_model_ass,h=10))
    
    
    #########
  
 # AI-A    GROUP 2 (BATCH 1)

  