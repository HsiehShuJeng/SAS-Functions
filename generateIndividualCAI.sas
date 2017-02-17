/*
	This macro function is for creating individual line charts grouped by a specific variable,
	then being exported as a .html file and the corresponding .png images.
*/
%GLOBAL totalCustomerNumber;
%MACRO generateIndividualCAI;
DATA Proper_Input;
	RETAIN TMPID;
	SET 某資料集;
	BY 某欄位;
	IF FIRST.某欄位 THEN TMPID+1; 
	OUTPUT;
RUN;
PROC SQL NOPRINT;
	SELECT COUNT(DISTINCT TMPID) INTO :totalCustomerNumber FROM Proper_Input;
QUIT;
%DO dynamicNumber=1 %TO &totalCustomerNumber;
PROC SGPLOT DATA=Proper_Input(WHERE=(TMPID=&dynamicNumber));
	TITLE TMPID=&dynamicNumber;
	VLINE X軸變數/RESPONSE=y軸變數;
RUN;
%END;
%MEND;
%generateIndividualCAI
