******************************************************;
*                                                     ;
*         Hepker, Sprout -- Final Project             ;
*            Data Construction Program                ;
*                                                     ;
******************************************************;

	* Define macro for assigned proc means options;

%macro means_check(if=);
	PROC MEANS DATA = &if n nmiss mean min max maxdec=3;
		TITLE "Means of &if";
	RUN;
%mend;


	* explore e625data.cps_raw_sample before importing for analysis;
	
PROC CONTENTS DATA = e625data.CPS_RAW_SAMPLE;
	TITLE "Contents of e625data.cps_raw_sample";
RUN;

%means_check(if=e625data.CPS_RAW_SAMPLE);


	* import cps_raw_sample as projdata1;
	
DATA e625proj.projdata1;
	SET e625data.CPS_RAW_SAMPLE;

********************************************************************;
*                                                                   ;
*                    Demographic Variables                          ;
*                                                                   ;
********************************************************************; 

	* citizenship indicator;

	citizen = 0;
	IF PRCITSHP GE 1 AND PRCITSHP LE 4 THEN citizen = 1;

	LABEL citizen = "= 1 if citizen; = 0 otherwise"; 

	* sex indicator;
   
	female = 0;
		IF A_SEX = 2 THEN female = 1;
	ELSE IF A_SEX = 1 THEN female = 0;
   
	LABEL female = "= 1 if female, = 0 otherwise";

	* poor health indicator;
		
	poor_health = 0;
	IF HEA IN (4, 5) THEN poor_health = 1;

	LABEL poor_health = "= 1 if health fair or poor; = 0 otherwise";   


	* categorical marital status -> binary indicators for regression analysis;

	married       = 0;
	widowed       = 0;
	divorced      = 0;
	separated     = 0;
	never_married = 0;

		 IF A_MARITL IN (1, 2, 3) THEN married       = 1;
	ELSE IF A_MARITL EQ 4         THEN widowed       = 1;
	ELSE IF A_MARITL EQ 5         THEN divorced      = 1;
	ELSE IF A_MARITL EQ 6         THEN separated     = 1;
	ELSE IF A_MARITL EQ 7         THEN never_married = 1;

	LABEL married       = "= 1 if married; = 0 otherwise";
	LABEL widowed       = "= 1 if widowed; = 0 otherwise";
	LABEL divorced      = "= 1 if divorced; = 0 otherwise";
	LABEL separated     = "= 1 if separated; = 0 otherwise";
	LABEL never_married = "= 1 if never_married; = 0 otherwise";

	* assign earned income and calculate annual hours and hourly wage from existing data;
		
	earned_income = PEARNVAL;
	annual_hours = HRSWK * WKSWORK;
	hourly_wage = earned_income / annual_hours;
   
	LABEL earned_income = "Annual Income";
	LABEL annual_hours  = "Annual Hours Worked";
	LABEL hourly_wage   = "Hourly Wage";
   
	* create mutually exclusive variables from two cps race and ethnicity variables; 
	* ensuring that each individual is categorized only once;

	hispanic = 0;
	white    = 0;
	black    = 0;
	asian    = 0;
	other    = 0;
	
	IF PEHSPNON = 1 THEN hispanic = 1;
	
	* elseif not hispanic select from PRDTRACE -> assign to race variables;
	* selection accounts for individuals who selected two races;
	
	ELSE DO;
		SELECT (PRDTRACE);
			WHEN (1)        white = 1;
			WHEN (2, 6)     black = 1;
			WHEN (4, 8, 11) asian = 1;
			OTHERWISE       other = 1;
		END;
	END;
	
	LABEL hispanic = "= 1 if hispanic; = 0 otherwise";
	LABEL white    = "= 1 if white; = 0 otherwise";
	LABEL black    = "= 1 if black; = 0 otherwise";
	LABEL asian    = "= 1 if asian; = 0 otherwise";
	LABEL other    = "= 1 if other; = 0 otherwise";


********************************************************************;
*                                                                   ;
*          Education Indicators and Categorical Variable            ;
*                                                                   ;
********************************************************************; 

	* initialize variables to 0;
	
	educ_lt_hs        = 0;
	educ_eq_hs        = 0;
	educ_some_college = 0;
	educ_college      = 0;
	educ_ma           = 0;
	educ_prof_phd     = 0;
   
	* extract six indicator variables for varying levels of education from A_HGA;
	
	 	 IF (A_HGA >= 31 AND A_HGA <= 38) THEN educ_lt_hs        = 1;
	ELSE IF  A_HGA EQ 39                  THEN educ_eq_hs        = 1;
	ELSE IF  A_HGA IN (40, 41, 42)        THEN educ_some_college = 1;
	ELSE IF  A_HGA EQ 43                  THEN educ_college      = 1;
	ELSE IF  A_HGA EQ 44                  THEN educ_ma           = 1;
	ELSE IF  A_HGA IN (45, 46)            THEN educ_prof_phd     = 1;

	LABEL educ_lt_hs        = "= 1 if less than a high school degree; = 0 otherwise";
	LABEL educ_eq_hs        = "= 1 if high school degree; = 0 otherwise";
	LABEL educ_some_college = "= 1 if beyond high school but less than bachelors degree; = 0 otherwise";
	LABEL educ_college      = "= 1 if college graduate; = 0 otherwise";
	LABEL educ_ma           = "= 1 if masters degree; = 0 otherwise";
	LABEL educ_prof_phd     = "= 1 if professional or doctoral degree; = 0 otherwise";

	* education categorical;
	
	educ_cat = 0;
        
		 IF educ_lt_hs        EQ 1 THEN educ_cat = 1;
	ELSE IF educ_eq_hs        EQ 1 THEN educ_cat = 2;
	ELSE IF educ_some_college EQ 1 THEN educ_cat = 3;
	ELSE IF educ_college      EQ 1 THEN educ_cat = 4;
	ELSE IF educ_ma           EQ 1 THEN educ_cat = 5;
	ELSE IF educ_prof_phd     EQ 1 THEN educ_cat = 6;

	LABEL educ_cat = "categorical measure of education";


********************************************************************;
*                                                                   ;
*          Allocation/Imputation Indicator Variables                ;
*                                                                   ;
********************************************************************; 

	* categorizes missing data indicators into combined earnings and combined demographic indicators;
		
	miss_earn = (AXHRS   ^= 0  OR I_HRSWK  ^= 0);

	miss_demo = (AXAGE   ^= 0  OR AXHGA    ^= 0 
	          OR I_HEA   ^= 0  OR PXHSPNON ^= 00 
	          OR PXRACE1 ^= 00 OR PXMARITL IN (10:53));

	LABEL miss_earn           = "1 if either HRSWK or WKSWK are imputed and 0 otherwise";
	LABEL miss_demo           = "1 if any A_GE, A_HGA, HEA, PEHSPNON, PRDTRACE, or A_MARITL are imputed and 0 otherwise";
	
RUN;

	* review means to ensure accuracy of above;
	
%means_check(if=e625proj.projdata1);


********************************************************************;

	* explore e625data.cps_hh_file before importing for analysis;

PROC CONTENTS DATA = e625data.CPS_HH_FILE;
	TITLE "Contents of e625data.cps_hh_file";
RUN;

PROC MEANS DATA = e625data.CPS_HH_FILE n nmiss mean min max maxdec=3;
	TITLE "Means of e625data.cps_hh_file";
RUN;

	* sort hhdata and projdata1 by hhid to prep for merger on that variable;

PROC SORT DATA = e625data.cps_hh_file OUT = WORK.hhdata;        BY hhid; RUN;
PROC SORT DATA = e625proj.projdata1   OUT = e625proj.projdata1; BY hhid; RUN;


********************************************************************;
*                                                                   ;
*          Household Data Merger and Region Variable                ;
*                                                                   ;
********************************************************************; 

DATA e625proj.temp;
	MERGE work.hhdata e625proj.projdata1;
	BY hhid;
    
    * extract four regional indicator variables from GEREG;
    
	south     = 0;
	northeast = 0;
	midwest   = 0;
	west      = 0;

	SELECT (GEREG);
		WHEN (1) northeast = 1;
		WHEN (2) midwest   = 1;
		WHEN (3) south     = 1;
		WHEN (4) west      = 1;
		OTHERWISE DO;
			northeast = .;
			midwest   = .;
			south     = .;
			west      = .;
		END;
	END;
	
	LABEL south     = "= 1 if residing in south; = 0 otherwise";
	LABEL northeast = "= 1 if residing in northeast; = 0 otherwise";
	LABEL midwest   = "= 1 if residing in midwest; = 0 otherwise";	
	LABEL west      = "= 1 if residing in west; = 0 otherwise";
RUN;

	* review means to ensure accuracy of above;
	
%means_check(if=e625proj.temp);

	* sort temp data by FIPS code (by state) to prep for adding state median_income	to observations;
	
PROC SORT DATA = e625proj.temp; BY GESTFIPS; RUN;

	* calculate and store state level median incomes in a working dataset by FIPS code;
	
PROC MEANS DATA = e625proj.temp NOPRINT;
	BY GESTFIPS;
	VAR earned_income;
	OUTPUT OUT = WORK.medianinc MEDIAN(earned_income) = median_income;
RUN;

	* add the relevant state's median_income to observations in temp to create projdata2;
	
DATA e625proj.projdata2;
	MERGE e625proj.temp WORK.medianinc (DROP = _TYPE_ _FREQ_);
	BY GESTFIPS;
	
	LABEL median_income = "median income in state of residency";
RUN;

	* review means to ensure accuracy of above;

%means_check(if=e625proj.projdata2);

	* sort projdata2 and cps_additional_variables on peridnum to prepare for merger on that variable;
	
PROC SORT DATA=e625proj.projdata2;                BY PERIDNUM; RUN;
PROC SORT DATA=e625data.cps_additional_variables; BY PERIDNUM; RUN;

	* merge additional variables onto projdata2 by peridnum;
	
DATA e625proj.projdata3;
    MERGE e625proj.projdata2 e625data.cps_additional_variables;
    BY PERIDNUM;
RUN;

	* review means to ensure accuracy of above;

%means_check(if=e625proj.projdata3);

	 * create analysis_data file by retaining created variables from projdata3;

DATA e625proj.analysis_data; 
	SET e625proj.projdata3; 
	KEEP earned_income         educyrs12             educ_cat 
         educ_eq_hs            educ_some_college     educ_college 
         educ_ma               educ_prof_phd         female 
         poor_health           married               widowed 
         divorced              separated             marry_cat 
         hispanic              white                 black 
         asian                 other                 age18 
         age                   age2                  citizen 
         south                 northeast             midwest 
         west                  median_income         educ_at_least_hs 
         educ_at_least_col     annual_hours          hourly_wage 
         miss_earn             miss_demo;
RUN;

	* review means to ensure accuracy of above;

%means_check(if=e625proj.analysis_data);


* ODS RTF CLOSE;