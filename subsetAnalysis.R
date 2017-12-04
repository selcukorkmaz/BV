# data = dataWithoutOutliers; subject = "subject"; gender = "Gender"; analyte = "value"; CVresult = "original"
# 
# subset(data, subject, gender, analyte, CVresult = "original")

subsetAnalysis <- function(data, subject, gender, analyte, CVresult = "original"){      
  
  if(CVresult == "transformed" || CVresult == "transformBack" ){
    
    analyteValue = data$value
    loganalytevalue = log(analyteValue)
    # logdata = data
    data$value = loganalytevalue      
    
  }
  
  genderLevels = levels(data[,gender])
  
  dataHomogenity = data
  analyteValue = data$value
  if(is.null(analyteValue)){
    
    analyteValue = data[,analyte]
  }
  
  subjects = as.factor(data[,subject])
  
  means <- tapply(analyteValue, subjects, mean)
  names(means) = levels(subjects)
  
  genderU = cbind.data.frame(unique(data[-c(3:6)]))
  
  gender2 = genderU[with(genderU, order(subject)), ]
  
  dataTtest = cbind.data.frame(gender2, means)
  
  
  bartlet = bartlett.test(dataTtest$means, dataTtest[, gender])
  
  
  HomogenityGenderResult =  data.frame(matrix(NA,1,5))
  names(HomogenityGenderResult) = c("Test", "Statistic", "df", "p-value", "Result")
  
  HomogenityGenderResult[1,1] = "Bartlett"
  HomogenityGenderResult[1,2] = bartlet$statistic[[1]]
  HomogenityGenderResult[1,3] = bartlet$parameter[[1]]
  HomogenityGenderResult[1,4] = bartlet$p.value[[1]]
  HomogenityGenderResult[1,5] = if(bartlet$p.value > 0.05){"Homogeneous"}else{"Heterogeneous"}
  
  
  if(bartlet$p.value > 0.05){ varEqual = TRUE}else{ varEqual = FALSE}
  
  
  
  ttest = t.test(as.formula(paste0("means~",gender)), data = dataTtest, var.equal = varEqual)
  
  sd = tapply(dataTtest[,"means"], dataTtest[,gender], sd)
  
  ttestResult =  data.frame(matrix(NA,1,7))
  names(ttestResult) = c("Analyte", paste0("Mean (", genderLevels[1],")"), paste0("SD (", genderLevels[1],")"), paste0("Mean (", genderLevels[2],")"), paste0("SD (", genderLevels[2],")"), "p-value", "Result")
  ttestResult[1,1] = analyte
  ttestResult[1,2] = round(ttest$estimate[[1]],2)
  ttestResult[1,3] = round(sd[[1]],2)
  ttestResult[1,4] = round(ttest$estimate[[2]],2)
  ttestResult[1,5] = round(sd[[2]],2)
  ttestResult[1,6] = round(ttest$p.value,2)
  ttestResult[1,7] = if(ttest$p.value > 0.05){"No difference"}else{"Different"}
  
  if(is.null(data$value)){
    dataHomogenity2 = data[,c(subject, analyte, gender)]
    vars =  tapply(dataHomogenity2[,analyte], as.factor(dataHomogenity2[,subject]), var)
    
  }else{
    
    dataHomogenity2 = data[,c(subject, "value", gender)]
    vars =  tapply(dataHomogenity2$value, as.factor(dataHomogenity2[,subject]), var)
    
  }
  
  names(vars) = levels(as.factor(dataHomogenity2[,subject]))
  
  genderU = cbind.data.frame(unique(dataHomogenity2[-2]))
  
  gender2 = genderU[with(genderU, order(subject)), ]
  
  dataHomogenity3 = cbind.data.frame(vars, gender2)
  
  bartlet = bartlett.test(dataHomogenity3$vars, dataHomogenity3[,gender])
  
  
  HomogenitySIAResult =  data.frame(matrix(NA,1,5))
  names(HomogenitySIAResult) = c("Test", "Statistic", "df", "p-value", "Result")
  
  HomogenitySIAResult[1,1] = "Bartlett"
  HomogenitySIAResult[1,2] = bartlet$statistic[[1]]
  HomogenitySIAResult[1,3] = bartlet$parameter[[1]]
  HomogenitySIAResult[1,4] = bartlet$p.value[[1]]
  HomogenitySIAResult[1,5] = if(bartlet$p.value > 0.05){"Homogeneous"}else{"Heterogeneous"}
  
  
  if(bartlet$p.value > 0.05){ varEqual = TRUE}else{ varEqual = FALSE}
  
  formula = as.formula(paste0("vars ~ ", gender))
  
  ttest = t.test(formula, data = dataHomogenity3, var.equal = varEqual)
  
  sd = tapply(dataHomogenity3$vars, dataHomogenity3[,gender], sd)
  
  ttestResultSIA =  data.frame(matrix(NA,1,7))
  names(ttestResultSIA) = c("Analyte", paste0("Mean (", genderLevels[1],")"), paste0("SD (", genderLevels[1],")"), paste0("Mean (", genderLevels[2],")"), paste0("SD (", genderLevels[2],")"), "p-value", "Result")
  ttestResultSIA[1,1] = analyte
  ttestResultSIA[1,2] = round(ttest$estimate[[1]],2)
  ttestResultSIA[1,3] = round(sd[[1]],2)
  ttestResultSIA[1,4] = round(ttest$estimate[[2]],2)
  ttestResultSIA[1,5] = round(sd[[2]],2)
  ttestResultSIA[1,6] = round(ttest$p.value,2)
  ttestResultSIA[1,7] = if(ttest$p.value > 0.05){"No difference"}else{"Different"}
  
  subsetResult = list(homogenity = HomogenityGenderResult, ttest = ttestResult, homogenitySIA = HomogenitySIAResult, ttestSIA = ttestResultSIA)
  
  return(subsetResult)
}
      
      
      
      