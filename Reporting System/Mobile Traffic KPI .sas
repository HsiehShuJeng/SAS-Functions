/*
	ActionSeparator is for observing records with different actions in convenience.
*/
%LET bk_string = %STR('分類字串1', '分類字串2','分類字串3','分類字串4','分類字串5','分類字串6','分類字串7', '分類字串8', '分類字串9');
/*
	CLCEDGenerator is for creating table of clicking-times on daily base and Excplicit category.
*/
%MACRO CLCEDGenerator;
%_eg_conditional_dropds(TMP_3)
PROC SQL NOPRINT;
	CREATE TABLE TMP_3 AS 
	SELECT Date, 大分類, SUM(點擊數) FORMAT=COMMA9. AS '點擊數'N 
	FROM TMP_2
	GROUP BY Date, 大分類;
	SELECT MAX(LENGTH(STRIP(大分類))) INTO: ctg_ln FROM TMP_3;
QUIT;
%LET ctg_ln = $%SYSFUNC(STRIP(&ctg_ln)).;
PROC MEANS DATA=TMP_3 SUM NOPRINT;
	CLASS Date 大分類;
	VAR 點擊數;
	TYPES Date Date*大分類;
	OUTPUT OUT=CLC_FIG_ITMD SUM='點擊數'N;
RUN;
%_eg_conditional_dropds(TMP_3)
DATA CLC_FIG_ITMD (DROP=大分類_TMP);
	RETAIN Date 大分類 點擊數;
	FORMAT 大分類 &ctg_ln;
	SET CLC_FIG_ITMD(DROP=_FREQ_ _TYPE_ RENAME=(大分類=大分類_TMP));
	IF 大分類_TMP EQ "" THEN 大分類="總和";
	ELSE 大分類=大分類_TMP;
RUN;
PROC SORT DATA=CLC_FIG_ITMD;
	BY Date DESCENDING '點擊數'N;
RUN;
PROC SQL NOPRINT;
	CREATE TABLE CLC_FIG_ITMD2 AS
	SELECT Date AS '日期'N, 大分類, 點擊數, 點擊數/MAX(點擊數) AS '佔比'N FORMAT=PERCENT8.2 FROM CLC_FIG_ITMD;
	SELECT COUNT(*) INTO: f_n FROM CLC_FIG_ITMD;
QUIT;
DATA CLC_FIG_TMP1;
	SET CLC_FIG_ITMD2;
	IF MOD(&f_n,2) EQ 0 THEN IF _N_ LE (&f_n/2);
	ELSE IF _N_ LE ROUND(&f_n/2);
RUN;
DATA CLC_FIG_TMP2;
	SET CLC_FIG_ITMD2;
	IF MOD(&f_n,2) EQ 0 THEN IF _N_ GT (&f_n/2);
	ELSE IF _N_ GT ROUND(&f_n/2);
RUN;
DATA CLC_FIG;
	MERGE CLC_FIG_TMP1 CLC_FIG_TMP2(RENAME=(日期='日期.'N 大分類='大分類.'N 點擊數='點擊數.'N 佔比='佔比.'N));
RUN;
PROC SQL;
	DROP TABLE CLC_FIG_TMP1, CLC_FIG_TMP2, CLC_FIG_ITMD, CLC_FIG_ITMD2;
QUIT;
%MEND;
/*
	CLCETRGenerator is for creating table of clicking-times on time-range base and Explicitcategory.
*/
%MACRO CLCETRGenerator;
%_eg_conditional_dropds(TMP_3)
PROC SQL NOPRINT;
	CREATE TABLE TMP_3 AS 
	SELECT Date, 大分類, SUM(點擊數) FORMAT=COMMA9. AS '點擊數'N 
	FROM TMP_2
	GROUP BY Date, 大分類;
	SELECT MAX(LENGTH(STRIP(大分類))) INTO: ctg_ln FROM TMP_3;
QUIT;
%LET ctg_ln = $%SYSFUNC(STRIP(&ctg_ln)).;
PROC MEANS DATA=TMP_3 SUM NOPRINT;
	CLASS Date 大分類;
	VAR 點擊數;
	TYPES () 大分類;
	OUTPUT OUT=CLC_FIG_ITMD SUM='點擊數'N;
RUN;
%_eg_conditional_dropds(TMP_3)
DATA CLC_FIG_ITMD (DROP=大分類_TMP);
	RETAIN Date 大分類 點擊數;
	FORMAT 大分類 &ctg_ln Date $45.;
	SET CLC_FIG_ITMD(DROP=_FREQ_ _TYPE_ Date RENAME=(大分類=大分類_TMP));
	Date=CATX(' ', STRIP(PUT(&INI_DATE, NLDATEMDL.)),'到', STRIP(PUT(&LAST_DATE, NLDATEMDL.)));
	IF 大分類_TMP EQ "" THEN 大分類="總和";
	ELSE 大分類=大分類_TMP;
RUN;
PROC SORT DATA=CLC_FIG_ITMD;
	BY Date DESCENDING '點擊數'N;
RUN;
PROC SQL NOPRINT;
	CREATE TABLE CLC_FIG_ITMD2 AS
	SELECT Date AS '日期'N, 大分類, 點擊數, 點擊數/MAX(點擊數) AS '佔比'N FORMAT=PERCENT8.2 FROM CLC_FIG_ITMD;
	SELECT COUNT(*) INTO: f_n FROM CLC_FIG_ITMD;
QUIT;
DATA CLC_FIG_TMP1;
	SET CLC_FIG_ITMD2;
	IF MOD(&f_n,2) EQ 0 THEN IF _N_ LE (&f_n/2);
	ELSE IF _N_ LE ROUND(&f_n/2);
RUN;
DATA CLC_FIG_TMP2;
	SET CLC_FIG_ITMD2;
	IF MOD(&f_n,2) EQ 0 THEN IF _N_ GT (&f_n/2);
	ELSE IF _N_ GT ROUND(&f_n/2);
RUN;
DATA CLC_FIG;
	MERGE CLC_FIG_TMP1 CLC_FIG_TMP2(RENAME=(日期='日期.'N 大分類='大分類.'N 點擊數='點擊數.'N 佔比='佔比.'N));
RUN;
PROC SQL;
	DROP TABLE CLC_FIG_TMP1, CLC_FIG_TMP2, CLC_FIG_ITMD, CLC_FIG_ITMD2;
QUIT;
%MEND;
/*
	CLCDGenerator is for creating table of clikcing times on daily base.
*/
%MACRO CLCDGenerator;
%_eg_conditional_dropds(TMP_3)
PROC SQL NOPRINT;
	CREATE TABLE TMP_3 AS SELECT Date AS '日期'N, 小分類 AS '頁籤'N, 點擊數 FROM TMP_2 WHERE 大分類 LIKE '%頁籤%';
	%LET ctg_ln=;
	SELECT MAX(LENGTH(STRIP(頁籤))) INTO: ctg_ln FROM TMP_3;
	%LET ctg_ln=$%SYSFUNC(STRIP(&ctg_ln)).;
QUIT;
PROC MEANS DATA=TMP_3 SUM NOPRINT;
	CLASS 日期 頁籤;
	VAR 點擊數;
	TYPES 日期 日期*頁籤;
	OUTPUT OUT=CLC_TABS_FIG_ITMD SUM='點擊數'N;
RUN;
%_eg_conditional_dropds(TMP_3)
DATA CLC_TABS_FIG_ITMD(DROP=tab_tmp);
	RETAIN 日期 頁籤 點擊數;
	FORMAT 頁籤 &ctg_ln;
	SET CLC_TABS_FIG_ITMD(DROP=_FREQ_ _TYPE_ RENAME=(頁籤=tab_tmp));
	IF tab_tmp EQ '' THEN 頁籤="總和";
	ELSE 頁籤=tab_tmp;
RUN;
PROC SQL;
	CREATE TABLE CLC_TABS_FIG AS
		SELECT 日期, 頁籤, 點擊數, 點擊數/MAX(點擊數) FORMAT=PERCENT8.2 AS '佔比'N FROM CLC_TABS_FIG_ITMD;
	DROP TABLE CLC_TABS_FIG_ITMD;
QUIT;
PROC SORT DATA=CLC_TABS_FIG;
	BY '日期'N DESCENDING '點擊數'N;
RUN;
%MEND;
/*
	CLCTRGenerator is for creating table of clicking times based on time range.
*/
%MACRO CLCTRGenerator;
%_eg_conditional_dropds(TMP_3)
PROC SQL NOPRINT;
	CREATE TABLE TMP_3 AS SELECT Date AS '日期'N, 小分類 AS '頁籤'N, 點擊數 FROM TMP_2 WHERE 大分類 LIKE '%頁籤%';
	%LET ctg_ln=;
	SELECT MAX(LENGTH(STRIP(頁籤))) INTO: ctg_ln FROM TMP_3;
	%LET ctg_ln=$%SYSFUNC(STRIP(&ctg_ln)).;
QUIT;
PROC MEANS DATA=TMP_3 SUM NOPRINT;
	CLASS 日期 頁籤;
	VAR 點擊數;
	TYPES () 頁籤;
	OUTPUT OUT=CLC_TABS_FIG_ITMD SUM='點擊數'N;
RUN;
%_eg_conditional_dropds(TMP_3)
DATA CLC_TABS_FIG_ITMD(DROP=tab_tmp);
	RETAIN 日期 頁籤 點擊數;
	FORMAT 頁籤 &ctg_ln 日期 $45.;
	SET CLC_TABS_FIG_ITMD(DROP=_FREQ_ _TYPE_ 日期 RENAME=(頁籤=tab_tmp));
	日期=CATX(' ', STRIP(PUT(&INI_DATE, NLDATEMDL.)),'到', STRIP(PUT(&LAST_DATE, NLDATEMDL.)));
	IF tab_tmp EQ '' THEN 頁籤="總和";
	ELSE 頁籤=tab_tmp;
RUN;
PROC SQL;
	CREATE TABLE CLC_TABS_FIG AS
		SELECT 日期, 頁籤, 點擊數, 點擊數/MAX(點擊數) FORMAT=PERCENT8.2 AS '佔比'N FROM CLC_TABS_FIG_ITMD;
	DROP TABLE CLC_TABS_FIG_ITMD;
QUIT;
PROC SORT DATA=CLC_TABS_FIG;
	BY '日期'N DESCENDING '點擊數'N;
RUN;
%MEND;
/*
	DYCLCTileChart is for creating report objects of one step.
	The argument, tp, stands for time range.
	tp1 represents the beginning date.
	tp2 represents the ending date.
*/
%MACRO DYCLCTileChart(tp1, tp2);
%_eg_conditional_dropds(TMP2)
%_eg_conditional_dropds(CLC_FIG)
%_eg_conditional_dropds(CLC_TABS_FIG)
ODS PDF SELECT NONE;
/*
	Combination of the stats of click and clicmp.
*/
PROC SQL;
	CREATE TABLE TMP_2 AS
		SELECT * FROM TMP_1
		WHERE Explicitcategory NE '全區塊' AND Implicitcategory NOT IN ('', '全版位') AND RegOrNot = 'U' 
				AND Date ^= . AND (Date BETWEEN &tp1 AND &tp2 ) AND Device='不分';
QUIT;
/*
	Rename the variables for the report.
*/
PROC DATASETS LIB=WORK NOLIST;
	MODIFY TMP_2;
		RENAME CLCtimes='點擊數'N Implicitcategory='大分類'N Explicitcategory='小分類'N;
QUIT;
/*
	Calculation of clicking time on a specific day based on Explicitcategory, 大分類 and not on the category.
*/
%IF %SYSFUNC(DATDIF(&tp1 ,&tp2 ,'ACT/ACT')) EQ 0 %THEN %DO;
	%CLCEDGenerator %CLCDGenerator %END;
%ELSE %DO; %CLCETRGenerator %CLCTRGenerator %END;
/*
	Generation of the document
*/
GOPTIONS RESET=ALL DEVICE=JAVA NOBORDER;
%IF %SYSFUNC(DATDIF(&tp1 ,&tp2 ,'ACT/ACT')) EQ 0 %THEN %DO;
	TITLE1 "%SYSFUNC(STRIP(%SYSFUNC(PUTN(&i, NLDATEW.)))) 點擊分布" C=BLACK; %END;
%ELSE %DO; TITLE1 "%SYSFUNC(STRIP(%SYSFUNC(PUTN(&INI_DATE, NLDATEW.))))到%SYSFUNC(STRIP(%SYSFUNC(PUTN(&LAST_DATE, NLDATEW.)))) 點擊分布" C=BLACK; %END;

TITLE2 "大分類" C=BLUE;
PROC GTILE DATA=TMP_2;
	/*FLOW CLCtimes TILEBY=(Implicitcategory Explicitcategory)/COLORVAR=CLCtimes;*/
	TILE 點擊數 TILEBY=(大分類)/
		COLORVAR=點擊數
		COLORRAMP=(CXBECAE2 CXD3F725 CXFF4826)
		COLORPOINTS=(0 0.5 1);
	RUN;
QUIT;
TITLE1; TITLE2;
PROC GTILE DATA=TMP_2;
	TITLE2 "小分類" C=BLUE;
	TILE 點擊數 TILEBY=(大分類 小分類)/
		COLORVAR=點擊數
		COLORRAMP=(CXBECAE2 CXD3F725 CXFF4826)
		COLORPOINTS=(0 0.5 1);
	RUN;
QUIT;
TITLE2;
ODS TAGSETS.SASREPORT13(ID=EGSR) SELECT NONE;
ODS PDF SELECT ALL;
ODS PDF STARTPAGE=NOW;
ODS PDF STARTPAGE=NEVER;
	%IF %SYSFUNC(DATDIF(&tp1,&tp2, 'ACT/ACT')) EQ 0 %THEN %DO;
		TITLE1 "%SYSFUNC(STRIP(%SYSFUNC(PUTN(&i, NLDATEW.)))) 點擊分布" C=BLACK; %END;
	%ELSE %DO; TITLE1 "%SYSFUNC(STRIP(%SYSFUNC(PUTN(&INI_DATE, NLDATEW.))))到%SYSFUNC(STRIP(%SYSFUNC(PUTN(&LAST_DATE, NLDATEW.)))) 點擊分布" C=BLACK; %END;
	TITLE2 "大分類" C=BLACK;
ODS PDF BOOKMARKGEN=YES;
%IF %SYSFUNC(DATDIF(&tp1,&tp2, 'ACT/ACT')) EQ 0 %THEN %DO;
ODS PROCLABEL="%SYSFUNC(STRIP(%SYSFUNC(PUTN(&i, NLDATEL.))))"; %END;
%ELSE %DO; ODS PROCLABEL="%SYSFUNC(STRIP(%SYSFUNC(PUTN(&INI_DATE, NLDATEL.))))到%SYSFUNC(STRIP(%SYSFUNC(PUTN(&LAST_DATE, NLDATEL.))))"; %END;
	PROC PRINT DATA=CLC_FIG NOOBS CONTENTS="大分類";
	QUIT;
ODS PDF BOOKMARKGEN=NO;
	TITLE1; TITLE2; /*Empty the titles*/
	GOPTIONS RESET=ALL DEVICE=ACTXIMG NOBORDER;
	PROC GTILE DATA=TMP_2;
		/*FLOW CLCtimes TILEBY=(Implicitcategory Explicitcategory)/COLORVAR=CLCtimes;*/
		TILE 點擊數 TILEBY=(大分類)/
			COLORVAR=點擊數
			COLORRAMP=(CXBECAE2 CXD3F725 CXFF4826)
			COLORPOINTS=(0 0.5 1);
		RUN;
	QUIT;
ODS PDF STARTPAGE=NOW;
ODS PDF STARTPAGE=NEVER;
	TITLE2 "小分類" C=BLUE;
	PROC PRINT DATA=CLC_TABS_FIG NOOBS CONTENTS="小分類";
	QUIT;
	TITLE2; /*Empty the title*/
	PROC GTILE DATA=TMP_2;
		TILE 點擊數 TILEBY=(大分類 小分類)/
			COLORVAR=點擊數
			COLORRAMP=(CXBECAE2 CXD3F725 CXFF4826)
			COLORPOINTS=(0 0.5 1);
		RUN;
	QUIT;
ODS TAGSETS.SASREPORT13(ID=EGSR) SELECT ALL;
%_eg_conditional_dropds(TMP2);
%_eg_conditional_dropds(CLC_FIG)
%_eg_conditional_dropds(CLC_TABS_FIG)
%MEND;
/*
	DYCLCReport is for creating ultimate outcomes of the clicking-times report.
*/
%MACRO DYCLCReport;
ODS PDF FILE='$HOME/CLC_REPROT.pdf';
ODS TRACE ON/ LABEL;
OPTIONS LOCALE=zh_TW;
%IF &CLCALL EQ 1 %THEN
%DO;
	%DO i=&INI_DATE %TO %EVAL(&LAST_DATE +1) %BY 1;
		%IF &i NE &LAST_DATE AND &i GT &LAST_DATE %THEN %DO;
			%DYCLCTileChart(&INI_DATE, &LAST_DATE) %END;
		%ELSE %DO;
			%DYCLCTileChart(&i, &i) %END;
	%END;
%END;
%ELSE
%DO;
	%DYCLCTileChart(&LAST_DATE, &LAST_DATE)
%END;
ODS PDF CLOSE;
OPTIONS LOCALE=en_US;
%MEND;
