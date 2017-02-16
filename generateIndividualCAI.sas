/*
	This macro function is for creating individual line charts grouped by a specific variable,
	then being exported as a .html file and the corresponding .png images.
*/
%GLOBAL totalCustomerNumber;
%MACRO generateIndividualCAI;
DATA Proper_Input;
	RETAIN TMPID;
	SET �Y��ƶ�;
	BY �P�O���;
	IF FIRST.�P�O��� THEN TMPID+1; 
	OUTPUT;
RUN;
PROC SQL NOPRINT;
	SELECT COUNT(DISTINCT TMPID) INTO :totalCustomerNumber FROM Proper_Input;
QUIT;
%DO dynamicNumber=1 %TO &totalCustomerNumber;
PROC SGPLOT DATA=Proper_Input(WHERE=(TMPID=&dynamicNumber));
	TITLE TMPID=&dynamicNumber;
	VLINE n/RESPONSE=dif_day;
RUN;
%END;
%MEND;
%generateIndividualCAI