******************************************************;
*                                                     ;
*         Hepker, Sprout -- Module 5 Assignment       ;
*                                                     ;
******************************************************;


****************** Assignment Setup *******************;
		
	* Load VOTE1 text data ;
	
DATA work.vote1;
    INFILE "/home/u63985778/my_shared_file_links/u59059857/eco643/vote1.txt";
    INPUT state $ district democA voteA expendA expendB
          prtystrA lexpendA lexpendB shareA;
RUN;


	* Load DISCRIM text data ;
	
DATA work.discrim;
    INFILE "/home/u63985778/my_shared_file_links/u59059857/eco643/discrim.txt";
    INPUT psoda pfries pentree wagest nmgrs nregs hrsopen emp
          psoda2 pfries2 pentree2 wagest2 nmgrs2 nregs2 hrsopen2 emp2
          compown chain density crmrte state prpblck prppov prpncar
          hseval nstores income county lpsoda lpfries lhseval lincome
          ldensity NJ BK KFC RR;
RUN;


	* Load HTV text data ;
	
DATA work.htv;
    INFILE "/home/u63985778/my_shared_file_links/u59059857/eco643/htv.txt";
    INPUT wage abil educ ne nc west south exper
          motheduc fatheduc brkhme14 sibs urban ne18 nc18 south18
          west18 urban18 tuit17 tuit18 lwage expersq ctuit;
RUN;

	
***************** Computer Exercise 1 *****************;

PROC REG DATA=work.vote1 PLOTS=NONE;
    MODEL voteA = lexpendA lexpendB prtystrA;
    TEST lexpendA + lexpendB = 0;
    TITLE "Computer Exercise 1";
RUN;


***************** Computer Exercise 9 *****************;

PROC REG DATA=work.discrim PLOTS=NONE;
    MODEL lpsoda = prpblck lincome prppov;
    TITLE "Computer Exercise 9i";
RUN;

PROC CORR DATA=work.discrim;
    VAR lincome prppov;
    TITLE "Computer Exercise 9ii";
RUN;

PROC REG DATA=work.discrim PLOTS=NONE;
    MODEL lpsoda = prpblck lincome prppov lhseval;
    TITLE "Computer Exercise 9iii";
    TEST lhseval = 0;
RUN;

PROC REG DATA=work.discrim PLOTS=NONE;
    MODEL lpsoda = prpblck lincome prppov lhseval;
    TITLE "Computer Exercise 9iv";
    TEST lincome = 0, prppov = 0;
RUN;


***************** Computer Exercise 11 ****************;

DATA work.htv;
    SET work.htv;
    abil2 = abil*abil;
RUN;

PROC REG DATA=work.htv PLOTS=NONE;
    MODEL educ = motheduc fatheduc abil abil2;
    TITLE "Computer Exercise 11i & 11ii";
    TEST abil2 = 0;
    TEST motheduc = fatheduc;
RUN;

PROC REG DATA=work.htv PLOTS=NONE;
    MODEL educ = motheduc fatheduc abil abil2 tuit17 tuit18;
    TITLE "Computer Exercise 11iii";
    TEST tuit17 = 0, tuit18 = 0;
RUN;

PROC CORR DATA=work.htv;
    VAR tuit17 tuit18;
    TITLE "Computer Exercise 11iv";
RUN;

DATA work.htv;
    SET work.htv;
    avgtuit = (tuit17 + tuit18)/2;
RUN;

PROC REG DATA=work.htv PLOTS=NONE;
    MODEL educ = motheduc fatheduc abil abil2 avgtuit;
RUN;

*******************************************************;
