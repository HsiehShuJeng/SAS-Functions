/*
	ActionSeparator is for observing records with different actions in convenience.
*/
%LET bk_string = %STR('�����r��1', '�����r��2','�����r��3','�����r��4','�����r��5','�����r��6','�����r��7', '�����r��8', '�����r��9');
/*
	CLCEDGenerator is for creating table of clicking-times on daily base and Excplicit category.
*/
%MACRO CLCEDGenerator;
%_eg_conditional_dropds(TMP_3)
PROC SQL NOPRINT;
	CREATE TABLE TMP_3 AS 
	SELECT Date, �j����, SUM(�I����) FORMAT=COMMA9. AS '�I����'N 
	FROM TMP_2
	GROUP BY Date, �j����;
	SELECT MAX(LENGTH(STRIP(�j����))) INTO: ctg_ln FROM TMP_3;
QUIT;
%LET ctg_ln = $%SYSFUNC(STRIP(&ctg_ln)).;
PROC MEANS DATA=TMP_3 SUM NOPRINT;
	CLASS Date �j����;
	VAR �I����;
	TYPES Date Date*�j����;
	OUTPUT OUT=CLC_FIG_ITMD SUM='�I����'N;
RUN;
%_eg_conditional_dropds(TMP_3)
DATA CLC_FIG_ITMD (DROP=�j����_TMP);
	RETAIN Date �j���� �I����;
	FORMAT �j���� &ctg_ln;
	SET CLC_FIG_ITMD(DROP=_FREQ_ _TYPE_ RENAME=(�j����=�j����_TMP));
	IF �j����_TMP EQ "" THEN �j����="�`�M";
	ELSE �j����=�j����_TMP;
RUN;
PROC SORT DATA=CLC_FIG_ITMD;
	BY Date DESCENDING '�I����'N;
RUN;
PROC SQL NOPRINT;
	CREATE TABLE CLC_FIG_ITMD2 AS
	SELECT Date AS '���'N, �j����, �I����, �I����/MAX(�I����) AS '����'N FORMAT=PERCENT8.2 FROM CLC_FIG_ITMD;
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
	MERGE CLC_FIG_TMP1 CLC_FIG_TMP2(RENAME=(���='���.'N �j����='�j����.'N �I����='�I����.'N ����='����.'N));
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
	SELECT Date, �j����, SUM(�I����) FORMAT=COMMA9. AS '�I����'N 
	FROM TMP_2
	GROUP BY Date, �j����;
	SELECT MAX(LENGTH(STRIP(�j����))) INTO: ctg_ln FROM TMP_3;
QUIT;
%LET ctg_ln = $%SYSFUNC(STRIP(&ctg_ln)).;
PROC MEANS DATA=TMP_3 SUM NOPRINT;
	CLASS Date �j����;
	VAR �I����;
	TYPES () �j����;
	OUTPUT OUT=CLC_FIG_ITMD SUM='�I����'N;
RUN;
%_eg_conditional_dropds(TMP_3)
DATA CLC_FIG_ITMD (DROP=�j����_TMP);
	RETAIN Date �j���� �I����;
	FORMAT �j���� &ctg_ln Date $45.;
	SET CLC_FIG_ITMD(DROP=_FREQ_ _TYPE_ Date RENAME=(�j����=�j����_TMP));
	Date=CATX(' ', STRIP(PUT(&INI_DATE, NLDATEMDL.)),'��', STRIP(PUT(&LAST_DATE, NLDATEMDL.)));
	IF �j����_TMP EQ "" THEN �j����="�`�M";
	ELSE �j����=�j����_TMP;
RUN;
PROC SORT DATA=CLC_FIG_ITMD;
	BY Date DESCENDING '�I����'N;
RUN;
PROC SQL NOPRINT;
	CREATE TABLE CLC_FIG_ITMD2 AS
	SELECT Date AS '���'N, �j����, �I����, �I����/MAX(�I����) AS '����'N FORMAT=PERCENT8.2 FROM CLC_FIG_ITMD;
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
	MERGE CLC_FIG_TMP1 CLC_FIG_TMP2(RENAME=(���='���.'N �j����='�j����.'N �I����='�I����.'N ����='����.'N));
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
	CREATE TABLE TMP_3 AS SELECT Date AS '���'N, �p���� AS '����'N, �I���� FROM TMP_2 WHERE �j���� LIKE '%����%';
	%LET ctg_ln=;
	SELECT MAX(LENGTH(STRIP(����))) INTO: ctg_ln FROM TMP_3;
	%LET ctg_ln=$%SYSFUNC(STRIP(&ctg_ln)).;
QUIT;
PROC MEANS DATA=TMP_3 SUM NOPRINT;
	CLASS ��� ����;
	VAR �I����;
	TYPES ��� ���*����;
	OUTPUT OUT=CLC_TABS_FIG_ITMD SUM='�I����'N;
RUN;
%_eg_conditional_dropds(TMP_3)
DATA CLC_TABS_FIG_ITMD(DROP=tab_tmp);
	RETAIN ��� ���� �I����;
	FORMAT ���� &ctg_ln;
	SET CLC_TABS_FIG_ITMD(DROP=_FREQ_ _TYPE_ RENAME=(����=tab_tmp));
	IF tab_tmp EQ '' THEN ����="�`�M";
	ELSE ����=tab_tmp;
RUN;
PROC SQL;
	CREATE TABLE CLC_TABS_FIG AS
		SELECT ���, ����, �I����, �I����/MAX(�I����) FORMAT=PERCENT8.2 AS '����'N FROM CLC_TABS_FIG_ITMD;
	DROP TABLE CLC_TABS_FIG_ITMD;
QUIT;
PROC SORT DATA=CLC_TABS_FIG;
	BY '���'N DESCENDING '�I����'N;
RUN;
%MEND;
/*
	CLCTRGenerator is for creating table of clicking times based on time range.
*/
%MACRO CLCTRGenerator;
%_eg_conditional_dropds(TMP_3)
PROC SQL NOPRINT;
	CREATE TABLE TMP_3 AS SELECT Date AS '���'N, �p���� AS '����'N, �I���� FROM TMP_2 WHERE �j���� LIKE '%����%';
	%LET ctg_ln=;
	SELECT MAX(LENGTH(STRIP(����))) INTO: ctg_ln FROM TMP_3;
	%LET ctg_ln=$%SYSFUNC(STRIP(&ctg_ln)).;
QUIT;
PROC MEANS DATA=TMP_3 SUM NOPRINT;
	CLASS ��� ����;
	VAR �I����;
	TYPES () ����;
	OUTPUT OUT=CLC_TABS_FIG_ITMD SUM='�I����'N;
RUN;
%_eg_conditional_dropds(TMP_3)
DATA CLC_TABS_FIG_ITMD(DROP=tab_tmp);
	RETAIN ��� ���� �I����;
	FORMAT ���� &ctg_ln ��� $45.;
	SET CLC_TABS_FIG_ITMD(DROP=_FREQ_ _TYPE_ ��� RENAME=(����=tab_tmp));
	���=CATX(' ', STRIP(PUT(&INI_DATE, NLDATEMDL.)),'��', STRIP(PUT(&LAST_DATE, NLDATEMDL.)));
	IF tab_tmp EQ '' THEN ����="�`�M";
	ELSE ����=tab_tmp;
RUN;
PROC SQL;
	CREATE TABLE CLC_TABS_FIG AS
		SELECT ���, ����, �I����, �I����/MAX(�I����) FORMAT=PERCENT8.2 AS '����'N FROM CLC_TABS_FIG_ITMD;
	DROP TABLE CLC_TABS_FIG_ITMD;
QUIT;
PROC SORT DATA=CLC_TABS_FIG;
	BY '���'N DESCENDING '�I����'N;
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
		WHERE Explicitcategory NE '���϶�' AND Implicitcategory NOT IN ('', '������') AND RegOrNot = 'U' 
				AND Date ^= . AND (Date BETWEEN &tp1 AND &tp2 ) AND Device='����';
QUIT;
/*
	Rename the variables for the report.
*/
PROC DATASETS LIB=WORK NOLIST;
	MODIFY TMP_2;
		RENAME CLCtimes='�I����'N Implicitcategory='�j����'N Explicitcategory='�p����'N;
QUIT;
/*
	Calculation of clicking time on a specific day based on Explicitcategory, �j���� and not on the category.
*/
%IF %SYSFUNC(DATDIF(&tp1 ,&tp2 ,'ACT/ACT')) EQ 0 %THEN %DO;
	%CLCEDGenerator %CLCDGenerator %END;
%ELSE %DO; %CLCETRGenerator %CLCTRGenerator %END;
/*
	Generation of the document
*/
GOPTIONS RESET=ALL DEVICE=JAVA NOBORDER;
%IF %SYSFUNC(DATDIF(&tp1 ,&tp2 ,'ACT/ACT')) EQ 0 %THEN %DO;
	TITLE1 "%SYSFUNC(STRIP(%SYSFUNC(PUTN(&i, NLDATEW.)))) �I������" C=BLACK; %END;
%ELSE %DO; TITLE1 "%SYSFUNC(STRIP(%SYSFUNC(PUTN(&INI_DATE, NLDATEW.))))��%SYSFUNC(STRIP(%SYSFUNC(PUTN(&LAST_DATE, NLDATEW.)))) �I������" C=BLACK; %END;

TITLE2 "�j����" C=BLUE;
PROC GTILE DATA=TMP_2;
	/*FLOW CLCtimes TILEBY=(Implicitcategory Explicitcategory)/COLORVAR=CLCtimes;*/
	TILE �I���� TILEBY=(�j����)/
		COLORVAR=�I����
		COLORRAMP=(CXBECAE2 CXD3F725 CXFF4826)
		COLORPOINTS=(0 0.5 1);
	RUN;
QUIT;
TITLE1; TITLE2;
PROC GTILE DATA=TMP_2;
	TITLE2 "�p����" C=BLUE;
	TILE �I���� TILEBY=(�j���� �p����)/
		COLORVAR=�I����
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
		TITLE1 "%SYSFUNC(STRIP(%SYSFUNC(PUTN(&i, NLDATEW.)))) �I������" C=BLACK; %END;
	%ELSE %DO; TITLE1 "%SYSFUNC(STRIP(%SYSFUNC(PUTN(&INI_DATE, NLDATEW.))))��%SYSFUNC(STRIP(%SYSFUNC(PUTN(&LAST_DATE, NLDATEW.)))) �I������" C=BLACK; %END;
	TITLE2 "�j����" C=BLACK;
ODS PDF BOOKMARKGEN=YES;
%IF %SYSFUNC(DATDIF(&tp1,&tp2, 'ACT/ACT')) EQ 0 %THEN %DO;
ODS PROCLABEL="%SYSFUNC(STRIP(%SYSFUNC(PUTN(&i, NLDATEL.))))"; %END;
%ELSE %DO; ODS PROCLABEL="%SYSFUNC(STRIP(%SYSFUNC(PUTN(&INI_DATE, NLDATEL.))))��%SYSFUNC(STRIP(%SYSFUNC(PUTN(&LAST_DATE, NLDATEL.))))"; %END;
	PROC PRINT DATA=CLC_FIG NOOBS CONTENTS="�j����";
	QUIT;
ODS PDF BOOKMARKGEN=NO;
	TITLE1; TITLE2; /*Empty the titles*/
	GOPTIONS RESET=ALL DEVICE=ACTXIMG NOBORDER;
	PROC GTILE DATA=TMP_2;
		/*FLOW CLCtimes TILEBY=(Implicitcategory Explicitcategory)/COLORVAR=CLCtimes;*/
		TILE �I���� TILEBY=(�j����)/
			COLORVAR=�I����
			COLORRAMP=(CXBECAE2 CXD3F725 CXFF4826)
			COLORPOINTS=(0 0.5 1);
		RUN;
	QUIT;
ODS PDF STARTPAGE=NOW;
ODS PDF STARTPAGE=NEVER;
	TITLE2 "�p����" C=BLUE;
	PROC PRINT DATA=CLC_TABS_FIG NOOBS CONTENTS="�p����";
	QUIT;
	TITLE2; /*Empty the title*/
	PROC GTILE DATA=TMP_2;
		TILE �I���� TILEBY=(�j���� �p����)/
			COLORVAR=�I����
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
