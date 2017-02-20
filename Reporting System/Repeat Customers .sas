%LET RC_Note_Str1 = %STR(1. 無法在ETU_APP對到的交易顧客目前皆算為就顧客。);
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
	VAR '銷售收入'N '商品數量'N '訂單數'N;
	TYPES ()*'OrderStatus'N eraddsc*'OrderStatus'N;
	OUTPUT OUT=M_O_O_STATS SUM='銷售收入'N '商品數量'N '訂單數'N;
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
	RETAIN '日期'N '版位'N '訂單狀況'N '銷售收入'N '商品數量'N '訂單數'N;
	FORMAT '日期'N $36. '訂單狀況'N &VARN1 '版位'N &VARN2 '銷售收入'N NLMNITWD22.0 '商品數量'N '訂單數'N COMMA9.0;
	SET M_O_O_STATS (DROP=_TYPE_ _FREQ_ RENAME=(Date=Date_TMP 'OrderStatus'N=OrderStatusTMP eraddsc=eraddsc_tmp));
	IF Date_TMP NE . THEN '日期'N=PUT(Date_TMP, NLDATEW.); ELSE DO; '日期'N=CATS(PUT(&INI_DATE, NLDATE.),'-', PUT(&LAST_DATE, NLDATE.)); END;
	IF OrderStatusTMP NE "" THEN '訂單狀況'N=OrderStatusTMP; ELSE '訂單狀況'N="全";
	IF eraddsc_tmp NE "" THEN '版位'N=eraddsc_tmp; ELSE '版位'N="全版位";
RUN;
%SYMDEL VARN1 VARN2;
/*
	Whole-time range stats for the new customers.
*/
OPTIONS LOCALE=zh_TW;
PROC MEANS DATA=WORK.M_N_O_SUMMARY SUM NOPRINT;
	CLASS Date 'OrderStatus'N eraddsc;
	VAR '銷售收入'N '商品數量'N '訂單數'N;
	TYPES ()*'OrderStatus'N eraddsc*'OrderStatus'N;
	OUTPUT OUT=M_N_O_STATS SUM='銷售收入'N '商品數量'N '訂單數'N;
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
	RETAIN '日期'N '版位'N '訂單狀況'N '銷售收入'N '商品數量'N '訂單數'N;
	FORMAT '日期'N $36. '訂單狀況'N &VARN1 '版位'N &VARN2 '銷售收入'N NLMNITWD22.0 '商品數量'N '訂單數'N COMMA9.0;
	SET M_N_O_STATS (DROP=_TYPE_ _FREQ_ RENAME=(Date=Date_TMP 'OrderStatus'N=OrderStatusTMP eraddsc=eraddsc_tmp));
	IF Date_TMP NE . THEN '日期'N=PUT(Date_TMP, NLDATEW.); ELSE DO; '日期'N=CATS(PUT(&INI_DATE, NLDATE.),'-', PUT(&LAST_DATE, NLDATE.)); END;
	IF OrderStatusTMP NE "" THEN '訂單狀況'N=OrderStatusTMP; ELSE '訂單狀況'N="全";
	IF eraddsc_tmp NE "" THEN '版位'N=eraddsc_tmp; ELSE '版位'N="全版位";
RUN;
%SYMDEL VARN1 VARN2;
OPTIONS LOCALE=en_US;
/*
	Generate the whole-range stats based on all app and blocks.
*/
PROC SQL;
	CREATE TABLE All_APP_N_O_R AS /*N_O_R stands for revenue from the old and new customers.*/
	SELECT '日期'N, "回頭客" FORMAT=$9. AS '客戶類型'N, '版位'N, '訂單狀況'N, '銷售收入'N, '商品數量'N, '訂單數'N,  
			'銷售收入'N/'訂單數'N AS '平均訂單價值（AOV）'N FORMAT=NLMNITWD22.2, '商品數量'N/'訂單數'N AS '平均訂單量（AOS）'N FORMAT=COMMA9.2
	FROM M_O_O_STATS
	UNION CORR ALL
	SELECT '日期'N, "新客" FORMAT=$9. AS '客戶類型'N, '版位'N, '訂單狀況'N, '銷售收入'N, '商品數量'N, '訂單數'N, 
			'銷售收入'N/'訂單數'N AS '平均訂單價值（AOV）'N FORMAT=NLMNITWD22.2, '商品數量'N/'訂單數'N AS '平均訂單量（AOS）'N FORMAT=COMMA9.2
	FROM M_N_O_STATS;
QUIT;
PROC SORT DATA=All_APP_N_O_R;
	BY '日期'N '版位'N;
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
	CREATE TABLE All_APP_N_O_R_TMP AS SELECT * FROM All_APP_N_O_R WHERE '版位'N = "全版位";
	CREATE TABLE Personal_N_O_R_TMP AS SELECT * FROM All_APP_N_O_R WHERE '版位'N IN ('即時新品', '好康商品', '季節商品', '知心商品', '專屬推薦');
	CREATE TABLE HotSale_N_O_R_TMP AS SELECT * FROM All_APP_N_O_R WHERE '版位'N IN ('宇匯推薦商品', '東科推薦商品');
	CREATE TABLE TOP10_N_O_R_TMP AS SELECT * FROM All_APP_N_O_R WHERE '版位'N LIKE '%TOP10%';
	CREATE TABLE Other_N_O_R_TMP AS SELECT * FROM All_APP_N_O_R WHERE '版位'N 
										NOT IN ('全版位', '即時新品', '好康商品', '季節商品', '知心商品', '專屬推薦', '宇匯推薦商品', '東科推薦商品')
										AND '版位'N NOT LIKE '%TOP10%';
	SELECT COUNT(DISTINCT '訂單狀況'N) INTO: All_row FROM All_APP_N_O_R_TMP;
QUIT;
%GLOBAL column; %GLOBAL row;
%ScopeDefine(&All_row) %SYMDEL All_row;
GOPTIONS RESET=ALL DEVICE=SVG BORDER; OPTIONS LOCALE=zh_TW;
TITLE1 %SYSFUNC(COMPRESS(%SYSFUNC(CATS(%SYSFUNC(PUTN(&INI_DATE, NLDATEW.)),至, %SYSFUNC(PUTN(&LAST_DATE, NLDATEW.)), 新舊客比例)))); OPTIONS LOCALE=en_US;
TITLE2 全APP;
PATTERN1 C=CX4965B0; PATTERN2 C=CXFF7B58; PATTERN3 C=CX95B60E;
PROC GCHART DATA=All_APP_N_O_R_TMP;
	PIE '客戶類型'N/SUMVAR='銷售收入'N GROUP='訂單狀況'N MIDPOINTS="回頭客" "新客"
		 ACROSS=&column DOWN=&row PERCENT=arrow COUTLINE=CX7C5C00 NOHEADING;
	RUN;
QUIT;
TITLE1; TITLE2;
PROC SQL;
	SELECT * FROM All_APP_N_O_R_TMP;
QUIT;
%_eg_conditional_dropds(All_APP_N_O_R_TMP)
%LET tmp_ftnt_1=%NRSTR(註1：細節圓餅圖只呈現「淨」訂單的分布。);
TITLE2 專屬推薦與精選好物; FOOTNOTE1 &tmp_ftnt_1;
PROC GCHART DATA=Personal_N_O_R_TMP(WHERE=('訂單狀況'N='淨'));
	PIE '客戶類型'N/SUMVAR='銷售收入'N VALUE=NONE SLICE=OUTSIDE OTHER=0
		MIDPOINTS="回頭客" "新客" PERCENT=arrow COUTLINE=CX7C5C00 NOHEADING
		DETAIL="版位"N DETAIL_PERCENT=BEST DETAIL_VALUE=NONE DETAIL_THRESHOLD=0.1;
	RUN;
QUIT;
TITLE2; FOOTNOTE1;
PROC GCHART DATA=Personal_N_O_R_TMP;
	VBAR '版位'N/SUMVAR='銷售收入'N GROUP='訂單狀況'N SUBGROUP='客戶類型'N SPACE=0;
	RUN;
QUIT;
PROC SQL;
	SELECT * FROM Personal_N_O_R_TMP;
QUIT;
%_eg_conditional_dropds(Personal_N_O_R_TMP)
TITLE2 當日熱賣; FOOTNOTE1 &tmp_ftnt_1;
PROC GCHART DATA=HotSale_N_O_R_TMP(WHERE=('訂單狀況'N='淨'));
	PIE '客戶類型'N/SUMVAR='銷售收入'N VALUE=NONE SLICE=OUTSIDE OTHER=0
		MIDPOINTS="回頭客" "新客" PERCENT=arrow COUTLINE=CX7C5C00 NOHEADING
		DETAIL="版位"N DETAIL_PERCENT=BEST DETAIL_VALUE=NONE DETAIL_THRESHOLD=0.1;
	RUN;
QUIT;
TITLE2; FOOTNOTE1;
PROC GCHART DATA=HotSale_N_O_R_TMP;
	VBAR '版位'N/SUMVAR='銷售收入'N GROUP='訂單狀況'N SUBGROUP='客戶類型'N SPACE=0;
	RUN;
QUIT;
PROC SQL;
	SELECT * FROM HotSale_N_O_R_TMP;
QUIT;
%_eg_conditional_dropds(HotSale_N_O_R_TMP)
TITLE2 TOP10; FOOTNOTE1 &tmp_ftnt_1;
PROC GCHART DATA=TOP10_N_O_R_TMP(WHERE=('訂單狀況'N='淨'));
	PIE '客戶類型'N/SUMVAR='銷售收入'N VALUE=NONE SLICE=OUTSIDE OTHER=0
		MIDPOINTS="回頭客" "新客" PERCENT=arrow COUTLINE=CX7C5C00 NOHEADING
		DETAIL="版位"N DETAIL_PERCENT=BEST DETAIL_VALUE=NONE DETAIL_THRESHOLD=0.1;
	RUN;
QUIT;
TITLE2; FOOTNOTE1;
PROC GCHART DATA=TOP10_N_O_R_TMP;
	VBAR '版位'N/SUMVAR='銷售收入'N GROUP='訂單狀況'N SUBGROUP='客戶類型'N SPACE=0;
	RUN;
QUIT;
PROC SQL;
	SELECT * FROM TOP10_N_O_R_TMP;
QUIT;
%_eg_conditional_dropds(TOP10_N_O_R_TMP)
TITLE2 其餘版位; FOOTNOTE1 &tmp_ftnt_1;
%LET tmp_ftnt_2 = %NRSTR(註2：佔比小於1%將不會顯示);
FOOTNOTE2 &tmp_ftnt_2;
PROC GCHART DATA=Other_N_O_R_TMP(WHERE=('訂單狀況'N='淨'));
	PIE '客戶類型'N/SUMVAR='銷售收入'N VALUE=NONE SLICE=OUTSIDE OTHER=0
		MIDPOINTS="回頭客" "新客" PERCENT=arrow COUTLINE=CX7C5C00 NOHEADING
		DETAIL="版位"N DETAIL_PERCENT=BEST DETAIL_VALUE=NONE DETAIL_THRESHOLD=1;
	RUN;
QUIT;
TITLE2; FOOTNOTE1; FOOTNOTE2;
PROC GCHART DATA=Other_N_O_R_TMP;
	VBAR '版位'N/SUMVAR='銷售收入'N GROUP='訂單狀況'N SUBGROUP='客戶類型'N SPACE=0;
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
	VAR '銷售收入'N '商品數量'N '訂單數'N;
	TYPES ()*'OrderStatus'N Date*eraddsc*'OrderStatus'N;
	OUTPUT OUT=M_O_O_STATS SUM='銷售收入'N '商品數量'N '訂單數'N;
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
	RETAIN '日期'N '版位'N '訂單狀況'N '銷售收入'N '商品數量'N '訂單數'N;
	FORMAT '日期'N $36. '訂單狀況'N &VARN1 '版位'N &VARN2 '銷售收入'N NLMNITWD22.0 '商品數量'N '訂單數'N COMMA9.0;
	SET M_O_O_STATS (DROP=_TYPE_ _FREQ_ RENAME=(Date=Date_TMP 'OrderStatus'N=OrderStatusTMP eraddsc=eraddsc_tmp));
	'日期'N=CATS(PUT(&dy, NLDATEW.));
	IF OrderStatusTMP NE "" THEN '訂單狀況'N=OrderStatusTMP; ELSE '訂單狀況'N="全";
	IF eraddsc_tmp NE "" THEN '版位'N=eraddsc_tmp; ELSE '版位'N="全版位";
RUN;
%SYMDEL VARN1 VARN2;
/*
	Whole-time range stats for the new customers.
*/
OPTIONS LOCALE=zh_TW;
PROC MEANS DATA=WORK.M_N_O_SUMMARY(WHERE=(Date=&dy)) SUM NOPRINT;
	CLASS Date 'OrderStatus'N eraddsc;
	VAR '銷售收入'N '商品數量'N '訂單數'N;
	TYPES ()*'OrderStatus'N Date*eraddsc*'OrderStatus'N;
	OUTPUT OUT=M_N_O_STATS SUM='銷售收入'N '商品數量'N '訂單數'N;
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
	RETAIN '日期'N '版位'N '訂單狀況'N '銷售收入'N '商品數量'N '訂單數'N;
	FORMAT '日期'N $36. '訂單狀況'N &VARN1 '版位'N &VARN2 '銷售收入'N NLMNITWD22.0 '商品數量'N '訂單數'N COMMA9.0;
	SET M_N_O_STATS (DROP=_TYPE_ _FREQ_ RENAME=(Date=Date_TMP 'OrderStatus'N=OrderStatusTMP eraddsc=eraddsc_tmp));
	'日期'N=CATS(PUT(&dy, NLDATEW.));
	IF OrderStatusTMP NE "" THEN '訂單狀況'N=OrderStatusTMP; ELSE '訂單狀況'N="全";
	IF eraddsc_tmp NE "" THEN '版位'N=eraddsc_tmp; ELSE '版位'N="全版位";
RUN;
%SYMDEL VARN1 VARN2;
OPTIONS LOCALE=en_US;
/*
	Generate the whole-range stats based on all app and blocks.
*/
PROC SQL;
	CREATE TABLE All_APP_N_O_R AS /*N_O_R stands for revenue from the old and new customers.*/
	SELECT '日期'N, "回頭客" FORMAT=$9. AS '客戶類型'N, '版位'N, '訂單狀況'N, '銷售收入'N, '商品數量'N, '訂單數'N,  
			'銷售收入'N/'訂單數'N AS '平均訂單價值（AOV）'N FORMAT=NLMNITWD22.2, '商品數量'N/'訂單數'N AS '平均訂單量（AOS）'N FORMAT=COMMA9.2
	FROM M_O_O_STATS
	UNION CORR ALL
	SELECT '日期'N, "新客" FORMAT=$9. AS '客戶類型'N, '版位'N, '訂單狀況'N, '銷售收入'N, '商品數量'N, '訂單數'N, 
			'銷售收入'N/'訂單數'N AS '平均訂單價值（AOV）'N FORMAT=NLMNITWD22.2, '商品數量'N/'訂單數'N AS '平均訂單量（AOS）'N FORMAT=COMMA9.2
	FROM M_N_O_STATS;
QUIT;
PROC SORT DATA=All_APP_N_O_R;
	BY '日期'N '版位'N;
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
	CREATE TABLE All_APP_N_O_R_TMP AS SELECT * FROM All_APP_N_O_R WHERE '版位'N = "全版位";
	CREATE TABLE Personal_N_O_R_TMP AS SELECT * FROM All_APP_N_O_R WHERE '版位'N IN ('即時新品', '好康商品', '季節商品', '知心商品', '專屬推薦');
	CREATE TABLE HotSale_N_O_R_TMP AS SELECT * FROM All_APP_N_O_R WHERE '版位'N IN ('宇匯推薦商品', '東科推薦商品');
	CREATE TABLE TOP10_N_O_R_TMP AS SELECT * FROM All_APP_N_O_R WHERE '版位'N LIKE '%TOP10%';
	CREATE TABLE Other_N_O_R_TMP AS SELECT * FROM All_APP_N_O_R WHERE '版位'N 
										NOT IN ('全版位', '即時新品', '好康商品', '季節商品', '知心商品', '專屬推薦', '宇匯推薦商品', '東科推薦商品')
										AND '版位'N NOT LIKE '%TOP10%';
	SELECT COUNT(DISTINCT '訂單狀況'N) INTO: All_row FROM All_APP_N_O_R_TMP;
QUIT;
%GLOBAL column; %GLOBAL row;
%ScopeDefine(&All_row) %SYMDEL All_row;
GOPTIONS RESET=ALL DEVICE=SVG BORDER; OPTIONS LOCALE=zh_TW;
TITLE1 %SYSFUNC(COMPRESS(%SYSFUNC(CATS(%SYSFUNC(PUTN(&dy, NLDATEW.)), 新舊客比例)))); OPTIONS LOCALE=en_US;
TITLE2 全APP;
PATTERN1 C=CX4965B0; PATTERN2 C=CXFF7B58; PATTERN3 C=CX95B60E;
PROC GCHART DATA=All_APP_N_O_R_TMP;
	PIE '客戶類型'N/SUMVAR='銷售收入'N GROUP='訂單狀況'N MIDPOINTS="回頭客" "新客"
		 ACROSS=&column DOWN=&row PERCENT=arrow COUTLINE=CX7C5C00 NOHEADING;
	RUN;
QUIT;
TITLE1; TITLE2;
PROC SQL;
	SELECT * FROM All_APP_N_O_R_TMP;
QUIT;
%_eg_conditional_dropds(All_APP_N_O_R_TMP)
%LET tmp_ftnt_1=%NRSTR(註1：細節圓餅圖只呈現「淨」訂單的分布。);
TITLE2 專屬推薦與精選好物; FOOTNOTE1 &tmp_ftnt_1;
PROC GCHART DATA=Personal_N_O_R_TMP(WHERE=('訂單狀況'N='淨'));
	PIE '客戶類型'N/SUMVAR='銷售收入'N VALUE=NONE SLICE=OUTSIDE OTHER=0
		MIDPOINTS="回頭客" "新客" PERCENT=arrow COUTLINE=CX7C5C00 NOHEADING
		DETAIL="版位"N DETAIL_PERCENT=BEST DETAIL_VALUE=NONE DETAIL_THRESHOLD=0.1;
	RUN;
QUIT;
TITLE2; FOOTNOTE1;
PROC GCHART DATA=Personal_N_O_R_TMP;
	VBAR '版位'N/SUMVAR='銷售收入'N GROUP='訂單狀況'N SUBGROUP='客戶類型'N SPACE=0;
	RUN;
QUIT;
PROC SQL;
	SELECT * FROM Personal_N_O_R_TMP;
QUIT;
%_eg_conditional_dropds(Personal_N_O_R_TMP)
TITLE2 當日熱賣; FOOTNOTE1 &tmp_ftnt_1;
PROC GCHART DATA=HotSale_N_O_R_TMP(WHERE=('訂單狀況'N='淨'));
	PIE '客戶類型'N/SUMVAR='銷售收入'N VALUE=NONE SLICE=OUTSIDE OTHER=0
		MIDPOINTS="回頭客" "新客" PERCENT=arrow COUTLINE=CX7C5C00 NOHEADING
		DETAIL="版位"N DETAIL_PERCENT=BEST DETAIL_VALUE=NONE DETAIL_THRESHOLD=0.1;
	RUN;
QUIT;
TITLE2; FOOTNOTE1;
PROC GCHART DATA=HotSale_N_O_R_TMP;
	VBAR '版位'N/SUMVAR='銷售收入'N GROUP='訂單狀況'N SUBGROUP='客戶類型'N SPACE=0;
	RUN;
QUIT;
PROC SQL;
	SELECT * FROM HotSale_N_O_R_TMP;
QUIT;
%_eg_conditional_dropds(HotSale_N_O_R_TMP)
TITLE2 TOP10; FOOTNOTE1 &tmp_ftnt_1;
PROC GCHART DATA=TOP10_N_O_R_TMP(WHERE=('訂單狀況'N='淨'));
	PIE '客戶類型'N/SUMVAR='銷售收入'N VALUE=NONE SLICE=OUTSIDE OTHER=0
		MIDPOINTS="回頭客" "新客" PERCENT=arrow COUTLINE=CX7C5C00 NOHEADING
		DETAIL="版位"N DETAIL_PERCENT=BEST DETAIL_VALUE=NONE DETAIL_THRESHOLD=0.1;
	RUN;
QUIT;
TITLE2; FOOTNOTE1;
PROC GCHART DATA=TOP10_N_O_R_TMP;
	VBAR '版位'N/SUMVAR='銷售收入'N GROUP='訂單狀況'N SUBGROUP='客戶類型'N SPACE=0;
	RUN;
QUIT;
PROC SQL;
	SELECT * FROM TOP10_N_O_R_TMP;
QUIT;
%_eg_conditional_dropds(TOP10_N_O_R_TMP)
TITLE2 其餘版位; FOOTNOTE1 &tmp_ftnt_1;
%LET tmp_ftnt_2 = %NRSTR(註2：佔比小於1%將不會顯示);
FOOTNOTE2 &tmp_ftnt_2;
PROC GCHART DATA=Other_N_O_R_TMP(WHERE=('訂單狀況'N='淨'));
	PIE '客戶類型'N/SUMVAR='銷售收入'N VALUE=NONE SLICE=OUTSIDE OTHER=0
		MIDPOINTS="回頭客" "新客" PERCENT=arrow COUTLINE=CX7C5C00 NOHEADING
		DETAIL="版位"N DETAIL_PERCENT=BEST DETAIL_VALUE=NONE DETAIL_THRESHOLD=1;
	RUN;
QUIT;
TITLE2; FOOTNOTE1; FOOTNOTE2;
PROC GCHART DATA=Other_N_O_R_TMP;
	VBAR '版位'N/SUMVAR='銷售收入'N GROUP='訂單狀況'N SUBGROUP='客戶類型'N SPACE=0;
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