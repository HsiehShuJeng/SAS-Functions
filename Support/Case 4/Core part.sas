PROC SQL NOPRINT;
	/*
		Extract new flag value 
		and the existing flag value with new date
	*/
	CREATE TABLE NEWBORN_INTERMEDIATE AS
		SELECT flag, DATEPART(Creation) FORMAT=YYMMDDS10. FROM WORK.FOUNDATION
		EXCEPT
		SELECT flag, ListDate FROM WORK.LOOKUP_TABLE;
	/*
		Get the category value of flag from the lookup table and
		its corresponding maximum subcategroy value.
	*/
	CREATE TABLE OPTIMUM AS
		SELECT N.flag, L.TYPE AS MaximumType, MAX(L.SUBTYPE) AS MaximumSubtype
		FROM NEWBORN_INTERMEDIATE N LEFT JOIN LOOKUP_TABLE L ON N.flag EQ L.flag
		GROUP BY L.flag
		ORDER BY MaximumType DESC;
	/*Get the maximal value of category*/
	SELECT MAX(TYPE) INTO :MaximalTypeValue FROM LOOKUP_TABLE;
QUIT;
/*Match new categories with new values*/
DATA OPTIMUM;
	SET OPTIMUM;
	IF MaximumType EQ . THEN	
		DO; 
			%LET MaximalTypeValue=%EVAL(&MaximalTypeValue+1);
			MaximumType=&MaximalTypeValue;
		END;
RUN;
/*Get the maximal sub-cateogry value*/
DATA _NULL_;
	SET OPTIMUM;
	CALL SYMPUT(CATS('TYPE',TRIM(MaximumType)), COMPRESS(COALESCE(MaximumSubtype,1001)));
RUN;
%PUT _USER_;
/*
	Match the extracted flag value and existing flag value on the new date
	with category value.
*/
PROC SQL;
CREATE TABLE NEWBORN_INTERMEDIATE2 AS
	SELECT NI1.flag, O.MaximumType, NI1.ListDate
	FROM NEWBORN_INTERMEDIATE NI1 INNER JOIN OPTIMUM O ON NI1.flag EQ O.flag
	ORDER BY MaximumType,ListDate;
QUIT;
/****************************************************************************************
* Assume Status3 and Status4 have limited sub-categories, the resting flags and those	*
* which may appear have unlimited sub-categories.										*
* Assum the definition of the early month is 1st to 15th, and the end month is 16th to	*
* the last.																				*
****************************************************************************************/
DATA NEWBORN;
	RETAIN flag MaximumType MaximumSubtype ListDate InsertionDate;
	FORMAT MaximumType MaximumSubtype 8.0 ListDate YYMMDDS10. InsertionDate DATETIME22.0;
	SET NEWBORN_INTERMEDIATE2;
	IF flag EQ 'Status3' OR flag EQ 'Status4' THEN DO;
		IF 1 LE DAY(ListDate) AND DAY(ListDate) LE 15 THEN DO; MaximumSubtype=1001; END;
		ELSE MaximumSubtype=1002;
	END;
	ELSE DO;
		IF SYMGET(CATS('TYPE',TRIM(MaximumType))) EQ 1001 THEN 
		DO; 
			MaximumSubtype=SYMGET(CATS('TYPE',TRIM(MaximumType)));
			CALL SYMPUT(CATS('TYPE',TRIM(MaximumType)),MaximumSubtype+1);
		END;
		ELSE 
		DO;
			CALL SYMPUT(CATS('TYPE',TRIM(MaximumType)),SYMGET(CATS('TYPE',COMPRESS(MaximumType)))+1);
			MaximumSubtype=SYMGET(CATS('TYPE',COMPRESS(MaximumType)));
		END;
	END;
	InsertionDate=DATETIME();
RUN;
%PUT _USER_;
PROC SQL;
INSERT INTO LOOKUP_TABLE
	SELECT * FROM NEWBORN;
CREATE TABLE FOUNDATION_TMP AS
	SELECT *, DATEPART(Creation) AS '日期'N FORMAT=YYMMDDS10. FROM FOUNDATION;
CREATE TABLE RESULT AS
	SELECT FT.flag, NB.MaximumType AS TYPE, NB.MaximumSubtype AS SUBTYPE, 
			FT.Creation, FT.EorU, FT.FakeID1, FT.FakeID2
	FROM FOUNDATION_TMP FT INNER JOIN NEWBORN NB
			ON FT.flag EQ NB.flag AND FT.'日期'N EQ NB.ListDate;
DROP TABLE OPTIMUM, NEWBORN_INTERMEDIATE, NEWBORN_INTERMEDIATE2, FOUNDATION_TMP;
QUIT;