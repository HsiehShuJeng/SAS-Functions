%LET salesKPIstr1 = %STR(註1：此為淨訂單的統計。);
OPTIONS MCOMPILENOTE=ALL;
/*
	DYRevenueLinePlot is for creating daily-revenue line plot.
*/
%MACRO DYRevenueLinePlot;
%IF &RIFALL EQ 1 %THEN
%DO;
	%DO i=&INI_DATE %TO &LAST_DATE %BY 1;
	ODS REGION;
		OPTIONS LOCALE=zh_TW;
		TITLE1 "%SYSFUNC(COMPRESS(%SYSFUNC(PUTN(&i, NLDATEW.)))) 營收狀況" C=BLACK;
		PROC SQL;
			SELECT Date FORMAT=NLDATEL. AS '日期'N, TVORWEBPROD AS '商品來源'N, '營收'N FORMAT=NLMNITWD22.0 AS '營收'N, 
					'訂單數'N FORMAT=COMMA9.0 AS '訂單數'N, '商品數量'N FORMAT=NLMNITWD22.0 AS '商品數量'N
			FROM WORK.R_H_ITMD3 WHERE Hour=. AND Date=&i;
		QUIT;
		OPTIONS LOCALE=en_US;
		GOPTIONS RESET=ALL;
		%_eg_conditional_dropds(WORK.SORTTempTableSorted)
		OPTIONS LOCALE=zh_TW;
		TITLE1 "%SYSFUNC(COMPRESS(%SYSFUNC(PUTN(&i, NLDATEW.)))) 營收（小時）圖" C=BLACK;
		OPTIONS LOCALE=en_US;
		PROC SORT DATA=WORK.R_H_ITMD3 (WHERE=(HOUR NE . AND Date=&i )) OUT=WORK.SORTTempTableSorted;
			BY Date Hour TVORWEBPROD;
		RUN;

		PROC GPLOT DATA=WORK.SORTTempTableSorted;
			SYMBOL1 INTERPOL=JOIN VALUE=DOT WIDTH=1 C=CXFE170B;
			SYMBOL2 INTERPOL=JOIN VALUE=DOT WIDTH=1 C=CXFE7D0B;
			SYMBOL3 INTERPOL=JOIN VALUE=DOT WIDTH=1 C=CXFEB00B;
			AXIS1 LABEL=("時段")
				ORDER=0 TO 23 BY 1
				OFFSET=(4);
			AXIS2 LABEL=("營收");
			LEGEND1 LABEL=("商品渠道");
			PLOT '營收'N*HOUR=TVORWEBPROD/
					HAXIS=AXIS1 HMINOR=0
					VAXIS=AXIS2 VMINOR=1
					LEGEND=LEGEND1;
		RUN;
		QUIT;
		%_eg_conditional_dropds(WORK.SORTTempTableSorted)
	%END;
%END;
%ELSE
%DO;
	OPTIONS LOCALE=zh_TW;
	TITLE1 "%SYSFUNC(COMPRESS(%SYSFUNC(PUTN(&LAST_DATE, NLDATEW.)))) 營收（小時）表" C=BLACK;
	OPTIONS LOCALE=en_US;
	PROC SQL NOPRINT;
		CREATE TABLE WORK.R_H_ITMD4 AS
		SELECT Date AS '日期'N, Hour AS '時數（區間）'N, TVORWEBPROD AS '商品渠道'N,
			'營收'N, '訂單數'N, '商品數量'N
			FROM WORK.R_H_ITMD3
			WHERE Hour NE . AND Hour LE 11 AND Date=&LAST_DATE;
		CREATE TABLE WORK.R_H_ITMD5 AS
		SELECT Date AS '日期.'N, Hour AS '時數（區間）.'N, TVORWEBPROD AS '商品渠道.'N,
			'營收'N AS '營收.'N, '訂單數'N AS '訂單數.'N, '商品數量'N AS '商品數量.'N
			FROM WORK.R_H_ITMD3
			WHERE Hour NE . AND Hour GE 12 AND Date=&LAST_DATE;
	QUIT;
	%_eg_conditional_dropds(WORK.R_H_ITMD_CB);
	DATA WORK.R_H_ITMD_CB;
		SET WORK.R_H_ITMD4;
		SET WORK.R_H_ITMD5;
	RUN;
	PROC SQL;
		DROP TABLE WORK.R_H_ITMD4, WORK.R_H_ITMD5;
		SELECT * FROM WORK.R_H_ITMD_CB;
	QUIT;
	%_eg_conditional_dropds(WORK.R_H_ITMD_CB);
	GOPTIONS RESET=ALL;
	%_eg_conditional_dropds(WORK.SORTTempTableSorted)
	OPTIONS LOCALE=zh_TW;
	TITLE1 "營收（小時）圖" C=BLACK; 
	OPTIONS LOCALE=en_US;
	PROC SORT DATA=WORK.R_H_ITMD3 (WHERE=(HOUR NE . AND Date=&LAST_DATE )) OUT=WORK.SORTTempTableSorted;
		BY Date Hour TVORWEBPROD;
	RUN;

	PROC GPLOT DATA=WORK.SORTTempTableSorted;
		SYMBOL1 INTERPOL=JOIN VALUE=DOT WIDTH=1 C=CXFE170B;
		SYMBOL2 INTERPOL=JOIN VALUE=DOT WIDTH=1 C=CXFE7D0B;
		SYMBOL3 INTERPOL=JOIN VALUE=DOT WIDTH=1 C=CXFEB00B;
		AXIS1 LABEL=("時段")
			ORDER=0 TO 23 BY 1
			OFFSET=(4);
		AXIS2 LABEL=("營收");
		LEGEND1 LABEL=("商品渠道");
		PLOT '營收'N*HOUR=TVORWEBPROD/
				HAXIS=AXIS1 HMINOR=0
				VAXIS=AXIS2 VMINOR=1
				LEGEND=LEGEND1;
	RUN;
	QUIT;
	%_eg_conditional_dropds(WORK.SORTTempTableSorted)
%END;
%MEND;
/*
	TVWEB Summary
*/
%MACRO compactSummaryTable;
PROC SQL NOPRINT;
	SELECT COUNT(DISTINCT Date) INTO :dt_num FROM TVWEB_Summary;
QUIT;
%IF %SYSFUNC(MOD(&dt_num, 2)) EQ 0 %THEN
%DO;
DATA TVWEB_Summary_TMP_1;
	SET TVWEB_Summary;
	IF _N_ LE (&dt_num./2)*3;
RUN;
DATA TVWEB_Summary_TMP_2;
	SET TVWEB_Summary;
	IF _N_ GT (&dt_num./2)*3;
RUN;
%END;
%ELSE
%DO;
%_eg_conditional_dropds(WORK.TVWEB_Summary_TMP_1)
%_eg_conditional_dropds(WORK.TVWEB_Summary_TMP_2)
DATA TVWEB_Summary_TMP_1;
	SET TVWEB_Summary;
	IF _N_ LE CEIL(&dt_num./2)*3;
RUN;
DATA TVWEB_Summary_TMP_2;
	SET TVWEB_Summary;
	IF _N_ GT CEIL(&dt_num./2)*3;
RUN;
%END;
DATA CompactTVWEBSummary;
	MERGE TVWEB_Summary_TMP_1 TVWEB_Summary_TMP_2(RENAME=(Date='Date.'N TVORWEBPROD='TVORWEBPROD.'N 營收='營收.'N 訂單數='訂單數.'N 商品數量='商品數量.'N));
RUN;
%_eg_conditional_dropds(WORK.TVWEB_Summary_TMP_1)
%_eg_conditional_dropds(WORK.TVWEB_Summary_TMP_2)
%MEND;
%MACRO summarizeTVWEB;
%IF %SYSFUNC(DATDIF(&INI_DATE,&LAST_DATE, ACT/ACT)) GT 0 %THEN %DO;
PROC MEANS DATA=WORK.R_H_ITMD3 SUM NOPRINT;
	CLASS Date Hour TVORWEBPROD;
	VAR '營收'N '訂單數'N '商品數量'N;
	TYPES Date*TVORWEBPROD ()*TVORWEBPROD;
	OUTPUT OUT=TVWEB_Summary SUM='營收'N '訂單數'N '商品數量'N;
RUN;
DATA TVWEB_Summary;
	RETAIN Date TVORWEBPROD '營收'N '訂單數'N '商品數量'N;
	FORMAT '營收'N DOLLAR22.0 '訂單數'N '商品數量'N COMMA9.0 Date DATE.;
	SET TVWEB_Summary(DROP=_FREQ_ _TYPE_ Hour);
RUN;
%compactSummaryTable;
%END;
%MEND;
OPTIONS MCOMPILENOTE=NONE;