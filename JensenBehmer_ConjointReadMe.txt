Replication files for Jensen/Behmer: "Home Country Attributes and Political Risk Abroad".
In addition to this file, this archive contains three files:

1) JensenBehmer_ConjointData.csv
2) JensenBehmer_ConjointSetup.do
3) overall_cjoint.r

To replicate all tables and figures from the paper (and appendix), follow the ensuing steps:

a) Open the do-file (JensenBehmer_ConjointSetup.do) in Stata.

b) Change the local directory at the top to wherever you are storing the data file (JensenBehmer_ConjointData.csv). 

c) Execute the entire script. Partial execution may lead to errors, due to the inclusion of local objects and temporarily saved files in the script. 

d) Upon having executed the script, three datasets will be generated and stored in your current directory. 

e) Open the r-script (overall_cjoint.r) in R (or R-Studio, etc.), and change your working directory to where you have stored the newly generated datasets. 

f) Execute the full script to generate PDF documents of the graphs, which will be stored in your working directory. Regression results appear in the console.