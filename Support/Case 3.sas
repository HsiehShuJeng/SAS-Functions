/*
	This is for forming a SAS SQL query which
	may contains a host of 'CONTAINS' with ease.
*/
DATA Sample;
	INPUT query $10.;
	DATALINES;
Baby
魔法
;
RUN;
proc sql NOPRINT;
	SELECT query INTO :sample_string SEPARATED BY ', ' FROM Sample;
quit;
%LET sample_string=(&sample_string);

%MACRO Sample;
%LET varnum=%SYSFUNC(COMPRESS(%EVAL(%SYSFUNC(COUNT(&sample_string, %STR(,)))+1)));
%DO i=1 %TO &varnum;
	%LET tmp_string = t1.SALENAME CONTAINS "%SCAN(&sample_string,&i)";
	%IF &i EQ 1 %THEN 
		%LET contain_string=&tmp_string;
	%ELSE %LET contain_string=&contain_string%STR( OR )&tmp_string;
	%IF &i EQ &varnum %THEN
		%LET contain_string=&contain_string%STR(;);
%END;
PROC SQL;
CREATE TABLE Outcome AS 
	SELECT * FROM TABLE t1
	WHERE &contain_string
QUIT;
%MEND;
%Sample