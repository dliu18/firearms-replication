# firearms-replication
A replication of the study "Firearms and accidental deaths: Evidence from the aftermath of the Sandy Hook school shooting". Completed for SOC 504, Princeton Spring 2018.

# Replication targets 
1. Google Trends figure 
Verify the correlation coefficient is 0.72 between search terms and then 0.71 with respect to background checks. 

2. National and State-level Background check trends 
Generate figures 2 and 3 

3. Causal Inference analysis 
OLS regression analysis with fixed effects 
Instrumental variable analysis 

# Accomplishments 
* (3/2) Downloaded original raw data, Stata code and readme from [Dataverse](https://dataverse.harvard.edu/dataset.xhtml?persistentId=doi:10.7910/DVN/EVLKBN). 
* (3/15) Followed readme.txt instructions to obtain mortality files from [CDC](https://www.cdc.gov/nchs/data_access/vitalstatsonline.htm#Mortality_Multiple). 
* (3/20) Annotated article and created Replication targets section 
* (3/20) To understand the format of the Vital Statistics data, I read the [Stata infix documentation](https://www.stata.com/manuals13/dinfixfixedformat.pdf). Will use fread to import fixed-width data in R. 
* (3/20) Created template code files for each of the key replication sections 
