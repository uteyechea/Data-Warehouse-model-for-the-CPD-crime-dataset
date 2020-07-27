# sql-Data-Warehouse-model-for-the-CPD-crime-dataset

The three most important types of crime prediction data, collected by police departments,
that can provide the most accurate forecasting input data that forms the spatio-temporal pattern of crime are the type of crime,
the location of the crime, and the date and time of the crime.
In this first a priori approach for our data model, the smallest hierarchy of time that we will use will
be the unit of time corresponding to one day. In future work, the smallest time hierarchy
will be that corresponding to a time window whose time unit will be in minutes. For example: a 23 minutes time window.
Decreasing to a granularity level of less than an hour is unlikely to improve the prediction
results, as even the police department does not receive the crime reports instantly,
as it would be in the case of the crime being reported in real time.
A detailed analysis of the data set will allow us to gain a better perspective on the size of the appropriate time window.
The other two types of data that I choose to form the data warehouse correspond to whether
an arrest was made and whether the crime occurred in a domestic setting or not.
The reason why I decided to include these two types of data is due to their usefulness, not for predicting future crime, but
for generating crime reports, so that we can present a more complete picture on the apprehension rates and rates of crime
carried out in a domestic environment, so that managers can make better decisions regarding the administration of their police personnel.
