%LET RC_Note_Str1 = %STR(1. �L�k�bETU_APP��쪺����U�ȥثe�Һ⬰�N�U�ȡC);
/*
	ScopeDefine is for defining the area which appears on chart.
*/
%MACRO ScopeDefine(status_row);
	%LET column=; %LET row=;
	%IF &status_row EQ 1 %THEN %DO; %LET column=1; %LET row=1; %END;
	%ELSE %IF &status_row EQ 2 %THEN %DO; %LET column=2; %LET row=2; %END;
	%ELSE %DO; %LET column=2; %LET row=2; %END;
%MEND;
%MACRO RCTRChartGenerator();
OPTIONS LOCALE=zh_TW;
%_eg_conditional_dropds(M_O_O_STATS)
%_eg_conditional_dropds(M_N_O_STATS)
PROC MEANS DATA=WORK.M_O_O_SUMMARY SUM NOPRINT;
	CLASS Date 'OrderStatus'N eraddsc;
	VAR '�P�⦬�J'N '�ӫ~�ƶq'N '�q���'N;
	TYPES ()*'OrderStatus'N eraddsc*'OrderStatus'N;
	OUTPUT OUT=M_O_O_STATS SUM='�P�⦬�J'N '�ӫ~�ƶq'N '�q���'N;
RUN;
/*Fetch the related length info for the latter recreation of data.*/
PROC SQL NOPRINT;
	SELECT length  INTO: VARN1-:VARN2 FROM DICTIONARY.COLUMNS 
				WHERE LIBNAME='WORK' AND MEMNAME='M_O_O_SUMMARY' AND VARNUM BETWEEN 2 AND 3
				ORDER BY name;
QUIT;
%LET VARN1=$&VARN1..; %LET VARN2=$&VARN2..;
/*Generate the stats.*/
DATA M_O_O_STATS(DROP=Date_TMP OrderStatusTMP eraddsc_tmp);
	RETAIN '���'N '����'N '�q�檬�p'N '�P�⦬�J'N '�ӫ~�ƶq'N '�q���'N;
	FORMAT '���'N $36. '�q�檬�p'N &VARN1 '����'N &VARN2 '�P�⦬�J'N NLMNITWD22.0 '�ӫ~�ƶq'N '�q���'N COMMA9.0;
	SET M_O_O_STATS (DROP=_TYPE_ _FREQ_ RENAME=(Date=Date_TMP 'OrderStatus'N=OrderStatusTMP eraddsc=eraddsc_tmp));
	IF Date_TMP NE . THEN '���'N=PUT(Date_TMP, NLDATEW.); ELSE DO; '���'N=CATS(PUT(&INI_DATE, NLDATE.),'-', PUT(&LAST_DATE, NLDATE.)); END;
	IF OrderStatusTMP NE "" THEN '�q�檬�p'N=OrderStatusTMP; ELSE '�q�檬�p'N="��";
	IF eraddsc_tmp NE "" THEN '����'N=eraddsc_tmp; ELSE '����'N="������";
RUN;
%SYMDEL VARN1 VARN2;
/*
	Whole-time range stats for the new customers.
*/
OPTIONS LOCALE=zh_TW;
PROC MEANS DATA=WORK.M_N_O_SUMMARY SUM NOPRINT;
	CLASS Date 'OrderStatus'N eraddsc;
	VAR '�P�⦬�J'N '�ӫ~�ƶq'N '�q���'N;
	TYPES ()*'OrderStatus'N eraddsc*'OrderStatus'N;
	OUTPUT OUT=M_N_O_STATS SUM='�P�⦬�J'N '�ӫ~�ƶq'N '�q���'N;
RUN;
/*Fetch the related length info for the latter recreation of data.*/
PROC SQL NOPRINT;
	SELECT length INTO :VARN1-:VARN2 FROM DICTIONARY.COLUMNS 
				WHERE LIBNAME='WORK' AND MEMNAME='M_N_O_STATS' AND VARNUM BETWEEN 2 AND 3
				ORDER BY name;
QUIT;
%LET VARN1=$&VARN1..; %LET VARN2=$&VARN2..;
/*Generate the stats.*/
DATA M_N_O_STATS(DROP=Date_TMP OrderStatusTMP eraddsc_tmp);
	RETAIN '���'N '����'N '�q�檬�p'N '�P�⦬�J'N '�ӫ~�ƶq'N '�q���'N;
	FORMAT '���'N $36. '�q�檬�p'N &VARN1 '����'N &VARN2 '�P�⦬�J'N NLMNITWD22.0 '�ӫ~�ƶq'N '�q���'N COMMA9.0;
	SET M_N_O_STATS (DROP=_TYPE_ _FREQ_ RENAME=(Date=Date_TMP 'OrderStatus'N=OrderStatusTMP eraddsc=eraddsc_tmp));
	IF Date_TMP NE . THEN '���'N=PUT(Date_TMP, NLDATEW.); ELSE DO; '���'N=CATS(PUT(&INI_DATE, NLDATE.),'-', PUT(&LAST_DATE, NLDATE.)); END;
	IF OrderStatusTMP NE "" THEN '�q�檬�p'N=OrderStatusTMP; ELSE '�q�檬�p'N="��";
	IF eraddsc_tmp NE "" THEN '����'N=eraddsc_tmp; ELSE '����'N="������";
RUN;
%SYMDEL VARN1 VARN2;
OPTIONS LOCALE=en_US;
/*
	Generate the whole-range stats based on all app and blocks.
*/
PROC SQL;
	CREATE TABLE All_APP_N_O_R AS /*N_O_R stands for revenue from the old and new customers.*/
	SELECT '���'N, "�^�Y��" FORMAT=$9. AS '�Ȥ�����'N, '����'N, '�q�檬�p'N, '�P�⦬�J'N, '�ӫ~�ƶq'N, '�q���'N,  
			'�P�⦬�J'N/'�q���'N AS '�����q����ȡ]AOV�^'N FORMAT=NLMNITWD22.2, '�ӫ~�ƶq'N/'�q���'N AS '�����q��q�]AOS�^'N FORMAT=COMMA9.2
	FROM M_O_O_STATS
	UNION CORR ALL
	SELECT '���'N, "�s��" FORMAT=$9. AS '�Ȥ�����'N, '����'N, '�q�檬�p'N, '�P�⦬�J'N, '�ӫ~�ƶq'N, '�q���'N, 
			'�P�⦬�J'N/'�q���'N AS '�����q����ȡ]AOV�^'N FORMAT=NLMNITWD22.2, '�ӫ~�ƶq'N/'�q���'N AS '�����q��q�]AOS�^'N FORMAT=COMMA9.2
	FROM M_N_O_STATS;
QUIT;
PROC SORT DATA=All_APP_N_O_R;
	BY '���'N '����'N;
RUN;
%_eg_conditional_dropds(M_O_O_STATS)
%_eg_conditional_dropds(M_N_O_STATS)
/*
	Generate the pie chart based on the previous dataset, All_APP_N_O_R.
*/
%_eg_conditional_dropds(All_APP_N_O_R_TMP)
%_eg_conditional_dropds(Personal_N_O_R_TMP)
%_eg_conditional_dropds(HotSale_N_O_R_TMP)
%_eg_conditional_dropds(Other_N_O_R_TMP)
PROC SQL NOPRINT;
	CREATE TABLE All_APP_N_O_R_TMP AS SELECT * FROM All_APP_N_O_R WHERE '����'N = "������";
	CREATE TABLE Personal_N_O_R_TMP AS SELECT * FROM All_APP_N_O_R WHERE '����'N IN ('�Y�ɷs�~', '�n�d�ӫ~', '�u�`�ӫ~', '���߰ӫ~', '�M�ݱ���');
	CREATE TABLE HotSale_N_O_R_TMP AS SELECT * FROM All_APP_N_O_R WHERE '����'N IN ('�t�ױ��˰ӫ~', '�F����˰ӫ~');
	CREATE TABLE TOP10_N_O_R_TMP AS SELECT * FROM All_APP_N_O_R WHERE '����'N LIKE '%TOP10%';
	CREATE TABLE Other_N_O_R_TMP AS SELECT * FROM All_APP_N_O_R WHERE '����'N 
										NOT IN ('������', '�Y�ɷs�~', '�n�d�ӫ~', '�u�`�ӫ~', '���߰ӫ~', '�M�ݱ���', '�t�ױ��˰ӫ~', '�F����˰ӫ~')
										AND '����'N NOT LIKE '%TOP10%';
	SELECT COUNT(DISTINCT '�q�檬�p'N) INTO: All_row FROM All_APP_N_O_R_TMP;
QUIT;
%GLOBAL column; %GLOBAL row;
%ScopeDefine(&All_row) %SYMDEL All_row;
GOPTIONS RESET=ALL DEVICE=SVG BORDER; OPTIONS LOCALE=zh_TW;
TITLE1 %SYSFUNC(COMPRESS(%SYSFUNC(CATS(%SYSFUNC(PUTN(&INI_DATE, NLDATEW.)),��, %SYSFUNC(PUTN(&LAST_DATE, NLDATEW.)), �s�«Ȥ��)))); OPTIONS LOCALE=en_US;
TITLE2 ��APP;
PATTERN1 C=CX4965B0; PATTERN2 C=CXFF7B58; PATTERN3 C=CX95B60E;
PROC GCHART DATA=All_APP_N_O_R_TMP;
	PIE '�Ȥ�����'N/SUMVAR='�P�⦬�J'N GROUP='�q�檬�p'N MIDPOINTS="�^�Y��" "�s��"
		 ACROSS=&column DOWN=&row PERCENT=arrow COUTLINE=CX7C5C00 NOHEADING;
	RUN;
QUIT;
TITLE1; TITLE2;
PROC SQL;
	SELECT * FROM All_APP_N_O_R_TMP;
QUIT;
%_eg_conditional_dropds(All_APP_N_O_R_TMP)
%LET tmp_ftnt_1=%NRSTR(��1�G�Ӹ`���ϥu�e�{�u�b�v�q�檺�����C);
TITLE2 �M�ݱ��˻P���n��; FOOTNOTE1 &tmp_ftnt_1;
PROC GCHART DATA=Personal_N_O_R_TMP(WHERE=('�q�檬�p'N='�b'));
	PIE '�Ȥ�����'N/SUMVAR='�P�⦬�J'N VALUE=NONE SLICE=OUTSIDE OTHER=0
		MIDPOINTS="�^�Y��" "�s��" PERCENT=arrow COUTLINE=CX7C5C00 NOHEADING
		DETAIL="����"N DETAIL_PERCENT=BEST DETAIL_VALUE=NONE DETAIL_THRESHOLD=0.1;
	RUN;
QUIT;
TITLE2; FOOTNOTE1;
PROC GCHART DATA=Personal_N_O_R_TMP;
	VBAR '����'N/SUMVAR='�P�⦬�J'N GROUP='�q�檬�p'N SUBGROUP='�Ȥ�����'N SPACE=0;
	RUN;
QUIT;
PROC SQL;
	SELECT * FROM Personal_N_O_R_TMP;
QUIT;
%_eg_conditional_dropds(Personal_N_O_R_TMP)
TITLE2 ������; FOOTNOTE1 &tmp_ftnt_1;
PROC GCHART DATA=HotSale_N_O_R_TMP(WHERE=('�q�檬�p'N='�b'));
	PIE '�Ȥ�����'N/SUMVAR='�P�⦬�J'N VALUE=NONE SLICE=OUTSIDE OTHER=0
		MIDPOINTS="�^�Y��" "�s��" PERCENT=arrow COUTLINE=CX7C5C00 NOHEADING
		DETAIL="����"N DETAIL_PERCENT=BEST DETAIL_VALUE=NONE DETAIL_THRESHOLD=0.1;
	RUN;
QUIT;
TITLE2; FOOTNOTE1;
PROC GCHART DATA=HotSale_N_O_R_TMP;
	VBAR '����'N/SUMVAR='�P�⦬�J'N GROUP='�q�檬�p'N SUBGROUP='�Ȥ�����'N SPACE=0;
	RUN;
QUIT;
PROC SQL;
	SELECT * FROM HotSale_N_O_R_TMP;
QUIT;
%_eg_conditional_dropds(HotSale_N_O_R_TMP)
TITLE2 TOP10; FOOTNOTE1 &tmp_ftnt_1;
PROC GCHART DATA=TOP10_N_O_R_TMP(WHERE=('�q�檬�p'N='�b'));
	PIE '�Ȥ�����'N/SUMVAR='�P�⦬�J'N VALUE=NONE SLICE=OUTSIDE OTHER=0
		MIDPOINTS="�^�Y��" "�s��" PERCENT=arrow COUTLINE=CX7C5C00 NOHEADING
		DETAIL="����"N DETAIL_PERCENT=BEST DETAIL_VALUE=NONE DETAIL_THRESHOLD=0.1;
	RUN;
QUIT;
TITLE2; FOOTNOTE1;
PROC GCHART DATA=TOP10_N_O_R_TMP;
	VBAR '����'N/SUMVAR='�P�⦬�J'N GROUP='�q�檬�p'N SUBGROUP='�Ȥ�����'N SPACE=0;
	RUN;
QUIT;
PROC SQL;
	SELECT * FROM TOP10_N_O_R_TMP;
QUIT;
%_eg_conditional_dropds(TOP10_N_O_R_TMP)
TITLE2 ��l����; FOOTNOTE1 &tmp_ftnt_1;
%LET tmp_ftnt_2 = %NRSTR(��2�G����p��1%�N���|���);
FOOTNOTE2 &tmp_ftnt_2;
PROC GCHART DATA=Other_N_O_R_TMP(WHERE=('�q�檬�p'N='�b'));
	PIE '�Ȥ�����'N/SUMVAR='�P�⦬�J'N VALUE=NONE SLICE=OUTSIDE OTHER=0
		MIDPOINTS="�^�Y��" "�s��" PERCENT=arrow COUTLINE=CX7C5C00 NOHEADING
		DETAIL="����"N DETAIL_PERCENT=BEST DETAIL_VALUE=NONE DETAIL_THRESHOLD=1;
	RUN;
QUIT;
TITLE2; FOOTNOTE1; FOOTNOTE2;
PROC GCHART DATA=Other_N_O_R_TMP;
	VBAR '����'N/SUMVAR='�P�⦬�J'N GROUP='�q�檬�p'N SUBGROUP='�Ȥ�����'N SPACE=0;
	RUN;
QUIT;
%SYMDEL tmp_ftnt_1 tmp_ftnt_2;
PROC SQL;
	SELECT * FROM Other_N_O_R_TMP;
QUIT;
%_eg_conditional_dropds(Other_N_O_R_TMP) %SYMDEL column row;
%MEND;
%MACRO RCDYChartGenerator(dy);
OPTIONS LOCALE=zh_TW;
%_eg_conditional_dropds(M_O_O_STATS)
%_eg_conditional_dropds(M_N_O_STATS)
PROC MEANS DATA=WORK.M_O_O_SUMMARY(WHERE=(Date=&dy)) SUM NOPRINT;
	CLASS Date 'OrderStatus'N eraddsc;
	VAR '�P�⦬�J'N '�ӫ~�ƶq'N '�q���'N;
	TYPES ()*'OrderStatus'N Date*eraddsc*'OrderStatus'N;
	OUTPUT OUT=M_O_O_STATS SUM='�P�⦬�J'N '�ӫ~�ƶq'N '�q���'N;
RUN;
/*Fetch the related length info for the latter recreation of data.*/
PROC SQL NOPRINT;
	SELECT length  INTO: VARN1-:VARN2 FROM DICTIONARY.COLUMNS 
				WHERE LIBNAME='WORK' AND MEMNAME='M_O_O_SUMMARY' AND VARNUM BETWEEN 2 AND 3
				ORDER BY name;
QUIT;
%LET VARN1=$&VARN1..; %LET VARN2=$&VARN2..;
/*Generate the stats.*/
DATA M_O_O_STATS(DROP=Date_TMP OrderStatusTMP eraddsc_tmp);
	RETAIN '���'N '����'N '�q�檬�p'N '�P�⦬�J'N '�ӫ~�ƶq'N '�q���'N;
	FORMAT '���'N $36. '�q�檬�p'N &VARN1 '����'N &VARN2 '�P�⦬�J'N NLMNITWD22.0 '�ӫ~�ƶq'N '�q���'N COMMA9.0;
	SET M_O_O_STATS (DROP=_TYPE_ _FREQ_ RENAME=(Date=Date_TMP 'OrderStatus'N=OrderStatusTMP eraddsc=eraddsc_tmp));
	'���'N=CATS(PUT(&dy, NLDATEW.));
	IF OrderStatusTMP NE "" THEN '�q�檬�p'N=OrderStatusTMP; ELSE '�q�檬�p'N="��";
	IF eraddsc_tmp NE "" THEN '����'N=eraddsc_tmp; ELSE '����'N="������";
RUN;
%SYMDEL VARN1 VARN2;
/*
	Whole-time range stats for the new customers.
*/
OPTIONS LOCALE=zh_TW;
PROC MEANS DATA=WORK.M_N_O_SUMMARY(WHERE=(Date=&dy)) SUM NOPRINT;
	CLASS Date 'OrderStatus'N eraddsc;
	VAR '�P�⦬�J'N '�ӫ~�ƶq'N '�q���'N;
	TYPES ()*'OrderStatus'N Date*eraddsc*'OrderStatus'N;
	OUTPUT OUT=M_N_O_STATS SUM='�P�⦬�J'N '�ӫ~�ƶq'N '�q���'N;
RUN;
/*Fetch the related length info for the latter recreation of data.*/
PROC SQL NOPRINT;
	SELECT length INTO :VARN1-:VARN2 FROM DICTIONARY.COLUMNS 
				WHERE LIBNAME='WORK' AND MEMNAME='M_N_O_STATS' AND VARNUM BETWEEN 2 AND 3
				ORDER BY name;
QUIT;
%LET VARN1=$&VARN1..; %LET VARN2=$&VARN2..;
/*Generate the stats.*/
DATA M_N_O_STATS(DROP=Date_TMP OrderStatusTMP eraddsc_tmp);
	RETAIN '���'N '����'N '�q�檬�p'N '�P�⦬�J'N '�ӫ~�ƶq'N '�q���'N;
	FORMAT '���'N $36. '�q�檬�p'N &VARN1 '����'N &VARN2 '�P�⦬�J'N NLMNITWD22.0 '�ӫ~�ƶq'N '�q���'N COMMA9.0;
	SET M_N_O_STATS (DROP=_TYPE_ _FREQ_ RENAME=(Date=Date_TMP 'OrderStatus'N=OrderStatusTMP eraddsc=eraddsc_tmp));
	'���'N=CATS(PUT(&dy, NLDATEW.));
	IF OrderStatusTMP NE "" THEN '�q�檬�p'N=OrderStatusTMP; ELSE '�q�檬�p'N="��";
	IF eraddsc_tmp NE "" THEN '����'N=eraddsc_tmp; ELSE '����'N="������";
RUN;
%SYMDEL VARN1 VARN2;
OPTIONS LOCALE=en_US;
/*
	Generate the whole-range stats based on all app and blocks.
*/
PROC SQL;
	CREATE TABLE All_APP_N_O_R AS /*N_O_R stands for revenue from the old and new customers.*/
	SELECT '���'N, "�^�Y��" FORMAT=$9. AS '�Ȥ�����'N, '����'N, '�q�檬�p'N, '�P�⦬�J'N, '�ӫ~�ƶq'N, '�q���'N,  
			'�P�⦬�J'N/'�q���'N AS '�����q����ȡ]AOV�^'N FORMAT=NLMNITWD22.2, '�ӫ~�ƶq'N/'�q���'N AS '�����q��q�]AOS�^'N FORMAT=COMMA9.2
	FROM M_O_O_STATS
	UNION CORR ALL
	SELECT '���'N, "�s��" FORMAT=$9. AS '�Ȥ�����'N, '����'N, '�q�檬�p'N, '�P�⦬�J'N, '�ӫ~�ƶq'N, '�q���'N, 
			'�P�⦬�J'N/'�q���'N AS '�����q����ȡ]AOV�^'N FORMAT=NLMNITWD22.2, '�ӫ~�ƶq'N/'�q���'N AS '�����q��q�]AOS�^'N FORMAT=COMMA9.2
	FROM M_N_O_STATS;
QUIT;
PROC SORT DATA=All_APP_N_O_R;
	BY '���'N '����'N;
RUN;
%_eg_conditional_dropds(M_O_O_STATS)
%_eg_conditional_dropds(M_N_O_STATS)
/*
	Generate the pie chart based on the previous dataset, All_APP_N_O_R.
*/
%_eg_conditional_dropds(All_APP_N_O_R_TMP)
%_eg_conditional_dropds(Personal_N_O_R_TMP)
%_eg_conditional_dropds(HotSale_N_O_R_TMP)
%_eg_conditional_dropds(Other_N_O_R_TMP)
PROC SQL NOPRINT;
	CREATE TABLE All_APP_N_O_R_TMP AS SELECT * FROM All_APP_N_O_R WHERE '����'N = "������";
	CREATE TABLE Personal_N_O_R_TMP AS SELECT * FROM All_APP_N_O_R WHERE '����'N IN ('�Y�ɷs�~', '�n�d�ӫ~', '�u�`�ӫ~', '���߰ӫ~', '�M�ݱ���');
	CREATE TABLE HotSale_N_O_R_TMP AS SELECT * FROM All_APP_N_O_R WHERE '����'N IN ('�t�ױ��˰ӫ~', '�F����˰ӫ~');
	CREATE TABLE TOP10_N_O_R_TMP AS SELECT * FROM All_APP_N_O_R WHERE '����'N LIKE '%TOP10%';
	CREATE TABLE Other_N_O_R_TMP AS SELECT * FROM All_APP_N_O_R WHERE '����'N 
										NOT IN ('������', '�Y�ɷs�~', '�n�d�ӫ~', '�u�`�ӫ~', '���߰ӫ~', '�M�ݱ���', '�t�ױ��˰ӫ~', '�F����˰ӫ~')
										AND '����'N NOT LIKE '%TOP10%';
	SELECT COUNT(DISTINCT '�q�檬�p'N) INTO: All_row FROM All_APP_N_O_R_TMP;
QUIT;
%GLOBAL column; %GLOBAL row;
%ScopeDefine(&All_row) %SYMDEL All_row;
GOPTIONS RESET=ALL DEVICE=SVG BORDER; OPTIONS LOCALE=zh_TW;
TITLE1 %SYSFUNC(COMPRESS(%SYSFUNC(CATS(%SYSFUNC(PUTN(&dy, NLDATEW.)), �s�«Ȥ��)))); OPTIONS LOCALE=en_US;
TITLE2 ��APP;
PATTERN1 C=CX4965B0; PATTERN2 C=CXFF7B58; PATTERN3 C=CX95B60E;
PROC GCHART DATA=All_APP_N_O_R_TMP;
	PIE '�Ȥ�����'N/SUMVAR='�P�⦬�J'N GROUP='�q�檬�p'N MIDPOINTS="�^�Y��" "�s��"
		 ACROSS=&column DOWN=&row PERCENT=arrow COUTLINE=CX7C5C00 NOHEADING;
	RUN;
QUIT;
TITLE1; TITLE2;
PROC SQL;
	SELECT * FROM All_APP_N_O_R_TMP;
QUIT;
%_eg_conditional_dropds(All_APP_N_O_R_TMP)
%LET tmp_ftnt_1=%NRSTR(��1�G�Ӹ`���ϥu�e�{�u�b�v�q�檺�����C);
TITLE2 �M�ݱ��˻P���n��; FOOTNOTE1 &tmp_ftnt_1;
PROC GCHART DATA=Personal_N_O_R_TMP(WHERE=('�q�檬�p'N='�b'));
	PIE '�Ȥ�����'N/SUMVAR='�P�⦬�J'N VALUE=NONE SLICE=OUTSIDE OTHER=0
		MIDPOINTS="�^�Y��" "�s��" PERCENT=arrow COUTLINE=CX7C5C00 NOHEADING
		DETAIL="����"N DETAIL_PERCENT=BEST DETAIL_VALUE=NONE DETAIL_THRESHOLD=0.1;
	RUN;
QUIT;
TITLE2; FOOTNOTE1;
PROC GCHART DATA=Personal_N_O_R_TMP;
	VBAR '����'N/SUMVAR='�P�⦬�J'N GROUP='�q�檬�p'N SUBGROUP='�Ȥ�����'N SPACE=0;
	RUN;
QUIT;
PROC SQL;
	SELECT * FROM Personal_N_O_R_TMP;
QUIT;
%_eg_conditional_dropds(Personal_N_O_R_TMP)
TITLE2 ������; FOOTNOTE1 &tmp_ftnt_1;
PROC GCHART DATA=HotSale_N_O_R_TMP(WHERE=('�q�檬�p'N='�b'));
	PIE '�Ȥ�����'N/SUMVAR='�P�⦬�J'N VALUE=NONE SLICE=OUTSIDE OTHER=0
		MIDPOINTS="�^�Y��" "�s��" PERCENT=arrow COUTLINE=CX7C5C00 NOHEADING
		DETAIL="����"N DETAIL_PERCENT=BEST DETAIL_VALUE=NONE DETAIL_THRESHOLD=0.1;
	RUN;
QUIT;
TITLE2; FOOTNOTE1;
PROC GCHART DATA=HotSale_N_O_R_TMP;
	VBAR '����'N/SUMVAR='�P�⦬�J'N GROUP='�q�檬�p'N SUBGROUP='�Ȥ�����'N SPACE=0;
	RUN;
QUIT;
PROC SQL;
	SELECT * FROM HotSale_N_O_R_TMP;
QUIT;
%_eg_conditional_dropds(HotSale_N_O_R_TMP)
TITLE2 TOP10; FOOTNOTE1 &tmp_ftnt_1;
PROC GCHART DATA=TOP10_N_O_R_TMP(WHERE=('�q�檬�p'N='�b'));
	PIE '�Ȥ�����'N/SUMVAR='�P�⦬�J'N VALUE=NONE SLICE=OUTSIDE OTHER=0
		MIDPOINTS="�^�Y��" "�s��" PERCENT=arrow COUTLINE=CX7C5C00 NOHEADING
		DETAIL="����"N DETAIL_PERCENT=BEST DETAIL_VALUE=NONE DETAIL_THRESHOLD=0.1;
	RUN;
QUIT;
TITLE2; FOOTNOTE1;
PROC GCHART DATA=TOP10_N_O_R_TMP;
	VBAR '����'N/SUMVAR='�P�⦬�J'N GROUP='�q�檬�p'N SUBGROUP='�Ȥ�����'N SPACE=0;
	RUN;
QUIT;
PROC SQL;
	SELECT * FROM TOP10_N_O_R_TMP;
QUIT;
%_eg_conditional_dropds(TOP10_N_O_R_TMP)
TITLE2 ��l����; FOOTNOTE1 &tmp_ftnt_1;
%LET tmp_ftnt_2 = %NRSTR(��2�G����p��1%�N���|���);
FOOTNOTE2 &tmp_ftnt_2;
PROC GCHART DATA=Other_N_O_R_TMP(WHERE=('�q�檬�p'N='�b'));
	PIE '�Ȥ�����'N/SUMVAR='�P�⦬�J'N VALUE=NONE SLICE=OUTSIDE OTHER=0
		MIDPOINTS="�^�Y��" "�s��" PERCENT=arrow COUTLINE=CX7C5C00 NOHEADING
		DETAIL="����"N DETAIL_PERCENT=BEST DETAIL_VALUE=NONE DETAIL_THRESHOLD=1;
	RUN;
QUIT;
TITLE2; FOOTNOTE1; FOOTNOTE2;
PROC GCHART DATA=Other_N_O_R_TMP;
	VBAR '����'N/SUMVAR='�P�⦬�J'N GROUP='�q�檬�p'N SUBGROUP='�Ȥ�����'N SPACE=0;
	RUN;
QUIT;
%SYMDEL tmp_ftnt_1 tmp_ftnt_2;
PROC SQL;
	SELECT * FROM Other_N_O_R_TMP;
QUIT;
%_eg_conditional_dropds(Other_N_O_R_TMP) %SYMDEL column row;
%MEND;
%MACRO RCChartGenerator(tp1, tp2);
	%IF %SYSFUNC(DATDIF(&tp1 ,&tp2 ,'ACT/ACT')) EQ 0 %THEN %DO;
		%END;
	%ELSE 
	%DO; 
		%IF &RCALL EQ 1 %THEN %DO;
			%RCTRChartGenerator()
			%DO i = &tp1 %TO &tp2 %BY 1;
				%RCDYChartGenerator(&i)
			%END;
			%END;
		%ELSE %DO;
			%RCTRChartGenerator() %RCDYChartGenerator(&LAST_DATE) %END;
	%END;
%MEND;