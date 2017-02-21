PROC SQL NOPRINT;
	SELECT Kiosk INTO :DEPARTMENTSTORES SEPARATED BY ', ' FROM WORK.INFO;
	SELECT BASTION INTO :DATES_LIST SEPARATED BY ',' FROM WORK.INFO;
QUIT;
%LET DATES_LIST=(&DATES_LIST);
%LET DEPARTMENTSTORES=(&DEPARTMENTSTORES);
%LET VariableNumber=%EVAL(%SYSFUNC(COUNT(&DEPARTMENTSTORES,%STR(,)))+1);
%GLOBAL RetainStatement;
%LET RetainStatement=;
%MACRO generateRetainStatement;
	%DO ProcessedVariable=1 %TO &VariableNumber;
		%IF &ProcessedVariable NE &VariableNumber %THEN
			%LET RetainStatement=&RetainStatement.%SCAN(&DEPARTMENTSTORES,&ProcessedVariable)%STR( %")%SCAN(&DATES_LIST,&ProcessedVariable,%STR(,()))%STR(%" );
		%ELSE 
			%LET RetainStatement=&RetainStatement.%SCAN(&DEPARTMENTSTORES,&ProcessedVariable)%STR( %")%SCAN(&DATES_LIST,&ProcessedVariable,%STR(,()))%STR(%");
	%END;
	%LET RetainStatement=%STR(RETAIN Date Number Times Items Contribution 0 )&RetainStatement%STR( �_�� ���� �n�� �F�� 0;);
%MEND;
%generateRetainStatement
OPTIONS VALIDVARNAME=ANY;

%MACRO generateDesirableDataSet;
DATA IMEDIATE_DATASET;
	%UNQUOTE(&RetainStatement)
	SET WORK."BASIC STATS"N;
RUN;
DATA ULTIMATE_RESULT;
	SET IMEDIATE_DATASET;
	%DO ProcessedVariable=1 %TO &VariableNumber;
		IF Date GE INPUT(SCAN(%SCAN(&DEPARTMENTSTORES,&ProcessedVariable),1,'/'),DATE9.) AND Date LE INPUT(SCAN(%SCAN(&DEPARTMENTSTORES,&ProcessedVariable),2,'/'),DATE9.) 
			THEN 
				DO;
					IF COMPRESS(SCAN(%SCAN(&DEPARTMENTSTORES,&ProcessedVariable),3,'/')) EQ '�_' THEN "�_��"N="�_��"N+1;
					ELSE IF COMPRESS(SCAN(%SCAN(&DEPARTMENTSTORES,&ProcessedVariable),3,'/')) EQ '��' THEN "����"N="����"N+1;
					ELSE IF COMPRESS(SCAN(%SCAN(&DEPARTMENTSTORES,&ProcessedVariable),3,'/')) EQ '�n' THEN "�n��"N="�n��"N+1;
					ELSE "�F��"N="�F��"N+1;
					%SCAN(&DEPARTMENTSTORES,&ProcessedVariable)='1';		
				END;
		ELSE %SCAN(&DEPARTMENTSTORES,&ProcessedVariable)='0';
	%END;
RUN;
%_eg_conditional_dropds(IMEDIATE_DATASET)
%MEND;
%generateDesirableDataSet