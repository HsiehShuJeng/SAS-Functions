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
			WHERE Explicitcategory NE '���϶�' AND Implicitcategory NOT IN ('', '������') AND RegOrNot = 'U' 
					AND Date ^= . AND (Date BETWEEN &LAST_DATE AND &LAST_DATE ) AND Device='����';
	QUIT;
	%END;
	%ELSE %DO;
	PROC SQL;
		CREATE TABLE TMP_2 AS
			SELECT * FROM TMP_1
			WHERE Explicitcategory NE '���϶�' AND Implicitcategory NOT IN ('', '������') AND RegOrNot = 'U' 
					AND Date ^= . AND (Date BETWEEN &LAST_DATE AND &LAST_DATE ) AND Device='����';
	QUIT;
	%END;
	/*
		Rename the variables for the report.
	*/
	PROC DATASETS LIB=WORK NOLIST;
		MODIFY TMP_2;
			RENAME CLCtimes='�I����'N Implicitcategory='�j����'N Explicitcategory='�p����'N;
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
		ODS TEXT="^S={FONTSIZE=13pt JUST=C}%SYSFUNC(STRIP(%SYSFUNC(PUTN(&LAST_DATE, NLDATEW.)))) �I���Ʀ�";
		ODS LAYOUT GRIDDED /*STYLE={FONTFAMILY="Microsoft JhengHei"}*/
						COLUMNS=2 ROWS=2 COLUMN_WIDTHS=(50% 50%) HEIGHT=10in COLUMN_GUTTER=0 ROW_GUTTER=0;
		/*Left-top corner*/
		ODS REGION HEIGHT=50pct;
			ODS TEXT="^S={FONTSIZE=13pt}��APP�I���Ʀ��";
			PROC PRINT DATA=WORK.LOCALIZED_CLC_FIG_TMP1 NOOBS STYLE(DATA)=[JUST=C VJUST=M]
						STYLE(HEAD)=[JUST=C VJUST=M BACKGROUNDCOLOR=RGBA765CC833] CONTENTS="";
			RUN;
			ODS TEXT="^S={WIDTH=100% JUST=L}��1�G�u�C�X�����I���ƥH�αƦW�e�Q���j�����C";
			ODS TEXT="^S={WIDTH=100% JUST=L}��2�G�ثeOthers�]�tercampid�Ȭ�Interstitial_Ad�BExclusiveProd_ChessBoardBT�BHome_LiveNow�BNewProd_*�BPanic_Buy�BShopCart�BAPINoDataOrTimeOut�BChatRoom�BContactService�H��PushSet���O���C";
		/*Right-top corner*/
		ODS REGION HEIGHT=50pct;
			ODS TEXT="^S={FONTSIZE=13pt}�����I���Ʀ��";
			PROC PRINT DATA=WORK.CLC_TABS_FIG NOOBS STYLE(DATA)=[JUST=C VJUST=M]
						STYLE(HEAD)=[JUST=C VJUST=M BACKGROUNDCOLOR=RGBA765CC833] CONTENTS="";
			RUN;
			ODS TEXT="^S={WIDTH=100% JUST=L}��1�G��������_*�P��������_*���ݪ��Y��쳣���u�Y�����v�C";
			ODS TEXT="^S={WIDTH=100% JUST=L}��2�G��������_*�P��������_*�ҥN�����Ҧ�󭺭����A�ӥ����I���ƻP�����I���Ƭ����}�p��C";
		/*Left-bottom corner*/
		ODS REGION HEIGHT=48pct;
		TITLE1;
			ODS TEXT="^S={FONTSIZE=13pt}�����I���Ʀ��";
			PROC PRINT DATA=WORK.BK_CLK_PER NOOBS STYLE(DATA)=[JUST=C VJUST=M]
						STYLE(HEAD)=[JUST=C VJUST=M BACKGROUNDCOLOR=RGBA765CC833] CONTENTS="";
			RUN;
			ODS TEXT="^S={WIDTH=95% JUST=L}��1�G���O�Ŀ�]�������������^�B�Ŀ�M�����Ŀ�]�������������^�B�ݧ�h�]Ĵ�p�G�������������^���O���t�A���C";
		/*Right-bottom corner*/
		ODS REGION HEIGHT=48pct;
			ODS TEXT="^S={FONTSIZE=13pt}��������";
			ODS TEXT="";
			ODS TEXT="^S={WIDTH=100% JUST=L}1.";
			ODS TEXT="^S={WIDTH=100% JUST=L}���F�W�[�iŪ�ʥH�ε�ı�ƪ��i��ʡA����t��v2.0����F�A�������A�Y�j�����M�p�����A�Ө�̪������D�n�̾ڬ��������������M�������������C";
			ODS TEXT="^S={WIDTH=100% JUST=L}2.";
			ODS TEXT="^S={WIDTH=100% JUST=L}�Ҧ��j�����M�p�������I������i�Ѧ�HTML�ɡA�ثe�O�H�x�Φ��𪬵��c�άO����ϡ]Treemap�^�ӧe�{�F���ʪ�APP���I�����p�C";
			ODS TEXT="^S={WIDTH=100% JUST=L}3.";
			ODS TEXT="^S={WIDTH=100% JUST=L}�I�����ԭz�έp�ӷ����������������ȬO�������������M����������������������A�ӡ������������M�������������|������ID���ƪ����p�C�ثe����t��v2.0�u������������M���������������涰�ǤJ�@���A";
			ODS TEXT="^S={WIDTH=100% JUST=L}���y�ܻ��A�I���ԭz�έp���ӷ����������������������[�W�������������b�����������������۹�t���C";
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
				WHERE Explicitcategory NE '���϶�' AND Implicitcategory NOT IN ('', '������') AND RegOrNot = 'U' 
						AND Date ^= . AND (Date BETWEEN &i AND &i ) AND Device='����';
		QUIT;
		/*
			Rename the variables for the report.
		*/
		PROC DATASETS LIB=WORK NOLIST;
			MODIFY TMP_2;
				RENAME CLCtimes='�I����'N Implicitcategory='�j����'N Explicitcategory='�p����'N;
		QUIT;
		OPTIONS LOCALE=zh_TW; OPTIONS NODATE;
		%generateExplicitDailyRank /*%generateExplicitDailyRank*/
		%generateDailyTabStats /*%generateTimeRangeTabStats*/
		OPTIONS NODATE; OPTIONS DEV=ACTXIMG;
		ODS PDF (ID=DYFIG) STARTPAGE=NOW;
		ODS ESCAPECHAR="^";
		GOPTIONS RESET=ALL NOBORDER;
		ODS TEXT="^S={FONTSIZE=13pt JUST=C}%SYSFUNC(STRIP(%SYSFUNC(PUTN(&i, NLDATEW.)))) �I���Ʀ�";
		ODS LAYOUT GRIDDED /*STYLE={FONTFAMILY="Microsoft JhengHei"}*/
						COLUMNS=2 ROWS=2 COLUMN_WIDTHS=(50% 50%) HEIGHT=10in COLUMN_GUTTER=0 ROW_GUTTER=0;
		/*Left-top corner*/
		ODS REGION HEIGHT=50pct;
			ODS TEXT="^S={FONTSIZE=13pt}��APP�I���Ʀ��";
			PROC PRINT DATA=WORK.LOCALIZED_CLC_FIG_TMP1 NOOBS STYLE(DATA)=[JUST=C VJUST=M]
						STYLE(HEAD)=[JUST=C VJUST=M BACKGROUNDCOLOR=RGBA765CC833] CONTENTS="";
			RUN;
			ODS TEXT="^S={WIDTH=100% JUST=L}��1�G�u�C�X�����I���ƥH�αƦW�e�Q���j�����C";
			ODS TEXT="^S={WIDTH=100% JUST=L}��2�G�ثeOthers�]�t�������������Ȭ��������������B�������������B�������������B�������������B�������������B�������������B�������������B�������������B�������������H�Ρ��������������O���C";
		/*Right-top corner*/
		ODS REGION HEIGHT=50pct;
			ODS TEXT="^S={FONTSIZE=13pt}�����I���Ʀ��";
			PROC PRINT DATA=WORK.CLC_TABS_FIG NOOBS STYLE(DATA)=[JUST=C VJUST=M]
						STYLE(HEAD)=[JUST=C VJUST=M BACKGROUNDCOLOR=RGBA765CC833] CONTENTS="";
			RUN;
			ODS TEXT="^S={WIDTH=100% JUST=L}��1�G�������������P���������������ݪ������������������u�������������v�C";
			ODS TEXT="^S={WIDTH=100% JUST=L}��2�G�������������P�������������ҥN�����Ҧ�󭺭����A�ӥ����I���ƻP�����I���Ƭ����}�p��C";
		/*Left-bottom corner*/
		ODS REGION HEIGHT=48pct;
		TITLE1;
			ODS TEXT="^S={FONTSIZE=13pt}�����I���Ʀ��";
			PROC PRINT DATA=WORK.BK_CLK_PER NOOBS STYLE(DATA)=[JUST=C VJUST=M]
						STYLE(HEAD)=[JUST=C VJUST=M BACKGROUNDCOLOR=RGBA765CC833] CONTENTS="";
			RUN;
			ODS TEXT="^S={WIDTH=95% JUST=L}��1�G���O�Ŀ�]�������������^�B�Ŀ�M�����Ŀ�]�������������^�B�ݧ�h�]Ĵ�p�G�������������^���O���t�A���C";
		/*Right-bottom corner*/
		ODS REGION HEIGHT=48pct;
			ODS TEXT="^S={FONTSIZE=13pt}��������";
			ODS TEXT="";
			ODS TEXT="^S={WIDTH=100% JUST=L}1.";
			ODS TEXT="^S={WIDTH=100% JUST=L}���F�W�[�iŪ�ʥH�ε�ı�ƪ��i��ʡA����t��v2.0����F�A�������A�Y�j�����M�p�����A�Ө�̪������D�n�̾ڬ��������������M�������������C";
			ODS TEXT="^S={WIDTH=100% JUST=L}2.";
			ODS TEXT="^S={WIDTH=100% JUST=L}�Ҧ��j�����M�p�������I������i�Ѧ�HTML�ɡA�ثe�O�H�x�Φ��𪬵��c�άO����ϡ]Treemap�^�ӧe�{�F���ʪ�APP���I�����p�C";
			ODS TEXT="^S={WIDTH=100% JUST=L}3.";
			ODS TEXT="^S={WIDTH=100% JUST=L}�I�����ԭz�έp�ӷ����������������ȬO�������������M����������������������A�ӡ������������M�������������|�������������������p�C�ثe����t��v2.0�u������������M���������������涰�ǤJ�@���A";
			ODS TEXT="^S={WIDTH=100% JUST=L}���y�ܻ��A�I���ԭz�έp���ӷ����������������������[�W�������������b�����������������۹�t���C";
		ODS LAYOUT END;
		ODS PDF (ID=DYFIG) STARTPAGE=NOW;
		/*Page for the whole time range.*/
		%IF &i EQ &LAST_DATE %THEN %DO;
			PROC SQL;
				CREATE TABLE TMP_2 AS
					SELECT * FROM TMP_1
					WHERE Explicitcategory NE '���϶�' AND Implicitcategory NOT IN ('', '������') AND RegOrNot = 'U' 
							AND Date ^= . AND (Date BETWEEN &INI_DATE AND &LASt_DATE ) AND Device='����';
			QUIT;
			/*
				Rename the variables for the report.
			*/
			PROC DATASETS LIB=WORK NOLIST;
				MODIFY TMP_2;
					RENAME CLCtimes='�I����'N Implicitcategory='�j����'N Explicitcategory='�p����'N;
			QUIT;
			OPTIONS LOCALE=zh_TW; OPTIONS NODATE;
			%generateExplicitTimeRangeRank /*%generateExplicitDailyRank*/
			%generateTimeRangeTabStats /*%generateDailyTabStats*/
			OPTIONS NODATE;
			OPTIONS DEV=ACTXIMG;
			ODS ESCAPECHAR="^";
			GOPTIONS RESET=ALL NOBORDER;
			ODS TEXT="^S={FONTSIZE=13pt JUST=C}%SYSFUNC(STRIP(%SYSFUNC(PUTN(&INI_DATE, NLDATEW.))))��%SYSFUNC(STRIP(%SYSFUNC(PUTN(&LAST_DATE, NLDATEW.)))) �I���Ʀ�";
			ODS LAYOUT GRIDDED /*STYLE={FONTFAMILY="Microsoft JhengHei"}*/
							COLUMNS=2 ROWS=2 COLUMN_WIDTHS=(50% 50%) HEIGHT=10in COLUMN_GUTTER=0 ROW_GUTTER=0;
			/*Left-top corner*/
			ODS REGION HEIGHT=50pct;
				ODS TEXT="^S={FONTSIZE=13pt}��APP�I���Ʀ��";
				PROC PRINT DATA=WORK.LOCALIZED_CLC_FIG_TMP1 NOOBS STYLE(DATA)=[JUST=C VJUST=M]
							STYLE(HEAD)=[JUST=C VJUST=M BACKGROUNDCOLOR=RGBA765CC833] CONTENTS="";
				RUN;
				ODS TEXT="^S={WIDTH=100% JUST=L}��1�G�u�C�X�����I���ƥH�αƦW�e�Q���j�����C";
				ODS TEXT="^S={WIDTH=100% JUST=L}��2�G�ثeOthers�]�t�������������Ȭ��������������B�������������B�������������B�������������B�������������B�������������B�������������B�������������B�������������H�Ρ��������������O���C";
			/*Right-top corner*/
			ODS REGION HEIGHT=50pct;
				ODS TEXT="^S={FONTSIZE=13pt}�����I���Ʀ��";
				PROC PRINT DATA=WORK.CLC_TABS_FIG NOOBS STYLE(DATA)=[JUST=C VJUST=M]
							STYLE(HEAD)=[JUST=C VJUST=M BACKGROUNDCOLOR=RGBA765CC833] CONTENTS="";
				RUN;
				ODS TEXT="^S={WIDTH=100% JUST=L}��1�G�������������P���������������ݪ������������������u�������������v�C";
				ODS TEXT="^S={WIDTH=100% JUST=L}��2�G�������������P�������������ҥN�����Ҧ�󭺭����A�ӥ����I���ƻP�����I���Ƭ����}�p��C";
			/*Left-bottom corner*/
			ODS REGION HEIGHT=48pct;
			TITLE1;
				ODS TEXT="^S={FONTSIZE=13pt}�����I���Ʀ��";
				PROC PRINT DATA=WORK.BK_CLK_PER NOOBS STYLE(DATA)=[JUST=C VJUST=M]
							STYLE(HEAD)=[JUST=C VJUST=M BACKGROUNDCOLOR=RGBA765CC833] CONTENTS="";
				RUN;
				ODS TEXT="^S={WIDTH=95% JUST=L}��1�G���O�Ŀ�]�������������^�B�Ŀ�M�����Ŀ�]�������������^�B�ݧ�h�]Ĵ�p�G�������������^���O���t�A���C";
			/*Right-bottom corner*/
			ODS REGION HEIGHT=48pct;
				%_eg_conditional_dropds(CLK_PER_EACHD_TMP)
				ODS TEXT="^S={FONTSIZE=13pt}��APP�M�����I���Ͷչ�";
				PROC SQL;
					CREATE TABLE CLK_PER_EACHD_TMP AS
						SELECT Date AS '���'N, CASE WHEN �j���� EQ "" THEN "�`�M" ELSE �j���� END AS �j����, �I���� 
						FROM CLK_PER_EACHD
						WHERE CALCULATED �j���� IN ("�`�M", "����");
				QUIT;
				GOPTIONS RESET=ALL NOBORDER DEVICE=SVG;
				PROC SGPLOT DATA=CLK_PER_EACHD_TMP;
					REG X='���'N Y='�I����'N/GROUP=�j����
						/*DATALABEL='�I����'N DATALABELPOS=TOP*/ DEGREE=2 JITTER;
						XAXIS DISPLAY=(NOLABEL); YAXIS DISPLAY=(NOLABEL);
						KEYLEGEND/ TITLE="�϶�" TITLEATTRS=(FAMILY=BiauKai SIZE=12) VALUEATTRS=(FAMILY=BiauKai SIZE=10);
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
				WHERE Explicitcategory NE '���϶�' AND Implicitcategory NOT IN ('', '������') AND RegOrNot = 'U' 
						AND Date ^= . AND (Date BETWEEN &LAST_DATE AND &LAST_DATE ) AND Device='����';
		QUIT;
		/*
			Rename the variables for the report.
		*/
		PROC DATASETS LIB=WORK NOLIST;
			MODIFY TMP_2;
				RENAME CLCtimes='�I����'N Implicitcategory='�j����'N Explicitcategory='�p����'N;
		QUIT;
		OPTIONS LOCALE=zh_TW; OPTIONS NODATE;
		%generateExplicitDailyRank /*%generateExplicitDailyRank*/
		%generateDailyTabStats /*%generateTimeRangeTabStats*/
		OPTIONS NODATE;
		OPTIONS DEV=ACTXIMG;
		ODS ESCAPECHAR="^";
		GOPTIONS RESET=ALL NOBORDER;
		ODS TEXT="^S={FONTSIZE=13pt JUST=C}%SYSFUNC(STRIP(%SYSFUNC(PUTN(&LAST_DATE, NLDATEW.)))) �I���Ʀ�";
		ODS LAYOUT GRIDDED /*STYLE={FONTFAMILY="Microsoft JhengHei"}*/
						COLUMNS=2 ROWS=2 COLUMN_WIDTHS=(50% 50%) HEIGHT=10in COLUMN_GUTTER=0 ROW_GUTTER=0;
		/*Left-top corner*/
		ODS REGION HEIGHT=50pct;
			ODS TEXT="^S={FONTSIZE=13pt}��APP�I���Ʀ��";
			PROC PRINT DATA=WORK.LOCALIZED_CLC_FIG_TMP1 NOOBS STYLE(DATA)=[JUST=C VJUST=M]
						STYLE(HEAD)=[JUST=C VJUST=M BACKGROUNDCOLOR=RGBA765CC833] CONTENTS="";
			RUN;
			ODS TEXT="^S={WIDTH=100% JUST=L}��1�G�u�C�X�����I���ƥH�αƦW�e�Q���j�����C";
			ODS TEXT="^S={WIDTH=100% JUST=L}��2�G�ثeOthers�]�t�������������Ȭ��������������B�������������B�������������B�������������B�������������B�������������B�������������B�������������B�������������H�Ρ��������������O���C";
		/*Right-top corner*/
		ODS REGION HEIGHT=50pct;
			ODS TEXT="^S={FONTSIZE=13pt}�����I���Ʀ��";
			PROC PRINT DATA=WORK.CLC_TABS_FIG NOOBS STYLE(DATA)=[JUST=C VJUST=M]
						STYLE(HEAD)=[JUST=C VJUST=M BACKGROUNDCOLOR=RGBA765CC833] CONTENTS="";
			RUN;
			ODS TEXT="^S={WIDTH=100% JUST=L}��1�G�������������P���������������ݪ������������������u�������������v�C";
			ODS TEXT="^S={WIDTH=100% JUST=L}��2�G�������������P�������������ҥN�����Ҧ�󭺭����A�ӥ����I���ƻP�����I���Ƭ����}�p��C";
		/*Left-bottom corner*/
		ODS REGION HEIGHT=48pct;
		TITLE1;
			ODS TEXT="^S={FONTSIZE=13pt}�����I���Ʀ��";
			PROC PRINT DATA=WORK.BK_CLK_PER NOOBS STYLE(DATA)=[JUST=C VJUST=M]
						STYLE(HEAD)=[JUST=C VJUST=M BACKGROUNDCOLOR=RGBA765CC833] CONTENTS="";
			RUN;
			ODS TEXT="^S={WIDTH=95% JUST=L}��1�G���O�Ŀ�]�������������^�B�Ŀ�M�����Ŀ�]�������������^�B�ݧ�h�]Ĵ�p�G�������������^���O���t�A���C";
		/*Right-bottom corner*/
		ODS REGION HEIGHT=48pct;
			ODS TEXT="^S={FONTSIZE=13pt}��������";
			ODS TEXT="";
			ODS TEXT="^S={WIDTH=100% JUST=L}1.";
			ODS TEXT="^S={WIDTH=100% JUST=L}���F�W�[�iŪ�ʥH�ε�ı�ƪ��i��ʡA����t��v2.0����F�A�������A�Y�j�����M�p�����A�Ө�̪������D�n�̾ڬ��������������M�������������C";
			ODS TEXT="^S={WIDTH=100% JUST=L}2.";
			ODS TEXT="^S={WIDTH=100% JUST=L}�Ҧ��j�����M�p�������I������i�Ѧ�HTML�ɡA�ثe�O�H�x�Φ��𪬵��c�άO����ϡ]Treemap�^�ӧe�{�F���ʪ�APP���I�����p�C";
			ODS TEXT="^S={WIDTH=100% JUST=L}3.";
			ODS TEXT="^S={WIDTH=100% JUST=L}�I�����ԭz�έp�ӷ����������������ȬO�������������M����������������������A�ӡ������������M�������������|������ID���ƪ����p�C�ثe����t��v2.0�u������������M���������������涰�ǤJ�@���A";
			ODS TEXT="^S={WIDTH=100% JUST=L}���y�ܻ��A�I���ԭz�έp���ӷ����������������������[�W�������������b�����������������۹�t���C";
		ODS LAYOUT END;
		ODS PDF (ID=DYFIG) STARTPAGE=NOW;
		/*Page for the whole time range.*/
		PROC SQL;
			CREATE TABLE TMP_2 AS
				SELECT * FROM TMP_1
				WHERE Explicitcategory NE '���϶�' AND Implicitcategory NOT IN ('', '������') AND RegOrNot = 'U' 
						AND Date ^= . AND (Date BETWEEN &INI_DATE AND &LASt_DATE ) AND Device='����';
		QUIT;
		/*
			Rename the variables for the report.
		*/
		PROC DATASETS LIB=WORK NOLIST;
			MODIFY TMP_2;
				RENAME CLCtimes='�I����'N Implicitcategory='�j����'N Explicitcategory='�p����'N;
		QUIT;
		OPTIONS LOCALE=zh_TW; OPTIONS NODATE;
		%generateExplicitTimeRangeRank /*%generateExplicitDailyRank*/
		%generateTimeRangeTabStats /*%generateDailyTabStats*/
		OPTIONS NODATE;
		OPTIONS DEV=ACTXIMG;
		ODS ESCAPECHAR="^";
		GOPTIONS RESET=ALL NOBORDER;
		ODS TEXT="^S={FONTSIZE=13pt JUST=C}%SYSFUNC(STRIP(%SYSFUNC(PUTN(&INI_DATE, NLDATEW.))))��%SYSFUNC(STRIP(%SYSFUNC(PUTN(&LAST_DATE, NLDATEW.)))) �I���Ʀ�";
		ODS LAYOUT GRIDDED /*STYLE={FONTFAMILY="Microsoft JhengHei"}*/
						COLUMNS=2 ROWS=2 COLUMN_WIDTHS=(50% 50%) HEIGHT=10in COLUMN_GUTTER=0 ROW_GUTTER=0;
		/*Left-top corner*/
		ODS REGION HEIGHT=50pct;
			ODS TEXT="^S={FONTSIZE=13pt}��APP�I���Ʀ��";
			PROC PRINT DATA=WORK.LOCALIZED_CLC_FIG_TMP1 NOOBS STYLE(DATA)=[JUST=C VJUST=M]
						STYLE(HEAD)=[JUST=C VJUST=M BACKGROUNDCOLOR=RGBA765CC833] CONTENTS="";
			RUN;
			ODS TEXT="^S={WIDTH=100% JUST=L}��1�G�u�C�X�����I���ƥH�αƦW�e�Q���j�����C";
			ODS TEXT="^S={WIDTH=100% JUST=L}��2�G�ثeOthers�]�t�������������Ȭ��������������B�������������B�������������B�������������B�������������B�������������B�������������B�������������B�������������H�Ρ��������������O���C";
		/*Right-top corner*/
		ODS REGION HEIGHT=50pct;
			ODS TEXT="^S={FONTSIZE=13pt}�����I���Ʀ��";
			PROC PRINT DATA=WORK.CLC_TABS_FIG NOOBS STYLE(DATA)=[JUST=C VJUST=M]
						STYLE(HEAD)=[JUST=C VJUST=M BACKGROUNDCOLOR=RGBA765CC833] CONTENTS="";
			RUN;
			ODS TEXT="^S={WIDTH=100% JUST=L}��1�G�������������P���������������ݪ������������������u�������������v�C";
			ODS TEXT="^S={WIDTH=100% JUST=L}��2�G�������������P�������������ҥN�����Ҧ�󭺭����A�ӥ����I���ƻP�����I���Ƭ����}�p��C";
		/*Left-bottom corner*/
		ODS REGION HEIGHT=48pct;
		TITLE1;
			ODS TEXT="^S={FONTSIZE=13pt}�����I���Ʀ��";
			PROC PRINT DATA=WORK.BK_CLK_PER NOOBS STYLE(DATA)=[JUST=C VJUST=M]
						STYLE(HEAD)=[JUST=C VJUST=M BACKGROUNDCOLOR=RGBA765CC833] CONTENTS="";
			RUN;
			ODS TEXT="^S={WIDTH=95% JUST=L}��1�G���O�Ŀ�]�������������^�B�Ŀ�M�����Ŀ�]�������������^�B�ݧ�h�]Ĵ�p�G�������������^���O���t�A���C";
		/*Right-bottom corner*/
		ODS REGION HEIGHT=48pct;
			%_eg_conditional_dropds(CLK_PER_EACHD_TMP)
			ODS TEXT="^S={FONTSIZE=13pt}��APP�M�����I���Ͷչ�";
			PROC SQL;
				CREATE TABLE CLK_PER_EACHD_TMP AS
					SELECT Date AS '���'N, CASE WHEN �j���� EQ "" THEN "�`�M" ELSE �j���� END AS �j����, �I���� 
					FROM CLK_PER_EACHD
					WHERE CALCULATED �j���� IN ("�`�M", "����");
			QUIT;
			GOPTIONS HSIZE=2in VSIZE=1in DEVICE=SVG;
			PROC SGPLOT DATA=CLK_PER_EACHD_TMP;
				REG X='���'N Y='�I����'N/GROUP=�j����
					/*DATALABEL='�I����'N DATALABELPOS=TOP*/ DEGREE=2;
					XAXIS DISPLAY=(NOLABEL); YAXIS DISPLAY=(NOLABEL);
					KEYLEGEND/ TITLE="�϶�" TITLEATTRS=(FAMILY=BiauKai SIZE=12) VALUEATTRS=(FAMILY=BiauKai SIZE=10);
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
			SELECT MDY(INPUT(SUBSTR(SUBSTR(���,FIND(���,'�~'),FIND(���,'��')-FIND(���,'�~')),ANYDIGIT(SUBSTR(���,FIND(���,'�~'),FIND(���,'��')-FIND(���,'�~')))),8.0),
						INPUT(SUBSTR(SUBSTR(���,FIND(���,'��'),FIND(���,'��')-FIND(���,'��')),ANYDIGIT(SUBSTR(���,FIND(���,'��'),FIND(���,'��')-FIND(���,'��')))),8.0),
						INPUT(SCAN(���,1,'�~'),8.0)) FORMAT=DATE9. AS ��� ,���� ,�I������ ,��J���� ,��J�ӫ~�ƶq ,��󦸼� ,���ӫ~�ƶq ,�q�檬�p 
					,�P�⦬�J FORMAT=DOLLAR12.0,�P�⦨�� FORMAT=DOLLAR12.0,�Q�� FORMAT=DOLLAR12.0,�ӫ~�ƶq ,�q��� ,��Q�v ,�ʪ����ഫ�v ,�ʪ��������v ,�q���ഫ�v ,�����ഫ�v
			FROM WORK.SS_DY_STATS
			WHERE �q�檬�p IN('NET','�L')
			UNION CORRESPONDING ALL
			SELECT MDY(INPUT(SUBSTR(SUBSTR(���,FIND(���,'�~'),FIND(���,'��')-FIND(���,'�~')),ANYDIGIT(SUBSTR(���,FIND(���,'�~'),FIND(���,'��')-FIND(���,'�~')))),8.0),
						INPUT(SUBSTR(SUBSTR(���,FIND(���,'��'),FIND(���,'��')-FIND(���,'��')),ANYDIGIT(SUBSTR(���,FIND(���,'��'),FIND(���,'��')-FIND(���,'��')))),8.0),
						INPUT(SCAN(���,1,'�~'),8.0)) FORMAT=DATE9. AS ��� ,���� ,�I������ ,��J���� ,��J�ӫ~�ƶq ,��󦸼� ,���ӫ~�ƶq ,�q�檬�p 
					,�P�⦬�J FORMAT=DOLLAR12.0,�P�⦨�� FORMAT=DOLLAR12.0,�Q�� FORMAT=DOLLAR12.0,�ӫ~�ƶq ,�q��� ,��Q�v ,�ʪ����ഫ�v ,�ʪ��������v ,�q���ഫ�v ,�����ഫ�v
			FROM WORK.HOTSALE_DY_STATS
			WHERE �q�檬�p IN('NET','�L')
			UNION CORRESPONDING ALL
			SELECT MDY(INPUT(SUBSTR(SUBSTR(���,FIND(���,'�~'),FIND(���,'��')-FIND(���,'�~')),ANYDIGIT(SUBSTR(���,FIND(���,'�~'),FIND(���,'��')-FIND(���,'�~')))),8.0),
						INPUT(SUBSTR(SUBSTR(���,FIND(���,'��'),FIND(���,'��')-FIND(���,'��')),ANYDIGIT(SUBSTR(���,FIND(���,'��'),FIND(���,'��')-FIND(���,'��')))),8.0),
						INPUT(SCAN(���,1,'�~'),8.0)) FORMAT=DATE9. AS ��� ,���� ,�I������ ,��J���� ,��J�ӫ~�ƶq ,��󦸼� ,���ӫ~�ƶq ,�q�檬�p 
					,�P�⦬�J FORMAT=DOLLAR12.0,�P�⦨�� FORMAT=DOLLAR12.0,�Q�� FORMAT=DOLLAR12.0,�ӫ~�ƶq ,�q��� ,��Q�v ,�ʪ����ഫ�v ,�ʪ��������v ,�q���ഫ�v ,�����ഫ�v
			FROM WORK.REST_DY_STATS
			WHERE �q�檬�p IN('NET','�L');
			CREATE TABLE DY_BK_REV AS
			SELECT ��� ,���� ,�I������ ,��J���� ,��J�ӫ~�ƶq ,��󦸼� ,���ӫ~�ƶq ,�q�檬�p ,�P�⦬�J/SUM(�P�⦬�J) FORMAT=PERCENT8.2 AS �禬����, �P�⦬�J ,
					�P�⦨�� ,�Q�� ,�ӫ~�ƶq ,�q��� ,��Q�v ,�ʪ����ഫ�v ,�ʪ��������v ,�q���ഫ�v ,�����ഫ�v
			FROM TEST
			GROUP BY ���
			ORDER BY ���, �����ഫ�v DESC;
		QUIT;
		%_eg_conditional_dropds(TEST2)
		PROC MEANS DATA=WORK.DY_BK_REV SUM NOPRINT;
			CLASS '���'N '����'N '�q�檬�p'N;
			VAR �I������ ��J���� ��J�ӫ~�ƶq ��󦸼� ���ӫ~�ƶq �P�⦬�J �P�⦨�� �Q�� �ӫ~�ƶq �q���;
			TYPES ��� ���*����*'�q�檬�p'N;
			OUTPUT OUT=TEST2 SUM=�I������ ��J���� ��J�ӫ~�ƶq ��󦸼� ���ӫ~�ƶq �P�⦬�J �P�⦨�� �Q�� �ӫ~�ƶq �q���;
		RUN;
		PROC SQL NOPRINT;
			SELECT MAX(LENGTH(STRIP(����))) INTO: position_ln FROM TEST2;
		QUIT;
		%LET position_ln=$%SYSFUNC(COMPRESS(&position_ln)).;
		DATA TEST2;
			RETAIN '���'N '����'N �I������ ��J���� ��J�ӫ~�ƶq ��󦸼� ���ӫ~�ƶq �q�檬�p �禬���� �P�⦬�J �P�⦨�� �Q�� 
					�ӫ~�ƶq �q��� ��Q�v �ʪ����ഫ�v �ʪ��������v �q���ഫ�v �����ഫ�v;
			FORMAT ���� &position_ln ��Q�v �ʪ����ഫ�v �ʪ��������v �q���ഫ�v �����ഫ�v PERCENT8.2;
			SET TEST2(DROP=_TYPE_ _FREQ_ RENAME=(����=����_TMP �q�檬�p=�q�檬�p_TMP));
			��Q�v=COALESCE(�Q��/�P�⦬�J,0); �ʪ����ഫ�v=COALESCE(��J����/�I������,0); 
			�ʪ��������v=COALESCE(��󦸼�/��J����,0); �q���ഫ�v=COALESCE(�q���/��J����,0); �����ഫ�v=COALESCE(�q���/�I������,0);
			IF �q�檬�p_TMP="" THEN �q�檬�p="NET"; ELSE �q�檬�p=�q�檬�p_TMP;
			IF ����_TMP="" THEN ����="��APP"; ELSE ����=����_TMP;
			DROP �q�檬�p_TMP ����_TMP;
		RUN;
		PROC SQL;
			CREATE TABLE TEST3 AS SELECT '���'N, '����'N, �I������, ��J����, ��J�ӫ~�ƶq, ��󦸼�, ���ӫ~�ƶq, 
				�q�檬�p, �P�⦬�J/MAX(�P�⦬�J) AS �禬���� FORMAT=percent8.2, 
				�P�⦬�J, �P�⦨��, �Q��, �ӫ~�ƶq, �q���, ��Q�v, �ʪ����ഫ�v, �ʪ��������v, �q���ഫ�v, �����ഫ�v
			FROM TEST2
			GROUP BY "���"N
			ORDER BY �����ഫ�v DESC;
		QUIT;
		%_eg_conditional_dropds(TEST2)
		ODS ESCAPECHAR="^";
		ODS REGION;
			ODS TEXT="^S={FONTSIZE=14pt JUST=C}������įq";
			GOPTIONS RESET=ALL NOBORDER;
			OPTIONS LOCALE=zh_TW;
			/*TITLE1 %SYSFUNC(CATS(%SYSFUNC(PUTN(&INI_DATE, NLDATEW.)),��, %SYSFUNC(PUTN(&LAST_DATE, NLDATEW.))));*/
			OPTIONS LOCALE=en_US;
			AXIS1 LABEL=NONE OFFSET=(4);
			AXIS2 LABEL=("�P�⦬�J");
			PROC GCHART DATA=TEST;
			PIE '����'N/SUMVAR='�P�⦬�J'N
				 PERCENT=INSIDE COUTLINE=CX7C5C00 NOHEADING JSTYLE OTHER=3;
			RUN;
			QUIT;
			%_eg_conditional_dropds(TEST)
			ODS TEXT="^S={WIDTH=80% JUST=L}��1�G���q����p��3 %STR(%%) �����쳣�|�Q�k��OTHER�C";
		ODS REGION;
			PROC PRINT DATA=TEST3(WHERE=(���� IN ('�r��1', '�r��2', '�r��3', '�r��4', '�r��5', '�r��6', '�r��7', '��APP'))) 
							NOOBS STYLE(DATA)=[JUST=C VJUST=M] STYLE(HEAD)=[JUST=C VJUST=M BACKGROUNDCOLOR=RGBA765CC833] CONTENTS="";
				VAR ��� ���� �禬���� �P�⦬�J ��Q�v �ʪ����ഫ�v �ʪ��������v �q���ഫ�v �����ഫ�v;
			RUN;
			ODS TEXT="^S={WIDTH=80% JUST=L}��1�G���H�����ഫ�v������ƧǡC";
			ODS TEXT="^S={WIDTH=80% JUST=L}��2�G�u�t�A�b�q��";
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
			SELECT MDY(INPUT(SUBSTR(SUBSTR(���,FIND(���,'�~'),FIND(���,'��')-FIND(���,'�~')),ANYDIGIT(SUBSTR(���,FIND(���,'�~'),FIND(���,'��')-FIND(���,'�~')))),8.0),
						INPUT(SUBSTR(SUBSTR(���,FIND(���,'��'),FIND(���,'��')-FIND(���,'��')),ANYDIGIT(SUBSTR(���,FIND(���,'��'),FIND(���,'��')-FIND(���,'��')))),8.0),
						INPUT(SCAN(���,1,'�~'),8.0)) FORMAT=DATE9. AS ��� ,���� ,�I������ ,��J���� ,��J�ӫ~�ƶq ,��󦸼� ,���ӫ~�ƶq ,�q�檬�p 
					,�P�⦬�J FORMAT=DOLLAR12.0,�P�⦨�� FORMAT=DOLLAR12.0,�Q�� FORMAT=DOLLAR12.0,�ӫ~�ƶq ,�q��� ,��Q�v ,�ʪ����ഫ�v ,�ʪ��������v ,�q���ഫ�v ,�����ഫ�v
			FROM WORK.SS_DY_STATS
			WHERE �q�檬�p IN('NET','�L')
			UNION CORRESPONDING ALL
			SELECT MDY(INPUT(SUBSTR(SUBSTR(���,FIND(���,'�~'),FIND(���,'��')-FIND(���,'�~')),ANYDIGIT(SUBSTR(���,FIND(���,'�~'),FIND(���,'��')-FIND(���,'�~')))),8.0),
						INPUT(SUBSTR(SUBSTR(���,FIND(���,'��'),FIND(���,'��')-FIND(���,'��')),ANYDIGIT(SUBSTR(���,FIND(���,'��'),FIND(���,'��')-FIND(���,'��')))),8.0),
						INPUT(SCAN(���,1,'�~'),8.0)) FORMAT=DATE9. AS ��� ,���� ,�I������ ,��J���� ,��J�ӫ~�ƶq ,��󦸼� ,���ӫ~�ƶq ,�q�檬�p 
					,�P�⦬�J FORMAT=DOLLAR12.0,�P�⦨�� FORMAT=DOLLAR12.0,�Q�� FORMAT=DOLLAR12.0,�ӫ~�ƶq ,�q��� ,��Q�v ,�ʪ����ഫ�v ,�ʪ��������v ,�q���ഫ�v ,�����ഫ�v
			FROM WORK.HOTSALE_DY_STATS
			WHERE �q�檬�p IN('NET','�L')
			UNION CORRESPONDING ALL
			SELECT MDY(INPUT(SUBSTR(SUBSTR(���,FIND(���,'�~'),FIND(���,'��')-FIND(���,'�~')),ANYDIGIT(SUBSTR(���,FIND(���,'�~'),FIND(���,'��')-FIND(���,'�~')))),8.0),
						INPUT(SUBSTR(SUBSTR(���,FIND(���,'��'),FIND(���,'��')-FIND(���,'��')),ANYDIGIT(SUBSTR(���,FIND(���,'��'),FIND(���,'��')-FIND(���,'��')))),8.0),
						INPUT(SCAN(���,1,'�~'),8.0)) FORMAT=DATE9. AS ��� ,���� ,�I������ ,��J���� ,��J�ӫ~�ƶq ,��󦸼� ,���ӫ~�ƶq ,�q�檬�p 
					,�P�⦬�J FORMAT=DOLLAR12.0,�P�⦨�� FORMAT=DOLLAR12.0,�Q�� FORMAT=DOLLAR12.0,�ӫ~�ƶq ,�q��� ,��Q�v ,�ʪ����ഫ�v ,�ʪ��������v ,�q���ഫ�v ,�����ഫ�v
			FROM WORK.REST_DY_STATS
			WHERE �q�檬�p IN('NET','�L');
			CREATE TABLE TR_BK_REV AS
			SELECT ��� ,���� ,�I������ ,��J���� ,��J�ӫ~�ƶq ,��󦸼� ,���ӫ~�ƶq ,�q�檬�p ,�P�⦬�J/SUM(�P�⦬�J) FORMAT=PERCENT8.2 AS �禬����, �P�⦬�J ,
					�P�⦨�� ,�Q�� ,�ӫ~�ƶq ,�q��� ,��Q�v ,�ʪ����ഫ�v ,�ʪ��������v ,�q���ഫ�v ,�����ഫ�v
			FROM TEST
			GROUP BY ���
			ORDER BY ���, �����ഫ�v DESC;
		QUIT;
		%_eg_conditional_dropds(TEST2)
		PROC MEANS DATA=WORK.TR_BK_REV SUM NOPRINT;
			CLASS '���'N '����'N '�q�檬�p'N;
			VAR �I������ ��J���� ��J�ӫ~�ƶq ��󦸼� ���ӫ~�ƶq �P�⦬�J �P�⦨�� �Q�� �ӫ~�ƶq �q���;
			TYPES ��� ���*����*'�q�檬�p'N;
			OUTPUT OUT=TEST2 SUM=�I������ ��J���� ��J�ӫ~�ƶq ��󦸼� ���ӫ~�ƶq �P�⦬�J �P�⦨�� �Q�� �ӫ~�ƶq �q���;
		RUN;
		PROC SQL NOPRINT;
			SELECT MAX(LENGTH(STRIP(����))) INTO: position_ln FROM TEST2;
		QUIT;
		%LET position_ln=$%SYSFUNC(COMPRESS(&position_ln)).;
		DATA TEST2;
			RETAIN '���'N '����'N �I������ ��J���� ��J�ӫ~�ƶq ��󦸼� ���ӫ~�ƶq �q�檬�p �禬���� �P�⦬�J �P�⦨�� �Q�� 
					�ӫ~�ƶq �q��� ��Q�v �ʪ����ഫ�v �ʪ��������v �q���ഫ�v �����ഫ�v;
			FORMAT ���� &position_ln ��Q�v �ʪ����ഫ�v �ʪ��������v �q���ഫ�v �����ഫ�v PERCENT8.2;
			SET TEST2(DROP=_TYPE_ _FREQ_ RENAME=(����=����_TMP �q�檬�p=�q�檬�p_TMP));
			��Q�v=COALESCE(�Q��/�P�⦬�J,0); �ʪ����ഫ�v=COALESCE(��J����/�I������,0); 
			�ʪ��������v=COALESCE(��󦸼�/��J����,0); �q���ഫ�v=COALESCE(�q���/��J����,0); �����ഫ�v=COALESCE(�q���/�I������,0);
			IF �q�檬�p_TMP="" THEN �q�檬�p="NET"; ELSE �q�檬�p=�q�檬�p_TMP;
			IF ����_TMP="" THEN ����="��APP"; ELSE ����=����_TMP;
			DROP �q�檬�p_TMP ����_TMP;
		RUN;
		PROC SQL;
			CREATE TABLE TEST3 AS SELECT '���'N, '����'N, �I������, ��J����, ��J�ӫ~�ƶq, ��󦸼�, ���ӫ~�ƶq, 
				�q�檬�p, �P�⦬�J/MAX(�P�⦬�J) AS �禬���� FORMAT=percent8.2, 
				�P�⦬�J, �P�⦨��, �Q��, �ӫ~�ƶq, �q���, ��Q�v, �ʪ����ഫ�v, �ʪ��������v, �q���ഫ�v, �����ഫ�v
			FROM TEST2
			GROUP BY "���"N;
		QUIT;
		%_eg_conditional_dropds(TEST2)
		%LET count=1;
		%DO i=&INI_DATE %TO &LAST_DATE %BY 1;
			ODS ESCAPECHAR="^";
			ODS REGION COLUMN_SPAN=2 HEIGHT=5pct;
				OPTIONS LOCALE=zh_TW;
				ODS TEXT="^S={FONTSIZE=14pt WIDTH=100% JUST=C}%SYSFUNC(PUTN(&i, NLDATEW.)) ����įq";
			ODS REGION HEIGHT=45pct;
				GOPTIONS RESET=ALL NOBORDER;
				%_eg_conditional_dropds(TR_BK_REV_TMP)
				DATA TR_BK_REV_TMP;
					SET TEST3;
					WHERE ��� EQ &i;
				RUN;
				PROC SORT DATA=TR_BK_REV_TMP;
					BY ��� DESCENDING �����ഫ�v;
				RUN;
				PROC GCHART DATA=TR_BK_REV_TMP(WHERE=(���� ^= '�䥦'));
					VBAR ����/SUMVAR=�P�⦬�J DESCENDING NOFR SPACE=0;
				RUN; QUIT;
				OPTIONS LOCALE=en_US;
			ODS REGION HEIGHT=45pct;
				ODS TEXT="^S={WIDTH=80% JUST=L} "; ODS TEXT="^S={WIDTH=80% JUST=L} "; 
				ODS TEXT="^S={WIDTH=80% JUST=L} "; ODS TEXT="^S={WIDTH=80% JUST=L} ";
				PROC PRINT DATA=TR_BK_REV_TMP(WHERE=(���� IN ('�F����˰ӫ~', '�t�ױ��˰ӫ~', '���߰ӫ~', '�n�d�ӫ~', '�Y�ɷs�~', '�M�ݱ���', '�u�`�ӫ~', '��APP'))) 
								NOOBS STYLE(DATA)=[JUST=C VJUST=M] STYLE(HEAD)=[JUST=C VJUST=M BACKGROUNDCOLOR=RGBA765CC833] CONTENTS="";
					VAR ��� ���� �禬���� �P�⦬�J ��Q�v �����ഫ�v;
				RUN;
			%IF %SYSFUNC(MOD(&count,2)) EQ 0 AND &i NE &LAST_DATE %THEN %DO; ODS PDF (ID=DYFIG) STARTPAGE=NOW; %END;
			%IF &i EQ &LAST_DATE %THEN %DO; ODS PDF (ID=DYFIG) STARTPAGE=NOW; %END;
			%LET count=%EVAL(&count+1);
		%END; /*Loop end*/
		ODS LAYOUT END;
		ODS LAYOUT GRIDDED /*STYLE={FONTFAMILY="Microsoft JhengHei"}*/ ROWS=3 COLUMNS=2 COLUMN_WIDTHS=(50pct 50pct) HEIGHT=10in;
		ODS REGION COLUMN_SPAN=2 HEIGHT=5pct;
			OPTIONS LOCALE=zh_TW;
			ODS TEXT="^S={FONTSIZE=14pt JUST=C}%SYSFUNC(STRIP(%SYSFUNC(PUTN(&INI_DATE, NLDATEW.))))��%SYSFUNC(STRIP(%SYSFUNC(PUTN(&LAST_DATE, NLDATEW.)))) ����įq";
		ODS REGION HEIGHT=44pct;
			GOPTIONS RESET=ALL NOBORDER DEV=SVG;
			PROC GCHART DATA=WORK.TR_STATS(WHERE=(���� NE '�䥦' AND ���� NE '��APP'));
				VBAR '����'N/SUMVAR='�P�⦬�J'N DESCENDING NOFR SPACE=0; RUN;
			QUIT;
		ODS REGION HEIGHT=44pct;
			ODS TEXT="^S={WIDTH=80% JUST=L} "; ODS TEXT="^S={WIDTH=80% JUST=L} "; 
			ODS TEXT="^S={WIDTH=80% JUST=L} "; ODS TEXT="^S={WIDTH=80% JUST=L} ";
			PROC PRINT DATA=WORK.TR_STATS(WHERE=(���� IN ('�F����˰ӫ~', '�t�ױ��˰ӫ~', '���߰ӫ~', '�n�d�ӫ~', '�Y�ɷs�~', '�M�ݱ���', '�u�`�ӫ~', '��APP'))) 
								NOOBS STYLE(DATA)=[JUST=C VJUST=M] STYLE(HEAD)=[JUST=C VJUST=M BACKGROUNDCOLOR=RGBA765CC833] CONTENTS="";
					VAR ���� �禬���� �P�⦬�J ��Q�v �����ഫ�v;
				RUN;
		ODS REGION COLUMN_SPAN=2 HEIGHT=44pct;
			ODS TEXT="^S={FONTSIZE=14pt JUST=C}����įq�Ͷ�";
			GOPTIONS RESET=ALL NOBORDER DEV=SVG;
			PROC SGPLOT DATA=WORK.TR_BK_REV(WHERE=("����"N IN ("�F����˰ӫ~", "�t�ױ��˰ӫ~", "���߰ӫ~", "�n�d�ӫ~", "�Y�ɷs�~", "�M�ݱ���", "�u�`�ӫ~")));
				VLINE '���'N/RESPONSE='�P�⦬�J'N GROUP='����'N LINEATTRS=(PATTERN=SOLID);
				XAXIS DISPLAY=(NOLABEL); YAXIS DISPLAY=(NOLABEL);
				KEYLEGEND/ TITLE="����" TITLEATTRS=(FAMILY=BiauKai SIZE=12) VALUEATTRS=(FAMILY=BiauKai SIZE=9);
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
			SELECT MDY(INPUT(SUBSTR(SUBSTR(���,FIND(���,'�~'),FIND(���,'��')-FIND(���,'�~')),ANYDIGIT(SUBSTR(���,FIND(���,'�~'),FIND(���,'��')-FIND(���,'�~')))),8.0),
						INPUT(SUBSTR(SUBSTR(���,FIND(���,'��'),FIND(���,'��')-FIND(���,'��')),ANYDIGIT(SUBSTR(���,FIND(���,'��'),FIND(���,'��')-FIND(���,'��')))),8.0),
						INPUT(SCAN(���,1,'�~'),8.0)) FORMAT=DATE9. AS ��� ,���� ,�I������ ,��J���� ,��J�ӫ~�ƶq ,��󦸼� ,���ӫ~�ƶq ,�q�檬�p 
					,�P�⦬�J FORMAT=DOLLAR12.0,�P�⦨�� FORMAT=DOLLAR12.0,�Q�� FORMAT=DOLLAR12.0,�ӫ~�ƶq ,�q��� ,��Q�v ,�ʪ����ഫ�v ,�ʪ��������v ,�q���ഫ�v ,�����ഫ�v
			FROM WORK.SS_DY_STATS
			WHERE �q�檬�p IN('NET','�L')
			UNION CORRESPONDING ALL
			SELECT MDY(INPUT(SUBSTR(SUBSTR(���,FIND(���,'�~'),FIND(���,'��')-FIND(���,'�~')),ANYDIGIT(SUBSTR(���,FIND(���,'�~'),FIND(���,'��')-FIND(���,'�~')))),8.0),
						INPUT(SUBSTR(SUBSTR(���,FIND(���,'��'),FIND(���,'��')-FIND(���,'��')),ANYDIGIT(SUBSTR(���,FIND(���,'��'),FIND(���,'��')-FIND(���,'��')))),8.0),
						INPUT(SCAN(���,1,'�~'),8.0)) FORMAT=DATE9. AS ��� ,���� ,�I������ ,��J���� ,��J�ӫ~�ƶq ,��󦸼� ,���ӫ~�ƶq ,�q�檬�p 
					,�P�⦬�J FORMAT=DOLLAR12.0,�P�⦨�� FORMAT=DOLLAR12.0,�Q�� FORMAT=DOLLAR12.0,�ӫ~�ƶq ,�q��� ,��Q�v ,�ʪ����ഫ�v ,�ʪ��������v ,�q���ഫ�v ,�����ഫ�v
			FROM WORK.HOTSALE_DY_STATS
			WHERE �q�檬�p IN('NET','�L')
			UNION CORRESPONDING ALL
			SELECT MDY(INPUT(SUBSTR(SUBSTR(���,FIND(���,'�~'),FIND(���,'��')-FIND(���,'�~')),ANYDIGIT(SUBSTR(���,FIND(���,'�~'),FIND(���,'��')-FIND(���,'�~')))),8.0),
						INPUT(SUBSTR(SUBSTR(���,FIND(���,'��'),FIND(���,'��')-FIND(���,'��')),ANYDIGIT(SUBSTR(���,FIND(���,'��'),FIND(���,'��')-FIND(���,'��')))),8.0),
						INPUT(SCAN(���,1,'�~'),8.0)) FORMAT=DATE9. AS ��� ,���� ,�I������ ,��J���� ,��J�ӫ~�ƶq ,��󦸼� ,���ӫ~�ƶq ,�q�檬�p 
					,�P�⦬�J FORMAT=DOLLAR12.0,�P�⦨�� FORMAT=DOLLAR12.0,�Q�� FORMAT=DOLLAR12.0,�ӫ~�ƶq ,�q��� ,��Q�v ,�ʪ����ഫ�v ,�ʪ��������v ,�q���ഫ�v ,�����ഫ�v
			FROM WORK.REST_DY_STATS
			WHERE �q�檬�p IN('NET','�L');
			CREATE TABLE TR_BK_REV AS
			SELECT ��� ,���� ,�I������ ,��J���� ,��J�ӫ~�ƶq ,��󦸼� ,���ӫ~�ƶq ,�q�檬�p ,�P�⦬�J/SUM(�P�⦬�J) FORMAT=PERCENT8.2 AS �禬����, �P�⦬�J ,
					�P�⦨�� ,�Q�� ,�ӫ~�ƶq ,�q��� ,��Q�v ,�ʪ����ഫ�v ,�ʪ��������v ,�q���ഫ�v ,�����ഫ�v
			FROM TEST
			GROUP BY ���
			ORDER BY ���, �����ഫ�v DESC;
		QUIT;
		%_eg_conditional_dropds(TEST2)
		PROC MEANS DATA=WORK.TR_BK_REV SUM NOPRINT;
			CLASS '���'N '����'N '�q�檬�p'N;
			VAR �I������ ��J���� ��J�ӫ~�ƶq ��󦸼� ���ӫ~�ƶq �P�⦬�J �P�⦨�� �Q�� �ӫ~�ƶq �q���;
			TYPES ��� ���*����*'�q�檬�p'N;
			OUTPUT OUT=TEST2 SUM=�I������ ��J���� ��J�ӫ~�ƶq ��󦸼� ���ӫ~�ƶq �P�⦬�J �P�⦨�� �Q�� �ӫ~�ƶq �q���;
		RUN;
		PROC SQL NOPRINT;
			SELECT MAX(LENGTH(STRIP(����))) INTO: position_ln FROM TEST2;
		QUIT;
		%LET position_ln=$%SYSFUNC(COMPRESS(&position_ln)).;
		DATA TEST2;
			RETAIN '���'N '����'N �I������ ��J���� ��J�ӫ~�ƶq ��󦸼� ���ӫ~�ƶq �q�檬�p �禬���� �P�⦬�J �P�⦨�� �Q�� 
					�ӫ~�ƶq �q��� ��Q�v �ʪ����ഫ�v �ʪ��������v �q���ഫ�v �����ഫ�v;
			FORMAT ���� &position_ln ��Q�v �ʪ����ഫ�v �ʪ��������v �q���ഫ�v �����ഫ�v PERCENT8.2;
			SET TEST2(DROP=_TYPE_ _FREQ_ RENAME=(����=����_TMP �q�檬�p=�q�檬�p_TMP));
			��Q�v=COALESCE(�Q��/�P�⦬�J,0); �ʪ����ഫ�v=COALESCE(��J����/�I������,0); 
			�ʪ��������v=COALESCE(��󦸼�/��J����,0); �q���ഫ�v=COALESCE(�q���/��J����,0); �����ഫ�v=COALESCE(�q���/�I������,0);
			IF �q�檬�p_TMP="" THEN �q�檬�p="NET"; ELSE �q�檬�p=�q�檬�p_TMP;
			IF ����_TMP="" THEN ����="��APP"; ELSE ����=����_TMP;
			DROP �q�檬�p_TMP ����_TMP;
		RUN;
		PROC SQL;
			CREATE TABLE TEST3 AS SELECT '���'N, '����'N, �I������, ��J����, ��J�ӫ~�ƶq, ��󦸼�, ���ӫ~�ƶq, 
				�q�檬�p, �P�⦬�J/MAX(�P�⦬�J) AS �禬���� FORMAT=percent8.2, 
				�P�⦬�J, �P�⦨��, �Q��, �ӫ~�ƶq, �q���, ��Q�v, �ʪ����ഫ�v, �ʪ��������v, �q���ഫ�v, �����ഫ�v
			FROM TEST2
			GROUP BY "���"N;
		QUIT;
		%_eg_conditional_dropds(TEST2)
		ODS ESCAPECHAR="^";
		ODS REGION COLUMN_SPAN=2 HEIGHT=5pct;
			OPTIONS LOCALE=zh_TW;
			ODS TEXT="^S={FONTSIZE=14pt WIDTH=100% JUST=C}%SYSFUNC(PUTN(&LAST_DATE, NLDATEW.)) ����įq";
		ODS REGION HEIGHT=45pct;
			GOPTIONS RESET=ALL NOBORDER;
			%_eg_conditional_dropds(TR_BK_REV_TMP)
			DATA TR_BK_REV_TMP;
				SET TEST3;
				WHERE ��� EQ &LAST_DATE;
			RUN;
			PROC SORT DATA=TR_BK_REV_TMP;
				BY ��� DESCENDING �����ഫ�v;
			RUN;
			PROC GCHART DATA=TR_BK_REV_TMP(WHERE=("����"N ^= "�䥦" AND "����"N ^= "��APP"));
				VBAR ����/SUMVAR=�P�⦬�J DESCENDING NOFR SPACE=0;
			RUN; QUIT;
			OPTIONS LOCALE=en_US;
		ODS REGION HEIGHT=45pct;
			ODS TEXT="^S={WIDTH=80% JUST=L} "; ODS TEXT="^S={WIDTH=80% JUST=L} "; 
			ODS TEXT="^S={WIDTH=80% JUST=L} "; ODS TEXT="^S={WIDTH=80% JUST=L} ";
			PROC PRINT DATA=TR_BK_REV_TMP(WHERE=(���� IN ('�䥦', '�F����˰ӫ~', '�t�ױ��˰ӫ~', '���߰ӫ~', '�n�d�ӫ~', '�Y�ɷs�~', '�M�ݱ���', '�u�`�ӫ~', '��APP'))) 
							NOOBS STYLE(DATA)=[JUST=C VJUST=M] STYLE(HEAD)=[JUST=C VJUST=M BACKGROUNDCOLOR=RGBA765CC833] CONTENTS="";
				VAR ���� �禬���� �P�⦬�J ��Q�v �����ഫ�v;
			RUN;
			
		ODS LAYOUT END;
		ODS PDF (ID=DYFIG) STARTPAGE=NOW;
		ODS LAYOUT GRIDDED /*STYLE={FONTFAMILY="Microsoft JhengHei"}*/ ROWS=3 COLUMNS=2 COLUMN_WIDTHS=(50pct 50pct) HEIGHT=10in;
		ODS REGION COLUMN_SPAN=2 HEIGHT=5pct;
			OPTIONS LOCALE=zh_TW;
			ODS TEXT="^S={FONTSIZE=14pt JUST=C}%SYSFUNC(STRIP(%SYSFUNC(PUTN(&INI_DATE, NLDATEW.))))��%SYSFUNC(STRIP(%SYSFUNC(PUTN(&LAST_DATE, NLDATEW.)))) ����įq";
		ODS REGION HEIGHT=44pct;
			GOPTIONS RESET=ALL NOBORDER DEV=SVG;
			PROC GCHART DATA=WORK.TR_STATS(WHERE=(���� NE '�䥦' AND ���� NE '��APP'));
				VBAR '����'N/SUMVAR='�P�⦬�J'N DESCENDING NOFR SPACE=0; RUN;
			QUIT;
		ODS REGION HEIGHT=44pct;
			ODS TEXT="^S={WIDTH=80% JUST=L} "; ODS TEXT="^S={WIDTH=80% JUST=L} "; 
			ODS TEXT="^S={WIDTH=80% JUST=L} "; ODS TEXT="^S={WIDTH=80% JUST=L} ";
			PROC PRINT DATA=WORK.TR_STATS(WHERE=(���� IN ('�F����˰ӫ~', '�t�ױ��˰ӫ~', '���߰ӫ~', '�n�d�ӫ~', '�Y�ɷs�~', '�M�ݱ���', '�u�`�ӫ~', '��APP'))) 
								NOOBS STYLE(DATA)=[JUST=C VJUST=M] STYLE(HEAD)=[JUST=C VJUST=M BACKGROUNDCOLOR=RGBA765CC833] CONTENTS="";
					VAR ���� �禬���� �P�⦬�J ��Q�v �����ഫ�v;
				RUN;
		ODS REGION COLUMN_SPAN=2 HEIGHT=44pct;
			ODS TEXT="^S={FONTSIZE=14pt JUST=C}����įq�Ͷ�";
			GOPTIONS RESET=ALL NOBORDER DEV=SVG;
			PROC SGPLOT DATA=WORK.TR_BK_REV(WHERE=("����"N IN ("�F����˰ӫ~", "�t�ױ��˰ӫ~", "���߰ӫ~", "�n�d�ӫ~", "�Y�ɷs�~", "�M�ݱ���", "�u�`�ӫ~")));
				VLINE '���'N/RESPONSE='�P�⦬�J'N GROUP='����'N;
				XAXIS DISPLAY=(NOLABEL); YAXIS DISPLAY=(NOLABEL);
				KEYLEGEND/ TITLE="����" TITLEATTRS=(FAMILY=BiauKai SIZE=12) VALUEATTRS=(FAMILY=BiauKai SIZE=9);
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
	Input requirement�GWORK.M_N_O_SUMMARY, WORK.M_N_O_SUMMARY, WORK.NET_LIST_AMOUNT, WORK.NET_LIST_MN
*/
%MACRO generateRepetitiveCustomer;
%IF %SYSFUNC(DATDIF(&INI_DATE,&LAST_DATE,ACT/ACT)) EQ 0 %THEN %DO;
	OPTIONS NODATE; OPTIONS DEV=ACTXIMG;
	OPTIONS LOCALE=zh_TW;
	%_eg_conditional_dropds(M_O_O_STATS)
	%_eg_conditional_dropds(M_N_O_STATS)
	PROC MEANS DATA=WORK.M_O_O_SUMMARY(WHERE=(Date=&LAST_DATE)) SUM NOPRINT;
		CLASS Date "OrderStatus"N eraddsc;
		VAR "�P�⦬�J"N "�ӫ~�ƶq"N "�q���"N "�U�ȼ�"N;
		TYPES ()*"OrderStatus"N Date*eraddsc*"OrderStatus"N;
		OUTPUT OUT=M_O_O_STATS SUM="�P�⦬�J"N "�ӫ~�ƶq"N "�q���"N "�U�ȼ�"N;
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
		RETAIN "���"N "����"N "�q�檬�p"N "�P�⦬�J"N "�ӫ~�ƶq"N "�q���"N;
		FORMAT "���"N $36. "�q�檬�p"N &VARN1 "����"N &VARN2 "�P�⦬�J"N NLMNITWD22.0 "�ӫ~�ƶq"N "�q���"N COMMA9.0;
		SET M_O_O_STATS (DROP=_TYPE_ _FREQ_ RENAME=(Date=Date_TMP "OrderStatus"N=OrderStatusTMP eraddsc=eraddsc_tmp));
		"���"N=CATS(PUT(&LAST_DATE, NLDATEW.));
		IF OrderStatusTMP NE "" THEN "�q�檬�p"N=OrderStatusTMP; ELSE "�q�檬�p"N="��";
		IF eraddsc_tmp NE "" THEN "����"N=eraddsc_tmp; ELSE "����"N="������";
	RUN;
	/*
		Whole-time range stats for the new customers.
	*/
	PROC MEANS DATA=WORK.M_N_O_SUMMARY(WHERE=(Date=&LAST_DATE)) SUM NOPRINT;
		CLASS Date "OrderStatus"N eraddsc;
		VAR "�P�⦬�J"N "�ӫ~�ƶq"N "�q���"N "�U�ȼ�"N;
		TYPES ()*"OrderStatus"N Date*eraddsc*"OrderStatus"N;
		OUTPUT OUT=M_N_O_STATS SUM="�P�⦬�J"N "�ӫ~�ƶq"N "�q���"N "�U�ȼ�"N;
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
		RETAIN "���"N "����"N "�q�檬�p"N "�P�⦬�J"N "�ӫ~�ƶq"N "�q���"N;
		FORMAT "���"N $36. "�q�檬�p"N &VARN1 "����"N &VARN2 "�P�⦬�J"N NLMNITWD22.0 "�ӫ~�ƶq"N "�q���"N COMMA9.0;
		SET M_N_O_STATS (DROP=_TYPE_ _FREQ_ RENAME=(Date=Date_TMP "OrderStatus"N=OrderStatusTMP eraddsc=eraddsc_tmp));
		"���"N=CATS(PUT(&LAST_DATE, NLDATEW.));
		IF OrderStatusTMP NE "" THEN "�q�檬�p"N=OrderStatusTMP; ELSE "�q�檬�p"N="��";
		IF eraddsc_tmp NE "" THEN "����"N=eraddsc_tmp; ELSE "����"N="������";
	RUN;
	OPTIONS LOCALE=en_US;
	/*
		Generate the whole-range stats based on all app and blocks.
	*/
	PROC SQL;
		CREATE TABLE All_APP_N_O_R AS /*N_O_R stands for revenue from the old and new customers.*/
		SELECT "���"N, "�^�Y��" FORMAT=$9. AS "�Ȥ�����"N, "����"N, "�q�檬�p"N, "�P�⦬�J"N FORMAT=DOLLAR12.0, "�P�⦬�J"N/"�U�ȼ�"N AS "�ȳ���]AS�^"N  FORMAT=DOLLAR12.0,
				"�P�⦬�J"N/"�q���"N AS "�����q����ȡ]AOV�^"N FORMAT=DOLLAR12.0, "�ӫ~�ƶq"N/"�q���"N AS "�����q��q�]AOS�^"N FORMAT=COMMA9.2
		FROM M_O_O_STATS
		UNION CORR ALL
		SELECT "���"N, "�s��" FORMAT=$9. AS "�Ȥ�����"N, "����"N, "�q�檬�p"N, "�P�⦬�J"N FORMAT=DOLLAR12.0, "�P�⦬�J"N/"�U�ȼ�"N AS "�ȳ���]AS�^"N  FORMAT=DOLLAR12.0,
				"�P�⦬�J"N/"�q���"N AS "�����q����ȡ]AOV�^"N FORMAT=DOLLAR12.0, "�ӫ~�ƶq"N/"�q���"N AS "�����q��q�]AOS�^"N FORMAT=COMMA9.2
		FROM M_N_O_STATS;
	QUIT;
	PROC SORT DATA=All_APP_N_O_R;
		BY "���"N "����"N;
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
		CREATE TABLE All_APP_N_O_R_TMP AS SELECT * FROM All_APP_N_O_R WHERE "����"N = "������";
		CREATE TABLE Personal_N_O_R_TMP AS SELECT * FROM All_APP_N_O_R WHERE "����"N IN ("�Y�ɷs�~", "�n�d�ӫ~", "�u�`�ӫ~", "���߰ӫ~", "�M�ݱ���");
		CREATE TABLE HotSale_N_O_R_TMP AS SELECT * FROM All_APP_N_O_R WHERE "����"N IN ("�t�ױ��˰ӫ~", "�F����˰ӫ~");
	QUIT;
	/*Page 1*/
	ODS LAYOUT GRIDDED /*STYLE={FONTFAMILY="Microsoft JhengHei"}*/
						COLUMNS=2 ROWS=3 COLUMN_WIDTHS=(50% 50%) HEIGHT=10in COLUMN_GUTTER=0 ROW_GUTTER=0;
	ODS ESCAPECHAR="^"; OPTIONS LOCALE=zh_TW;
	ODS REGION COLUMN_SPAN=2 HEIGHT=5pct;
		ODS TEXT="^S={OUTPUTWIDTH=100% FONTSIZE=13pt JUST=C}%SYSFUNC(COMPRESS(%SYSFUNC(CATS(%SYSFUNC(PUTN(&LAST_DATE, NLDATEW.)), ��APP�s�«Ȥ��))))"; OPTIONS LOCALE=en_US;
	ODS REGION COLUMN_SPAN=2 HEIGHT=50pct;
		GOPTIONS RESET=ALL DEVICE=SVG NOBORDER HSIZE=7in VSIZE=4.6in;
		PATTERN1 C=CX4965B0; PATTERN2 C=CXFF7B58; PATTERN3 C=CX95B60E;
		PROC GCHART DATA=All_APP_N_O_R_TMP;
			PIE "�Ȥ�����"N/SUMVAR="�P�⦬�J"N GROUP="�q�檬�p"N MIDPOINTS="�^�Y��" "�s��"
				 ACROSS=2 DOWN=2 PERCENT=arrow COUTLINE=CX7C5C00 NOHEADING;
			RUN;
		QUIT;
	ODS REGION COLUMN_SPAN=2 HEIGHT=45pct; OPTIONS LOCALE=zh_TW;
		ODS TEXT="^S={OUTPUTWIDTH=100% FONTSIZE=12pt JUST=C}%SYSFUNC(COMPRESS(%SYSFUNC(PUTN(&LAST_DATE, NLDATEW.))))�q���T�P�P�h�Ӹ`"; OPTIONS LOCALE=en_US;
		PROC PRINT DATA=All_APP_N_O_R_TMP NOOBS STYLE(DATA)=[JUST=C VJUST=M] STYLE(HEAD)=[JUST=C VJUST=M BACKGROUNDCOLOR=RGBAAA393933] CONTENTS="" LABEL;
		QUIT;
		ODS TEXT="^S={OUTPUTWIDTH=85% JUST=L}��1�G�ȳ��=�P�⦬�J���U�ȼ�";
		ODS TEXT="^S={OUTPUTWIDTH=85% JUST=L}��2�G�����q�����=�P�⦬�J�ҭq���";
		ODS TEXT="^S={OUTPUTWIDTH=85% JUST=L}��3�G�����q��q=�ӫ~�ƶq�ҭq���";
		PROC PRINT DATA=WORK.DETAILED_R_LIST NOOBS STYLE(DATA)=[JUST=C VJUST=M] STYLE(HEAD)=[JUST=C VJUST=M BACKGROUNDCOLOR=RGBA765CC833] CONTENTS="" LABEL;
			VAR customerid SALENO SALENAME �P�⦬�J �ƶq;
			LABEL customerid=�ȥN SALENAME=�ӫ~�W�� SALENO=�P��s�� �ƶq=�ӫ~�ƶq �P�⦬�J=���B;
		QUIT;
	ODS LAYOUT END;
	%_eg_conditional_dropds(All_APP_N_O_R_TMP)
	ODS PDF (ID=DYFIG) STARTPAGE=NOW;
	/*Page 2*/
	ODS LAYOUT GRIDDED STYLE={FONTFAMILY="Microsoft JhengHei"}
						COLUMNS=2 ROWS=4 COLUMN_WIDTHS=(50% 50%) HEIGHT=10in COLUMN_GUTTER=0 ROW_GUTTER=0;
	/*%LET tmp_ftnt_1=%NRSTR(��1�G�Ӹ`���ϥu�e�{�u�b�v�q�檺�����C);
	TITLE2 �M�ݱ��˻P���n��; FOOTNOTE1 &tmp_ftnt_1;*/
	ODS REGION COLUMN_SPAN=2 HEIGHT=5pct; OPTIONS LOCALE=zh_TW;
		ODS TEXT="^S={OUTPUTWIDTH=100% FONTSIZE=13pt JUST=C}%SYSFUNC(COMPRESS(%SYSFUNC(CATS(%SYSFUNC(PUTN(&LAST_DATE, NLDATEW.)), �M�ݱ��˻P���n���s�«�))))"; OPTIONS LOCALE=en_US;
	ODS REGION COLUMN_SPAN=2 HEIGHT=48pct;
		GOPTIONS HSIZE=7.01in VSIZE=4.61in;
		PROC GCHART DATA=Personal_N_O_R_TMP;
			VBAR "����"N/SUMVAR="�P�⦬�J"N GROUP="�q�檬�p"N SUBGROUP="�Ȥ�����"N SPACE=0;
			RUN;
		QUIT;
	ODS REGION COLUMN_SPAN=2 HEIGHT=24pct;
		ODS TEXT="^S={OUTPUTWIDTH=100% FONTSIZE=10pt JUST=C}�q���T";
		PROC PRINT DATA=Personal_N_O_R_TMP NOOBS STYLE(DATA)=[JUST=C VJUST=M] STYLE(HEAD)=[JUST=C VJUST=M BACKGROUNDCOLOR=RGBAAA393933] CONTENTS="" LABEL;
		QUIT;
	ODS REGION HEIGHT=23pct;
		ODS TEXT="^S={OUTPUTWIDTH=100% FONTSIZE=10pt JUST=C}���B�Ʀ�](�b�q��)";
		PROC PRINT DATA=WORK.NET_LIST_MN(WHERE=(eraddsc IN ('�M�ݱ���', '���߰ӫ~', '�Y�ɷs�~', '�n�d�ӫ~', '�u�`�ӫ~') AND Date EQ &LAST_DATE)) NOOBS 
					STYLE(DATA)=[JUST=C VJUST=M] STYLE(HEAD)=[JUST=C VJUST=M BACKGROUNDCOLOR=RGBA469E3433] CONTENTS="" LABEL;
			VAR eraddsc customerid '���B'N '�ƶq'N;
			LABEL eraddsc=���� customerid=�ȥN;
		QUIT;
		ODS TEXT="^S={OUTPUTWIDTH=70% JUST=L}��1�G�u�e�{�C�Ӫ��쪺�e�T�W�C";
	ODS REGION HEIGHT=23pct;
		ODS TEXT="^S={OUTPUTWIDTH=100% FONTSIZE=10pt JUST=C}�ƶq�Ʀ�](�b�q��)";
			PROC PRINT DATA=WORK.NET_LIST_AMOUNT(WHERE=(eraddsc IN ('�M�ݱ���', '���߰ӫ~', '�Y�ɷs�~', '�n�d�ӫ~', '�u�`�ӫ~') AND Date EQ &LAST_DATE)) NOOBS 
						STYLE(DATA)=[JUST=C VJUST=M] STYLE(HEAD)=[JUST=C VJUST=M BACKGROUNDCOLOR=RGBA469E3433] CONTENTS="" LABEL;
				VAR eraddsc customerid '���B'N '�ƶq'N;
				LABEL eraddsc=���� customerid=�ȥN;
			QUIT;
		ODS TEXT="^S={OUTPUTWIDTH=70% JUST=L}��1�G�u�e�{�C�Ӫ��쪺�e�T�W�C";
	ODS LAYOUT END;
	%_eg_conditional_dropds(Personal_N_O_R_TMP)
	ODS PDF (ID=DYFIG) STARTPAGE=NOW;
	/*Page 3*/
	ODS LAYOUT GRIDDED /*STYLE={FONTFAMILY="Microsoft JhengHei"}*/
						COLUMNS=2 ROWS=4 COLUMN_WIDTHS=(50% 50%) HEIGHT=10in COLUMN_GUTTER=0 ROW_GUTTER=0;
	ODS REGION COLUMN_SPAN=2 HEIGHT=5pct; OPTIONS LOCALE=zh_TW;
		ODS TEXT="^S={OUTPUTWIDTH=100% FONTSIZE=13pt JUST=C}%SYSFUNC(COMPRESS(%SYSFUNC(CATS(%SYSFUNC(PUTN(&LAST_DATE, NLDATEW.)), ������s�«�))))"; OPTIONS LOCALE=en_US;
	ODS REGION COLUMN_SPAN=2 HEIGHT=48pct;
		GOPTIONS HSIZE=7.02in VSIZE=4.62in;
		PROC GCHART DATA=HotSale_N_O_R_TMP;
			VBAR "����"N/SUMVAR="�P�⦬�J"N GROUP="�q�檬�p"N SUBGROUP="�Ȥ�����"N SPACE=0;
			RUN;
		QUIT;
	ODS REGION COLUMN_SPAN=2 HEIGHT=24pct;
		ODS TEXT="^S={OUTPUTWIDTH=100% FONTSIZE=10pt JUST=C}�q���T";
		PROC PRINT DATA=HotSale_N_O_R_TMP NOOBS STYLE(DATA)=[JUST=C VJUST=M] STYLE(HEAD)=[JUST=C VJUST=M BACKGROUNDCOLOR=RGBAAA393933] CONTENTS="" LABEL;
		QUIT;
		%_eg_conditional_dropds(HotSale_N_O_R_TMP)
	ODS REGION HEIGHT=23pct;
		ODS TEXT="^S={OUTPUTWIDTH=100% FONTSIZE=10pt JUST=C}���B�Ʀ�](�b�q��)";
		PROC PRINT DATA=WORK.NET_LIST_MN(WHERE=(eraddsc IN ('�t�ױ��˰ӫ~', '�F����˰ӫ~') AND Date EQ &LAST_DATE)) NOOBS 
					STYLE(DATA)=[JUST=C VJUST=M] STYLE(HEAD)=[JUST=C VJUST=M BACKGROUNDCOLOR=RGBA469E3433] CONTENTS="" LABEL;
			VAR eraddsc customerid '���B'N '�ƶq'N;
			LABEL eraddsc=���� customerid=�ȥN;
		QUIT;
		ODS TEXT="^S={OUTPUTWIDTH=70% JUST=L}��1�G�u�e�{�C�Ӫ��쪺�e�T�W�C";
	ODS REGION HEIGHT=23pct;
		ODS TEXT="^S={OUTPUTWIDTH=100% FONTSIZE=10pt JUST=C}�ƶq�Ʀ�](�b�q��)";
		PROC PRINT DATA=WORK.NET_LIST_AMOUNT(WHERE=(eraddsc IN ('�t�ױ��˰ӫ~', '�F����˰ӫ~') AND Date EQ &LAST_DATE)) NOOBS 
					STYLE(DATA)=[JUST=C VJUST=M] STYLE(HEAD)=[JUST=C VJUST=M BACKGROUNDCOLOR=RGBA469E3433] CONTENTS="" LABEL;
			VAR eraddsc customerid '���B'N '�ƶq'N;
			LABEL eraddsc=���� customerid=�ȥN;
		QUIT;
		ODS TEXT="^S={OUTPUTWIDTH=70% JUST=L}��1�G�u�e�{�C�Ӫ��쪺�e�T�W�C";
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
				VAR "�P�⦬�J"N "�ӫ~�ƶq"N "�q���"N "�U�ȼ�"N;
				TYPES ()*"OrderStatus"N ()*eraddsc*"OrderStatus"N Date*"OrderStatus"N Date*eraddsc*"OrderStatus"N;
				OUTPUT OUT=M_O_O_STATS SUM="�P�⦬�J"N "�ӫ~�ƶq"N "�q���"N "�U�ȼ�"N;
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
				RETAIN '���'N '����'N '�q�檬�p'N '�P�⦬�J'N '�ӫ~�ƶq'N '�q���'N;
				FORMAT '���'N NLDATEW. '�q�檬�p'N &VARN1 '����'N &VARN2 '�P�⦬�J'N NLMNITWD22.0 '�ӫ~�ƶq'N '�q���'N COMMA9.0;
				SET M_O_O_STATS (DROP=_TYPE_ _FREQ_ RENAME=(Date=��� 'OrderStatus'N=OrderStatusTMP eraddsc=eraddsc_tmp));
				IF OrderStatusTMP NE "" THEN '�q�檬�p'N=OrderStatusTMP; ELSE '�q�檬�p'N="��";
				IF eraddsc_tmp NE "" THEN '����'N=eraddsc_tmp; ELSE '����'N="������";
			RUN;
			/*
				Whole-time range stats for the new customers.
			*/
			PROC MEANS DATA=WORK.M_N_O_SUMMARY SUM NOPRINT;
				CLASS Date "OrderStatus"N eraddsc;
				VAR "�P�⦬�J"N "�ӫ~�ƶq"N "�q���"N "�U�ȼ�"N;
				TYPES ()*"OrderStatus"N  ()*eraddsc*"OrderStatus"N Date*"OrderStatus"N Date*eraddsc*"OrderStatus"N;
				OUTPUT OUT=M_N_O_STATS SUM="�P�⦬�J"N "�ӫ~�ƶq"N "�q���"N "�U�ȼ�"N;
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
				RETAIN '���'N '����'N '�q�檬�p'N '�P�⦬�J'N '�ӫ~�ƶq'N '�q���'N;
				FORMAT '���'N NLDATEW. '�q�檬�p'N &VARN1 '����'N &VARN2 '�P�⦬�J'N NLMNITWD22.0 '�ӫ~�ƶq'N '�q���'N COMMA9.0;
				SET M_N_O_STATS (DROP=_TYPE_ _FREQ_ RENAME=(Date=��� 'OrderStatus'N=OrderStatusTMP eraddsc=eraddsc_tmp));
				IF OrderStatusTMP NE "" THEN '�q�檬�p'N=OrderStatusTMP; ELSE '�q�檬�p'N="��";
				IF eraddsc_tmp NE "" THEN '����'N=eraddsc_tmp; ELSE '����'N="������";
			RUN;
			/*
				Generate the whole-range stats based on all app and blocks.
			*/
			PROC SQL;
				CREATE TABLE All_APP_N_O_R AS /*N_O_R stands for revenue from the old and new customers.*/
				SELECT "���"N, "�^�Y��" FORMAT=$9. AS "�Ȥ�����"N, "����"N, "�q�檬�p"N, "�P�⦬�J"N FORMAT=DOLLAR12.0, "�P�⦬�J"N/"�U�ȼ�"N AS "�ȳ���]AS�^"N  FORMAT=DOLLAR12.0,
						"�P�⦬�J"N/"�q���"N AS "�����q����ȡ]AOV�^"N FORMAT=DOLLAR12.0, "�ӫ~�ƶq"N/"�q���"N AS "�����q��q�]AOS�^"N FORMAT=COMMA9.2
				FROM M_O_O_STATS
				UNION CORR ALL
				SELECT "���"N, "�s��" FORMAT=$9. AS "�Ȥ�����"N, "����"N, "�q�檬�p"N, "�P�⦬�J"N FORMAT=DOLLAR12.0, "�P�⦬�J"N/"�U�ȼ�"N AS "�ȳ���]AS�^"N  FORMAT=DOLLAR12.0,
						"�P�⦬�J"N/"�q���"N AS "�����q����ȡ]AOV�^"N FORMAT=DOLLAR12.0, "�ӫ~�ƶq"N/"�q���"N AS "�����q��q�]AOS�^"N FORMAT=COMMA9.2
				FROM M_N_O_STATS;
			QUIT;
			PROC SORT DATA=All_APP_N_O_R;
				BY "���"N "����"N;
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
				CREATE TABLE All_APP_N_O_R_TMP AS SELECT * FROM All_APP_N_O_R WHERE "����"N = "������";
				CREATE TABLE Personal_N_O_R_TMP AS SELECT * FROM All_APP_N_O_R WHERE "����"N IN ("�Y�ɷs�~", "�n�d�ӫ~", "�u�`�ӫ~", "���߰ӫ~", "�M�ݱ���");
				CREATE TABLE HotSale_N_O_R_TMP AS SELECT * FROM All_APP_N_O_R WHERE "����"N IN ("�t�ױ��˰ӫ~", "�F����˰ӫ~");
			QUIT;
			%DO i=&INI_DATE %TO &LAST_DATE %BY 1;
			/*Page 1*/
			ODS LAYOUT GRIDDED /*STYLE={FONTFAMILY="Microsoft JhengHei"}*/
								COLUMNS=2 ROWS=3 COLUMN_WIDTHS=(50% 50%) HEIGHT=10in COLUMN_GUTTER=0 ROW_GUTTER=0;
			ODS ESCAPECHAR="^";
			ODS REGION COLUMN_SPAN=2 HEIGHT=5pct;
				ODS TEXT="^S={OUTPUTWIDTH=100% FONTSIZE=13pt JUST=C}%SYSFUNC(COMPRESS(%SYSFUNC(CATS(%SYSFUNC(PUTN(&i, NLDATEW.)), ��APP�s�«Ȥ��))))";
			ODS REGION COLUMN_SPAN=2 HEIGHT=48pct;
				GOPTIONS RESET=ALL DEVICE=SVG NOBORDER HSIZE=%SYSEVALF(7+&h_count.*0.01)in VSIZE=%SYSEVALF(4.6+&v_count.*0.01)in; 
				PATTERN1 C=CX4965B0; PATTERN2 C=CXFF7B58; PATTERN3 C=CX95B60E;
				PROC GCHART DATA=All_APP_N_O_R_TMP(WHERE=("���"N=&i));
					PIE "�Ȥ�����"N/SUMVAR="�P�⦬�J"N GROUP="�q�檬�p"N MIDPOINTS="�^�Y��" "�s��"
						 ACROSS=2 DOWN=2 PERCENT=arrow COUTLINE=CX7C5C00 NOHEADING;
					RUN;
				QUIT;
			ODS REGION COLUMN_SPAN=2 HEIGHT=47pct;
				ODS TEXT="^S={OUTPUTWIDTH=100% FONTSIZE=12pt JUST=C}%SYSFUNC(COMPRESS(%SYSFUNC(PUTN(&i, NLDATEW.))))�q���T�P�P�h�Ӹ`";
				PROC PRINT DATA=All_APP_N_O_R_TMP(WHERE=("���"N=&i)) NOOBS STYLE(DATA)=[JUST=C VJUST=M] STYLE(HEAD)=[JUST=C VJUST=M BACKGROUNDCOLOR=RGBAAA393933] CONTENTS="" LABEL;
				QUIT;
				ODS TEXT="^S={OUTPUTWIDTH=85% JUST=L}��1�G�ȳ��=�P�⦬�J���U�ȼ�";
				ODS TEXT="^S={OUTPUTWIDTH=85% JUST=L}��2�G�����q�����=�P�⦬�J�ҭq���";
				ODS TEXT="^S={OUTPUTWIDTH=85% JUST=L}��3�G�����q��q=�ӫ~�ƶq�ҭq���";
				PROC PRINT DATA=WORK.DETAILED_R_LIST(WHERE=(Date=&i)) NOOBS STYLE(DATA)=[JUST=C VJUST=M] STYLE(HEAD)=[JUST=C VJUST=M BACKGROUNDCOLOR=RGBA765CC833] CONTENTS="" LABEL;
					VAR customerid SALENO SALENAME �P�⦬�J �ƶq;
					LABEL customerid=�ȥN SALENAME=�P�h�ӫ~�W�� SALENO=�P��s�� �ƶq=�ӫ~�ƶq �P�⦬�J=���B;
				QUIT;
			ODS LAYOUT END;
			%LET h_count=%EVAL(&h_count+1); %LET v_count=%EVAL(&v_count+1); /*For displaying charts normally*/
			ODS PDF (ID=DYFIG) STARTPAGE=NOW;
			/*Page 2*/
			ODS LAYOUT GRIDDED /*STYLE={FONTFAMILY="Microsoft JhengHei"}*/
								COLUMNS=2 ROWS=4 COLUMN_WIDTHS=(50% 50%) HEIGHT=10in COLUMN_GUTTER=0 ROW_GUTTER=0;
			ODS REGION COLUMN_SPAN=2 HEIGHT=5pct;
				ODS TEXT="^S={OUTPUTWIDTH=100% FONTSIZE=13pt JUST=C}%SYSFUNC(COMPRESS(%SYSFUNC(CATS(%SYSFUNC(PUTN(&i, NLDATEW.)), �M�ݱ��˻P���n���s�«�))))";
			ODS REGION COLUMN_SPAN=2 HEIGHT=48pct;
				GOPTIONS HSIZE=%SYSEVALF(7+&h_count.*0.01)in VSIZE=%SYSEVALF(4.6+&v_count.*0.01)in;
				PROC GCHART DATA=Personal_N_O_R_TMP(WHERE=("���"N=&i));
					VBAR "����"N/SUMVAR="�P�⦬�J"N GROUP="�q�檬�p"N SUBGROUP="�Ȥ�����"N SPACE=0;
					RUN;
				QUIT;
			ODS REGION COLUMN_SPAN=2 HEIGHT=24pct;
				ODS TEXT="^S={OUTPUTWIDTH=100% FONTSIZE=10pt JUST=C}�q���T";
				PROC PRINT DATA=Personal_N_O_R_TMP(WHERE=("���"N=&i)) NOOBS STYLE(DATA)=[JUST=C VJUST=M] STYLE(HEAD)=[JUST=C VJUST=M BACKGROUNDCOLOR=RGBAAA393933] CONTENTS="" LABEL;
				QUIT;
			ODS REGION HEIGHT=23pct;
				ODS TEXT="^S={OUTPUTWIDTH=100% FONTSIZE=10pt JUST=C}���B�Ʀ�](�b�q��)";
				PROC PRINT DATA=WORK.NET_LIST_MN(WHERE=(eraddsc IN ('�M�ݱ���', '���߰ӫ~', '�Y�ɷs�~', '�n�d�ӫ~', '�u�`�ӫ~') AND Date EQ &i)) NOOBS 
							STYLE(DATA)=[JUST=C VJUST=M] STYLE(HEAD)=[JUST=C VJUST=M BACKGROUNDCOLOR=RGBA469E3433] CONTENTS="" LABEL;
					VAR eraddsc customerid '���B'N '�ƶq'N;
					LABEL eraddsc=���� customerid=�ȥN;
				QUIT;
				ODS TEXT="^S={OUTPUTWIDTH=70% JUST=L}��1�G�u�e�{�C�Ӫ��쪺�e�T�W�C";
			ODS REGION HEIGHT=23pct;
				ODS TEXT="^S={OUTPUTWIDTH=100% FONTSIZE=10pt JUST=C}�ƶq�Ʀ�](�b�q��)";
				PROC PRINT DATA=WORK.NET_LIST_AMOUNT(WHERE=(eraddsc IN ('�M�ݱ���', '���߰ӫ~', '�Y�ɷs�~', '�n�d�ӫ~', '�u�`�ӫ~') AND Date EQ &i)) NOOBS 
							STYLE(DATA)=[JUST=C VJUST=M] STYLE(HEAD)=[JUST=C VJUST=M BACKGROUNDCOLOR=RGBA469E3433] CONTENTS="" LABEL;
					VAR eraddsc customerid '���B'N '�ƶq'N;
					LABEL eraddsc=���� customerid=�ȥN;
				QUIT;
				ODS TEXT="^S={OUTPUTWIDTH=70% JUST=L}��1�G�u�e�{�C�Ӫ��쪺�e�T�W�C";
			ODS LAYOUT END;
			%LET h_count=%EVAL(&h_count+1); %LET v_count=%EVAL(&v_count+1); /*For displaying charts normally*/
			ODS PDF (ID=DYFIG) STARTPAGE=NOW;
			/*Page 3*/
			ODS LAYOUT GRIDDED /*STYLE={FONTFAMILY="Microsoft JhengHei"}*/
								COLUMNS=2 ROWS=4 COLUMN_WIDTHS=(50% 50%) HEIGHT=10in COLUMN_GUTTER=0 ROW_GUTTER=0;
			ODS REGION COLUMN_SPAN=2 HEIGHT=5pct;
				ODS TEXT="^S={OUTPUTWIDTH=100% FONTSIZE=13pt JUST=C}%SYSFUNC(COMPRESS(%SYSFUNC(CATS(%SYSFUNC(PUTN(&i, NLDATEW.)), ������s�«�))))";
			ODS REGION COLUMN_SPAN=2 HEIGHT=48pct;
				GOPTIONS HSIZE=%SYSEVALF(7+&h_count.*0.01)in VSIZE=%SYSEVALF(4.6+&v_count.*0.01)in;
				PROC GCHART DATA=HotSale_N_O_R_TMP(WHERE=("���"N=&i));
					VBAR "����"N/SUMVAR="�P�⦬�J"N GROUP="�q�檬�p"N SUBGROUP="�Ȥ�����"N SPACE=0;
					RUN;
				QUIT;
			ODS REGION COLUMN_SPAN=2 HEIGHT=24pct;
				ODS TEXT="^S={OUTPUTWIDTH=100% FONTSIZE=10pt JUST=C}�q���T";
				PROC PRINT DATA=HotSale_N_O_R_TMP(WHERE=("���"N=&i)) NOOBS STYLE(DATA)=[JUST=C VJUST=M] STYLE(HEAD)=[JUST=C VJUST=M BACKGROUNDCOLOR=RGBAAA393933] CONTENTS="" LABEL;
				QUIT;
			ODS REGION HEIGHT=23pct;
				ODS TEXT="^S={OUTPUTWIDTH=100% FONTSIZE=10pt JUST=C}���B�Ʀ�](�b�q��)";
				PROC PRINT DATA=WORK.NET_LIST_MN(WHERE=(eraddsc IN ('�t�ױ��˰ӫ~', '�F����˰ӫ~') AND Date EQ &i)) NOOBS 
							STYLE(DATA)=[JUST=C VJUST=M] STYLE(HEAD)=[JUST=C VJUST=M BACKGROUNDCOLOR=RGBA469E3433] CONTENTS="" LABEL;
					VAR eraddsc customerid '���B'N '�ƶq'N;
					LABEL eraddsc=���� customerid=�ȥN;
				QUIT;
				ODS TEXT="^S={OUTPUTWIDTH=70% JUST=L}��1�G�u�e�{�C�Ӫ��쪺�e�T�W�C";
			ODS REGION HEIGHT=23pct;
				ODS TEXT="^S={OUTPUTWIDTH=100% FONTSIZE=10pt JUST=C}�ƶq�Ʀ�](�b�q��)";
				PROC PRINT DATA=WORK.NET_LIST_AMOUNT(WHERE=(eraddsc IN ('�t�ױ��˰ӫ~', '�F����˰ӫ~') AND Date EQ &i)) NOOBS 
							STYLE(DATA)=[JUST=C VJUST=M] STYLE(HEAD)=[JUST=C VJUST=M BACKGROUNDCOLOR=RGBA469E3433] CONTENTS="" LABEL;
					VAR eraddsc customerid '���B'N '�ƶq'N;
					LABEL eraddsc=���� customerid=�ȥN;
				QUIT;
				ODS TEXT="^S={OUTPUTWIDTH=70% JUST=L}��1�G�u�e�{�C�Ӫ��쪺�e�T�W�C";
			ODS LAYOUT END;
			%LET h_count=%EVAL(&h_count+1); %LET v_count=%EVAL(&v_count+1); /*For displaying charts normally*/
			ODS PDF (ID=DYFIG) STARTPAGE=NOW;
			%IF &i EQ &LAST_DATE %THEN %DO;
				ODS LAYOUT GRIDDED /*STYLE={FONTFAMILY="Microsoft JhengHei"}*/
									COLUMNS=2 ROWS=3 COLUMN_WIDTHS=(50% 50%) HEIGHT=10in COLUMN_GUTTER=0 ROW_GUTTER=0;
				ODS ESCAPECHAR="^";
				ODS REGION COLUMN_SPAN=2 HEIGHT=5pct;
					ODS TEXT="^S={OUTPUTWIDTH=100% FONTSIZE=13pt JUST=C}%SYSFUNC(COMPRESS(%SYSFUNC(CATS(%SYSFUNC(PUTN(&INI_DATE, NLDATEW.)), -,%SYSFUNC(PUTN(&LAST_DATE, NLDATEW.)),��APP�s�«Ȥ��))))";
				ODS REGION COLUMN_SPAN=2 HEIGHT=48pct;
					GOPTIONS RESET=ALL DEVICE=SVG NOBORDER HSIZE=%SYSEVALF(7+&h_count.*0.01)in VSIZE=%SYSEVALF(4.6+&v_count.*0.01)in; 
					PATTERN1 C=CX4965B0; PATTERN2 C=CXFF7B58; PATTERN3 C=CX95B60E;
					PROC GCHART DATA=All_APP_N_O_R_TMP(WHERE=("���"N=.));
						PIE "�Ȥ�����"N/SUMVAR="�P�⦬�J"N GROUP="�q�檬�p"N MIDPOINTS="�^�Y��" "�s��"
							 ACROSS=2 DOWN=2 PERCENT=arrow COUTLINE=CX7C5C00 NOHEADING;
						RUN;
					QUIT;
				ODS REGION COLUMN_SPAN=2 HEIGHT=47pct;
					ODS TEXT="^S={OUTPUTWIDTH=100% FONTSIZE=12pt JUST=C}%SYSFUNC(COMPRESS(%SYSFUNC(PUTN(&INI_DATE, NLDATEW.))))-%SYSFUNC(COMPRESS(%SYSFUNC(PUTN(&LAST_DATE, NLDATEW.))))�q���T�P�P�h�Ӹ`";
					PROC PRINT DATA=All_APP_N_O_R_TMP(WHERE=("���"N=. AND "�q�檬�p"N="NET")) NOOBS STYLE(DATA)=[JUST=C VJUST=M] STYLE(HEAD)=[JUST=C VJUST=M BACKGROUNDCOLOR=RGBAAA393933] CONTENTS="" LABEL;
						VAR �Ȥ����� ���� �q�檬�p �P�⦬�J "�ȳ���]AS�^"N "�����q����ȡ]AOV�^"N "�����q��q�]AOS�^"N;
					QUIT;
					ODS TEXT="^S={OUTPUTWIDTH=85% JUST=L}��1�G�ȳ��=�P�⦬�J���U�ȼ�";
					ODS TEXT="^S={OUTPUTWIDTH=85% JUST=L}��2�G�����q�����=�P�⦬�J�ҭq���";
					ODS TEXT="^S={OUTPUTWIDTH=85% JUST=L}��3�G�����q��q=�ӫ~�ƶq�ҭq���";
					PROC PRINT DATA=WORK.R_LIST NOOBS STYLE(DATA)=[JUST=C VJUST=M] STYLE(HEAD)=[JUST=C VJUST=M BACKGROUNDCOLOR=RGBA765CC833] CONTENTS="" LABEL;
						VAR SALENO SALENAME �P�⦬�J �ƶq;
						LABEL SALENAME=�P�h�ӫ~�W�� SALENO=�P��s�� �ƶq=�ӫ~�ƶq �P�⦬�J=���B;
					QUIT;
				ODS LAYOUT END;
				%LET h_count=%EVAL(&h_count+1); %LET v_count=%EVAL(&v_count+1); /*For displaying charts normally*/
				ODS PDF (ID=DYFIG) STARTPAGE=NOW;
				/*Page 2*/
				ODS LAYOUT GRIDDED STYLE={FONTFAMILY="Microsoft JhengHei"}
									COLUMNS=3 ROWS=4 COLUMN_WIDTHS=(33.3% 33.3% 33.4%) HEIGHT=10in COLUMN_GUTTER=0 ROW_GUTTER=0;
				ODS REGION COLUMN_SPAN=3 HEIGHT=5pct;
					ODS TEXT="^S={OUTPUTWIDTH=100% FONTSIZE=13pt JUST=C}%SYSFUNC(COMPRESS(%SYSFUNC(CATS(%SYSFUNC(PUTN(&INI_DATE, NLDATEW.)), -,%SYSFUNC(PUTN(&LAST_DATE, NLDATEW.)),�M�ݱ��˻P���n���s�«�))))";
				ODS REGION COLUMN_SPAN=3 HEIGHT=48pct;
					GOPTIONS HSIZE=%SYSEVALF(7+&h_count.*0.01)in VSIZE=%SYSEVALF(4.6+&v_count.*0.01)in;
					PROC GCHART DATA=Personal_N_O_R_TMP(WHERE=("���"N=. AND "�q�檬�p"N = "NET"));
						VBAR "����"N/SUMVAR="�P�⦬�J"N GROUP="�q�檬�p"N SUBGROUP="�Ȥ�����"N SPACE=0;
						RUN;
					QUIT;
				ODS REGION COLUMN_SPAN=3 HEIGHT=24pct;
					ODS TEXT="^S={OUTPUTWIDTH=100% FONTSIZE=10pt JUST=C}�q���T";
					PROC PRINT DATA=Personal_N_O_R_TMP(WHERE=("���"N=.  AND "�q�檬�p"N="NET")) NOOBS STYLE(DATA)=[JUST=C VJUST=M] STYLE(HEAD)=[JUST=C VJUST=M BACKGROUNDCOLOR=RGBAAA393933] CONTENTS="" LABEL;
						VAR �Ȥ����� ���� �q�檬�p �P�⦬�J "�ȳ���]AS�^"N "�����q����ȡ]AOV�^"N "�����q��q�]AOS�^"N;
					QUIT;
				ODS REGION HEIGHT=23pct;
					ODS TEXT="^S={OUTPUTWIDTH=100% FONTSIZE=10pt JUST=C}���B�Ʀ�](�b�q��)";
					PROC PRINT DATA=WORK.NET_LIST_MN(WHERE=(eraddsc IN ('�M�ݱ���', '���߰ӫ~', '�Y�ɷs�~', '�n�d�ӫ~', '�u�`�ӫ~') AND Date EQ .)) NOOBS 
								STYLE(DATA)=[JUST=C VJUST=M] STYLE(HEAD)=[JUST=C VJUST=M BACKGROUNDCOLOR=RGBA469E3433] CONTENTS="" LABEL;
						VAR eraddsc customerid '���B'N '�ƶq'N;
						LABEL eraddsc=���� customerid=�ȥN;
					QUIT;
					ODS TEXT="^S={OUTPUTWIDTH=70% JUST=L}��1�G�u�e�{�C�Ӫ��쪺�e�T�W�C";
				ODS REGION HEIGHT=23pct;
					ODS TEXT="^S={OUTPUTWIDTH=100% FONTSIZE=10pt JUST=C}�ƶq�Ʀ�](�b�q��)";
					PROC PRINT DATA=WORK.NET_LIST_AMOUNT(WHERE=(eraddsc IN ('�M�ݱ���', '���߰ӫ~', '�Y�ɷs�~', '�n�d�ӫ~', '�u�`�ӫ~') AND Date EQ .)) NOOBS 
								STYLE(DATA)=[JUST=C VJUST=M] STYLE(HEAD)=[JUST=C VJUST=M BACKGROUNDCOLOR=RGBA469E3433] CONTENTS="" LABEL;
						VAR eraddsc customerid '���B'N '�ƶq'N;
						LABEL eraddsc=���� customerid=�ȥN;
					QUIT;
					ODS TEXT="^S={OUTPUTWIDTH=70% JUST=L}��1�G�u�e�{�C�Ӫ��쪺�e�T�W�C";
				ODS REGION HEIGHT=23pct;
					ODS TEXT="^S={OUTPUTWIDTH=100% FONTSIZE=9pt JUST=C}���즬�q�Ͷ�";
					PROC SGPLOT DATA=WORK.NET_LIST_AMOUNT(WHERE=(eraddsc IN ('�M�ݱ���', '���߰ӫ~', '�Y�ɷs�~', '�n�d�ӫ~', '�u�`�ӫ~')  AND Date NE .));
						VLINE Date/RESPONSE='���B'N GROUP=eraddsc;
						XAXIS DISPLAY=(NOLABEL); YAXIS DISPLAY=(NOLABEL);
						KEYLEGEND/ TITLE="����" TITLEATTRS=(FAMILY=BiauKai SIZE=8) VALUEATTRS=(FAMILY=BiauKai SIZE=8);
					RUN; QUIT;
				ODS LAYOUT END;
				%LET h_count=%EVAL(&h_count+1); %LET v_count=%EVAL(&v_count+1); /*For displaying charts normally*/
				ODS PDF (ID=DYFIG) STARTPAGE=NOW;
				/*Page 3*/
				ODS LAYOUT GRIDDED /*STYLE={FONTFAMILY="Microsoft JhengHei"}*/
									COLUMNS=3 ROWS=4 COLUMN_WIDTHS=(33.3% 33.3% 33.4%) HEIGHT=10in COLUMN_GUTTER=0 ROW_GUTTER=0;
				ODS REGION COLUMN_SPAN=3 HEIGHT=5pct;
					ODS TEXT="^S={OUTPUTWIDTH=100% FONTSIZE=13pt JUST=C}%SYSFUNC(COMPRESS(%SYSFUNC(CATS(%SYSFUNC(PUTN(&INI_DATE, NLDATEW.)), -,%SYSFUNC(PUTN(&LAST_DATE, NLDATEW.)),������s�«�))))";
				ODS REGION COLUMN_SPAN=3 HEIGHT=48pct;
					GOPTIONS HSIZE=%SYSEVALF(7+&h_count.*0.01)in VSIZE=%SYSEVALF(4.6+&v_count.*0.01)in;
					PROC GCHART DATA=HotSale_N_O_R_TMP(WHERE=("���"N=.));
						VBAR "����"N/SUMVAR="�P�⦬�J"N GROUP="�q�檬�p"N SUBGROUP="�Ȥ�����"N SPACE=0;
						RUN;
					QUIT;
				ODS REGION COLUMN_SPAN=3 HEIGHT=24pct;
					ODS TEXT="^S={OUTPUTWIDTH=100% FONTSIZE=10pt JUST=C}�q���T";
					PROC PRINT DATA=HotSale_N_O_R_TMP(WHERE=("���"N=. AND "�q�檬�p"N="NET")) NOOBS STYLE(DATA)=[JUST=C VJUST=M] STYLE(HEAD)=[JUST=C VJUST=M BACKGROUNDCOLOR=RGBAAA393933] CONTENTS="" LABEL;
						VAR �Ȥ����� ���� �q�檬�p �P�⦬�J "�ȳ���]AS�^"N "�����q����ȡ]AOV�^"N "�����q��q�]AOS�^"N;
					QUIT;
				ODS REGION HEIGHT=23pct;
					ODS TEXT="^S={OUTPUTWIDTH=100% FONTSIZE=10pt JUST=C}���B�Ʀ�](�b�q��)";
					PROC PRINT DATA=WORK.NET_LIST_MN(WHERE=(eraddsc IN ('�t�ױ��˰ӫ~', '�F����˰ӫ~') AND Date EQ .)) NOOBS 
								STYLE(DATA)=[JUST=C VJUST=M] STYLE(HEAD)=[JUST=C VJUST=M BACKGROUNDCOLOR=RGBA469E3433] CONTENTS="" LABEL;
						VAR eraddsc customerid '���B'N '�ƶq'N;
						LABEL eraddsc=���� customerid=�ȥN;
					QUIT;
					ODS TEXT="^S={OUTPUTWIDTH=70% JUST=L}��1�G�u�e�{�C�Ӫ��쪺�e�T�W�C";
				ODS REGION HEIGHT=23pct;
					ODS TEXT="^S={OUTPUTWIDTH=100% FONTSIZE=10pt JUST=C}�ƶq�Ʀ�](�b�q��)";
					PROC PRINT DATA=WORK.NET_LIST_AMOUNT(WHERE=(eraddsc IN ('�t�ױ��˰ӫ~', '�F����˰ӫ~') AND Date EQ .)) NOOBS 
								STYLE(DATA)=[JUST=C VJUST=M] STYLE(HEAD)=[JUST=C VJUST=M BACKGROUNDCOLOR=RGBA469E3433] CONTENTS="" LABEL;
						VAR eraddsc customerid '���B'N '�ƶq'N;
						LABEL eraddsc=���� customerid=�ȥN;
					QUIT;
					ODS TEXT="^S={OUTPUTWIDTH=70% JUST=L}��1�G�u�e�{�C�Ӫ��쪺�e�T�W�C";
				ODS REGION HEIGHT=23pct;
					ODS TEXT="^S={OUTPUTWIDTH=100% FONTSIZE=9pt JUST=C}���즬�q�Ͷ�";
					PROC SGPLOT DATA=WORK.NET_LIST_AMOUNT(WHERE=(eraddsc IN ('�t�ױ��˰ӫ~', '�F����˰ӫ~')  AND Date NE .));
						VLINE Date/RESPONSE='���B'N GROUP=eraddsc;
						XAXIS DISPLAY=(NOLABEL); YAXIS DISPLAY=(NOLABEL);
						KEYLEGEND/ TITLE="����" TITLEATTRS=(FAMILY=BiauKai SIZE=8) VALUEATTRS=(FAMILY=BiauKai SIZE=8);
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
				VAR "�P�⦬�J"N "�ӫ~�ƶq"N "�q���"N "�U�ȼ�"N;
				TYPES ()*"OrderStatus"N ()*eraddsc*"OrderStatus"N Date*"OrderStatus"N Date*eraddsc*"OrderStatus"N;
				OUTPUT OUT=M_O_O_STATS SUM="�P�⦬�J"N "�ӫ~�ƶq"N "�q���"N "�U�ȼ�"N;
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
				RETAIN '���'N '����'N '�q�檬�p'N '�P�⦬�J'N '�ӫ~�ƶq'N '�q���'N;
				FORMAT '���'N NLDATEW. '�q�檬�p'N &VARN1 '����'N &VARN2 '�P�⦬�J'N NLMNITWD22.0 '�ӫ~�ƶq'N '�q���'N COMMA9.0;
				SET M_O_O_STATS (DROP=_TYPE_ _FREQ_ RENAME=(Date=��� 'OrderStatus'N=OrderStatusTMP eraddsc=eraddsc_tmp));
				IF OrderStatusTMP NE "" THEN '�q�檬�p'N=OrderStatusTMP; ELSE '�q�檬�p'N="��";
				IF eraddsc_tmp NE "" THEN '����'N=eraddsc_tmp; ELSE '����'N="������";
			RUN;
			/*
				Whole-time range stats for the new customers.
			*/
			PROC MEANS DATA=WORK.M_N_O_SUMMARY SUM NOPRINT;
				CLASS Date "OrderStatus"N eraddsc;
				VAR "�P�⦬�J"N "�ӫ~�ƶq"N "�q���"N "�U�ȼ�"N;
				TYPES ()*"OrderStatus"N  ()*eraddsc*"OrderStatus"N Date*"OrderStatus"N Date*eraddsc*"OrderStatus"N;
				OUTPUT OUT=M_N_O_STATS SUM="�P�⦬�J"N "�ӫ~�ƶq"N "�q���"N "�U�ȼ�"N;
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
				RETAIN '���'N '����'N '�q�檬�p'N '�P�⦬�J'N '�ӫ~�ƶq'N '�q���'N;
				FORMAT '���'N NLDATEW. '�q�檬�p'N &VARN1 '����'N &VARN2 '�P�⦬�J'N NLMNITWD22.0 '�ӫ~�ƶq'N '�q���'N COMMA9.0;
				SET M_N_O_STATS (DROP=_TYPE_ _FREQ_ RENAME=(Date=��� 'OrderStatus'N=OrderStatusTMP eraddsc=eraddsc_tmp));
				IF OrderStatusTMP NE "" THEN '�q�檬�p'N=OrderStatusTMP; ELSE '�q�檬�p'N="��";
				IF eraddsc_tmp NE "" THEN '����'N=eraddsc_tmp; ELSE '����'N="������";
			RUN;
			/*
				Generate the whole-range stats based on all app and blocks.
			*/
			PROC SQL;
				CREATE TABLE All_APP_N_O_R AS /*N_O_R stands for revenue from the old and new customers.*/
				SELECT "���"N, "�^�Y��" FORMAT=$9. AS "�Ȥ�����"N, "����"N, "�q�檬�p"N, "�P�⦬�J"N FORMAT=DOLLAR12.0, "�P�⦬�J"N/"�U�ȼ�"N AS "�ȳ���]AS�^"N  FORMAT=DOLLAR12.0,
						"�P�⦬�J"N/"�q���"N AS "�����q����ȡ]AOV�^"N FORMAT=DOLLAR12.0, "�ӫ~�ƶq"N/"�q���"N AS "�����q��q�]AOS�^"N FORMAT=COMMA9.2
				FROM M_O_O_STATS
				UNION CORR ALL
				SELECT "���"N, "�s��" FORMAT=$9. AS "�Ȥ�����"N, "����"N, "�q�檬�p"N, "�P�⦬�J"N FORMAT=DOLLAR12.0, "�P�⦬�J"N/"�U�ȼ�"N AS "�ȳ���]AS�^"N  FORMAT=DOLLAR12.0,
						"�P�⦬�J"N/"�q���"N AS "�����q����ȡ]AOV�^"N FORMAT=DOLLAR12.0, "�ӫ~�ƶq"N/"�q���"N AS "�����q��q�]AOS�^"N FORMAT=COMMA9.2
				FROM M_N_O_STATS;
			QUIT;
			PROC SORT DATA=All_APP_N_O_R;
				BY "���"N "����"N;
			RUN;
			
			%_eg_conditional_dropds(M_O_O_STATS)
			%_eg_conditional_dropds(M_N_O_STATS)
			/*
				Generate the pie chart based on the previous dataset, All_APP_N_O_R.
			*/
			PROC SQL NOPRINT;
				CREATE TABLE All_APP_N_O_R_TMP AS SELECT * FROM All_APP_N_O_R WHERE "����"N = "������";
				CREATE TABLE Personal_N_O_R_TMP AS SELECT * FROM All_APP_N_O_R WHERE "����"N IN ("�Y�ɷs�~", "�n�d�ӫ~", "�u�`�ӫ~", "���߰ӫ~", "�M�ݱ���");
				CREATE TABLE HotSale_N_O_R_TMP AS SELECT * FROM All_APP_N_O_R WHERE "����"N IN ("�t�ױ��˰ӫ~", "�F����˰ӫ~");
			QUIT;
			/*Page 1*/
			ODS LAYOUT GRIDDED /*STYLE={FONTFAMILY="Microsoft JhengHei"}*/
								COLUMNS=2 ROWS=3 COLUMN_WIDTHS=(50% 50%) HEIGHT=10in COLUMN_GUTTER=0 ROW_GUTTER=0;
			ODS ESCAPECHAR="^";
			ODS REGION COLUMN_SPAN=2 HEIGHT=5pct;
				ODS TEXT="^S={OUTPUTWIDTH=100% FONTSIZE=13pt JUST=C}%SYSFUNC(COMPRESS(%SYSFUNC(CATS(%SYSFUNC(PUTN(&LAST_DATE, NLDATEW.)), ��APP�s�«Ȥ��))))";
			ODS REGION COLUMN_SPAN=2 HEIGHT=48pct;
				GOPTIONS RESET=ALL DEVICE=SVG NOBORDER HSIZE=%SYSEVALF(7+&h_count.*0.01)in VSIZE=%SYSEVALF(4.6+&v_count.*0.01)in; 
				PATTERN1 C=CX4965B0; PATTERN2 C=CXFF7B58; PATTERN3 C=CX95B60E;
				PROC GCHART DATA=All_APP_N_O_R_TMP(WHERE=("���"N=&LAST_DATE));
					PIE "�Ȥ�����"N/SUMVAR="�P�⦬�J"N GROUP="�q�檬�p"N MIDPOINTS="�^�Y��" "�s��"
						 ACROSS=2 DOWN=2 PERCENT=arrow COUTLINE=CX7C5C00 NOHEADING;
					RUN;
				QUIT;
			ODS REGION COLUMN_SPAN=2 HEIGHT=47pct;
				ODS TEXT="^S={OUTPUTWIDTH=100% FONTSIZE=12pt JUST=C}%SYSFUNC(COMPRESS(%SYSFUNC(PUTN(&LAST_DATE, NLDATEW.))))�q���T�P�P�h�Ӹ`";
				PROC PRINT DATA=All_APP_N_O_R_TMP(WHERE=("���"N=&LAST_DATE)) NOOBS STYLE(DATA)=[JUST=C VJUST=M] STYLE(HEAD)=[JUST=C VJUST=M BACKGROUNDCOLOR=RGBAAA393933] CONTENTS="" LABEL;
				QUIT;
				ODS TEXT="^S={OUTPUTWIDTH=85% JUST=L}��1�G�ȳ��=�P�⦬�J���U�ȼ�";
				ODS TEXT="^S={OUTPUTWIDTH=85% JUST=L}��2�G�����q�����=�P�⦬�J�ҭq���";
				ODS TEXT="^S={OUTPUTWIDTH=85% JUST=L}��3�G�����q��q=�ӫ~�ƶq�ҭq���";
				PROC PRINT DATA=WORK.DETAILED_R_LIST(WHERE=(Date=&LAST_DATE)) NOOBS STYLE(DATA)=[JUST=C VJUST=M] STYLE(HEAD)=[JUST=C VJUST=M BACKGROUNDCOLOR=RGBA765CC833] CONTENTS="" LABEL;
					VAR customerid SALENO SALENAME �P�⦬�J �ƶq;
					LABEL customerid=�ȥN SALENAME=�P�h�ӫ~�W�� SALENO=�P��s�� �ƶq=�ӫ~�ƶq �P�⦬�J=���B;
				QUIT;
			ODS LAYOUT END;
			%LET h_count=%EVAL(&h_count+1); %LET v_count=%EVAL(&v_count+1); /*For displaying charts normally*/
			ODS PDF (ID=DYFIG) STARTPAGE=NOW;
			/*Page 2*/
			ODS LAYOUT GRIDDED STYLE={FONTFAMILY="Microsoft JhengHei"}
								COLUMNS=2 ROWS=4 COLUMN_WIDTHS=(50% 50%) HEIGHT=10in COLUMN_GUTTER=0 ROW_GUTTER=0;
			ODS REGION COLUMN_SPAN=2 HEIGHT=5pct;
				ODS TEXT="^S={OUTPUTWIDTH=100% FONTSIZE=13pt JUST=C}%SYSFUNC(COMPRESS(%SYSFUNC(CATS(%SYSFUNC(PUTN(&LAST_DATE, NLDATEW.)), �M�ݱ��˻P���n���s�«�))))";
			ODS REGION COLUMN_SPAN=2 HEIGHT=48pct;
				GOPTIONS HSIZE=%SYSEVALF(7+&h_count.*0.01)in VSIZE=%SYSEVALF(4.6+&v_count.*0.01)in;
				PROC GCHART DATA=Personal_N_O_R_TMP(WHERE=("���"N=&LAST_DATE));
					VBAR "����"N/SUMVAR="�P�⦬�J"N GROUP="�q�檬�p"N SUBGROUP="�Ȥ�����"N SPACE=0;
					RUN;
				QUIT;
			ODS REGION COLUMN_SPAN=2 HEIGHT=24pct;
				ODS TEXT="^S={OUTPUTWIDTH=100% FONTSIZE=10pt JUST=C}�q���T";
				PROC PRINT DATA=Personal_N_O_R_TMP(WHERE=("���"N=&LAST_DATE)) NOOBS STYLE(DATA)=[JUST=C VJUST=M] STYLE(HEAD)=[JUST=C VJUST=M BACKGROUNDCOLOR=RGBAAA393933] CONTENTS="" LABEL;
				QUIT;
			ODS REGION HEIGHT=23pct;
				ODS TEXT="^S={OUTPUTWIDTH=100% FONTSIZE=10pt JUST=C}���B�Ʀ�](�b�q��)";
				PROC PRINT DATA=WORK.NET_LIST_MN(WHERE=(eraddsc IN ('�M�ݱ���', '���߰ӫ~', '�Y�ɷs�~', '�n�d�ӫ~', '�u�`�ӫ~') AND Date EQ &LAST_DATE)) NOOBS 
							STYLE(DATA)=[JUST=C VJUST=M] STYLE(HEAD)=[JUST=C VJUST=M BACKGROUNDCOLOR=RGBA469E3433] CONTENTS="" LABEL;
					VAR eraddsc customerid '���B'N '�ƶq'N;
					LABEL eraddsc=���� customerid=�ȥN;
				QUIT;
				ODS TEXT="^S={OUTPUTWIDTH=70% JUST=L}��1�G�u�e�{�C�Ӫ��쪺�e�T�W�C";
			ODS REGION HEIGHT=23pct;
				ODS TEXT="^S={OUTPUTWIDTH=100% FONTSIZE=10pt JUST=C}�ƶq�Ʀ�](�b�q��)";
				PROC PRINT DATA=WORK.NET_LIST_AMOUNT(WHERE=(eraddsc IN ('�M�ݱ���', '���߰ӫ~', '�Y�ɷs�~', '�n�d�ӫ~', '�u�`�ӫ~') AND Date EQ &LAST_DATE)) NOOBS 
							STYLE(DATA)=[JUST=C VJUST=M] STYLE(HEAD)=[JUST=C VJUST=M BACKGROUNDCOLOR=RGBA469E3433] CONTENTS="" LABEL;
					VAR eraddsc customerid '���B'N '�ƶq'N;
					LABEL eraddsc=���� customerid=�ȥN;
				QUIT;
				ODS TEXT="^S={OUTPUTWIDTH=70% JUST=L}��1�G�u�e�{�C�Ӫ��쪺�e�T�W�C";
			ODS LAYOUT END;
			%LET h_count=%EVAL(&h_count+1); %LET v_count=%EVAL(&v_count+1); /*For displaying charts normally*/
			ODS PDF (ID=DYFIG) STARTPAGE=NOW;
			/*Page 3*/
			ODS LAYOUT GRIDDED /*STYLE={FONTFAMILY="Microsoft JhengHei"}*/
								COLUMNS=2 ROWS=4 COLUMN_WIDTHS=(50% 50%) HEIGHT=10in COLUMN_GUTTER=0 ROW_GUTTER=0;
			ODS REGION COLUMN_SPAN=2 HEIGHT=5pct;
				ODS TEXT="^S={OUTPUTWIDTH=100% FONTSIZE=13pt JUST=C}%SYSFUNC(COMPRESS(%SYSFUNC(CATS(%SYSFUNC(PUTN(&LAST_DATE, NLDATEW.)), ������s�«�))))";
			ODS REGION COLUMN_SPAN=2 HEIGHT=48pct;
				GOPTIONS HSIZE=%SYSEVALF(7+&h_count.*0.01)in VSIZE=%SYSEVALF(4.6+&v_count.*0.01)in;
				PROC GCHART DATA=HotSale_N_O_R_TMP(WHERE=("���"N=&LAST_DATE));
					VBAR "����"N/SUMVAR="�P�⦬�J"N GROUP="�q�檬�p"N SUBGROUP="�Ȥ�����"N SPACE=0;
					RUN;
				QUIT;
			ODS REGION COLUMN_SPAN=2 HEIGHT=24pct;
				ODS TEXT="^S={OUTPUTWIDTH=100% FONTSIZE=10pt JUST=C}�q���T";
				PROC PRINT DATA=HotSale_N_O_R_TMP(WHERE=("���"N=&LAST_DATE)) NOOBS STYLE(DATA)=[JUST=C VJUST=M] STYLE(HEAD)=[JUST=C VJUST=M BACKGROUNDCOLOR=RGBAAA393933] CONTENTS="" LABEL;
				QUIT;
			ODS REGION HEIGHT=23pct;
				ODS TEXT="^S={OUTPUTWIDTH=100% FONTSIZE=10pt JUST=C}���B�Ʀ�](�b�q��)";
				PROC PRINT DATA=WORK.NET_LIST_MN(WHERE=(eraddsc IN ('�t�ױ��˰ӫ~', '�F����˰ӫ~') AND Date EQ &LAST_DATE)) NOOBS 
							STYLE(DATA)=[JUST=C VJUST=M] STYLE(HEAD)=[JUST=C VJUST=M BACKGROUNDCOLOR=RGBA469E3433] CONTENTS="" LABEL;
					VAR eraddsc customerid '���B'N '�ƶq'N;
					LABEL eraddsc=���� customerid=�ȥN;
				QUIT;
				ODS TEXT="^S={OUTPUTWIDTH=70% JUST=L}��1�G�u�e�{�C�Ӫ��쪺�e�T�W�C";
			ODS REGION HEIGHT=23pct;
				ODS TEXT="^S={OUTPUTWIDTH=100% FONTSIZE=10pt JUST=C}�ƶq�Ʀ�](�b�q��)";
				PROC PRINT DATA=WORK.NET_LIST_AMOUNT(WHERE=(eraddsc IN ('�t�ױ��˰ӫ~', '�F����˰ӫ~') AND Date EQ &LAST_DATE)) NOOBS 
							STYLE(DATA)=[JUST=C VJUST=M] STYLE(HEAD)=[JUST=C VJUST=M BACKGROUNDCOLOR=RGBA469E3433] CONTENTS="" LABEL;
					VAR eraddsc customerid '���B'N '�ƶq'N;
					LABEL eraddsc=���� customerid=�ȥN;
				QUIT;
				ODS TEXT="^S={OUTPUTWIDTH=70% JUST=L}��1�G�u�e�{�C�Ӫ��쪺�e�T�W�C";
			ODS LAYOUT END;
			%LET h_count=%EVAL(&h_count+1); %LET v_count=%EVAL(&v_count+1); /*For displaying charts normally*/
			ODS PDF (ID=DYFIG) STARTPAGE=NOW;
				ODS LAYOUT GRIDDED /*STYLE={FONTFAMILY="Microsoft JhengHei"}*/
									COLUMNS=2 ROWS=3 COLUMN_WIDTHS=(50% 50%) HEIGHT=10in COLUMN_GUTTER=0 ROW_GUTTER=0;
				ODS ESCAPECHAR="^";
				ODS REGION COLUMN_SPAN=2 HEIGHT=5pct;
					ODS TEXT="^S={OUTPUTWIDTH=100% FONTSIZE=13pt JUST=C}%SYSFUNC(COMPRESS(%SYSFUNC(CATS(%SYSFUNC(PUTN(&INI_DATE, NLDATEW.)), -,%SYSFUNC(PUTN(&LAST_DATE, NLDATEW.)),��APP�s�«Ȥ��))))";
				ODS REGION COLUMN_SPAN=2 HEIGHT=48pct;
					GOPTIONS RESET=ALL DEVICE=SVG NOBORDER HSIZE=%SYSEVALF(7+&h_count.*0.01)in VSIZE=%SYSEVALF(4.6+&v_count.*0.01)in; 
					PATTERN1 C=CX4965B0; PATTERN2 C=CXFF7B58; PATTERN3 C=CX95B60E;
					PROC GCHART DATA=All_APP_N_O_R_TMP(WHERE=("���"N=.));
						PIE "�Ȥ�����"N/SUMVAR="�P�⦬�J"N GROUP="�q�檬�p"N MIDPOINTS="�^�Y��" "�s��"
							 ACROSS=2 DOWN=2 PERCENT=arrow COUTLINE=CX7C5C00 NOHEADING;
						RUN;
					QUIT;
				ODS REGION COLUMN_SPAN=2 HEIGHT=47pct;
					ODS TEXT="^S={OUTPUTWIDTH=100% FONTSIZE=12pt JUST=C}%SYSFUNC(COMPRESS(%SYSFUNC(PUTN(&INI_DATE, NLDATEW.))))-%SYSFUNC(COMPRESS(%SYSFUNC(PUTN(&LAST_DATE, NLDATEW.))))�q���T�P�P�h�Ӹ`";
					PROC PRINT DATA=All_APP_N_O_R_TMP(WHERE=("���"N=. AND "�q�檬�p"N="NET")) NOOBS STYLE(DATA)=[JUST=C VJUST=M] STYLE(HEAD)=[JUST=C VJUST=M BACKGROUNDCOLOR=RGBAAA393933] CONTENTS="" LABEL;
						VAR �Ȥ����� ���� �q�檬�p �P�⦬�J "�ȳ���]AS�^"N "�����q����ȡ]AOV�^"N "�����q��q�]AOS�^"N;
					QUIT;
					ODS TEXT="^S={OUTPUTWIDTH=85% JUST=L}��1�G�ȳ��=�P�⦬�J���U�ȼ�";
					ODS TEXT="^S={OUTPUTWIDTH=85% JUST=L}��2�G�����q�����=�P�⦬�J�ҭq���";
					ODS TEXT="^S={OUTPUTWIDTH=85% JUST=L}��3�G�����q��q=�ӫ~�ƶq�ҭq���";
					PROC PRINT DATA=WORK.R_LIST NOOBS STYLE(DATA)=[JUST=C VJUST=M] STYLE(HEAD)=[JUST=C VJUST=M BACKGROUNDCOLOR=RGBA765CC833] CONTENTS="" LABEL;
						VAR SALENO SALENAME �P�⦬�J �ƶq;
						LABEL SALENAME=�P�h�ӫ~�W�� SALENO=�P��s�� �ƶq=�ӫ~�ƶq �P�⦬�J=���B;
					QUIT;
				ODS LAYOUT END;
				%LET h_count=%EVAL(&h_count+1); %LET v_count=%EVAL(&v_count+1); /*For displaying charts normally*/
				ODS PDF (ID=DYFIG) STARTPAGE=NOW;
				/*Page 2*/
				ODS LAYOUT GRIDDED STYLE={FONTFAMILY="Microsoft JhengHei"}
									COLUMNS=3 ROWS=4 COLUMN_WIDTHS=(33.3% 33.3% 33.4%) HEIGHT=10in COLUMN_GUTTER=0 ROW_GUTTER=0;
				ODS REGION COLUMN_SPAN=3 HEIGHT=5pct;
					ODS TEXT="^S={OUTPUTWIDTH=100% FONTSIZE=13pt JUST=C}%SYSFUNC(COMPRESS(%SYSFUNC(CATS(%SYSFUNC(PUTN(&INI_DATE, NLDATEW.)), -,%SYSFUNC(PUTN(&LAST_DATE, NLDATEW.)),�M�ݱ��˻P���n���s�«�))))";
				ODS REGION COLUMN_SPAN=3 HEIGHT=48pct;
					GOPTIONS HSIZE=%SYSEVALF(7+&h_count.*0.01)in VSIZE=%SYSEVALF(4.6+&v_count.*0.01)in;
					PROC GCHART DATA=Personal_N_O_R_TMP(WHERE=("���"N=. AND "�q�檬�p"N = "NET"));
						VBAR "����"N/SUMVAR="�P�⦬�J"N GROUP="�q�檬�p"N SUBGROUP="�Ȥ�����"N SPACE=0;
						RUN;
					QUIT;
				ODS REGION COLUMN_SPAN=3 HEIGHT=24pct;
					ODS TEXT="^S={OUTPUTWIDTH=100% FONTSIZE=10pt JUST=C}�q���T";
					PROC PRINT DATA=Personal_N_O_R_TMP(WHERE=("���"N=.  AND "�q�檬�p"N="NET")) NOOBS STYLE(DATA)=[JUST=C VJUST=M] STYLE(HEAD)=[JUST=C VJUST=M BACKGROUNDCOLOR=RGBAAA393933] CONTENTS="" LABEL;
						VAR �Ȥ����� ���� �q�檬�p �P�⦬�J "�ȳ���]AS�^"N "�����q����ȡ]AOV�^"N "�����q��q�]AOS�^"N;
					QUIT;
				ODS REGION HEIGHT=23pct;
					ODS TEXT="^S={OUTPUTWIDTH=100% FONTSIZE=10pt JUST=C}���B�Ʀ�](�b�q��)";
					PROC PRINT DATA=WORK.NET_LIST_MN(WHERE=(eraddsc IN ('�M�ݱ���', '���߰ӫ~', '�Y�ɷs�~', '�n�d�ӫ~', '�u�`�ӫ~') AND Date EQ .)) NOOBS 
								STYLE(DATA)=[JUST=C VJUST=M] STYLE(HEAD)=[JUST=C VJUST=M BACKGROUNDCOLOR=RGBA469E3433] CONTENTS="" LABEL;
						VAR eraddsc customerid '���B'N '�ƶq'N;
						LABEL eraddsc=���� customerid=�ȥN;
					QUIT;
					ODS TEXT="^S={OUTPUTWIDTH=70% JUST=L}��1�G�u�e�{�C�Ӫ��쪺�e�T�W�C";
				ODS REGION HEIGHT=23pct;
					ODS TEXT="^S={OUTPUTWIDTH=100% FONTSIZE=10pt JUST=C}�ƶq�Ʀ�](�b�q��)";
					PROC PRINT DATA=WORK.NET_LIST_AMOUNT(WHERE=(eraddsc IN ('�M�ݱ���', '���߰ӫ~', '�Y�ɷs�~', '�n�d�ӫ~', '�u�`�ӫ~') AND Date EQ .)) NOOBS 
								STYLE(DATA)=[JUST=C VJUST=M] STYLE(HEAD)=[JUST=C VJUST=M BACKGROUNDCOLOR=RGBA469E3433] CONTENTS="" LABEL;
						VAR eraddsc customerid '���B'N '�ƶq'N;
						LABEL eraddsc=���� customerid=�ȥN;
					QUIT;
					ODS TEXT="^S={OUTPUTWIDTH=70% JUST=L}��1�G�u�e�{�C�Ӫ��쪺�e�T�W�C";
				ODS REGION HEIGHT=23pct;
					ODS TEXT="^S={OUTPUTWIDTH=100% FONTSIZE=9pt JUST=C}���즬�q�Ͷ�";
					PROC SGPLOT DATA=WORK.NET_LIST_AMOUNT(WHERE=(eraddsc IN ('�M�ݱ���', '���߰ӫ~', '�Y�ɷs�~', '�n�d�ӫ~', '�u�`�ӫ~')  AND Date NE .));
						VLINE Date/RESPONSE='���B'N GROUP=eraddsc;
						XAXIS DISPLAY=(NOLABEL); YAXIS DISPLAY=(NOLABEL);
						KEYLEGEND/ TITLE="����" TITLEATTRS=(FAMILY=BiauKai SIZE=8) VALUEATTRS=(FAMILY=BiauKai SIZE=8);
					RUN; QUIT;
				ODS LAYOUT END;
				%LET h_count=%EVAL(&h_count+1); %LET v_count=%EVAL(&v_count+1); /*For displaying charts normally*/
				ODS PDF (ID=DYFIG) STARTPAGE=NOW;
				/*Page 3*/
				ODS LAYOUT GRIDDED /*STYLE={FONTFAMILY="Microsoft JhengHei"}*/
									COLUMNS=3 ROWS=4 COLUMN_WIDTHS=(33.3% 33.3% 33.4%) HEIGHT=10in COLUMN_GUTTER=0 ROW_GUTTER=0;
				ODS REGION COLUMN_SPAN=3 HEIGHT=5pct;
					ODS TEXT="^S={OUTPUTWIDTH=100% FONTSIZE=13pt JUST=C}%SYSFUNC(COMPRESS(%SYSFUNC(CATS(%SYSFUNC(PUTN(&INI_DATE, NLDATEW.)), -,%SYSFUNC(PUTN(&LAST_DATE, NLDATEW.)),������s�«�))))";
				ODS REGION COLUMN_SPAN=3 HEIGHT=48pct;
					GOPTIONS HSIZE=%SYSEVALF(7+&h_count.*0.01)in VSIZE=%SYSEVALF(4.6+&v_count.*0.01)in;
					PROC GCHART DATA=HotSale_N_O_R_TMP(WHERE=("���"N=.));
						VBAR "����"N/SUMVAR="�P�⦬�J"N GROUP="�q�檬�p"N SUBGROUP="�Ȥ�����"N SPACE=0;
						RUN;
					QUIT;
				ODS REGION COLUMN_SPAN=3 HEIGHT=24pct;
					ODS TEXT="^S={OUTPUTWIDTH=100% FONTSIZE=10pt JUST=C}�q���T";
					PROC PRINT DATA=HotSale_N_O_R_TMP(WHERE=("���"N=. AND "�q�檬�p"N="NET")) NOOBS STYLE(DATA)=[JUST=C VJUST=M] STYLE(HEAD)=[JUST=C VJUST=M BACKGROUNDCOLOR=RGBAAA393933] CONTENTS="" LABEL;
						VAR �Ȥ����� ���� �q�檬�p �P�⦬�J "�ȳ���]AS�^"N "�����q����ȡ]AOV�^"N "�����q��q�]AOS�^"N;
					QUIT;
				ODS REGION HEIGHT=23pct;
					ODS TEXT="^S={OUTPUTWIDTH=100% FONTSIZE=10pt JUST=C}���B�Ʀ�](�b�q��)";
					PROC PRINT DATA=WORK.NET_LIST_MN(WHERE=(eraddsc IN ('�t�ױ��˰ӫ~', '�F����˰ӫ~') AND Date EQ .)) NOOBS 
								STYLE(DATA)=[JUST=C VJUST=M] STYLE(HEAD)=[JUST=C VJUST=M BACKGROUNDCOLOR=RGBA469E3433] CONTENTS="" LABEL;
						VAR eraddsc customerid '���B'N '�ƶq'N;
						LABEL eraddsc=���� customerid=�ȥN;
					QUIT;
					ODS TEXT="^S={OUTPUTWIDTH=70% JUST=L}��1�G�u�e�{�C�Ӫ��쪺�e�T�W�C";
				ODS REGION HEIGHT=23pct;
					ODS TEXT="^S={OUTPUTWIDTH=100% FONTSIZE=10pt JUST=C}�ƶq�Ʀ�](�b�q��)";
					PROC PRINT DATA=WORK.NET_LIST_AMOUNT(WHERE=(eraddsc IN ('�t�ױ��˰ӫ~', '�F����˰ӫ~') AND Date EQ .)) NOOBS 
								STYLE(DATA)=[JUST=C VJUST=M] STYLE(HEAD)=[JUST=C VJUST=M BACKGROUNDCOLOR=RGBA469E3433] CONTENTS="" LABEL;
						VAR eraddsc customerid '���B'N '�ƶq'N;
						LABEL eraddsc=���� customerid=�ȥN;
					QUIT;
					ODS TEXT="^S={OUTPUTWIDTH=70% JUST=L}��1�G�u�e�{�C�Ӫ��쪺�e�T�W�C";
				ODS REGION HEIGHT=23pct;
					ODS TEXT="^S={OUTPUTWIDTH=100% FONTSIZE=9pt JUST=C}���즬�q�Ͷ�";
					PROC SGPLOT DATA=WORK.NET_LIST_AMOUNT(WHERE=(eraddsc IN ('�t�ױ��˰ӫ~', '�F����˰ӫ~')  AND Date NE .));
						VLINE Date/RESPONSE='���B'N GROUP=eraddsc;
						XAXIS DISPLAY=(NOLABEL); YAXIS DISPLAY=(NOLABEL);
						KEYLEGEND/ TITLE="����" TITLEATTRS=(FAMILY=BiauKai SIZE=8) VALUEATTRS=(FAMILY=BiauKai SIZE=8);
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