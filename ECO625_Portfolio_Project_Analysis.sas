******************************************************;
*                                                     ;
*         Hepker, Sprout -- Final Project             ;
*              Data Analysis Program                  ;
*                                                     ;
******************************************************;

ODS RTF FILE = "~/eco625/project/hepker_project.rtf" STYLE = journal;

	* calculate summary statistics for variables in analysis_data;

PROC MEANS DATA=e625proj.analysis_data  n mean std min max maxdec=3;
	TITLE "Summary Statistics for Project Analysis Data";
RUN;

	* define format for education categories;
	
PROC FORMAT;
	VALUE educ_fmt 
		1 = "Less than High School"
		2 = "High School Graduate"
		3 = "Some College"
		4 = "College Graduate"
		5 = "Masters Degree"
		6 = "Professional or Doctorate Degree";
RUN;

	* visualizations for earned income, years of education, and education categories;
	
PROC SGPLOT DATA = e625proj.analysis_data;
	TITLE "Distribution of Earned Income";
	HISTOGRAM earned_income / SCALE = PERCENT;
RUN;

PROC SGPLOT DATA = e625proj.analysis_data;
	TITLE "Distribution of Years of Education";
	VBAR educyrs12;
RUN;

PROC SGPLOT DATA = e625proj.analysis_data;
	TITLE "Distribution of Education Levels";
	VBAR educ_cat;
	FORMAT educ_cat educ_fmt.;
RUN;

PROC SGPLOT DATA = e625proj.analysis_data;
	TITLE "Scatterplot of (Years of Education - 12) and Earned Income";
	SCATTER Y = earned_income X = educyrs12;
RUN;

	* comparison of means across education categories;

PROC MEANS DATA = e625proj.analysis_data nonobs mean maxdec=3;
	TITLE "Descriptive Information on Income Variables By Education Level";
	CLASS educ_cat;
	VAR earned_income;
	FORMAT educ_cat educ_fmt.;
RUN;

	* comparison of distributions across education categories;

PROC SGPANEL DATA = e625proj.analysis_data;
	TITLE "Distribution of Earned Income by Education Categories";
	PANELBY educ_cat / NOVARNAME;
	HISTOGRAM earned_income;
	FORMAT educ_cat educ_fmt.;
RUN;

	

PROC FORMAT;
	VALUE misslbl
		0 = "Not Allocated"
		1 = "Allocated"
		;
RUN;

	* frequencies of imputed/allocated data;

PROC FREQ DATA = e625proj.analysis_data;
	TITLE "Cross Tabulation of Missing Demographics with Percents";
    TABLES miss_demo * miss_earn / NOCOL NOROW;
    FORMAT miss_demo misslbl. miss_earn misslbl.;
RUN;

* linear regression of earned income on (years of education - 12);

PROC REG DATA = e625proj.analysis_data PLOTS = NONE;
	TITLE "Regression of Earned Income on Years of Education -12";
	MODEL earned_income = educyrs12;
RUN;

	* frequencies of imputed/allocated data - display count only;
	
PROC FREQ DATA = e625proj.analysis_data;
TITLE "Cross Tabulation of Missing Demographics without Percents";
    TABLES miss_demo * miss_earn / NOCOL NOROW NOPERCENT;
    FORMAT miss_demo misslbl. miss_earn misslbl.;
RUN;

	* multiple regression - using only data WITHOUT allocated/imputed data;
	
PROC REG DATA=e625proj.analysis_data PLOTS = none;
	TITLE "Regression - Observations with Complete Demographics";
	WHERE miss_demo = 0 AND miss_earn = 0;
	MODEL earned_income = age18 female citizen poor_health hispanic black asian other married 
		 				 widowed divorced separated educ_eq_hs educ_some_college median_income
		 				 educ_college educ_ma educ_prof_phd northeast midwest west;
RUN;
 		
	* hypothesis test population parameters on the education variables are jointly equal to 0;
 		
PROC REG DATA = e625proj.analysis_data PLOTS = none;
    TITLE "Testing for Significance in Education Variable Effects on Earned Income";
    MODEL earned_income = age18 female citizen poor_health hispanic black asian other married 
		 				 widowed divorced separated educ_eq_hs educ_some_college median_income
		 				 educ_college educ_ma educ_prof_phd northeast midwest west;
    TEST educ_eq_hs = 0, educ_some_college = 0, educ_college = 0, educ_ma = 0, educ_prof_phd = 0;
RUN;

	* multiple regression - using only data WITH allocated/imputed data;
	
PROC REG DATA=e625proj.analysis_data PLOTS = none;
	TITLE "Regression - Observations with Incomplete Demographics";
	WHERE miss_demo = 1 AND miss_earn = 1;
	MODEL earned_income = age18 female citizen poor_health hispanic black asian other married 
		 				 widowed divorced separated educ_eq_hs educ_some_college median_income
		 				 educ_college educ_ma educ_prof_phd northeast midwest west;
RUN;

ODS RTF CLOSE;