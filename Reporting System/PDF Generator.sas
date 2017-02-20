OPTIONS MCOMPILENOTE=ALL;
%MACRO generateSalesKPI;
	%IF %SYSFUNC(DATDIF(&INI_DATE, &LAST_DATE, ACT/ACT)) EQ 0 %THEN %DO;
		%createDailyTVWEBSummary(R_H_ITMD3) %END;
	%ELSE %DO;
		%createTimeRangeTVWEBSummary(R_H_ITMD3, TVWEB_SUMMARY, &RIFALL) %END;
%MEND;
%MACRO generateClickingDistribution;
TITLE1; TITLE2; TITLE3;
%IF %SYSFUNC(DATDIF(&INI_DATE, &LAST_DATE, ACT/ACT)) EQ 0 %THEN
%DO;
	%IF %SYSFUNC(EXIST(TMP_1)) %THEN %DO;
	PROC SQL;
		DROP TABLE TMP_1;
		CREATE TABLE TMP_1 AS
			SELECT * FROM WORK.CLCMP_STATS
			UNION ALL
			SELECT * FROM WORK.CLC_STATS;
	QUIT;
	%END;
	%ELSE %DO;
	PROC SQL;
		CREATE TABLE TMP_1 AS
			SELECT * FROM WORK.CLCMP_STATS
			UNION ALL
			SELECT * FROM WORK.CLC_STATS;
	QUIT;
	%END;
	/*
		Combination of the stats of click and clicmp.
	*/
	%IF %SYSFUNC(EXIST(TMP_2)) %THEN %DO;
	PROC SQL;
		DROP TABLE TMP_2;
		CREATE TABLE TMP_2 AS
			SELECT * FROM TMP_1
			WHERE Explicitcategory NE '全區塊' AND Implicitcategory NOT IN ('', '全版位') AND RegOrNot = 'U' 
					AND Date ^= . AND (Date BETWEEN &LAST_DATE AND &LAST_DATE ) AND Device='不分';
	QUIT;
	%END;
	%ELSE %DO;
	PROC SQL;
		CREATE TABLE TMP_2 AS
			SELECT * FROM TMP_1
			WHERE Explicitcategory NE '全區塊' AND Implicitcategory NOT IN ('', '全版位') AND RegOrNot = 'U' 
					AND Date ^= . AND (Date BETWEEN &LAST_DATE AND &LAST_DATE ) AND Device='不分';
	QUIT;
	%END;
	/*
		Rename the variables for the report.
	*/
	PROC DATASETS LIB=WORK NOLIST;
		MODIFY TMP_2;
			RENAME CLCtimes='點擊數'N Implicitcategory='大分類'N Explicitcategory='小分類'N;
	QUIT;
	OPTIONS LOCALE=zh_TW; OPTIONS NODATE;
	%generateExplicitDailyRank /*%generateExplicitDailyRank*/
	%generateDailyTabStats /*%generateTimeRangeTabStats*/
	TITLE; TITLE1; TITLE2; TITLE3;
		OPTIONS NODATE;
		OPTIONS DEV=ACTXIMG;
		ODS ESCAPECHAR="^";
		GOPTIONS RESET=ALL NOBORDER;
		ODS PDF (ID=DYFIG) STARTPAGE=NOW;
		ODS TEXT="^S={FONTSIZE=13pt JUST=C}%SYSFUNC(STRIP(%SYSFUNC(PUTN(&LAST_DATE, NLDATEW.)))) 點擊排行";
		ODS LAYOUT GRIDDED /*STYLE={FONTFAMILY="Microsoft JhengHei"}*/
						COLUMNS=2 ROWS=2 COLUMN_WIDTHS=(50% 50%) HEIGHT=10in COLUMN_GUTTER=0 ROW_GUTTER=0;
		/*Left-top corner*/
		ODS REGION HEIGHT=50pct;
			ODS TEXT="^S={FONTSIZE=13pt}全APP點擊排行表";
			PROC PRINT DATA=WORK.LOCALIZED_CLC_FIG_TMP1 NOOBS STYLE(DATA)=[JUST=C VJUST=M]
						STYLE(HEAD)=[JUST=C VJUST=M BACKGROUNDCOLOR=RGBA765CC833] CONTENTS="";
			RUN;
			ODS TEXT="^S={WIDTH=100% JUST=L}註1：只列出全部點擊數以及排名前十的大分類。";
			ODS TEXT="^S={WIDTH=100% JUST=L}註2：目前Others包含ercampid值為Interstitial_Ad、ExclusiveProd_ChessBoardBT、Home_LiveNow、NewProd_*、Panic_Buy、ShopCart、APINoDataOrTimeOut、ChatRoom、ContactService以及PushSet的記錄。";
		/*Right-top corner*/
		ODS REGION HEIGHT=50pct;
			ODS TEXT="^S={FONTSIZE=13pt}頁籤點擊排行表";
			PROC PRINT DATA=WORK.CLC_TABS_FIG NOOBS STYLE(DATA)=[JUST=C VJUST=M]
						STYLE(HEAD)=[JUST=C VJUST=M BACKGROUNDCOLOR=RGBA765CC833] CONTENTS="";
			RUN;
			ODS TEXT="^S={WIDTH=100% JUST=L}註1：●●●●_*與●●●●_*所屬的某欄位都為「某分類」。";
			ODS TEXT="^S={WIDTH=100% JUST=L}註2：●●●●_*與●●●●_*所代表的頁籤位於首頁當中，而它的點擊數與首頁點擊數為分開計算。";
		/*Left-bottom corner*/
		ODS REGION HEIGHT=48pct;
		TITLE1;
			ODS TEXT="^S={FONTSIZE=13pt}版位點擊排行表";
			PROC PRINT DATA=WORK.BK_CLK_PER NOOBS STYLE(DATA)=[JUST=C VJUST=M]
						STYLE(HEAD)=[JUST=C VJUST=M BACKGROUNDCOLOR=RGBA765CC833] CONTENTS="";
			RUN;
			ODS TEXT="^S={WIDTH=95% JUST=L}註1：類別勾選（●●●●●●）、勾選和取消勾選（●●●●●●）、看更多（譬如：●●●●●●）都是有含括的。";
		/*Right-bottom corner*/
		ODS REGION HEIGHT=48pct;
			ODS TEXT="^S={FONTSIZE=13pt}須知說明";
			ODS TEXT="";
			ODS TEXT="^S={WIDTH=100% JUST=L}1.";
			ODS TEXT="^S={WIDTH=100% JUST=L}為了增加可讀性以及視覺化的可能性，報表系統v2.0執行了適當的分類，即大分類和小分類，而兩者的分類主要依據為●●●●●●和●●●●●●。";
			ODS TEXT="^S={WIDTH=100% JUST=L}2.";
			ODS TEXT="^S={WIDTH=100% JUST=L}所有大分類和小分類的點擊佔比可參考HTML檔，目前是以矩形式樹狀結構或是說樹圖（Treemap）來呈現東森購物APP的點擊狀況。";
			ODS TEXT="^S={WIDTH=100% JUST=L}3.";
			ODS TEXT="^S={WIDTH=100% JUST=L}點擊的敘述統計來源為●●●●●●值是●●●●●●和●●●●●●的交易紀錄，而●●●●●●和●●●●●●會有版位ID重複的情況。目前報表系統v2.0只對●●●●●●和●●●●●●的交集納入一次，";
			ODS TEXT="^S={WIDTH=100% JUST=L}換句話說，點擊敘述統計的來源為●●●●●●的全集加上●●●●●●在●●●●●●中的相對差集。";
		ODS LAYOUT END;
		PROC SQL;
			DROP TABLE WORK.CLC_FIG_ITMD3, WORK.BK_CLK_PER, WORK.CLC_FIG, WORK.LOCALIZED_CLC_FIG_TMP1, WORK.CLC_TABS_FIG;
			/*WORK.CLK_PER_EACHD*/
		QUIT;
%END;
%ELSE
%DO;
	%IF &CLCALL EQ 1 %THEN %DO;
		PROC SQL;
			CREATE TABLE TMP_1 AS
				SELECT * FROM WORK.CLCMP_STATS
				UNION ALL
				SELECT * FROM WORK.CLC_STATS;
		QUIT;
		%DO i=&INI_DATE %TO &LAST_DATE %BY 1;		
		/*
			Combination of the stats of click and clicmp.
		*/
		PROC SQL;
			CREATE TABLE TMP_2 AS
				SELECT * FROM TMP_1
				WHERE Explicitcategory NE '全區塊' AND Implicitcategory NOT IN ('', '全版位') AND RegOrNot = 'U' 
						AND Date ^= . AND (Date BETWEEN &i AND &i ) AND Device='不分';
		QUIT;
		/*
			Rename the variables for the report.
		*/
		PROC DATASETS LIB=WORK NOLIST;
			MODIFY TMP_2;
				RENAME CLCtimes='點擊數'N Implicitcategory='大分類'N Explicitcategory='小分類'N;
		QUIT;
		OPTIONS LOCALE=zh_TW; OPTIONS NODATE;
		%generateExplicitDailyRank /*%generateExplicitDailyRank*/
		%generateDailyTabStats /*%generateTimeRangeTabStats*/
		OPTIONS NODATE; OPTIONS DEV=ACTXIMG;
		ODS PDF (ID=DYFIG) STARTPAGE=NOW;
		ODS ESCAPECHAR="^";
		GOPTIONS RESET=ALL NOBORDER;
		ODS TEXT="^S={FONTSIZE=13pt JUST=C}%SYSFUNC(STRIP(%SYSFUNC(PUTN(&i, NLDATEW.)))) 點擊排行";
		ODS LAYOUT GRIDDED /*STYLE={FONTFAMILY="Microsoft JhengHei"}*/
						COLUMNS=2 ROWS=2 COLUMN_WIDTHS=(50% 50%) HEIGHT=10in COLUMN_GUTTER=0 ROW_GUTTER=0;
		/*Left-top corner*/
		ODS REGION HEIGHT=50pct;
			ODS TEXT="^S={FONTSIZE=13pt}全APP點擊排行表";
			PROC PRINT DATA=WORK.LOCALIZED_CLC_FIG_TMP1 NOOBS STYLE(DATA)=[JUST=C VJUST=M]
						STYLE(HEAD)=[JUST=C VJUST=M BACKGROUNDCOLOR=RGBA765CC833] CONTENTS="";
			RUN;
			ODS TEXT="^S={WIDTH=100% JUST=L}註1：只列出全部點擊數以及排名前十的大分類。";
			ODS TEXT="^S={WIDTH=100% JUST=L}註2：目前Others包含●●●●●●值為●●●●●●、●●●●●●、●●●●●●、●●●●●●、●●●●●●、●●●●●●、●●●●●●、●●●●●●、●●●●●●以及●●●●●●的記錄。";
		/*Right-top corner*/
		ODS REGION HEIGHT=50pct;
			ODS TEXT="^S={FONTSIZE=13pt}頁籤點擊排行表";
			PROC PRINT DATA=WORK.CLC_TABS_FIG NOOBS STYLE(DATA)=[JUST=C VJUST=M]
						STYLE(HEAD)=[JUST=C VJUST=M BACKGROUNDCOLOR=RGBA765CC833] CONTENTS="";
			RUN;
			ODS TEXT="^S={WIDTH=100% JUST=L}註1：●●●●●●與●●●●●●所屬的●●●●●●都為「●●●●●●」。";
			ODS TEXT="^S={WIDTH=100% JUST=L}註2：●●●●●●與●●●●●●所代表的頁籤位於首頁當中，而它的點擊數與首頁點擊數為分開計算。";
		/*Left-bottom corner*/
		ODS REGION HEIGHT=48pct;
		TITLE1;
			ODS TEXT="^S={FONTSIZE=13pt}版位點擊排行表";
			PROC PRINT DATA=WORK.BK_CLK_PER NOOBS STYLE(DATA)=[JUST=C VJUST=M]
						STYLE(HEAD)=[JUST=C VJUST=M BACKGROUNDCOLOR=RGBA765CC833] CONTENTS="";
			RUN;
			ODS TEXT="^S={WIDTH=95% JUST=L}註1：類別勾選（●●●●●●）、勾選和取消勾選（●●●●●●）、看更多（譬如：●●●●●●）都是有含括的。";
		/*Right-bottom corner*/
		ODS REGION HEIGHT=48pct;
			ODS TEXT="^S={FONTSIZE=13pt}須知說明";
			ODS TEXT="";
			ODS TEXT="^S={WIDTH=100% JUST=L}1.";
			ODS TEXT="^S={WIDTH=100% JUST=L}為了增加可讀性以及視覺化的可行性，報表系統v2.0執行了適當的分類，即大分類和小分類，而兩者的分類主要依據為●●●●●●和●●●●●●。";
			ODS TEXT="^S={WIDTH=100% JUST=L}2.";
			ODS TEXT="^S={WIDTH=100% JUST=L}所有大分類和小分類的點擊佔比可參考HTML檔，目前是以矩形式樹狀結構或是說樹圖（Treemap）來呈現東森購物APP的點擊狀況。";
			ODS TEXT="^S={WIDTH=100% JUST=L}3.";
			ODS TEXT="^S={WIDTH=100% JUST=L}點擊的敘述統計來源為●●●●●●值是●●●●●●和●●●●●●的交易紀錄，而●●●●●●和●●●●●●會有●●●●●●的情況。目前報表系統v2.0只對●●●●●●和●●●●●●的交集納入一次，";
			ODS TEXT="^S={WIDTH=100% JUST=L}換句話說，點擊敘述統計的來源為●●●●●●的全集加上●●●●●●在●●●●●●中的相對差集。";
		ODS LAYOUT END;
		ODS PDF (ID=DYFIG) STARTPAGE=NOW;
		/*Page for the whole time range.*/
		%IF &i EQ &LAST_DATE %THEN %DO;
			PROC SQL;
				CREATE TABLE TMP_2 AS
					SELECT * FROM TMP_1
					WHERE Explicitcategory NE '全區塊' AND Implicitcategory NOT IN ('', '全版位') AND RegOrNot = 'U' 
							AND Date ^= . AND (Date BETWEEN &INI_DATE AND &LASt_DATE ) AND Device='不分';
			QUIT;
			/*
				Rename the variables for the report.
			*/
			PROC DATASETS LIB=WORK NOLIST;
				MODIFY TMP_2;
					RENAME CLCtimes='點擊數'N Implicitcategory='大分類'N Explicitcategory='小分類'N;
			QUIT;
			OPTIONS LOCALE=zh_TW; OPTIONS NODATE;
			%generateExplicitTimeRangeRank /*%generateExplicitDailyRank*/
			%generateTimeRangeTabStats /*%generateDailyTabStats*/
			OPTIONS NODATE;
			OPTIONS DEV=ACTXIMG;
			ODS ESCAPECHAR="^";
			GOPTIONS RESET=ALL NOBORDER;
			ODS TEXT="^S={FONTSIZE=13pt JUST=C}%SYSFUNC(STRIP(%SYSFUNC(PUTN(&INI_DATE, NLDATEW.))))到%SYSFUNC(STRIP(%SYSFUNC(PUTN(&LAST_DATE, NLDATEW.)))) 點擊排行";
			ODS LAYOUT GRIDDED /*STYLE={FONTFAMILY="Microsoft JhengHei"}*/
							COLUMNS=2 ROWS=2 COLUMN_WIDTHS=(50% 50%) HEIGHT=10in COLUMN_GUTTER=0 ROW_GUTTER=0;
			/*Left-top corner*/
			ODS REGION HEIGHT=50pct;
				ODS TEXT="^S={FONTSIZE=13pt}全APP點擊排行表";
				PROC PRINT DATA=WORK.LOCALIZED_CLC_FIG_TMP1 NOOBS STYLE(DATA)=[JUST=C VJUST=M]
							STYLE(HEAD)=[JUST=C VJUST=M BACKGROUNDCOLOR=RGBA765CC833] CONTENTS="";
				RUN;
				ODS TEXT="^S={WIDTH=100% JUST=L}註1：只列出全部點擊數以及排名前十的大分類。";
				ODS TEXT="^S={WIDTH=100% JUST=L}註2：目前Others包含●●●●●●值為●●●●●●、●●●●●●、●●●●●●、●●●●●●、●●●●●●、●●●●●●、●●●●●●、●●●●●●、●●●●●●以及●●●●●●的記錄。";
			/*Right-top corner*/
			ODS REGION HEIGHT=50pct;
				ODS TEXT="^S={FONTSIZE=13pt}頁籤點擊排行表";
				PROC PRINT DATA=WORK.CLC_TABS_FIG NOOBS STYLE(DATA)=[JUST=C VJUST=M]
							STYLE(HEAD)=[JUST=C VJUST=M BACKGROUNDCOLOR=RGBA765CC833] CONTENTS="";
				RUN;
				ODS TEXT="^S={WIDTH=100% JUST=L}註1：●●●●●●與●●●●●●所屬的●●●●●●都為「●●●●●●」。";
				ODS TEXT="^S={WIDTH=100% JUST=L}註2：●●●●●●與●●●●●●所代表的頁籤位於首頁當中，而它的點擊數與首頁點擊數為分開計算。";
			/*Left-bottom corner*/
			ODS REGION HEIGHT=48pct;
			TITLE1;
				ODS TEXT="^S={FONTSIZE=13pt}版位點擊排行表";
				PROC PRINT DATA=WORK.BK_CLK_PER NOOBS STYLE(DATA)=[JUST=C VJUST=M]
							STYLE(HEAD)=[JUST=C VJUST=M BACKGROUNDCOLOR=RGBA765CC833] CONTENTS="";
				RUN;
				ODS TEXT="^S={WIDTH=95% JUST=L}註1：類別勾選（●●●●●●）、勾選和取消勾選（●●●●●●）、看更多（譬如：●●●●●●）都是有含括的。";
			/*Right-bottom corner*/
			ODS REGION HEIGHT=48pct;
				%_eg_conditional_dropds(CLK_PER_EACHD_TMP)
				ODS TEXT="^S={FONTSIZE=13pt}全APP和頁籤點擊趨勢圖";
				PROC SQL;
					CREATE TABLE CLK_PER_EACHD_TMP AS
						SELECT Date AS '日期'N, CASE WHEN 大分類 EQ "" THEN "總和" ELSE 大分類 END AS 大分類, 點擊數 
						FROM CLK_PER_EACHD
						WHERE CALCULATED 大分類 IN ("總和", "頁籤");
				QUIT;
				GOPTIONS RESET=ALL NOBORDER DEVICE=SVG;
				PROC SGPLOT DATA=CLK_PER_EACHD_TMP;
					REG X='日期'N Y='點擊數'N/GROUP=大分類
						/*DATALABEL='點擊數'N DATALABELPOS=TOP*/ DEGREE=2 JITTER;
						XAXIS DISPLAY=(NOLABEL); YAXIS DISPLAY=(NOLABEL);
						KEYLEGEND/ TITLE="區塊" TITLEATTRS=(FAMILY=BiauKai SIZE=12) VALUEATTRS=(FAMILY=BiauKai SIZE=10);
				RUN;
				%_eg_conditional_dropds(CLK_PER_EACHD_TMP)
			ODS LAYOUT END;
		%END;
		%END; /*End of the do-loop*/
		PROC SQL;
			DROP TABLE WORK.CLC_FIG_ITMD3, WORK.BK_CLK_PER, WORK.CLC_FIG, WORK.LOCALIZED_CLC_FIG_TMP1, WORK.CLC_TABS_FIG, WORK.CLK_PER_EACHD;
		QUIT;
	%END;
	%ELSE %DO;
		PROC SQL;
			CREATE TABLE TMP_1 AS
				SELECT * FROM WORK.CLCMP_STATS
				UNION ALL
				SELECT * FROM WORK.CLC_STATS;
		QUIT;
		/*
			Combination of the stats of click and clicmp.
		*/
		PROC SQL;
			CREATE TABLE TMP_2 AS
				SELECT * FROM TMP_1
				WHERE Explicitcategory NE '全區塊' AND Implicitcategory NOT IN ('', '全版位') AND RegOrNot = 'U' 
						AND Date ^= . AND (Date BETWEEN &LAST_DATE AND &LAST_DATE ) AND Device='不分';
		QUIT;
		/*
			Rename the variables for the report.
		*/
		PROC DATASETS LIB=WORK NOLIST;
			MODIFY TMP_2;
				RENAME CLCtimes='點擊數'N Implicitcategory='大分類'N Explicitcategory='小分類'N;
		QUIT;
		OPTIONS LOCALE=zh_TW; OPTIONS NODATE;
		%generateExplicitDailyRank /*%generateExplicitDailyRank*/
		%generateDailyTabStats /*%generateTimeRangeTabStats*/
		OPTIONS NODATE;
		OPTIONS DEV=ACTXIMG;
		ODS ESCAPECHAR="^";
		GOPTIONS RESET=ALL NOBORDER;
		ODS TEXT="^S={FONTSIZE=13pt JUST=C}%SYSFUNC(STRIP(%SYSFUNC(PUTN(&LAST_DATE, NLDATEW.)))) 點擊排行";
		ODS LAYOUT GRIDDED /*STYLE={FONTFAMILY="Microsoft JhengHei"}*/
						COLUMNS=2 ROWS=2 COLUMN_WIDTHS=(50% 50%) HEIGHT=10in COLUMN_GUTTER=0 ROW_GUTTER=0;
		/*Left-top corner*/
		ODS REGION HEIGHT=50pct;
			ODS TEXT="^S={FONTSIZE=13pt}全APP點擊排行表";
			PROC PRINT DATA=WORK.LOCALIZED_CLC_FIG_TMP1 NOOBS STYLE(DATA)=[JUST=C VJUST=M]
						STYLE(HEAD)=[JUST=C VJUST=M BACKGROUNDCOLOR=RGBA765CC833] CONTENTS="";
			RUN;
			ODS TEXT="^S={WIDTH=100% JUST=L}註1：只列出全部點擊數以及排名前十的大分類。";
			ODS TEXT="^S={WIDTH=100% JUST=L}註2：目前Others包含●●●●●●值為●●●●●●、●●●●●●、●●●●●●、●●●●●●、●●●●●●、●●●●●●、●●●●●●、●●●●●●、●●●●●●以及●●●●●●的記錄。";
		/*Right-top corner*/
		ODS REGION HEIGHT=50pct;
			ODS TEXT="^S={FONTSIZE=13pt}頁籤點擊排行表";
			PROC PRINT DATA=WORK.CLC_TABS_FIG NOOBS STYLE(DATA)=[JUST=C VJUST=M]
						STYLE(HEAD)=[JUST=C VJUST=M BACKGROUNDCOLOR=RGBA765CC833] CONTENTS="";
			RUN;
			ODS TEXT="^S={WIDTH=100% JUST=L}註1：●●●●●●與●●●●●●所屬的●●●●●●都為「●●●●●●」。";
			ODS TEXT="^S={WIDTH=100% JUST=L}註2：●●●●●●與●●●●●●所代表的頁籤位於首頁當中，而它的點擊數與首頁點擊數為分開計算。";
		/*Left-bottom corner*/
		ODS REGION HEIGHT=48pct;
		TITLE1;
			ODS TEXT="^S={FONTSIZE=13pt}版位點擊排行表";
			PROC PRINT DATA=WORK.BK_CLK_PER NOOBS STYLE(DATA)=[JUST=C VJUST=M]
						STYLE(HEAD)=[JUST=C VJUST=M BACKGROUNDCOLOR=RGBA765CC833] CONTENTS="";
			RUN;
			ODS TEXT="^S={WIDTH=95% JUST=L}註1：類別勾選（●●●●●●）、勾選和取消勾選（●●●●●●）、看更多（譬如：●●●●●●）都是有含括的。";
		/*Right-bottom corner*/
		ODS REGION HEIGHT=48pct;
			ODS TEXT="^S={FONTSIZE=13pt}須知說明";
			ODS TEXT="";
			ODS TEXT="^S={WIDTH=100% JUST=L}1.";
			ODS TEXT="^S={WIDTH=100% JUST=L}為了增加可讀性以及視覺化的可能性，報表系統v2.0執行了適當的分類，即大分類和小分類，而兩者的分類主要依據為●●●●●●和●●●●●●。";
			ODS TEXT="^S={WIDTH=100% JUST=L}2.";
			ODS TEXT="^S={WIDTH=100% JUST=L}所有大分類和小分類的點擊佔比可參考HTML檔，目前是以矩形式樹狀結構或是說樹圖（Treemap）來呈現東森購物APP的點擊狀況。";
			ODS TEXT="^S={WIDTH=100% JUST=L}3.";
			ODS TEXT="^S={WIDTH=100% JUST=L}點擊的敘述統計來源為●●●●●●值是●●●●●●和●●●●●●的交易紀錄，而●●●●●●和●●●●●●會有版位ID重複的情況。目前報表系統v2.0只對●●●●●●和●●●●●●的交集納入一次，";
			ODS TEXT="^S={WIDTH=100% JUST=L}換句話說，點擊敘述統計的來源為●●●●●●的全集加上●●●●●●在●●●●●●中的相對差集。";
		ODS LAYOUT END;
		ODS PDF (ID=DYFIG) STARTPAGE=NOW;
		/*Page for the whole time range.*/
		PROC SQL;
			CREATE TABLE TMP_2 AS
				SELECT * FROM TMP_1
				WHERE Explicitcategory NE '全區塊' AND Implicitcategory NOT IN ('', '全版位') AND RegOrNot = 'U' 
						AND Date ^= . AND (Date BETWEEN &INI_DATE AND &LASt_DATE ) AND Device='不分';
		QUIT;
		/*
			Rename the variables for the report.
		*/
		PROC DATASETS LIB=WORK NOLIST;
			MODIFY TMP_2;
				RENAME CLCtimes='點擊數'N Implicitcategory='大分類'N Explicitcategory='小分類'N;
		QUIT;
		OPTIONS LOCALE=zh_TW; OPTIONS NODATE;
		%generateExplicitTimeRangeRank /*%generateExplicitDailyRank*/
		%generateTimeRangeTabStats /*%generateDailyTabStats*/
		OPTIONS NODATE;
		OPTIONS DEV=ACTXIMG;
		ODS ESCAPECHAR="^";
		GOPTIONS RESET=ALL NOBORDER;
		ODS TEXT="^S={FONTSIZE=13pt JUST=C}%SYSFUNC(STRIP(%SYSFUNC(PUTN(&INI_DATE, NLDATEW.))))到%SYSFUNC(STRIP(%SYSFUNC(PUTN(&LAST_DATE, NLDATEW.)))) 點擊排行";
		ODS LAYOUT GRIDDED /*STYLE={FONTFAMILY="Microsoft JhengHei"}*/
						COLUMNS=2 ROWS=2 COLUMN_WIDTHS=(50% 50%) HEIGHT=10in COLUMN_GUTTER=0 ROW_GUTTER=0;
		/*Left-top corner*/
		ODS REGION HEIGHT=50pct;
			ODS TEXT="^S={FONTSIZE=13pt}全APP點擊排行表";
			PROC PRINT DATA=WORK.LOCALIZED_CLC_FIG_TMP1 NOOBS STYLE(DATA)=[JUST=C VJUST=M]
						STYLE(HEAD)=[JUST=C VJUST=M BACKGROUNDCOLOR=RGBA765CC833] CONTENTS="";
			RUN;
			ODS TEXT="^S={WIDTH=100% JUST=L}註1：只列出全部點擊數以及排名前十的大分類。";
			ODS TEXT="^S={WIDTH=100% JUST=L}註2：目前Others包含●●●●●●值為●●●●●●、●●●●●●、●●●●●●、●●●●●●、●●●●●●、●●●●●●、●●●●●●、●●●●●●、●●●●●●以及●●●●●●的記錄。";
		/*Right-top corner*/
		ODS REGION HEIGHT=50pct;
			ODS TEXT="^S={FONTSIZE=13pt}頁籤點擊排行表";
			PROC PRINT DATA=WORK.CLC_TABS_FIG NOOBS STYLE(DATA)=[JUST=C VJUST=M]
						STYLE(HEAD)=[JUST=C VJUST=M BACKGROUNDCOLOR=RGBA765CC833] CONTENTS="";
			RUN;
			ODS TEXT="^S={WIDTH=100% JUST=L}註1：●●●●●●與●●●●●●所屬的●●●●●●都為「●●●●●●」。";
			ODS TEXT="^S={WIDTH=100% JUST=L}註2：●●●●●●與●●●●●●所代表的頁籤位於首頁當中，而它的點擊數與首頁點擊數為分開計算。";
		/*Left-bottom corner*/
		ODS REGION HEIGHT=48pct;
		TITLE1;
			ODS TEXT="^S={FONTSIZE=13pt}版位點擊排行表";
			PROC PRINT DATA=WORK.BK_CLK_PER NOOBS STYLE(DATA)=[JUST=C VJUST=M]
						STYLE(HEAD)=[JUST=C VJUST=M BACKGROUNDCOLOR=RGBA765CC833] CONTENTS="";
			RUN;
			ODS TEXT="^S={WIDTH=95% JUST=L}註1：類別勾選（●●●●●●）、勾選和取消勾選（●●●●●●）、看更多（譬如：●●●●●●）都是有含括的。";
		/*Right-bottom corner*/
		ODS REGION HEIGHT=48pct;
			%_eg_conditional_dropds(CLK_PER_EACHD_TMP)
			ODS TEXT="^S={FONTSIZE=13pt}全APP和頁籤點擊趨勢圖";
			PROC SQL;
				CREATE TABLE CLK_PER_EACHD_TMP AS
					SELECT Date AS '日期'N, CASE WHEN 大分類 EQ "" THEN "總和" ELSE 大分類 END AS 大分類, 點擊數 
					FROM CLK_PER_EACHD
					WHERE CALCULATED 大分類 IN ("總和", "頁籤");
			QUIT;
			GOPTIONS HSIZE=2in VSIZE=1in DEVICE=SVG;
			PROC SGPLOT DATA=CLK_PER_EACHD_TMP;
				REG X='日期'N Y='點擊數'N/GROUP=大分類
					/*DATALABEL='點擊數'N DATALABELPOS=TOP*/ DEGREE=2;
					XAXIS DISPLAY=(NOLABEL); YAXIS DISPLAY=(NOLABEL);
					KEYLEGEND/ TITLE="區塊" TITLEATTRS=(FAMILY=BiauKai SIZE=12) VALUEATTRS=(FAMILY=BiauKai SIZE=10);
			RUN;
			%_eg_conditional_dropds(CLK_PER_EACHD_TMP)
		ODS LAYOUT END;
		PROC SQL;
			DROP TABLE WORK.CLC_FIG_ITMD3, WORK.BK_CLK_PER, WORK.CLC_FIG, WORK.LOCALIZED_CLC_FIG_TMP1, WORK.CLC_TABS_FIG, WORK.CLK_PER_EACHD;
		QUIT;
	%END;
%END;
PROC SQL;
	DROP TABLE TMP_1;
QUIT;
%MEND;
/*
	Input requirement: SS_DY_STATS, 
*/
%MACRO generateBlockPerformance;
TITLE1; TITLE2; TITLE3;
ODS PDF (ID=DYFIG) STARTPAGE=NOW;
%IF %SYSFUNC(DATDIF(&INI_DATE, &LAST_DATE, ACT/ACT)) EQ 0 %THEN
%DO;
		OPTIONS NODATE;
		OPTIONS DEV=ACTXIMG;
		ODS LAYOUT GRIDDED /*STYLE={FONTFAMILY="Microsoft JhengHei"}*/
							/*COLUMNS=2 ROWS=2 COLUMN_WIDTHS=(50% 50%) HEIGHT=10in COLUMN_GUTTER=0 ROW_GUTTER=0*/;
		%_eg_conditional_dropds(TEST)
		%_eg_conditional_dropds(TEST3)
		PROC SQL;
			CREATE TABLE TEST AS
			SELECT MDY(INPUT(SUBSTR(SUBSTR(日期,FIND(日期,'年'),FIND(日期,'月')-FIND(日期,'年')),ANYDIGIT(SUBSTR(日期,FIND(日期,'年'),FIND(日期,'月')-FIND(日期,'年')))),8.0),
						INPUT(SUBSTR(SUBSTR(日期,FIND(日期,'月'),FIND(日期,'日')-FIND(日期,'月')),ANYDIGIT(SUBSTR(日期,FIND(日期,'月'),FIND(日期,'日')-FIND(日期,'月')))),8.0),
						INPUT(SCAN(日期,1,'年'),8.0)) FORMAT=DATE9. AS 日期 ,版位 ,點擊次數 ,放入次數 ,放入商品數量 ,丟棄次數 ,丟棄商品數量 ,訂單狀況 
					,銷售收入 FORMAT=DOLLAR12.0,銷售成本 FORMAT=DOLLAR12.0,利潤 FORMAT=DOLLAR12.0,商品數量 ,訂單數 ,毛利率 ,購物車轉換率 ,購物車取消率 ,訂單轉換率 ,完全轉換率
			FROM WORK.SS_DY_STATS
			WHERE 訂單狀況 IN('NET','無')
			UNION CORRESPONDING ALL
			SELECT MDY(INPUT(SUBSTR(SUBSTR(日期,FIND(日期,'年'),FIND(日期,'月')-FIND(日期,'年')),ANYDIGIT(SUBSTR(日期,FIND(日期,'年'),FIND(日期,'月')-FIND(日期,'年')))),8.0),
						INPUT(SUBSTR(SUBSTR(日期,FIND(日期,'月'),FIND(日期,'日')-FIND(日期,'月')),ANYDIGIT(SUBSTR(日期,FIND(日期,'月'),FIND(日期,'日')-FIND(日期,'月')))),8.0),
						INPUT(SCAN(日期,1,'年'),8.0)) FORMAT=DATE9. AS 日期 ,版位 ,點擊次數 ,放入次數 ,放入商品數量 ,丟棄次數 ,丟棄商品數量 ,訂單狀況 
					,銷售收入 FORMAT=DOLLAR12.0,銷售成本 FORMAT=DOLLAR12.0,利潤 FORMAT=DOLLAR12.0,商品數量 ,訂單數 ,毛利率 ,購物車轉換率 ,購物車取消率 ,訂單轉換率 ,完全轉換率
			FROM WORK.HOTSALE_DY_STATS
			WHERE 訂單狀況 IN('NET','無')
			UNION CORRESPONDING ALL
			SELECT MDY(INPUT(SUBSTR(SUBSTR(日期,FIND(日期,'年'),FIND(日期,'月')-FIND(日期,'年')),ANYDIGIT(SUBSTR(日期,FIND(日期,'年'),FIND(日期,'月')-FIND(日期,'年')))),8.0),
						INPUT(SUBSTR(SUBSTR(日期,FIND(日期,'月'),FIND(日期,'日')-FIND(日期,'月')),ANYDIGIT(SUBSTR(日期,FIND(日期,'月'),FIND(日期,'日')-FIND(日期,'月')))),8.0),
						INPUT(SCAN(日期,1,'年'),8.0)) FORMAT=DATE9. AS 日期 ,版位 ,點擊次數 ,放入次數 ,放入商品數量 ,丟棄次數 ,丟棄商品數量 ,訂單狀況 
					,銷售收入 FORMAT=DOLLAR12.0,銷售成本 FORMAT=DOLLAR12.0,利潤 FORMAT=DOLLAR12.0,商品數量 ,訂單數 ,毛利率 ,購物車轉換率 ,購物車取消率 ,訂單轉換率 ,完全轉換率
			FROM WORK.REST_DY_STATS
			WHERE 訂單狀況 IN('NET','無');
			CREATE TABLE DY_BK_REV AS
			SELECT 日期 ,版位 ,點擊次數 ,放入次數 ,放入商品數量 ,丟棄次數 ,丟棄商品數量 ,訂單狀況 ,銷售收入/SUM(銷售收入) FORMAT=PERCENT8.2 AS 營收佔比, 銷售收入 ,
					銷售成本 ,利潤 ,商品數量 ,訂單數 ,毛利率 ,購物車轉換率 ,購物車取消率 ,訂單轉換率 ,完全轉換率
			FROM TEST
			GROUP BY 日期
			ORDER BY 日期, 完全轉換率 DESC;
		QUIT;
		%_eg_conditional_dropds(TEST2)
		PROC MEANS DATA=WORK.DY_BK_REV SUM NOPRINT;
			CLASS '日期'N '版位'N '訂單狀況'N;
			VAR 點擊次數 放入次數 放入商品數量 丟棄次數 丟棄商品數量 銷售收入 銷售成本 利潤 商品數量 訂單數;
			TYPES 日期 日期*版位*'訂單狀況'N;
			OUTPUT OUT=TEST2 SUM=點擊次數 放入次數 放入商品數量 丟棄次數 丟棄商品數量 銷售收入 銷售成本 利潤 商品數量 訂單數;
		RUN;
		PROC SQL NOPRINT;
			SELECT MAX(LENGTH(STRIP(版位))) INTO: position_ln FROM TEST2;
		QUIT;
		%LET position_ln=$%SYSFUNC(COMPRESS(&position_ln)).;
		DATA TEST2;
			RETAIN '日期'N '版位'N 點擊次數 放入次數 放入商品數量 丟棄次數 丟棄商品數量 訂單狀況 營收佔比 銷售收入 銷售成本 利潤 
					商品數量 訂單數 毛利率 購物車轉換率 購物車取消率 訂單轉換率 完全轉換率;
			FORMAT 版位 &position_ln 毛利率 購物車轉換率 購物車取消率 訂單轉換率 完全轉換率 PERCENT8.2;
			SET TEST2(DROP=_TYPE_ _FREQ_ RENAME=(版位=版位_TMP 訂單狀況=訂單狀況_TMP));
			毛利率=COALESCE(利潤/銷售收入,0); 購物車轉換率=COALESCE(放入次數/點擊次數,0); 
			購物車取消率=COALESCE(丟棄次數/放入次數,0); 訂單轉換率=COALESCE(訂單數/放入次數,0); 完全轉換率=COALESCE(訂單數/點擊次數,0);
			IF 訂單狀況_TMP="" THEN 訂單狀況="NET"; ELSE 訂單狀況=訂單狀況_TMP;
			IF 版位_TMP="" THEN 版位="全APP"; ELSE 版位=版位_TMP;
			DROP 訂單狀況_TMP 版位_TMP;
		RUN;
		PROC SQL;
			CREATE TABLE TEST3 AS SELECT '日期'N, '版位'N, 點擊次數, 放入次數, 放入商品數量, 丟棄次數, 丟棄商品數量, 
				訂單狀況, 銷售收入/MAX(銷售收入) AS 營收佔比 FORMAT=percent8.2, 
				銷售收入, 銷售成本, 利潤, 商品數量, 訂單數, 毛利率, 購物車轉換率, 購物車取消率, 訂單轉換率, 完全轉換率
			FROM TEST2
			GROUP BY "日期"N
			ORDER BY 完全轉換率 DESC;
		QUIT;
		%_eg_conditional_dropds(TEST2)
		ODS ESCAPECHAR="^";
		ODS REGION;
			ODS TEXT="^S={FONTSIZE=14pt JUST=C}全版位效益";
			GOPTIONS RESET=ALL NOBORDER;
			OPTIONS LOCALE=zh_TW;
			/*TITLE1 %SYSFUNC(CATS(%SYSFUNC(PUTN(&INI_DATE, NLDATEW.)),至, %SYSFUNC(PUTN(&LAST_DATE, NLDATEW.))));*/
			OPTIONS LOCALE=en_US;
			AXIS1 LABEL=NONE OFFSET=(4);
			AXIS2 LABEL=("銷售收入");
			PROC GCHART DATA=TEST;
			PIE '版位'N/SUMVAR='銷售收入'N
				 PERCENT=INSIDE COUTLINE=CX7C5C00 NOHEADING JSTYLE OTHER=3;
			RUN;
			QUIT;
			%_eg_conditional_dropds(TEST)
			ODS TEXT="^S={WIDTH=80% JUST=L}註1：收益佔比小於3 %STR(%%) 的版位都會被歸到OTHER。";
		ODS REGION;
			PROC PRINT DATA=TEST3(WHERE=(版位 IN ('字串1', '字串2', '字串3', '字串4', '字串5', '字串6', '字串7', '全APP'))) 
							NOOBS STYLE(DATA)=[JUST=C VJUST=M] STYLE(HEAD)=[JUST=C VJUST=M BACKGROUNDCOLOR=RGBA765CC833] CONTENTS="";
				VAR 日期 版位 營收佔比 銷售收入 毛利率 購物車轉換率 購物車取消率 訂單轉換率 完全轉換率;
			RUN;
			ODS TEXT="^S={WIDTH=80% JUST=L}註1：表格以完全轉換率做遞減排序。";
			ODS TEXT="^S={WIDTH=80% JUST=L}註2：只含括淨訂單";
		ODS LAYOUT END;
		%_eg_conditional_dropds(TEST3)
		/*%_eg_conditional_dropds(DY_BK_REV)*/
		ODS PDF (ID=DYFIG) STARTPAGE=NOW;
%END;
%ELSE %DO;
	%IF &BKPERALL EQ 1 %THEN %DO;
		OPTIONS NODATE; OPTIONS DEV=ACTXIMG;
			ODS LAYOUT GRIDDED /*STYLE={FONTFAMILY="Microsoft JhengHei"}*/ ROWS=4 COLUMNS=2 COLUMN_WIDTHS=(50pct 50pct) HEIGHT=10in COLUMN_GUTTER=0 ROW_GUTTER=0;
		%_eg_conditional_dropds(TEST)
		PROC SQL;
			CREATE TABLE TEST AS
			SELECT MDY(INPUT(SUBSTR(SUBSTR(日期,FIND(日期,'年'),FIND(日期,'月')-FIND(日期,'年')),ANYDIGIT(SUBSTR(日期,FIND(日期,'年'),FIND(日期,'月')-FIND(日期,'年')))),8.0),
						INPUT(SUBSTR(SUBSTR(日期,FIND(日期,'月'),FIND(日期,'日')-FIND(日期,'月')),ANYDIGIT(SUBSTR(日期,FIND(日期,'月'),FIND(日期,'日')-FIND(日期,'月')))),8.0),
						INPUT(SCAN(日期,1,'年'),8.0)) FORMAT=DATE9. AS 日期 ,版位 ,點擊次數 ,放入次數 ,放入商品數量 ,丟棄次數 ,丟棄商品數量 ,訂單狀況 
					,銷售收入 FORMAT=DOLLAR12.0,銷售成本 FORMAT=DOLLAR12.0,利潤 FORMAT=DOLLAR12.0,商品數量 ,訂單數 ,毛利率 ,購物車轉換率 ,購物車取消率 ,訂單轉換率 ,完全轉換率
			FROM WORK.SS_DY_STATS
			WHERE 訂單狀況 IN('NET','無')
			UNION CORRESPONDING ALL
			SELECT MDY(INPUT(SUBSTR(SUBSTR(日期,FIND(日期,'年'),FIND(日期,'月')-FIND(日期,'年')),ANYDIGIT(SUBSTR(日期,FIND(日期,'年'),FIND(日期,'月')-FIND(日期,'年')))),8.0),
						INPUT(SUBSTR(SUBSTR(日期,FIND(日期,'月'),FIND(日期,'日')-FIND(日期,'月')),ANYDIGIT(SUBSTR(日期,FIND(日期,'月'),FIND(日期,'日')-FIND(日期,'月')))),8.0),
						INPUT(SCAN(日期,1,'年'),8.0)) FORMAT=DATE9. AS 日期 ,版位 ,點擊次數 ,放入次數 ,放入商品數量 ,丟棄次數 ,丟棄商品數量 ,訂單狀況 
					,銷售收入 FORMAT=DOLLAR12.0,銷售成本 FORMAT=DOLLAR12.0,利潤 FORMAT=DOLLAR12.0,商品數量 ,訂單數 ,毛利率 ,購物車轉換率 ,購物車取消率 ,訂單轉換率 ,完全轉換率
			FROM WORK.HOTSALE_DY_STATS
			WHERE 訂單狀況 IN('NET','無')
			UNION CORRESPONDING ALL
			SELECT MDY(INPUT(SUBSTR(SUBSTR(日期,FIND(日期,'年'),FIND(日期,'月')-FIND(日期,'年')),ANYDIGIT(SUBSTR(日期,FIND(日期,'年'),FIND(日期,'月')-FIND(日期,'年')))),8.0),
						INPUT(SUBSTR(SUBSTR(日期,FIND(日期,'月'),FIND(日期,'日')-FIND(日期,'月')),ANYDIGIT(SUBSTR(日期,FIND(日期,'月'),FIND(日期,'日')-FIND(日期,'月')))),8.0),
						INPUT(SCAN(日期,1,'年'),8.0)) FORMAT=DATE9. AS 日期 ,版位 ,點擊次數 ,放入次數 ,放入商品數量 ,丟棄次數 ,丟棄商品數量 ,訂單狀況 
					,銷售收入 FORMAT=DOLLAR12.0,銷售成本 FORMAT=DOLLAR12.0,利潤 FORMAT=DOLLAR12.0,商品數量 ,訂單數 ,毛利率 ,購物車轉換率 ,購物車取消率 ,訂單轉換率 ,完全轉換率
			FROM WORK.REST_DY_STATS
			WHERE 訂單狀況 IN('NET','無');
			CREATE TABLE TR_BK_REV AS
			SELECT 日期 ,版位 ,點擊次數 ,放入次數 ,放入商品數量 ,丟棄次數 ,丟棄商品數量 ,訂單狀況 ,銷售收入/SUM(銷售收入) FORMAT=PERCENT8.2 AS 營收佔比, 銷售收入 ,
					銷售成本 ,利潤 ,商品數量 ,訂單數 ,毛利率 ,購物車轉換率 ,購物車取消率 ,訂單轉換率 ,完全轉換率
			FROM TEST
			GROUP BY 日期
			ORDER BY 日期, 完全轉換率 DESC;
		QUIT;
		%_eg_conditional_dropds(TEST2)
		PROC MEANS DATA=WORK.TR_BK_REV SUM NOPRINT;
			CLASS '日期'N '版位'N '訂單狀況'N;
			VAR 點擊次數 放入次數 放入商品數量 丟棄次數 丟棄商品數量 銷售收入 銷售成本 利潤 商品數量 訂單數;
			TYPES 日期 日期*版位*'訂單狀況'N;
			OUTPUT OUT=TEST2 SUM=點擊次數 放入次數 放入商品數量 丟棄次數 丟棄商品數量 銷售收入 銷售成本 利潤 商品數量 訂單數;
		RUN;
		PROC SQL NOPRINT;
			SELECT MAX(LENGTH(STRIP(版位))) INTO: position_ln FROM TEST2;
		QUIT;
		%LET position_ln=$%SYSFUNC(COMPRESS(&position_ln)).;
		DATA TEST2;
			RETAIN '日期'N '版位'N 點擊次數 放入次數 放入商品數量 丟棄次數 丟棄商品數量 訂單狀況 營收佔比 銷售收入 銷售成本 利潤 
					商品數量 訂單數 毛利率 購物車轉換率 購物車取消率 訂單轉換率 完全轉換率;
			FORMAT 版位 &position_ln 毛利率 購物車轉換率 購物車取消率 訂單轉換率 完全轉換率 PERCENT8.2;
			SET TEST2(DROP=_TYPE_ _FREQ_ RENAME=(版位=版位_TMP 訂單狀況=訂單狀況_TMP));
			毛利率=COALESCE(利潤/銷售收入,0); 購物車轉換率=COALESCE(放入次數/點擊次數,0); 
			購物車取消率=COALESCE(丟棄次數/放入次數,0); 訂單轉換率=COALESCE(訂單數/放入次數,0); 完全轉換率=COALESCE(訂單數/點擊次數,0);
			IF 訂單狀況_TMP="" THEN 訂單狀況="NET"; ELSE 訂單狀況=訂單狀況_TMP;
			IF 版位_TMP="" THEN 版位="全APP"; ELSE 版位=版位_TMP;
			DROP 訂單狀況_TMP 版位_TMP;
		RUN;
		PROC SQL;
			CREATE TABLE TEST3 AS SELECT '日期'N, '版位'N, 點擊次數, 放入次數, 放入商品數量, 丟棄次數, 丟棄商品數量, 
				訂單狀況, 銷售收入/MAX(銷售收入) AS 營收佔比 FORMAT=percent8.2, 
				銷售收入, 銷售成本, 利潤, 商品數量, 訂單數, 毛利率, 購物車轉換率, 購物車取消率, 訂單轉換率, 完全轉換率
			FROM TEST2
			GROUP BY "日期"N;
		QUIT;
		%_eg_conditional_dropds(TEST2)
		%LET count=1;
		%DO i=&INI_DATE %TO &LAST_DATE %BY 1;
			ODS ESCAPECHAR="^";
			ODS REGION COLUMN_SPAN=2 HEIGHT=5pct;
				OPTIONS LOCALE=zh_TW;
				ODS TEXT="^S={FONTSIZE=14pt WIDTH=100% JUST=C}%SYSFUNC(PUTN(&i, NLDATEW.)) 版位效益";
			ODS REGION HEIGHT=45pct;
				GOPTIONS RESET=ALL NOBORDER;
				%_eg_conditional_dropds(TR_BK_REV_TMP)
				DATA TR_BK_REV_TMP;
					SET TEST3;
					WHERE 日期 EQ &i;
				RUN;
				PROC SORT DATA=TR_BK_REV_TMP;
					BY 日期 DESCENDING 完全轉換率;
				RUN;
				PROC GCHART DATA=TR_BK_REV_TMP(WHERE=(版位 ^= '其它'));
					VBAR 版位/SUMVAR=銷售收入 DESCENDING NOFR SPACE=0;
				RUN; QUIT;
				OPTIONS LOCALE=en_US;
			ODS REGION HEIGHT=45pct;
				ODS TEXT="^S={WIDTH=80% JUST=L} "; ODS TEXT="^S={WIDTH=80% JUST=L} "; 
				ODS TEXT="^S={WIDTH=80% JUST=L} "; ODS TEXT="^S={WIDTH=80% JUST=L} ";
				PROC PRINT DATA=TR_BK_REV_TMP(WHERE=(版位 IN ('東科推薦商品', '宇匯推薦商品', '知心商品', '好康商品', '即時新品', '專屬推薦', '季節商品', '全APP'))) 
								NOOBS STYLE(DATA)=[JUST=C VJUST=M] STYLE(HEAD)=[JUST=C VJUST=M BACKGROUNDCOLOR=RGBA765CC833] CONTENTS="";
					VAR 日期 版位 營收佔比 銷售收入 毛利率 完全轉換率;
				RUN;
			%IF %SYSFUNC(MOD(&count,2)) EQ 0 AND &i NE &LAST_DATE %THEN %DO; ODS PDF (ID=DYFIG) STARTPAGE=NOW; %END;
			%IF &i EQ &LAST_DATE %THEN %DO; ODS PDF (ID=DYFIG) STARTPAGE=NOW; %END;
			%LET count=%EVAL(&count+1);
		%END; /*Loop end*/
		ODS LAYOUT END;
		ODS LAYOUT GRIDDED /*STYLE={FONTFAMILY="Microsoft JhengHei"}*/ ROWS=3 COLUMNS=2 COLUMN_WIDTHS=(50pct 50pct) HEIGHT=10in;
		ODS REGION COLUMN_SPAN=2 HEIGHT=5pct;
			OPTIONS LOCALE=zh_TW;
			ODS TEXT="^S={FONTSIZE=14pt JUST=C}%SYSFUNC(STRIP(%SYSFUNC(PUTN(&INI_DATE, NLDATEW.))))到%SYSFUNC(STRIP(%SYSFUNC(PUTN(&LAST_DATE, NLDATEW.)))) 版位效益";
		ODS REGION HEIGHT=44pct;
			GOPTIONS RESET=ALL NOBORDER DEV=SVG;
			PROC GCHART DATA=WORK.TR_STATS(WHERE=(版位 NE '其它' AND 版位 NE '全APP'));
				VBAR '版位'N/SUMVAR='銷售收入'N DESCENDING NOFR SPACE=0; RUN;
			QUIT;
		ODS REGION HEIGHT=44pct;
			ODS TEXT="^S={WIDTH=80% JUST=L} "; ODS TEXT="^S={WIDTH=80% JUST=L} "; 
			ODS TEXT="^S={WIDTH=80% JUST=L} "; ODS TEXT="^S={WIDTH=80% JUST=L} ";
			PROC PRINT DATA=WORK.TR_STATS(WHERE=(版位 IN ('東科推薦商品', '宇匯推薦商品', '知心商品', '好康商品', '即時新品', '專屬推薦', '季節商品', '全APP'))) 
								NOOBS STYLE(DATA)=[JUST=C VJUST=M] STYLE(HEAD)=[JUST=C VJUST=M BACKGROUNDCOLOR=RGBA765CC833] CONTENTS="";
					VAR 版位 營收佔比 銷售收入 毛利率 完全轉換率;
				RUN;
		ODS REGION COLUMN_SPAN=2 HEIGHT=44pct;
			ODS TEXT="^S={FONTSIZE=14pt JUST=C}版位效益趨勢";
			GOPTIONS RESET=ALL NOBORDER DEV=SVG;
			PROC SGPLOT DATA=WORK.TR_BK_REV(WHERE=("版位"N IN ("東科推薦商品", "宇匯推薦商品", "知心商品", "好康商品", "即時新品", "專屬推薦", "季節商品")));
				VLINE '日期'N/RESPONSE='銷售收入'N GROUP='版位'N LINEATTRS=(PATTERN=SOLID);
				XAXIS DISPLAY=(NOLABEL); YAXIS DISPLAY=(NOLABEL);
				KEYLEGEND/ TITLE="版位" TITLEATTRS=(FAMILY=BiauKai SIZE=12) VALUEATTRS=(FAMILY=BiauKai SIZE=9);
			RUN; QUIT;
		ODS LAYOUT END;
		ODS PDF (ID=DYFIG) STARTPAGE=NOW;
		%_eg_conditional_dropds(TEST)
		%_eg_conditional_dropds(TR_BK_REV)
		%_eg_conditional_dropds(TR_BK_REV_TMP)
	%END;
	%ELSE %DO;
		OPTIONS NODATE; OPTIONS DEV=ACTXIMG;
		ODS LAYOUT GRIDDED /*STYLE={FONTFAMILY="Microsoft JhengHei"}*/ ROWS=4 COLUMNS=2 COLUMN_WIDTHS=(50pct 50pct) HEIGHT=10in COLUMN_GUTTER=0 ROW_GUTTER=0;
		%_eg_conditional_dropds(TEST)
		PROC SQL;
			CREATE TABLE TEST AS
			SELECT MDY(INPUT(SUBSTR(SUBSTR(日期,FIND(日期,'年'),FIND(日期,'月')-FIND(日期,'年')),ANYDIGIT(SUBSTR(日期,FIND(日期,'年'),FIND(日期,'月')-FIND(日期,'年')))),8.0),
						INPUT(SUBSTR(SUBSTR(日期,FIND(日期,'月'),FIND(日期,'日')-FIND(日期,'月')),ANYDIGIT(SUBSTR(日期,FIND(日期,'月'),FIND(日期,'日')-FIND(日期,'月')))),8.0),
						INPUT(SCAN(日期,1,'年'),8.0)) FORMAT=DATE9. AS 日期 ,版位 ,點擊次數 ,放入次數 ,放入商品數量 ,丟棄次數 ,丟棄商品數量 ,訂單狀況 
					,銷售收入 FORMAT=DOLLAR12.0,銷售成本 FORMAT=DOLLAR12.0,利潤 FORMAT=DOLLAR12.0,商品數量 ,訂單數 ,毛利率 ,購物車轉換率 ,購物車取消率 ,訂單轉換率 ,完全轉換率
			FROM WORK.SS_DY_STATS
			WHERE 訂單狀況 IN('NET','無')
			UNION CORRESPONDING ALL
			SELECT MDY(INPUT(SUBSTR(SUBSTR(日期,FIND(日期,'年'),FIND(日期,'月')-FIND(日期,'年')),ANYDIGIT(SUBSTR(日期,FIND(日期,'年'),FIND(日期,'月')-FIND(日期,'年')))),8.0),
						INPUT(SUBSTR(SUBSTR(日期,FIND(日期,'月'),FIND(日期,'日')-FIND(日期,'月')),ANYDIGIT(SUBSTR(日期,FIND(日期,'月'),FIND(日期,'日')-FIND(日期,'月')))),8.0),
						INPUT(SCAN(日期,1,'年'),8.0)) FORMAT=DATE9. AS 日期 ,版位 ,點擊次數 ,放入次數 ,放入商品數量 ,丟棄次數 ,丟棄商品數量 ,訂單狀況 
					,銷售收入 FORMAT=DOLLAR12.0,銷售成本 FORMAT=DOLLAR12.0,利潤 FORMAT=DOLLAR12.0,商品數量 ,訂單數 ,毛利率 ,購物車轉換率 ,購物車取消率 ,訂單轉換率 ,完全轉換率
			FROM WORK.HOTSALE_DY_STATS
			WHERE 訂單狀況 IN('NET','無')
			UNION CORRESPONDING ALL
			SELECT MDY(INPUT(SUBSTR(SUBSTR(日期,FIND(日期,'年'),FIND(日期,'月')-FIND(日期,'年')),ANYDIGIT(SUBSTR(日期,FIND(日期,'年'),FIND(日期,'月')-FIND(日期,'年')))),8.0),
						INPUT(SUBSTR(SUBSTR(日期,FIND(日期,'月'),FIND(日期,'日')-FIND(日期,'月')),ANYDIGIT(SUBSTR(日期,FIND(日期,'月'),FIND(日期,'日')-FIND(日期,'月')))),8.0),
						INPUT(SCAN(日期,1,'年'),8.0)) FORMAT=DATE9. AS 日期 ,版位 ,點擊次數 ,放入次數 ,放入商品數量 ,丟棄次數 ,丟棄商品數量 ,訂單狀況 
					,銷售收入 FORMAT=DOLLAR12.0,銷售成本 FORMAT=DOLLAR12.0,利潤 FORMAT=DOLLAR12.0,商品數量 ,訂單數 ,毛利率 ,購物車轉換率 ,購物車取消率 ,訂單轉換率 ,完全轉換率
			FROM WORK.REST_DY_STATS
			WHERE 訂單狀況 IN('NET','無');
			CREATE TABLE TR_BK_REV AS
			SELECT 日期 ,版位 ,點擊次數 ,放入次數 ,放入商品數量 ,丟棄次數 ,丟棄商品數量 ,訂單狀況 ,銷售收入/SUM(銷售收入) FORMAT=PERCENT8.2 AS 營收佔比, 銷售收入 ,
					銷售成本 ,利潤 ,商品數量 ,訂單數 ,毛利率 ,購物車轉換率 ,購物車取消率 ,訂單轉換率 ,完全轉換率
			FROM TEST
			GROUP BY 日期
			ORDER BY 日期, 完全轉換率 DESC;
		QUIT;
		%_eg_conditional_dropds(TEST2)
		PROC MEANS DATA=WORK.TR_BK_REV SUM NOPRINT;
			CLASS '日期'N '版位'N '訂單狀況'N;
			VAR 點擊次數 放入次數 放入商品數量 丟棄次數 丟棄商品數量 銷售收入 銷售成本 利潤 商品數量 訂單數;
			TYPES 日期 日期*版位*'訂單狀況'N;
			OUTPUT OUT=TEST2 SUM=點擊次數 放入次數 放入商品數量 丟棄次數 丟棄商品數量 銷售收入 銷售成本 利潤 商品數量 訂單數;
		RUN;
		PROC SQL NOPRINT;
			SELECT MAX(LENGTH(STRIP(版位))) INTO: position_ln FROM TEST2;
		QUIT;
		%LET position_ln=$%SYSFUNC(COMPRESS(&position_ln)).;
		DATA TEST2;
			RETAIN '日期'N '版位'N 點擊次數 放入次數 放入商品數量 丟棄次數 丟棄商品數量 訂單狀況 營收佔比 銷售收入 銷售成本 利潤 
					商品數量 訂單數 毛利率 購物車轉換率 購物車取消率 訂單轉換率 完全轉換率;
			FORMAT 版位 &position_ln 毛利率 購物車轉換率 購物車取消率 訂單轉換率 完全轉換率 PERCENT8.2;
			SET TEST2(DROP=_TYPE_ _FREQ_ RENAME=(版位=版位_TMP 訂單狀況=訂單狀況_TMP));
			毛利率=COALESCE(利潤/銷售收入,0); 購物車轉換率=COALESCE(放入次數/點擊次數,0); 
			購物車取消率=COALESCE(丟棄次數/放入次數,0); 訂單轉換率=COALESCE(訂單數/放入次數,0); 完全轉換率=COALESCE(訂單數/點擊次數,0);
			IF 訂單狀況_TMP="" THEN 訂單狀況="NET"; ELSE 訂單狀況=訂單狀況_TMP;
			IF 版位_TMP="" THEN 版位="全APP"; ELSE 版位=版位_TMP;
			DROP 訂單狀況_TMP 版位_TMP;
		RUN;
		PROC SQL;
			CREATE TABLE TEST3 AS SELECT '日期'N, '版位'N, 點擊次數, 放入次數, 放入商品數量, 丟棄次數, 丟棄商品數量, 
				訂單狀況, 銷售收入/MAX(銷售收入) AS 營收佔比 FORMAT=percent8.2, 
				銷售收入, 銷售成本, 利潤, 商品數量, 訂單數, 毛利率, 購物車轉換率, 購物車取消率, 訂單轉換率, 完全轉換率
			FROM TEST2
			GROUP BY "日期"N;
		QUIT;
		%_eg_conditional_dropds(TEST2)
		ODS ESCAPECHAR="^";
		ODS REGION COLUMN_SPAN=2 HEIGHT=5pct;
			OPTIONS LOCALE=zh_TW;
			ODS TEXT="^S={FONTSIZE=14pt WIDTH=100% JUST=C}%SYSFUNC(PUTN(&LAST_DATE, NLDATEW.)) 版位效益";
		ODS REGION HEIGHT=45pct;
			GOPTIONS RESET=ALL NOBORDER;
			%_eg_conditional_dropds(TR_BK_REV_TMP)
			DATA TR_BK_REV_TMP;
				SET TEST3;
				WHERE 日期 EQ &LAST_DATE;
			RUN;
			PROC SORT DATA=TR_BK_REV_TMP;
				BY 日期 DESCENDING 完全轉換率;
			RUN;
			PROC GCHART DATA=TR_BK_REV_TMP(WHERE=("版位"N ^= "其它" AND "版位"N ^= "全APP"));
				VBAR 版位/SUMVAR=銷售收入 DESCENDING NOFR SPACE=0;
			RUN; QUIT;
			OPTIONS LOCALE=en_US;
		ODS REGION HEIGHT=45pct;
			ODS TEXT="^S={WIDTH=80% JUST=L} "; ODS TEXT="^S={WIDTH=80% JUST=L} "; 
			ODS TEXT="^S={WIDTH=80% JUST=L} "; ODS TEXT="^S={WIDTH=80% JUST=L} ";
			PROC PRINT DATA=TR_BK_REV_TMP(WHERE=(版位 IN ('其它', '東科推薦商品', '宇匯推薦商品', '知心商品', '好康商品', '即時新品', '專屬推薦', '季節商品', '全APP'))) 
							NOOBS STYLE(DATA)=[JUST=C VJUST=M] STYLE(HEAD)=[JUST=C VJUST=M BACKGROUNDCOLOR=RGBA765CC833] CONTENTS="";
				VAR 版位 營收佔比 銷售收入 毛利率 完全轉換率;
			RUN;
			
		ODS LAYOUT END;
		ODS PDF (ID=DYFIG) STARTPAGE=NOW;
		ODS LAYOUT GRIDDED /*STYLE={FONTFAMILY="Microsoft JhengHei"}*/ ROWS=3 COLUMNS=2 COLUMN_WIDTHS=(50pct 50pct) HEIGHT=10in;
		ODS REGION COLUMN_SPAN=2 HEIGHT=5pct;
			OPTIONS LOCALE=zh_TW;
			ODS TEXT="^S={FONTSIZE=14pt JUST=C}%SYSFUNC(STRIP(%SYSFUNC(PUTN(&INI_DATE, NLDATEW.))))到%SYSFUNC(STRIP(%SYSFUNC(PUTN(&LAST_DATE, NLDATEW.)))) 版位效益";
		ODS REGION HEIGHT=44pct;
			GOPTIONS RESET=ALL NOBORDER DEV=SVG;
			PROC GCHART DATA=WORK.TR_STATS(WHERE=(版位 NE '其它' AND 版位 NE '全APP'));
				VBAR '版位'N/SUMVAR='銷售收入'N DESCENDING NOFR SPACE=0; RUN;
			QUIT;
		ODS REGION HEIGHT=44pct;
			ODS TEXT="^S={WIDTH=80% JUST=L} "; ODS TEXT="^S={WIDTH=80% JUST=L} "; 
			ODS TEXT="^S={WIDTH=80% JUST=L} "; ODS TEXT="^S={WIDTH=80% JUST=L} ";
			PROC PRINT DATA=WORK.TR_STATS(WHERE=(版位 IN ('東科推薦商品', '宇匯推薦商品', '知心商品', '好康商品', '即時新品', '專屬推薦', '季節商品', '全APP'))) 
								NOOBS STYLE(DATA)=[JUST=C VJUST=M] STYLE(HEAD)=[JUST=C VJUST=M BACKGROUNDCOLOR=RGBA765CC833] CONTENTS="";
					VAR 版位 營收佔比 銷售收入 毛利率 完全轉換率;
				RUN;
		ODS REGION COLUMN_SPAN=2 HEIGHT=44pct;
			ODS TEXT="^S={FONTSIZE=14pt JUST=C}版位效益趨勢";
			GOPTIONS RESET=ALL NOBORDER DEV=SVG;
			PROC SGPLOT DATA=WORK.TR_BK_REV(WHERE=("版位"N IN ("東科推薦商品", "宇匯推薦商品", "知心商品", "好康商品", "即時新品", "專屬推薦", "季節商品")));
				VLINE '日期'N/RESPONSE='銷售收入'N GROUP='版位'N;
				XAXIS DISPLAY=(NOLABEL); YAXIS DISPLAY=(NOLABEL);
				KEYLEGEND/ TITLE="版位" TITLEATTRS=(FAMILY=BiauKai SIZE=12) VALUEATTRS=(FAMILY=BiauKai SIZE=9);
			RUN; QUIT;
		ODS LAYOUT END;
		ODS PDF (ID=DYFIG) STARTPAGE=NOW;
		%_eg_conditional_dropds(TEST)
		/*%_eg_conditional_dropds(TR_BK_REV)*/
		%_eg_conditional_dropds(TR_BK_REV_TMP)
	%END;
%END;
%MEND;
/*
	Input requirement：WORK.M_N_O_SUMMARY, WORK.M_N_O_SUMMARY, WORK.NET_LIST_AMOUNT, WORK.NET_LIST_MN
*/
%MACRO generateRepetitiveCustomer;
%IF %SYSFUNC(DATDIF(&INI_DATE,&LAST_DATE,ACT/ACT)) EQ 0 %THEN %DO;
	OPTIONS NODATE; OPTIONS DEV=ACTXIMG;
	OPTIONS LOCALE=zh_TW;
	%_eg_conditional_dropds(M_O_O_STATS)
	%_eg_conditional_dropds(M_N_O_STATS)
	PROC MEANS DATA=WORK.M_O_O_SUMMARY(WHERE=(Date=&LAST_DATE)) SUM NOPRINT;
		CLASS Date "OrderStatus"N eraddsc;
		VAR "銷售收入"N "商品數量"N "訂單數"N "顧客數"N;
		TYPES ()*"OrderStatus"N Date*eraddsc*"OrderStatus"N;
		OUTPUT OUT=M_O_O_STATS SUM="銷售收入"N "商品數量"N "訂單數"N "顧客數"N;
	RUN;
	/*Fetch the related length info for the latter recreation of data.*/
	PROC SQL NOPRINT;
		SELECT length  INTO: VARN1-:VARN2 FROM DICTIONARY.COLUMNS 
					WHERE LIBNAME="WORK" AND MEMNAME="M_O_O_SUMMARY" AND VARNUM BETWEEN 2 AND 3
					ORDER BY name;
	QUIT;
	%LET VARN1=$&VARN1..; %LET VARN2=$&VARN2..;
	/*Generate the stats.*/
	DATA M_O_O_STATS(DROP=Date_TMP OrderStatusTMP eraddsc_tmp);
		RETAIN "日期"N "版位"N "訂單狀況"N "銷售收入"N "商品數量"N "訂單數"N;
		FORMAT "日期"N $36. "訂單狀況"N &VARN1 "版位"N &VARN2 "銷售收入"N NLMNITWD22.0 "商品數量"N "訂單數"N COMMA9.0;
		SET M_O_O_STATS (DROP=_TYPE_ _FREQ_ RENAME=(Date=Date_TMP "OrderStatus"N=OrderStatusTMP eraddsc=eraddsc_tmp));
		"日期"N=CATS(PUT(&LAST_DATE, NLDATEW.));
		IF OrderStatusTMP NE "" THEN "訂單狀況"N=OrderStatusTMP; ELSE "訂單狀況"N="全";
		IF eraddsc_tmp NE "" THEN "版位"N=eraddsc_tmp; ELSE "版位"N="全版位";
	RUN;
	/*
		Whole-time range stats for the new customers.
	*/
	PROC MEANS DATA=WORK.M_N_O_SUMMARY(WHERE=(Date=&LAST_DATE)) SUM NOPRINT;
		CLASS Date "OrderStatus"N eraddsc;
		VAR "銷售收入"N "商品數量"N "訂單數"N "顧客數"N;
		TYPES ()*"OrderStatus"N Date*eraddsc*"OrderStatus"N;
		OUTPUT OUT=M_N_O_STATS SUM="銷售收入"N "商品數量"N "訂單數"N "顧客數"N;
	RUN;
	/*Fetch the related length info for the latter recreation of data.*/
	PROC SQL NOPRINT;
		SELECT length INTO :VARN1-:VARN2 FROM DICTIONARY.COLUMNS 
					WHERE LIBNAME="WORK" AND MEMNAME="M_N_O_STATS" AND VARNUM BETWEEN 2 AND 3
					ORDER BY name;
	QUIT;
	%LET VARN1=$&VARN1..; %LET VARN2=$&VARN2..;
	/*Generate the stats.*/
	DATA M_N_O_STATS(DROP=Date_TMP OrderStatusTMP eraddsc_tmp);
		RETAIN "日期"N "版位"N "訂單狀況"N "銷售收入"N "商品數量"N "訂單數"N;
		FORMAT "日期"N $36. "訂單狀況"N &VARN1 "版位"N &VARN2 "銷售收入"N NLMNITWD22.0 "商品數量"N "訂單數"N COMMA9.0;
		SET M_N_O_STATS (DROP=_TYPE_ _FREQ_ RENAME=(Date=Date_TMP "OrderStatus"N=OrderStatusTMP eraddsc=eraddsc_tmp));
		"日期"N=CATS(PUT(&LAST_DATE, NLDATEW.));
		IF OrderStatusTMP NE "" THEN "訂單狀況"N=OrderStatusTMP; ELSE "訂單狀況"N="全";
		IF eraddsc_tmp NE "" THEN "版位"N=eraddsc_tmp; ELSE "版位"N="全版位";
	RUN;
	OPTIONS LOCALE=en_US;
	/*
		Generate the whole-range stats based on all app and blocks.
	*/
	PROC SQL;
		CREATE TABLE All_APP_N_O_R AS /*N_O_R stands for revenue from the old and new customers.*/
		SELECT "日期"N, "回頭客" FORMAT=$9. AS "客戶類型"N, "版位"N, "訂單狀況"N, "銷售收入"N FORMAT=DOLLAR12.0, "銷售收入"N/"顧客數"N AS "客單價（AS）"N  FORMAT=DOLLAR12.0,
				"銷售收入"N/"訂單數"N AS "平均訂單價值（AOV）"N FORMAT=DOLLAR12.0, "商品數量"N/"訂單數"N AS "平均訂單量（AOS）"N FORMAT=COMMA9.2
		FROM M_O_O_STATS
		UNION CORR ALL
		SELECT "日期"N, "新客" FORMAT=$9. AS "客戶類型"N, "版位"N, "訂單狀況"N, "銷售收入"N FORMAT=DOLLAR12.0, "銷售收入"N/"顧客數"N AS "客單價（AS）"N  FORMAT=DOLLAR12.0,
				"銷售收入"N/"訂單數"N AS "平均訂單價值（AOV）"N FORMAT=DOLLAR12.0, "商品數量"N/"訂單數"N AS "平均訂單量（AOS）"N FORMAT=COMMA9.2
		FROM M_N_O_STATS;
	QUIT;
	PROC SORT DATA=All_APP_N_O_R;
		BY "日期"N "版位"N;
	RUN;
	%_eg_conditional_dropds(M_O_O_STATS)
	%_eg_conditional_dropds(M_N_O_STATS)
	/*
		Generate the pie chart based on the previous dataset, All_APP_N_O_R.
	*/
	%_eg_conditional_dropds(All_APP_N_O_R_TMP)
	%_eg_conditional_dropds(Personal_N_O_R_TMP)
	%_eg_conditional_dropds(HotSale_N_O_R_TMP)
	PROC SQL NOPRINT;
		CREATE TABLE All_APP_N_O_R_TMP AS SELECT * FROM All_APP_N_O_R WHERE "版位"N = "全版位";
		CREATE TABLE Personal_N_O_R_TMP AS SELECT * FROM All_APP_N_O_R WHERE "版位"N IN ("即時新品", "好康商品", "季節商品", "知心商品", "專屬推薦");
		CREATE TABLE HotSale_N_O_R_TMP AS SELECT * FROM All_APP_N_O_R WHERE "版位"N IN ("宇匯推薦商品", "東科推薦商品");
	QUIT;
	/*Page 1*/
	ODS LAYOUT GRIDDED /*STYLE={FONTFAMILY="Microsoft JhengHei"}*/
						COLUMNS=2 ROWS=3 COLUMN_WIDTHS=(50% 50%) HEIGHT=10in COLUMN_GUTTER=0 ROW_GUTTER=0;
	ODS ESCAPECHAR="^"; OPTIONS LOCALE=zh_TW;
	ODS REGION COLUMN_SPAN=2 HEIGHT=5pct;
		ODS TEXT="^S={OUTPUTWIDTH=100% FONTSIZE=13pt JUST=C}%SYSFUNC(COMPRESS(%SYSFUNC(CATS(%SYSFUNC(PUTN(&LAST_DATE, NLDATEW.)), 全APP新舊客比例))))"; OPTIONS LOCALE=en_US;
	ODS REGION COLUMN_SPAN=2 HEIGHT=50pct;
		GOPTIONS RESET=ALL DEVICE=SVG NOBORDER HSIZE=7in VSIZE=4.6in;
		PATTERN1 C=CX4965B0; PATTERN2 C=CXFF7B58; PATTERN3 C=CX95B60E;
		PROC GCHART DATA=All_APP_N_O_R_TMP;
			PIE "客戶類型"N/SUMVAR="銷售收入"N GROUP="訂單狀況"N MIDPOINTS="回頭客" "新客"
				 ACROSS=2 DOWN=2 PERCENT=arrow COUTLINE=CX7C5C00 NOHEADING;
			RUN;
		QUIT;
	ODS REGION COLUMN_SPAN=2 HEIGHT=45pct; OPTIONS LOCALE=zh_TW;
		ODS TEXT="^S={OUTPUTWIDTH=100% FONTSIZE=12pt JUST=C}%SYSFUNC(COMPRESS(%SYSFUNC(PUTN(&LAST_DATE, NLDATEW.))))訂單資訊與銷退細節"; OPTIONS LOCALE=en_US;
		PROC PRINT DATA=All_APP_N_O_R_TMP NOOBS STYLE(DATA)=[JUST=C VJUST=M] STYLE(HEAD)=[JUST=C VJUST=M BACKGROUNDCOLOR=RGBAAA393933] CONTENTS="" LABEL;
		QUIT;
		ODS TEXT="^S={OUTPUTWIDTH=85% JUST=L}註1：客單價=銷售收入÷顧客數";
		ODS TEXT="^S={OUTPUTWIDTH=85% JUST=L}註2：平均訂單價值=銷售收入÷訂單數";
		ODS TEXT="^S={OUTPUTWIDTH=85% JUST=L}註3：平均訂單量=商品數量÷訂單數";
		PROC PRINT DATA=WORK.DETAILED_R_LIST NOOBS STYLE(DATA)=[JUST=C VJUST=M] STYLE(HEAD)=[JUST=C VJUST=M BACKGROUNDCOLOR=RGBA765CC833] CONTENTS="" LABEL;
			VAR customerid SALENO SALENAME 銷售收入 數量;
			LABEL customerid=客代 SALENAME=商品名稱 SALENO=銷售編號 數量=商品數量 銷售收入=金額;
		QUIT;
	ODS LAYOUT END;
	%_eg_conditional_dropds(All_APP_N_O_R_TMP)
	ODS PDF (ID=DYFIG) STARTPAGE=NOW;
	/*Page 2*/
	ODS LAYOUT GRIDDED STYLE={FONTFAMILY="Microsoft JhengHei"}
						COLUMNS=2 ROWS=4 COLUMN_WIDTHS=(50% 50%) HEIGHT=10in COLUMN_GUTTER=0 ROW_GUTTER=0;
	/*%LET tmp_ftnt_1=%NRSTR(註1：細節圓餅圖只呈現「淨」訂單的分布。);
	TITLE2 專屬推薦與精選好物; FOOTNOTE1 &tmp_ftnt_1;*/
	ODS REGION COLUMN_SPAN=2 HEIGHT=5pct; OPTIONS LOCALE=zh_TW;
		ODS TEXT="^S={OUTPUTWIDTH=100% FONTSIZE=13pt JUST=C}%SYSFUNC(COMPRESS(%SYSFUNC(CATS(%SYSFUNC(PUTN(&LAST_DATE, NLDATEW.)), 專屬推薦與精選好物新舊客))))"; OPTIONS LOCALE=en_US;
	ODS REGION COLUMN_SPAN=2 HEIGHT=48pct;
		GOPTIONS HSIZE=7.01in VSIZE=4.61in;
		PROC GCHART DATA=Personal_N_O_R_TMP;
			VBAR "版位"N/SUMVAR="銷售收入"N GROUP="訂單狀況"N SUBGROUP="客戶類型"N SPACE=0;
			RUN;
		QUIT;
	ODS REGION COLUMN_SPAN=2 HEIGHT=24pct;
		ODS TEXT="^S={OUTPUTWIDTH=100% FONTSIZE=10pt JUST=C}訂單資訊";
		PROC PRINT DATA=Personal_N_O_R_TMP NOOBS STYLE(DATA)=[JUST=C VJUST=M] STYLE(HEAD)=[JUST=C VJUST=M BACKGROUNDCOLOR=RGBAAA393933] CONTENTS="" LABEL;
		QUIT;
	ODS REGION HEIGHT=23pct;
		ODS TEXT="^S={OUTPUTWIDTH=100% FONTSIZE=10pt JUST=C}金額排行榜(淨訂單)";
		PROC PRINT DATA=WORK.NET_LIST_MN(WHERE=(eraddsc IN ('專屬推薦', '知心商品', '即時新品', '好康商品', '季節商品') AND Date EQ &LAST_DATE)) NOOBS 
					STYLE(DATA)=[JUST=C VJUST=M] STYLE(HEAD)=[JUST=C VJUST=M BACKGROUNDCOLOR=RGBA469E3433] CONTENTS="" LABEL;
			VAR eraddsc customerid '金額'N '數量'N;
			LABEL eraddsc=版位 customerid=客代;
		QUIT;
		ODS TEXT="^S={OUTPUTWIDTH=70% JUST=L}註1：只呈現每個版位的前三名。";
	ODS REGION HEIGHT=23pct;
		ODS TEXT="^S={OUTPUTWIDTH=100% FONTSIZE=10pt JUST=C}數量排行榜(淨訂單)";
			PROC PRINT DATA=WORK.NET_LIST_AMOUNT(WHERE=(eraddsc IN ('專屬推薦', '知心商品', '即時新品', '好康商品', '季節商品') AND Date EQ &LAST_DATE)) NOOBS 
						STYLE(DATA)=[JUST=C VJUST=M] STYLE(HEAD)=[JUST=C VJUST=M BACKGROUNDCOLOR=RGBA469E3433] CONTENTS="" LABEL;
				VAR eraddsc customerid '金額'N '數量'N;
				LABEL eraddsc=版位 customerid=客代;
			QUIT;
		ODS TEXT="^S={OUTPUTWIDTH=70% JUST=L}註1：只呈現每個版位的前三名。";
	ODS LAYOUT END;
	%_eg_conditional_dropds(Personal_N_O_R_TMP)
	ODS PDF (ID=DYFIG) STARTPAGE=NOW;
	/*Page 3*/
	ODS LAYOUT GRIDDED /*STYLE={FONTFAMILY="Microsoft JhengHei"}*/
						COLUMNS=2 ROWS=4 COLUMN_WIDTHS=(50% 50%) HEIGHT=10in COLUMN_GUTTER=0 ROW_GUTTER=0;
	ODS REGION COLUMN_SPAN=2 HEIGHT=5pct; OPTIONS LOCALE=zh_TW;
		ODS TEXT="^S={OUTPUTWIDTH=100% FONTSIZE=13pt JUST=C}%SYSFUNC(COMPRESS(%SYSFUNC(CATS(%SYSFUNC(PUTN(&LAST_DATE, NLDATEW.)), 當日熱賣新舊客))))"; OPTIONS LOCALE=en_US;
	ODS REGION COLUMN_SPAN=2 HEIGHT=48pct;
		GOPTIONS HSIZE=7.02in VSIZE=4.62in;
		PROC GCHART DATA=HotSale_N_O_R_TMP;
			VBAR "版位"N/SUMVAR="銷售收入"N GROUP="訂單狀況"N SUBGROUP="客戶類型"N SPACE=0;
			RUN;
		QUIT;
	ODS REGION COLUMN_SPAN=2 HEIGHT=24pct;
		ODS TEXT="^S={OUTPUTWIDTH=100% FONTSIZE=10pt JUST=C}訂單資訊";
		PROC PRINT DATA=HotSale_N_O_R_TMP NOOBS STYLE(DATA)=[JUST=C VJUST=M] STYLE(HEAD)=[JUST=C VJUST=M BACKGROUNDCOLOR=RGBAAA393933] CONTENTS="" LABEL;
		QUIT;
		%_eg_conditional_dropds(HotSale_N_O_R_TMP)
	ODS REGION HEIGHT=23pct;
		ODS TEXT="^S={OUTPUTWIDTH=100% FONTSIZE=10pt JUST=C}金額排行榜(淨訂單)";
		PROC PRINT DATA=WORK.NET_LIST_MN(WHERE=(eraddsc IN ('宇匯推薦商品', '東科推薦商品') AND Date EQ &LAST_DATE)) NOOBS 
					STYLE(DATA)=[JUST=C VJUST=M] STYLE(HEAD)=[JUST=C VJUST=M BACKGROUNDCOLOR=RGBA469E3433] CONTENTS="" LABEL;
			VAR eraddsc customerid '金額'N '數量'N;
			LABEL eraddsc=版位 customerid=客代;
		QUIT;
		ODS TEXT="^S={OUTPUTWIDTH=70% JUST=L}註1：只呈現每個版位的前三名。";
	ODS REGION HEIGHT=23pct;
		ODS TEXT="^S={OUTPUTWIDTH=100% FONTSIZE=10pt JUST=C}數量排行榜(淨訂單)";
		PROC PRINT DATA=WORK.NET_LIST_AMOUNT(WHERE=(eraddsc IN ('宇匯推薦商品', '東科推薦商品') AND Date EQ &LAST_DATE)) NOOBS 
					STYLE(DATA)=[JUST=C VJUST=M] STYLE(HEAD)=[JUST=C VJUST=M BACKGROUNDCOLOR=RGBA469E3433] CONTENTS="" LABEL;
			VAR eraddsc customerid '金額'N '數量'N;
			LABEL eraddsc=版位 customerid=客代;
		QUIT;
		ODS TEXT="^S={OUTPUTWIDTH=70% JUST=L}註1：只呈現每個版位的前三名。";
	ODS LAYOUT END;
	ODS PDF (ID=DYFIG) STARTPAGE=NOW;
	ODS _ALL_ CLOSE;
%END;
/*Time range*/
%ELSE %DO;
	%IF &RCALL EQ 1 %THEN %DO;
		OPTIONS NODATE; OPTIONS DEV=ACTXIMG;
			OPTIONS LOCALE=zh_TW;
			%LET h_count=1; %LET v_count=1;
			%_eg_conditional_dropds(M_O_O_STATS)
			%_eg_conditional_dropds(M_N_O_STATS)
			PROC MEANS DATA=WORK.M_O_O_SUMMARY SUM NOPRINT;
				CLASS Date "OrderStatus"N eraddsc;
				VAR "銷售收入"N "商品數量"N "訂單數"N "顧客數"N;
				TYPES ()*"OrderStatus"N ()*eraddsc*"OrderStatus"N Date*"OrderStatus"N Date*eraddsc*"OrderStatus"N;
				OUTPUT OUT=M_O_O_STATS SUM="銷售收入"N "商品數量"N "訂單數"N "顧客數"N;
			RUN;
			/*Fetch the related length info for the latter recreation of data.*/
			PROC SQL NOPRINT;
				SELECT length  INTO: VARN1-:VARN2 FROM DICTIONARY.COLUMNS 
							WHERE LIBNAME="WORK" AND MEMNAME="M_O_O_SUMMARY" AND VARNUM BETWEEN 2 AND 3
							ORDER BY name;
			QUIT;
			%LET VARN1=$&VARN1..; %LET VARN2=$&VARN2..;
			/*Generate the stats.*/
			DATA M_O_O_STATS(DROP=OrderStatusTMP eraddsc_tmp);
				RETAIN '日期'N '版位'N '訂單狀況'N '銷售收入'N '商品數量'N '訂單數'N;
				FORMAT '日期'N NLDATEW. '訂單狀況'N &VARN1 '版位'N &VARN2 '銷售收入'N NLMNITWD22.0 '商品數量'N '訂單數'N COMMA9.0;
				SET M_O_O_STATS (DROP=_TYPE_ _FREQ_ RENAME=(Date=日期 'OrderStatus'N=OrderStatusTMP eraddsc=eraddsc_tmp));
				IF OrderStatusTMP NE "" THEN '訂單狀況'N=OrderStatusTMP; ELSE '訂單狀況'N="全";
				IF eraddsc_tmp NE "" THEN '版位'N=eraddsc_tmp; ELSE '版位'N="全版位";
			RUN;
			/*
				Whole-time range stats for the new customers.
			*/
			PROC MEANS DATA=WORK.M_N_O_SUMMARY SUM NOPRINT;
				CLASS Date "OrderStatus"N eraddsc;
				VAR "銷售收入"N "商品數量"N "訂單數"N "顧客數"N;
				TYPES ()*"OrderStatus"N  ()*eraddsc*"OrderStatus"N Date*"OrderStatus"N Date*eraddsc*"OrderStatus"N;
				OUTPUT OUT=M_N_O_STATS SUM="銷售收入"N "商品數量"N "訂單數"N "顧客數"N;
			RUN;
			/*Fetch the related length info for the latter recreation of data.*/
			PROC SQL NOPRINT;
				SELECT length INTO :VARN1-:VARN2 FROM DICTIONARY.COLUMNS 
							WHERE LIBNAME="WORK" AND MEMNAME="M_N_O_STATS" AND VARNUM BETWEEN 2 AND 3
							ORDER BY name;
			QUIT;
			%LET VARN1=$&VARN1..; %LET VARN2=$&VARN2..;
			/*Generate the stats.*/
			DATA M_N_O_STATS(DROP=OrderStatusTMP eraddsc_tmp);
				RETAIN '日期'N '版位'N '訂單狀況'N '銷售收入'N '商品數量'N '訂單數'N;
				FORMAT '日期'N NLDATEW. '訂單狀況'N &VARN1 '版位'N &VARN2 '銷售收入'N NLMNITWD22.0 '商品數量'N '訂單數'N COMMA9.0;
				SET M_N_O_STATS (DROP=_TYPE_ _FREQ_ RENAME=(Date=日期 'OrderStatus'N=OrderStatusTMP eraddsc=eraddsc_tmp));
				IF OrderStatusTMP NE "" THEN '訂單狀況'N=OrderStatusTMP; ELSE '訂單狀況'N="全";
				IF eraddsc_tmp NE "" THEN '版位'N=eraddsc_tmp; ELSE '版位'N="全版位";
			RUN;
			/*
				Generate the whole-range stats based on all app and blocks.
			*/
			PROC SQL;
				CREATE TABLE All_APP_N_O_R AS /*N_O_R stands for revenue from the old and new customers.*/
				SELECT "日期"N, "回頭客" FORMAT=$9. AS "客戶類型"N, "版位"N, "訂單狀況"N, "銷售收入"N FORMAT=DOLLAR12.0, "銷售收入"N/"顧客數"N AS "客單價（AS）"N  FORMAT=DOLLAR12.0,
						"銷售收入"N/"訂單數"N AS "平均訂單價值（AOV）"N FORMAT=DOLLAR12.0, "商品數量"N/"訂單數"N AS "平均訂單量（AOS）"N FORMAT=COMMA9.2
				FROM M_O_O_STATS
				UNION CORR ALL
				SELECT "日期"N, "新客" FORMAT=$9. AS "客戶類型"N, "版位"N, "訂單狀況"N, "銷售收入"N FORMAT=DOLLAR12.0, "銷售收入"N/"顧客數"N AS "客單價（AS）"N  FORMAT=DOLLAR12.0,
						"銷售收入"N/"訂單數"N AS "平均訂單價值（AOV）"N FORMAT=DOLLAR12.0, "商品數量"N/"訂單數"N AS "平均訂單量（AOS）"N FORMAT=COMMA9.2
				FROM M_N_O_STATS;
			QUIT;
			PROC SORT DATA=All_APP_N_O_R;
				BY "日期"N "版位"N;
			RUN;
			
			%_eg_conditional_dropds(M_O_O_STATS)
			%_eg_conditional_dropds(M_N_O_STATS)
			/*
				Generate the pie chart based on the previous dataset, All_APP_N_O_R.
			*/
			%_eg_conditional_dropds(All_APP_N_O_R_TMP)
			%_eg_conditional_dropds(Personal_N_O_R_TMP)
			%_eg_conditional_dropds(HotSale_N_O_R_TMP)
			PROC SQL NOPRINT;
				CREATE TABLE All_APP_N_O_R_TMP AS SELECT * FROM All_APP_N_O_R WHERE "版位"N = "全版位";
				CREATE TABLE Personal_N_O_R_TMP AS SELECT * FROM All_APP_N_O_R WHERE "版位"N IN ("即時新品", "好康商品", "季節商品", "知心商品", "專屬推薦");
				CREATE TABLE HotSale_N_O_R_TMP AS SELECT * FROM All_APP_N_O_R WHERE "版位"N IN ("宇匯推薦商品", "東科推薦商品");
			QUIT;
			%DO i=&INI_DATE %TO &LAST_DATE %BY 1;
			/*Page 1*/
			ODS LAYOUT GRIDDED /*STYLE={FONTFAMILY="Microsoft JhengHei"}*/
								COLUMNS=2 ROWS=3 COLUMN_WIDTHS=(50% 50%) HEIGHT=10in COLUMN_GUTTER=0 ROW_GUTTER=0;
			ODS ESCAPECHAR="^";
			ODS REGION COLUMN_SPAN=2 HEIGHT=5pct;
				ODS TEXT="^S={OUTPUTWIDTH=100% FONTSIZE=13pt JUST=C}%SYSFUNC(COMPRESS(%SYSFUNC(CATS(%SYSFUNC(PUTN(&i, NLDATEW.)), 全APP新舊客比例))))";
			ODS REGION COLUMN_SPAN=2 HEIGHT=48pct;
				GOPTIONS RESET=ALL DEVICE=SVG NOBORDER HSIZE=%SYSEVALF(7+&h_count.*0.01)in VSIZE=%SYSEVALF(4.6+&v_count.*0.01)in; 
				PATTERN1 C=CX4965B0; PATTERN2 C=CXFF7B58; PATTERN3 C=CX95B60E;
				PROC GCHART DATA=All_APP_N_O_R_TMP(WHERE=("日期"N=&i));
					PIE "客戶類型"N/SUMVAR="銷售收入"N GROUP="訂單狀況"N MIDPOINTS="回頭客" "新客"
						 ACROSS=2 DOWN=2 PERCENT=arrow COUTLINE=CX7C5C00 NOHEADING;
					RUN;
				QUIT;
			ODS REGION COLUMN_SPAN=2 HEIGHT=47pct;
				ODS TEXT="^S={OUTPUTWIDTH=100% FONTSIZE=12pt JUST=C}%SYSFUNC(COMPRESS(%SYSFUNC(PUTN(&i, NLDATEW.))))訂單資訊與銷退細節";
				PROC PRINT DATA=All_APP_N_O_R_TMP(WHERE=("日期"N=&i)) NOOBS STYLE(DATA)=[JUST=C VJUST=M] STYLE(HEAD)=[JUST=C VJUST=M BACKGROUNDCOLOR=RGBAAA393933] CONTENTS="" LABEL;
				QUIT;
				ODS TEXT="^S={OUTPUTWIDTH=85% JUST=L}註1：客單價=銷售收入÷顧客數";
				ODS TEXT="^S={OUTPUTWIDTH=85% JUST=L}註2：平均訂單價值=銷售收入÷訂單數";
				ODS TEXT="^S={OUTPUTWIDTH=85% JUST=L}註3：平均訂單量=商品數量÷訂單數";
				PROC PRINT DATA=WORK.DETAILED_R_LIST(WHERE=(Date=&i)) NOOBS STYLE(DATA)=[JUST=C VJUST=M] STYLE(HEAD)=[JUST=C VJUST=M BACKGROUNDCOLOR=RGBA765CC833] CONTENTS="" LABEL;
					VAR customerid SALENO SALENAME 銷售收入 數量;
					LABEL customerid=客代 SALENAME=銷退商品名稱 SALENO=銷售編號 數量=商品數量 銷售收入=金額;
				QUIT;
			ODS LAYOUT END;
			%LET h_count=%EVAL(&h_count+1); %LET v_count=%EVAL(&v_count+1); /*For displaying charts normally*/
			ODS PDF (ID=DYFIG) STARTPAGE=NOW;
			/*Page 2*/
			ODS LAYOUT GRIDDED /*STYLE={FONTFAMILY="Microsoft JhengHei"}*/
								COLUMNS=2 ROWS=4 COLUMN_WIDTHS=(50% 50%) HEIGHT=10in COLUMN_GUTTER=0 ROW_GUTTER=0;
			ODS REGION COLUMN_SPAN=2 HEIGHT=5pct;
				ODS TEXT="^S={OUTPUTWIDTH=100% FONTSIZE=13pt JUST=C}%SYSFUNC(COMPRESS(%SYSFUNC(CATS(%SYSFUNC(PUTN(&i, NLDATEW.)), 專屬推薦與精選好物新舊客))))";
			ODS REGION COLUMN_SPAN=2 HEIGHT=48pct;
				GOPTIONS HSIZE=%SYSEVALF(7+&h_count.*0.01)in VSIZE=%SYSEVALF(4.6+&v_count.*0.01)in;
				PROC GCHART DATA=Personal_N_O_R_TMP(WHERE=("日期"N=&i));
					VBAR "版位"N/SUMVAR="銷售收入"N GROUP="訂單狀況"N SUBGROUP="客戶類型"N SPACE=0;
					RUN;
				QUIT;
			ODS REGION COLUMN_SPAN=2 HEIGHT=24pct;
				ODS TEXT="^S={OUTPUTWIDTH=100% FONTSIZE=10pt JUST=C}訂單資訊";
				PROC PRINT DATA=Personal_N_O_R_TMP(WHERE=("日期"N=&i)) NOOBS STYLE(DATA)=[JUST=C VJUST=M] STYLE(HEAD)=[JUST=C VJUST=M BACKGROUNDCOLOR=RGBAAA393933] CONTENTS="" LABEL;
				QUIT;
			ODS REGION HEIGHT=23pct;
				ODS TEXT="^S={OUTPUTWIDTH=100% FONTSIZE=10pt JUST=C}金額排行榜(淨訂單)";
				PROC PRINT DATA=WORK.NET_LIST_MN(WHERE=(eraddsc IN ('專屬推薦', '知心商品', '即時新品', '好康商品', '季節商品') AND Date EQ &i)) NOOBS 
							STYLE(DATA)=[JUST=C VJUST=M] STYLE(HEAD)=[JUST=C VJUST=M BACKGROUNDCOLOR=RGBA469E3433] CONTENTS="" LABEL;
					VAR eraddsc customerid '金額'N '數量'N;
					LABEL eraddsc=版位 customerid=客代;
				QUIT;
				ODS TEXT="^S={OUTPUTWIDTH=70% JUST=L}註1：只呈現每個版位的前三名。";
			ODS REGION HEIGHT=23pct;
				ODS TEXT="^S={OUTPUTWIDTH=100% FONTSIZE=10pt JUST=C}數量排行榜(淨訂單)";
				PROC PRINT DATA=WORK.NET_LIST_AMOUNT(WHERE=(eraddsc IN ('專屬推薦', '知心商品', '即時新品', '好康商品', '季節商品') AND Date EQ &i)) NOOBS 
							STYLE(DATA)=[JUST=C VJUST=M] STYLE(HEAD)=[JUST=C VJUST=M BACKGROUNDCOLOR=RGBA469E3433] CONTENTS="" LABEL;
					VAR eraddsc customerid '金額'N '數量'N;
					LABEL eraddsc=版位 customerid=客代;
				QUIT;
				ODS TEXT="^S={OUTPUTWIDTH=70% JUST=L}註1：只呈現每個版位的前三名。";
			ODS LAYOUT END;
			%LET h_count=%EVAL(&h_count+1); %LET v_count=%EVAL(&v_count+1); /*For displaying charts normally*/
			ODS PDF (ID=DYFIG) STARTPAGE=NOW;
			/*Page 3*/
			ODS LAYOUT GRIDDED /*STYLE={FONTFAMILY="Microsoft JhengHei"}*/
								COLUMNS=2 ROWS=4 COLUMN_WIDTHS=(50% 50%) HEIGHT=10in COLUMN_GUTTER=0 ROW_GUTTER=0;
			ODS REGION COLUMN_SPAN=2 HEIGHT=5pct;
				ODS TEXT="^S={OUTPUTWIDTH=100% FONTSIZE=13pt JUST=C}%SYSFUNC(COMPRESS(%SYSFUNC(CATS(%SYSFUNC(PUTN(&i, NLDATEW.)), 當日熱賣新舊客))))";
			ODS REGION COLUMN_SPAN=2 HEIGHT=48pct;
				GOPTIONS HSIZE=%SYSEVALF(7+&h_count.*0.01)in VSIZE=%SYSEVALF(4.6+&v_count.*0.01)in;
				PROC GCHART DATA=HotSale_N_O_R_TMP(WHERE=("日期"N=&i));
					VBAR "版位"N/SUMVAR="銷售收入"N GROUP="訂單狀況"N SUBGROUP="客戶類型"N SPACE=0;
					RUN;
				QUIT;
			ODS REGION COLUMN_SPAN=2 HEIGHT=24pct;
				ODS TEXT="^S={OUTPUTWIDTH=100% FONTSIZE=10pt JUST=C}訂單資訊";
				PROC PRINT DATA=HotSale_N_O_R_TMP(WHERE=("日期"N=&i)) NOOBS STYLE(DATA)=[JUST=C VJUST=M] STYLE(HEAD)=[JUST=C VJUST=M BACKGROUNDCOLOR=RGBAAA393933] CONTENTS="" LABEL;
				QUIT;
			ODS REGION HEIGHT=23pct;
				ODS TEXT="^S={OUTPUTWIDTH=100% FONTSIZE=10pt JUST=C}金額排行榜(淨訂單)";
				PROC PRINT DATA=WORK.NET_LIST_MN(WHERE=(eraddsc IN ('宇匯推薦商品', '東科推薦商品') AND Date EQ &i)) NOOBS 
							STYLE(DATA)=[JUST=C VJUST=M] STYLE(HEAD)=[JUST=C VJUST=M BACKGROUNDCOLOR=RGBA469E3433] CONTENTS="" LABEL;
					VAR eraddsc customerid '金額'N '數量'N;
					LABEL eraddsc=版位 customerid=客代;
				QUIT;
				ODS TEXT="^S={OUTPUTWIDTH=70% JUST=L}註1：只呈現每個版位的前三名。";
			ODS REGION HEIGHT=23pct;
				ODS TEXT="^S={OUTPUTWIDTH=100% FONTSIZE=10pt JUST=C}數量排行榜(淨訂單)";
				PROC PRINT DATA=WORK.NET_LIST_AMOUNT(WHERE=(eraddsc IN ('宇匯推薦商品', '東科推薦商品') AND Date EQ &i)) NOOBS 
							STYLE(DATA)=[JUST=C VJUST=M] STYLE(HEAD)=[JUST=C VJUST=M BACKGROUNDCOLOR=RGBA469E3433] CONTENTS="" LABEL;
					VAR eraddsc customerid '金額'N '數量'N;
					LABEL eraddsc=版位 customerid=客代;
				QUIT;
				ODS TEXT="^S={OUTPUTWIDTH=70% JUST=L}註1：只呈現每個版位的前三名。";
			ODS LAYOUT END;
			%LET h_count=%EVAL(&h_count+1); %LET v_count=%EVAL(&v_count+1); /*For displaying charts normally*/
			ODS PDF (ID=DYFIG) STARTPAGE=NOW;
			%IF &i EQ &LAST_DATE %THEN %DO;
				ODS LAYOUT GRIDDED /*STYLE={FONTFAMILY="Microsoft JhengHei"}*/
									COLUMNS=2 ROWS=3 COLUMN_WIDTHS=(50% 50%) HEIGHT=10in COLUMN_GUTTER=0 ROW_GUTTER=0;
				ODS ESCAPECHAR="^";
				ODS REGION COLUMN_SPAN=2 HEIGHT=5pct;
					ODS TEXT="^S={OUTPUTWIDTH=100% FONTSIZE=13pt JUST=C}%SYSFUNC(COMPRESS(%SYSFUNC(CATS(%SYSFUNC(PUTN(&INI_DATE, NLDATEW.)), -,%SYSFUNC(PUTN(&LAST_DATE, NLDATEW.)),全APP新舊客比例))))";
				ODS REGION COLUMN_SPAN=2 HEIGHT=48pct;
					GOPTIONS RESET=ALL DEVICE=SVG NOBORDER HSIZE=%SYSEVALF(7+&h_count.*0.01)in VSIZE=%SYSEVALF(4.6+&v_count.*0.01)in; 
					PATTERN1 C=CX4965B0; PATTERN2 C=CXFF7B58; PATTERN3 C=CX95B60E;
					PROC GCHART DATA=All_APP_N_O_R_TMP(WHERE=("日期"N=.));
						PIE "客戶類型"N/SUMVAR="銷售收入"N GROUP="訂單狀況"N MIDPOINTS="回頭客" "新客"
							 ACROSS=2 DOWN=2 PERCENT=arrow COUTLINE=CX7C5C00 NOHEADING;
						RUN;
					QUIT;
				ODS REGION COLUMN_SPAN=2 HEIGHT=47pct;
					ODS TEXT="^S={OUTPUTWIDTH=100% FONTSIZE=12pt JUST=C}%SYSFUNC(COMPRESS(%SYSFUNC(PUTN(&INI_DATE, NLDATEW.))))-%SYSFUNC(COMPRESS(%SYSFUNC(PUTN(&LAST_DATE, NLDATEW.))))訂單資訊與銷退細節";
					PROC PRINT DATA=All_APP_N_O_R_TMP(WHERE=("日期"N=. AND "訂單狀況"N="NET")) NOOBS STYLE(DATA)=[JUST=C VJUST=M] STYLE(HEAD)=[JUST=C VJUST=M BACKGROUNDCOLOR=RGBAAA393933] CONTENTS="" LABEL;
						VAR 客戶類型 版位 訂單狀況 銷售收入 "客單價（AS）"N "平均訂單價值（AOV）"N "平均訂單量（AOS）"N;
					QUIT;
					ODS TEXT="^S={OUTPUTWIDTH=85% JUST=L}註1：客單價=銷售收入÷顧客數";
					ODS TEXT="^S={OUTPUTWIDTH=85% JUST=L}註2：平均訂單價值=銷售收入÷訂單數";
					ODS TEXT="^S={OUTPUTWIDTH=85% JUST=L}註3：平均訂單量=商品數量÷訂單數";
					PROC PRINT DATA=WORK.R_LIST NOOBS STYLE(DATA)=[JUST=C VJUST=M] STYLE(HEAD)=[JUST=C VJUST=M BACKGROUNDCOLOR=RGBA765CC833] CONTENTS="" LABEL;
						VAR SALENO SALENAME 銷售收入 數量;
						LABEL SALENAME=銷退商品名稱 SALENO=銷售編號 數量=商品數量 銷售收入=金額;
					QUIT;
				ODS LAYOUT END;
				%LET h_count=%EVAL(&h_count+1); %LET v_count=%EVAL(&v_count+1); /*For displaying charts normally*/
				ODS PDF (ID=DYFIG) STARTPAGE=NOW;
				/*Page 2*/
				ODS LAYOUT GRIDDED STYLE={FONTFAMILY="Microsoft JhengHei"}
									COLUMNS=3 ROWS=4 COLUMN_WIDTHS=(33.3% 33.3% 33.4%) HEIGHT=10in COLUMN_GUTTER=0 ROW_GUTTER=0;
				ODS REGION COLUMN_SPAN=3 HEIGHT=5pct;
					ODS TEXT="^S={OUTPUTWIDTH=100% FONTSIZE=13pt JUST=C}%SYSFUNC(COMPRESS(%SYSFUNC(CATS(%SYSFUNC(PUTN(&INI_DATE, NLDATEW.)), -,%SYSFUNC(PUTN(&LAST_DATE, NLDATEW.)),專屬推薦與精選好物新舊客))))";
				ODS REGION COLUMN_SPAN=3 HEIGHT=48pct;
					GOPTIONS HSIZE=%SYSEVALF(7+&h_count.*0.01)in VSIZE=%SYSEVALF(4.6+&v_count.*0.01)in;
					PROC GCHART DATA=Personal_N_O_R_TMP(WHERE=("日期"N=. AND "訂單狀況"N = "NET"));
						VBAR "版位"N/SUMVAR="銷售收入"N GROUP="訂單狀況"N SUBGROUP="客戶類型"N SPACE=0;
						RUN;
					QUIT;
				ODS REGION COLUMN_SPAN=3 HEIGHT=24pct;
					ODS TEXT="^S={OUTPUTWIDTH=100% FONTSIZE=10pt JUST=C}訂單資訊";
					PROC PRINT DATA=Personal_N_O_R_TMP(WHERE=("日期"N=.  AND "訂單狀況"N="NET")) NOOBS STYLE(DATA)=[JUST=C VJUST=M] STYLE(HEAD)=[JUST=C VJUST=M BACKGROUNDCOLOR=RGBAAA393933] CONTENTS="" LABEL;
						VAR 客戶類型 版位 訂單狀況 銷售收入 "客單價（AS）"N "平均訂單價值（AOV）"N "平均訂單量（AOS）"N;
					QUIT;
				ODS REGION HEIGHT=23pct;
					ODS TEXT="^S={OUTPUTWIDTH=100% FONTSIZE=10pt JUST=C}金額排行榜(淨訂單)";
					PROC PRINT DATA=WORK.NET_LIST_MN(WHERE=(eraddsc IN ('專屬推薦', '知心商品', '即時新品', '好康商品', '季節商品') AND Date EQ .)) NOOBS 
								STYLE(DATA)=[JUST=C VJUST=M] STYLE(HEAD)=[JUST=C VJUST=M BACKGROUNDCOLOR=RGBA469E3433] CONTENTS="" LABEL;
						VAR eraddsc customerid '金額'N '數量'N;
						LABEL eraddsc=版位 customerid=客代;
					QUIT;
					ODS TEXT="^S={OUTPUTWIDTH=70% JUST=L}註1：只呈現每個版位的前三名。";
				ODS REGION HEIGHT=23pct;
					ODS TEXT="^S={OUTPUTWIDTH=100% FONTSIZE=10pt JUST=C}數量排行榜(淨訂單)";
					PROC PRINT DATA=WORK.NET_LIST_AMOUNT(WHERE=(eraddsc IN ('專屬推薦', '知心商品', '即時新品', '好康商品', '季節商品') AND Date EQ .)) NOOBS 
								STYLE(DATA)=[JUST=C VJUST=M] STYLE(HEAD)=[JUST=C VJUST=M BACKGROUNDCOLOR=RGBA469E3433] CONTENTS="" LABEL;
						VAR eraddsc customerid '金額'N '數量'N;
						LABEL eraddsc=版位 customerid=客代;
					QUIT;
					ODS TEXT="^S={OUTPUTWIDTH=70% JUST=L}註1：只呈現每個版位的前三名。";
				ODS REGION HEIGHT=23pct;
					ODS TEXT="^S={OUTPUTWIDTH=100% FONTSIZE=9pt JUST=C}版位收益趨勢";
					PROC SGPLOT DATA=WORK.NET_LIST_AMOUNT(WHERE=(eraddsc IN ('專屬推薦', '知心商品', '即時新品', '好康商品', '季節商品')  AND Date NE .));
						VLINE Date/RESPONSE='金額'N GROUP=eraddsc;
						XAXIS DISPLAY=(NOLABEL); YAXIS DISPLAY=(NOLABEL);
						KEYLEGEND/ TITLE="版位" TITLEATTRS=(FAMILY=BiauKai SIZE=8) VALUEATTRS=(FAMILY=BiauKai SIZE=8);
					RUN; QUIT;
				ODS LAYOUT END;
				%LET h_count=%EVAL(&h_count+1); %LET v_count=%EVAL(&v_count+1); /*For displaying charts normally*/
				ODS PDF (ID=DYFIG) STARTPAGE=NOW;
				/*Page 3*/
				ODS LAYOUT GRIDDED /*STYLE={FONTFAMILY="Microsoft JhengHei"}*/
									COLUMNS=3 ROWS=4 COLUMN_WIDTHS=(33.3% 33.3% 33.4%) HEIGHT=10in COLUMN_GUTTER=0 ROW_GUTTER=0;
				ODS REGION COLUMN_SPAN=3 HEIGHT=5pct;
					ODS TEXT="^S={OUTPUTWIDTH=100% FONTSIZE=13pt JUST=C}%SYSFUNC(COMPRESS(%SYSFUNC(CATS(%SYSFUNC(PUTN(&INI_DATE, NLDATEW.)), -,%SYSFUNC(PUTN(&LAST_DATE, NLDATEW.)),當日熱賣新舊客))))";
				ODS REGION COLUMN_SPAN=3 HEIGHT=48pct;
					GOPTIONS HSIZE=%SYSEVALF(7+&h_count.*0.01)in VSIZE=%SYSEVALF(4.6+&v_count.*0.01)in;
					PROC GCHART DATA=HotSale_N_O_R_TMP(WHERE=("日期"N=.));
						VBAR "版位"N/SUMVAR="銷售收入"N GROUP="訂單狀況"N SUBGROUP="客戶類型"N SPACE=0;
						RUN;
					QUIT;
				ODS REGION COLUMN_SPAN=3 HEIGHT=24pct;
					ODS TEXT="^S={OUTPUTWIDTH=100% FONTSIZE=10pt JUST=C}訂單資訊";
					PROC PRINT DATA=HotSale_N_O_R_TMP(WHERE=("日期"N=. AND "訂單狀況"N="NET")) NOOBS STYLE(DATA)=[JUST=C VJUST=M] STYLE(HEAD)=[JUST=C VJUST=M BACKGROUNDCOLOR=RGBAAA393933] CONTENTS="" LABEL;
						VAR 客戶類型 版位 訂單狀況 銷售收入 "客單價（AS）"N "平均訂單價值（AOV）"N "平均訂單量（AOS）"N;
					QUIT;
				ODS REGION HEIGHT=23pct;
					ODS TEXT="^S={OUTPUTWIDTH=100% FONTSIZE=10pt JUST=C}金額排行榜(淨訂單)";
					PROC PRINT DATA=WORK.NET_LIST_MN(WHERE=(eraddsc IN ('宇匯推薦商品', '東科推薦商品') AND Date EQ .)) NOOBS 
								STYLE(DATA)=[JUST=C VJUST=M] STYLE(HEAD)=[JUST=C VJUST=M BACKGROUNDCOLOR=RGBA469E3433] CONTENTS="" LABEL;
						VAR eraddsc customerid '金額'N '數量'N;
						LABEL eraddsc=版位 customerid=客代;
					QUIT;
					ODS TEXT="^S={OUTPUTWIDTH=70% JUST=L}註1：只呈現每個版位的前三名。";
				ODS REGION HEIGHT=23pct;
					ODS TEXT="^S={OUTPUTWIDTH=100% FONTSIZE=10pt JUST=C}數量排行榜(淨訂單)";
					PROC PRINT DATA=WORK.NET_LIST_AMOUNT(WHERE=(eraddsc IN ('宇匯推薦商品', '東科推薦商品') AND Date EQ .)) NOOBS 
								STYLE(DATA)=[JUST=C VJUST=M] STYLE(HEAD)=[JUST=C VJUST=M BACKGROUNDCOLOR=RGBA469E3433] CONTENTS="" LABEL;
						VAR eraddsc customerid '金額'N '數量'N;
						LABEL eraddsc=版位 customerid=客代;
					QUIT;
					ODS TEXT="^S={OUTPUTWIDTH=70% JUST=L}註1：只呈現每個版位的前三名。";
				ODS REGION HEIGHT=23pct;
					ODS TEXT="^S={OUTPUTWIDTH=100% FONTSIZE=9pt JUST=C}版位收益趨勢";
					PROC SGPLOT DATA=WORK.NET_LIST_AMOUNT(WHERE=(eraddsc IN ('宇匯推薦商品', '東科推薦商品')  AND Date NE .));
						VLINE Date/RESPONSE='金額'N GROUP=eraddsc;
						XAXIS DISPLAY=(NOLABEL); YAXIS DISPLAY=(NOLABEL);
						KEYLEGEND/ TITLE="版位" TITLEATTRS=(FAMILY=BiauKai SIZE=8) VALUEATTRS=(FAMILY=BiauKai SIZE=8);
					RUN; QUIT;
				ODS LAYOUT END;
				%LET h_count=%EVAL(&h_count+1); %LET v_count=%EVAL(&v_count+1); /*For displaying charts normally*/
				ODS PDF (ID=DYFIG) STARTPAGE=NOW;
				%_eg_conditional_dropds(All_APP_N_O_R_TMP)
				%_eg_conditional_dropds(Personal_N_O_R_TMP)
				%_eg_conditional_dropds(HotSale_N_O_R_TMP)
			%END;
		%END; /*Loop end*/
		OPTIONS LOCALE=en_US;
		ODS _ALL_ CLOSE;
	%END;
	%ELSE %DO;
		OPTIONS NODATE; OPTIONS DEV=ACTXIMG;
			OPTIONS LOCALE=zh_TW;
			%LET h_count=1; %LET v_count=1;
			%_eg_conditional_dropds(M_O_O_STATS)
			%_eg_conditional_dropds(M_N_O_STATS)
			PROC MEANS DATA=WORK.M_O_O_SUMMARY SUM NOPRINT;
				CLASS Date "OrderStatus"N eraddsc;
				VAR "銷售收入"N "商品數量"N "訂單數"N "顧客數"N;
				TYPES ()*"OrderStatus"N ()*eraddsc*"OrderStatus"N Date*"OrderStatus"N Date*eraddsc*"OrderStatus"N;
				OUTPUT OUT=M_O_O_STATS SUM="銷售收入"N "商品數量"N "訂單數"N "顧客數"N;
			RUN;
			/*Fetch the related length info for the latter recreation of data.*/
			PROC SQL NOPRINT;
				SELECT length  INTO: VARN1-:VARN2 FROM DICTIONARY.COLUMNS 
							WHERE LIBNAME="WORK" AND MEMNAME="M_O_O_SUMMARY" AND VARNUM BETWEEN 2 AND 3
							ORDER BY name;
			QUIT;
			%LET VARN1=$&VARN1..; %LET VARN2=$&VARN2..;
			/*Generate the stats.*/
			DATA M_O_O_STATS(DROP=OrderStatusTMP eraddsc_tmp);
				RETAIN '日期'N '版位'N '訂單狀況'N '銷售收入'N '商品數量'N '訂單數'N;
				FORMAT '日期'N NLDATEW. '訂單狀況'N &VARN1 '版位'N &VARN2 '銷售收入'N NLMNITWD22.0 '商品數量'N '訂單數'N COMMA9.0;
				SET M_O_O_STATS (DROP=_TYPE_ _FREQ_ RENAME=(Date=日期 'OrderStatus'N=OrderStatusTMP eraddsc=eraddsc_tmp));
				IF OrderStatusTMP NE "" THEN '訂單狀況'N=OrderStatusTMP; ELSE '訂單狀況'N="全";
				IF eraddsc_tmp NE "" THEN '版位'N=eraddsc_tmp; ELSE '版位'N="全版位";
			RUN;
			/*
				Whole-time range stats for the new customers.
			*/
			PROC MEANS DATA=WORK.M_N_O_SUMMARY SUM NOPRINT;
				CLASS Date "OrderStatus"N eraddsc;
				VAR "銷售收入"N "商品數量"N "訂單數"N "顧客數"N;
				TYPES ()*"OrderStatus"N  ()*eraddsc*"OrderStatus"N Date*"OrderStatus"N Date*eraddsc*"OrderStatus"N;
				OUTPUT OUT=M_N_O_STATS SUM="銷售收入"N "商品數量"N "訂單數"N "顧客數"N;
			RUN;
			/*Fetch the related length info for the latter recreation of data.*/
			PROC SQL NOPRINT;
				SELECT length INTO :VARN1-:VARN2 FROM DICTIONARY.COLUMNS 
							WHERE LIBNAME="WORK" AND MEMNAME="M_N_O_STATS" AND VARNUM BETWEEN 2 AND 3
							ORDER BY name;
			QUIT;
			%LET VARN1=$&VARN1..; %LET VARN2=$&VARN2..;
			/*Generate the stats.*/
			DATA M_N_O_STATS(DROP=OrderStatusTMP eraddsc_tmp);
				RETAIN '日期'N '版位'N '訂單狀況'N '銷售收入'N '商品數量'N '訂單數'N;
				FORMAT '日期'N NLDATEW. '訂單狀況'N &VARN1 '版位'N &VARN2 '銷售收入'N NLMNITWD22.0 '商品數量'N '訂單數'N COMMA9.0;
				SET M_N_O_STATS (DROP=_TYPE_ _FREQ_ RENAME=(Date=日期 'OrderStatus'N=OrderStatusTMP eraddsc=eraddsc_tmp));
				IF OrderStatusTMP NE "" THEN '訂單狀況'N=OrderStatusTMP; ELSE '訂單狀況'N="全";
				IF eraddsc_tmp NE "" THEN '版位'N=eraddsc_tmp; ELSE '版位'N="全版位";
			RUN;
			/*
				Generate the whole-range stats based on all app and blocks.
			*/
			PROC SQL;
				CREATE TABLE All_APP_N_O_R AS /*N_O_R stands for revenue from the old and new customers.*/
				SELECT "日期"N, "回頭客" FORMAT=$9. AS "客戶類型"N, "版位"N, "訂單狀況"N, "銷售收入"N FORMAT=DOLLAR12.0, "銷售收入"N/"顧客數"N AS "客單價（AS）"N  FORMAT=DOLLAR12.0,
						"銷售收入"N/"訂單數"N AS "平均訂單價值（AOV）"N FORMAT=DOLLAR12.0, "商品數量"N/"訂單數"N AS "平均訂單量（AOS）"N FORMAT=COMMA9.2
				FROM M_O_O_STATS
				UNION CORR ALL
				SELECT "日期"N, "新客" FORMAT=$9. AS "客戶類型"N, "版位"N, "訂單狀況"N, "銷售收入"N FORMAT=DOLLAR12.0, "銷售收入"N/"顧客數"N AS "客單價（AS）"N  FORMAT=DOLLAR12.0,
						"銷售收入"N/"訂單數"N AS "平均訂單價值（AOV）"N FORMAT=DOLLAR12.0, "商品數量"N/"訂單數"N AS "平均訂單量（AOS）"N FORMAT=COMMA9.2
				FROM M_N_O_STATS;
			QUIT;
			PROC SORT DATA=All_APP_N_O_R;
				BY "日期"N "版位"N;
			RUN;
			
			%_eg_conditional_dropds(M_O_O_STATS)
			%_eg_conditional_dropds(M_N_O_STATS)
			/*
				Generate the pie chart based on the previous dataset, All_APP_N_O_R.
			*/
			PROC SQL NOPRINT;
				CREATE TABLE All_APP_N_O_R_TMP AS SELECT * FROM All_APP_N_O_R WHERE "版位"N = "全版位";
				CREATE TABLE Personal_N_O_R_TMP AS SELECT * FROM All_APP_N_O_R WHERE "版位"N IN ("即時新品", "好康商品", "季節商品", "知心商品", "專屬推薦");
				CREATE TABLE HotSale_N_O_R_TMP AS SELECT * FROM All_APP_N_O_R WHERE "版位"N IN ("宇匯推薦商品", "東科推薦商品");
			QUIT;
			/*Page 1*/
			ODS LAYOUT GRIDDED /*STYLE={FONTFAMILY="Microsoft JhengHei"}*/
								COLUMNS=2 ROWS=3 COLUMN_WIDTHS=(50% 50%) HEIGHT=10in COLUMN_GUTTER=0 ROW_GUTTER=0;
			ODS ESCAPECHAR="^";
			ODS REGION COLUMN_SPAN=2 HEIGHT=5pct;
				ODS TEXT="^S={OUTPUTWIDTH=100% FONTSIZE=13pt JUST=C}%SYSFUNC(COMPRESS(%SYSFUNC(CATS(%SYSFUNC(PUTN(&LAST_DATE, NLDATEW.)), 全APP新舊客比例))))";
			ODS REGION COLUMN_SPAN=2 HEIGHT=48pct;
				GOPTIONS RESET=ALL DEVICE=SVG NOBORDER HSIZE=%SYSEVALF(7+&h_count.*0.01)in VSIZE=%SYSEVALF(4.6+&v_count.*0.01)in; 
				PATTERN1 C=CX4965B0; PATTERN2 C=CXFF7B58; PATTERN3 C=CX95B60E;
				PROC GCHART DATA=All_APP_N_O_R_TMP(WHERE=("日期"N=&LAST_DATE));
					PIE "客戶類型"N/SUMVAR="銷售收入"N GROUP="訂單狀況"N MIDPOINTS="回頭客" "新客"
						 ACROSS=2 DOWN=2 PERCENT=arrow COUTLINE=CX7C5C00 NOHEADING;
					RUN;
				QUIT;
			ODS REGION COLUMN_SPAN=2 HEIGHT=47pct;
				ODS TEXT="^S={OUTPUTWIDTH=100% FONTSIZE=12pt JUST=C}%SYSFUNC(COMPRESS(%SYSFUNC(PUTN(&LAST_DATE, NLDATEW.))))訂單資訊與銷退細節";
				PROC PRINT DATA=All_APP_N_O_R_TMP(WHERE=("日期"N=&LAST_DATE)) NOOBS STYLE(DATA)=[JUST=C VJUST=M] STYLE(HEAD)=[JUST=C VJUST=M BACKGROUNDCOLOR=RGBAAA393933] CONTENTS="" LABEL;
				QUIT;
				ODS TEXT="^S={OUTPUTWIDTH=85% JUST=L}註1：客單價=銷售收入÷顧客數";
				ODS TEXT="^S={OUTPUTWIDTH=85% JUST=L}註2：平均訂單價值=銷售收入÷訂單數";
				ODS TEXT="^S={OUTPUTWIDTH=85% JUST=L}註3：平均訂單量=商品數量÷訂單數";
				PROC PRINT DATA=WORK.DETAILED_R_LIST(WHERE=(Date=&LAST_DATE)) NOOBS STYLE(DATA)=[JUST=C VJUST=M] STYLE(HEAD)=[JUST=C VJUST=M BACKGROUNDCOLOR=RGBA765CC833] CONTENTS="" LABEL;
					VAR customerid SALENO SALENAME 銷售收入 數量;
					LABEL customerid=客代 SALENAME=銷退商品名稱 SALENO=銷售編號 數量=商品數量 銷售收入=金額;
				QUIT;
			ODS LAYOUT END;
			%LET h_count=%EVAL(&h_count+1); %LET v_count=%EVAL(&v_count+1); /*For displaying charts normally*/
			ODS PDF (ID=DYFIG) STARTPAGE=NOW;
			/*Page 2*/
			ODS LAYOUT GRIDDED STYLE={FONTFAMILY="Microsoft JhengHei"}
								COLUMNS=2 ROWS=4 COLUMN_WIDTHS=(50% 50%) HEIGHT=10in COLUMN_GUTTER=0 ROW_GUTTER=0;
			ODS REGION COLUMN_SPAN=2 HEIGHT=5pct;
				ODS TEXT="^S={OUTPUTWIDTH=100% FONTSIZE=13pt JUST=C}%SYSFUNC(COMPRESS(%SYSFUNC(CATS(%SYSFUNC(PUTN(&LAST_DATE, NLDATEW.)), 專屬推薦與精選好物新舊客))))";
			ODS REGION COLUMN_SPAN=2 HEIGHT=48pct;
				GOPTIONS HSIZE=%SYSEVALF(7+&h_count.*0.01)in VSIZE=%SYSEVALF(4.6+&v_count.*0.01)in;
				PROC GCHART DATA=Personal_N_O_R_TMP(WHERE=("日期"N=&LAST_DATE));
					VBAR "版位"N/SUMVAR="銷售收入"N GROUP="訂單狀況"N SUBGROUP="客戶類型"N SPACE=0;
					RUN;
				QUIT;
			ODS REGION COLUMN_SPAN=2 HEIGHT=24pct;
				ODS TEXT="^S={OUTPUTWIDTH=100% FONTSIZE=10pt JUST=C}訂單資訊";
				PROC PRINT DATA=Personal_N_O_R_TMP(WHERE=("日期"N=&LAST_DATE)) NOOBS STYLE(DATA)=[JUST=C VJUST=M] STYLE(HEAD)=[JUST=C VJUST=M BACKGROUNDCOLOR=RGBAAA393933] CONTENTS="" LABEL;
				QUIT;
			ODS REGION HEIGHT=23pct;
				ODS TEXT="^S={OUTPUTWIDTH=100% FONTSIZE=10pt JUST=C}金額排行榜(淨訂單)";
				PROC PRINT DATA=WORK.NET_LIST_MN(WHERE=(eraddsc IN ('專屬推薦', '知心商品', '即時新品', '好康商品', '季節商品') AND Date EQ &LAST_DATE)) NOOBS 
							STYLE(DATA)=[JUST=C VJUST=M] STYLE(HEAD)=[JUST=C VJUST=M BACKGROUNDCOLOR=RGBA469E3433] CONTENTS="" LABEL;
					VAR eraddsc customerid '金額'N '數量'N;
					LABEL eraddsc=版位 customerid=客代;
				QUIT;
				ODS TEXT="^S={OUTPUTWIDTH=70% JUST=L}註1：只呈現每個版位的前三名。";
			ODS REGION HEIGHT=23pct;
				ODS TEXT="^S={OUTPUTWIDTH=100% FONTSIZE=10pt JUST=C}數量排行榜(淨訂單)";
				PROC PRINT DATA=WORK.NET_LIST_AMOUNT(WHERE=(eraddsc IN ('專屬推薦', '知心商品', '即時新品', '好康商品', '季節商品') AND Date EQ &LAST_DATE)) NOOBS 
							STYLE(DATA)=[JUST=C VJUST=M] STYLE(HEAD)=[JUST=C VJUST=M BACKGROUNDCOLOR=RGBA469E3433] CONTENTS="" LABEL;
					VAR eraddsc customerid '金額'N '數量'N;
					LABEL eraddsc=版位 customerid=客代;
				QUIT;
				ODS TEXT="^S={OUTPUTWIDTH=70% JUST=L}註1：只呈現每個版位的前三名。";
			ODS LAYOUT END;
			%LET h_count=%EVAL(&h_count+1); %LET v_count=%EVAL(&v_count+1); /*For displaying charts normally*/
			ODS PDF (ID=DYFIG) STARTPAGE=NOW;
			/*Page 3*/
			ODS LAYOUT GRIDDED /*STYLE={FONTFAMILY="Microsoft JhengHei"}*/
								COLUMNS=2 ROWS=4 COLUMN_WIDTHS=(50% 50%) HEIGHT=10in COLUMN_GUTTER=0 ROW_GUTTER=0;
			ODS REGION COLUMN_SPAN=2 HEIGHT=5pct;
				ODS TEXT="^S={OUTPUTWIDTH=100% FONTSIZE=13pt JUST=C}%SYSFUNC(COMPRESS(%SYSFUNC(CATS(%SYSFUNC(PUTN(&LAST_DATE, NLDATEW.)), 當日熱賣新舊客))))";
			ODS REGION COLUMN_SPAN=2 HEIGHT=48pct;
				GOPTIONS HSIZE=%SYSEVALF(7+&h_count.*0.01)in VSIZE=%SYSEVALF(4.6+&v_count.*0.01)in;
				PROC GCHART DATA=HotSale_N_O_R_TMP(WHERE=("日期"N=&LAST_DATE));
					VBAR "版位"N/SUMVAR="銷售收入"N GROUP="訂單狀況"N SUBGROUP="客戶類型"N SPACE=0;
					RUN;
				QUIT;
			ODS REGION COLUMN_SPAN=2 HEIGHT=24pct;
				ODS TEXT="^S={OUTPUTWIDTH=100% FONTSIZE=10pt JUST=C}訂單資訊";
				PROC PRINT DATA=HotSale_N_O_R_TMP(WHERE=("日期"N=&LAST_DATE)) NOOBS STYLE(DATA)=[JUST=C VJUST=M] STYLE(HEAD)=[JUST=C VJUST=M BACKGROUNDCOLOR=RGBAAA393933] CONTENTS="" LABEL;
				QUIT;
			ODS REGION HEIGHT=23pct;
				ODS TEXT="^S={OUTPUTWIDTH=100% FONTSIZE=10pt JUST=C}金額排行榜(淨訂單)";
				PROC PRINT DATA=WORK.NET_LIST_MN(WHERE=(eraddsc IN ('宇匯推薦商品', '東科推薦商品') AND Date EQ &LAST_DATE)) NOOBS 
							STYLE(DATA)=[JUST=C VJUST=M] STYLE(HEAD)=[JUST=C VJUST=M BACKGROUNDCOLOR=RGBA469E3433] CONTENTS="" LABEL;
					VAR eraddsc customerid '金額'N '數量'N;
					LABEL eraddsc=版位 customerid=客代;
				QUIT;
				ODS TEXT="^S={OUTPUTWIDTH=70% JUST=L}註1：只呈現每個版位的前三名。";
			ODS REGION HEIGHT=23pct;
				ODS TEXT="^S={OUTPUTWIDTH=100% FONTSIZE=10pt JUST=C}數量排行榜(淨訂單)";
				PROC PRINT DATA=WORK.NET_LIST_AMOUNT(WHERE=(eraddsc IN ('宇匯推薦商品', '東科推薦商品') AND Date EQ &LAST_DATE)) NOOBS 
							STYLE(DATA)=[JUST=C VJUST=M] STYLE(HEAD)=[JUST=C VJUST=M BACKGROUNDCOLOR=RGBA469E3433] CONTENTS="" LABEL;
					VAR eraddsc customerid '金額'N '數量'N;
					LABEL eraddsc=版位 customerid=客代;
				QUIT;
				ODS TEXT="^S={OUTPUTWIDTH=70% JUST=L}註1：只呈現每個版位的前三名。";
			ODS LAYOUT END;
			%LET h_count=%EVAL(&h_count+1); %LET v_count=%EVAL(&v_count+1); /*For displaying charts normally*/
			ODS PDF (ID=DYFIG) STARTPAGE=NOW;
				ODS LAYOUT GRIDDED /*STYLE={FONTFAMILY="Microsoft JhengHei"}*/
									COLUMNS=2 ROWS=3 COLUMN_WIDTHS=(50% 50%) HEIGHT=10in COLUMN_GUTTER=0 ROW_GUTTER=0;
				ODS ESCAPECHAR="^";
				ODS REGION COLUMN_SPAN=2 HEIGHT=5pct;
					ODS TEXT="^S={OUTPUTWIDTH=100% FONTSIZE=13pt JUST=C}%SYSFUNC(COMPRESS(%SYSFUNC(CATS(%SYSFUNC(PUTN(&INI_DATE, NLDATEW.)), -,%SYSFUNC(PUTN(&LAST_DATE, NLDATEW.)),全APP新舊客比例))))";
				ODS REGION COLUMN_SPAN=2 HEIGHT=48pct;
					GOPTIONS RESET=ALL DEVICE=SVG NOBORDER HSIZE=%SYSEVALF(7+&h_count.*0.01)in VSIZE=%SYSEVALF(4.6+&v_count.*0.01)in; 
					PATTERN1 C=CX4965B0; PATTERN2 C=CXFF7B58; PATTERN3 C=CX95B60E;
					PROC GCHART DATA=All_APP_N_O_R_TMP(WHERE=("日期"N=.));
						PIE "客戶類型"N/SUMVAR="銷售收入"N GROUP="訂單狀況"N MIDPOINTS="回頭客" "新客"
							 ACROSS=2 DOWN=2 PERCENT=arrow COUTLINE=CX7C5C00 NOHEADING;
						RUN;
					QUIT;
				ODS REGION COLUMN_SPAN=2 HEIGHT=47pct;
					ODS TEXT="^S={OUTPUTWIDTH=100% FONTSIZE=12pt JUST=C}%SYSFUNC(COMPRESS(%SYSFUNC(PUTN(&INI_DATE, NLDATEW.))))-%SYSFUNC(COMPRESS(%SYSFUNC(PUTN(&LAST_DATE, NLDATEW.))))訂單資訊與銷退細節";
					PROC PRINT DATA=All_APP_N_O_R_TMP(WHERE=("日期"N=. AND "訂單狀況"N="NET")) NOOBS STYLE(DATA)=[JUST=C VJUST=M] STYLE(HEAD)=[JUST=C VJUST=M BACKGROUNDCOLOR=RGBAAA393933] CONTENTS="" LABEL;
						VAR 客戶類型 版位 訂單狀況 銷售收入 "客單價（AS）"N "平均訂單價值（AOV）"N "平均訂單量（AOS）"N;
					QUIT;
					ODS TEXT="^S={OUTPUTWIDTH=85% JUST=L}註1：客單價=銷售收入÷顧客數";
					ODS TEXT="^S={OUTPUTWIDTH=85% JUST=L}註2：平均訂單價值=銷售收入÷訂單數";
					ODS TEXT="^S={OUTPUTWIDTH=85% JUST=L}註3：平均訂單量=商品數量÷訂單數";
					PROC PRINT DATA=WORK.R_LIST NOOBS STYLE(DATA)=[JUST=C VJUST=M] STYLE(HEAD)=[JUST=C VJUST=M BACKGROUNDCOLOR=RGBA765CC833] CONTENTS="" LABEL;
						VAR SALENO SALENAME 銷售收入 數量;
						LABEL SALENAME=銷退商品名稱 SALENO=銷售編號 數量=商品數量 銷售收入=金額;
					QUIT;
				ODS LAYOUT END;
				%LET h_count=%EVAL(&h_count+1); %LET v_count=%EVAL(&v_count+1); /*For displaying charts normally*/
				ODS PDF (ID=DYFIG) STARTPAGE=NOW;
				/*Page 2*/
				ODS LAYOUT GRIDDED STYLE={FONTFAMILY="Microsoft JhengHei"}
									COLUMNS=3 ROWS=4 COLUMN_WIDTHS=(33.3% 33.3% 33.4%) HEIGHT=10in COLUMN_GUTTER=0 ROW_GUTTER=0;
				ODS REGION COLUMN_SPAN=3 HEIGHT=5pct;
					ODS TEXT="^S={OUTPUTWIDTH=100% FONTSIZE=13pt JUST=C}%SYSFUNC(COMPRESS(%SYSFUNC(CATS(%SYSFUNC(PUTN(&INI_DATE, NLDATEW.)), -,%SYSFUNC(PUTN(&LAST_DATE, NLDATEW.)),專屬推薦與精選好物新舊客))))";
				ODS REGION COLUMN_SPAN=3 HEIGHT=48pct;
					GOPTIONS HSIZE=%SYSEVALF(7+&h_count.*0.01)in VSIZE=%SYSEVALF(4.6+&v_count.*0.01)in;
					PROC GCHART DATA=Personal_N_O_R_TMP(WHERE=("日期"N=. AND "訂單狀況"N = "NET"));
						VBAR "版位"N/SUMVAR="銷售收入"N GROUP="訂單狀況"N SUBGROUP="客戶類型"N SPACE=0;
						RUN;
					QUIT;
				ODS REGION COLUMN_SPAN=3 HEIGHT=24pct;
					ODS TEXT="^S={OUTPUTWIDTH=100% FONTSIZE=10pt JUST=C}訂單資訊";
					PROC PRINT DATA=Personal_N_O_R_TMP(WHERE=("日期"N=.  AND "訂單狀況"N="NET")) NOOBS STYLE(DATA)=[JUST=C VJUST=M] STYLE(HEAD)=[JUST=C VJUST=M BACKGROUNDCOLOR=RGBAAA393933] CONTENTS="" LABEL;
						VAR 客戶類型 版位 訂單狀況 銷售收入 "客單價（AS）"N "平均訂單價值（AOV）"N "平均訂單量（AOS）"N;
					QUIT;
				ODS REGION HEIGHT=23pct;
					ODS TEXT="^S={OUTPUTWIDTH=100% FONTSIZE=10pt JUST=C}金額排行榜(淨訂單)";
					PROC PRINT DATA=WORK.NET_LIST_MN(WHERE=(eraddsc IN ('專屬推薦', '知心商品', '即時新品', '好康商品', '季節商品') AND Date EQ .)) NOOBS 
								STYLE(DATA)=[JUST=C VJUST=M] STYLE(HEAD)=[JUST=C VJUST=M BACKGROUNDCOLOR=RGBA469E3433] CONTENTS="" LABEL;
						VAR eraddsc customerid '金額'N '數量'N;
						LABEL eraddsc=版位 customerid=客代;
					QUIT;
					ODS TEXT="^S={OUTPUTWIDTH=70% JUST=L}註1：只呈現每個版位的前三名。";
				ODS REGION HEIGHT=23pct;
					ODS TEXT="^S={OUTPUTWIDTH=100% FONTSIZE=10pt JUST=C}數量排行榜(淨訂單)";
					PROC PRINT DATA=WORK.NET_LIST_AMOUNT(WHERE=(eraddsc IN ('專屬推薦', '知心商品', '即時新品', '好康商品', '季節商品') AND Date EQ .)) NOOBS 
								STYLE(DATA)=[JUST=C VJUST=M] STYLE(HEAD)=[JUST=C VJUST=M BACKGROUNDCOLOR=RGBA469E3433] CONTENTS="" LABEL;
						VAR eraddsc customerid '金額'N '數量'N;
						LABEL eraddsc=版位 customerid=客代;
					QUIT;
					ODS TEXT="^S={OUTPUTWIDTH=70% JUST=L}註1：只呈現每個版位的前三名。";
				ODS REGION HEIGHT=23pct;
					ODS TEXT="^S={OUTPUTWIDTH=100% FONTSIZE=9pt JUST=C}版位收益趨勢";
					PROC SGPLOT DATA=WORK.NET_LIST_AMOUNT(WHERE=(eraddsc IN ('專屬推薦', '知心商品', '即時新品', '好康商品', '季節商品')  AND Date NE .));
						VLINE Date/RESPONSE='金額'N GROUP=eraddsc;
						XAXIS DISPLAY=(NOLABEL); YAXIS DISPLAY=(NOLABEL);
						KEYLEGEND/ TITLE="版位" TITLEATTRS=(FAMILY=BiauKai SIZE=8) VALUEATTRS=(FAMILY=BiauKai SIZE=8);
					RUN; QUIT;
				ODS LAYOUT END;
				%LET h_count=%EVAL(&h_count+1); %LET v_count=%EVAL(&v_count+1); /*For displaying charts normally*/
				ODS PDF (ID=DYFIG) STARTPAGE=NOW;
				/*Page 3*/
				ODS LAYOUT GRIDDED /*STYLE={FONTFAMILY="Microsoft JhengHei"}*/
									COLUMNS=3 ROWS=4 COLUMN_WIDTHS=(33.3% 33.3% 33.4%) HEIGHT=10in COLUMN_GUTTER=0 ROW_GUTTER=0;
				ODS REGION COLUMN_SPAN=3 HEIGHT=5pct;
					ODS TEXT="^S={OUTPUTWIDTH=100% FONTSIZE=13pt JUST=C}%SYSFUNC(COMPRESS(%SYSFUNC(CATS(%SYSFUNC(PUTN(&INI_DATE, NLDATEW.)), -,%SYSFUNC(PUTN(&LAST_DATE, NLDATEW.)),當日熱賣新舊客))))";
				ODS REGION COLUMN_SPAN=3 HEIGHT=48pct;
					GOPTIONS HSIZE=%SYSEVALF(7+&h_count.*0.01)in VSIZE=%SYSEVALF(4.6+&v_count.*0.01)in;
					PROC GCHART DATA=HotSale_N_O_R_TMP(WHERE=("日期"N=.));
						VBAR "版位"N/SUMVAR="銷售收入"N GROUP="訂單狀況"N SUBGROUP="客戶類型"N SPACE=0;
						RUN;
					QUIT;
				ODS REGION COLUMN_SPAN=3 HEIGHT=24pct;
					ODS TEXT="^S={OUTPUTWIDTH=100% FONTSIZE=10pt JUST=C}訂單資訊";
					PROC PRINT DATA=HotSale_N_O_R_TMP(WHERE=("日期"N=. AND "訂單狀況"N="NET")) NOOBS STYLE(DATA)=[JUST=C VJUST=M] STYLE(HEAD)=[JUST=C VJUST=M BACKGROUNDCOLOR=RGBAAA393933] CONTENTS="" LABEL;
						VAR 客戶類型 版位 訂單狀況 銷售收入 "客單價（AS）"N "平均訂單價值（AOV）"N "平均訂單量（AOS）"N;
					QUIT;
				ODS REGION HEIGHT=23pct;
					ODS TEXT="^S={OUTPUTWIDTH=100% FONTSIZE=10pt JUST=C}金額排行榜(淨訂單)";
					PROC PRINT DATA=WORK.NET_LIST_MN(WHERE=(eraddsc IN ('宇匯推薦商品', '東科推薦商品') AND Date EQ .)) NOOBS 
								STYLE(DATA)=[JUST=C VJUST=M] STYLE(HEAD)=[JUST=C VJUST=M BACKGROUNDCOLOR=RGBA469E3433] CONTENTS="" LABEL;
						VAR eraddsc customerid '金額'N '數量'N;
						LABEL eraddsc=版位 customerid=客代;
					QUIT;
					ODS TEXT="^S={OUTPUTWIDTH=70% JUST=L}註1：只呈現每個版位的前三名。";
				ODS REGION HEIGHT=23pct;
					ODS TEXT="^S={OUTPUTWIDTH=100% FONTSIZE=10pt JUST=C}數量排行榜(淨訂單)";
					PROC PRINT DATA=WORK.NET_LIST_AMOUNT(WHERE=(eraddsc IN ('宇匯推薦商品', '東科推薦商品') AND Date EQ .)) NOOBS 
								STYLE(DATA)=[JUST=C VJUST=M] STYLE(HEAD)=[JUST=C VJUST=M BACKGROUNDCOLOR=RGBA469E3433] CONTENTS="" LABEL;
						VAR eraddsc customerid '金額'N '數量'N;
						LABEL eraddsc=版位 customerid=客代;
					QUIT;
					ODS TEXT="^S={OUTPUTWIDTH=70% JUST=L}註1：只呈現每個版位的前三名。";
				ODS REGION HEIGHT=23pct;
					ODS TEXT="^S={OUTPUTWIDTH=100% FONTSIZE=9pt JUST=C}版位收益趨勢";
					PROC SGPLOT DATA=WORK.NET_LIST_AMOUNT(WHERE=(eraddsc IN ('宇匯推薦商品', '東科推薦商品')  AND Date NE .));
						VLINE Date/RESPONSE='金額'N GROUP=eraddsc;
						XAXIS DISPLAY=(NOLABEL); YAXIS DISPLAY=(NOLABEL);
						KEYLEGEND/ TITLE="版位" TITLEATTRS=(FAMILY=BiauKai SIZE=8) VALUEATTRS=(FAMILY=BiauKai SIZE=8);
					RUN; QUIT;
				ODS LAYOUT END;
				%LET h_count=%EVAL(&h_count+1); %LET v_count=%EVAL(&v_count+1); /*For displaying charts normally*/
				ODS PDF (ID=DYFIG) STARTPAGE=NOW;
				%_eg_conditional_dropds(All_APP_N_O_R_TMP)
				%_eg_conditional_dropds(Personal_N_O_R_TMP)
				%_eg_conditional_dropds(HotSale_N_O_R_TMP)
		OPTIONS LOCALE=en_US;
		ODS _ALL_ CLOSE;
	%END;
%END;
%MEND;