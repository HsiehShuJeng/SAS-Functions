/*
	After some simple proper data manipulation, this data step
	can combine two columns as a new column and generate 
	two whole new columns, one is for listing some sort of item 
	and the other one, counting number with the limitation of 20 
	in a record at most at once.
*/
DATA Outcome(DROP=Column2 Column3 Column1 SerialNO);
	RETAIN 群組 清單;
	FORMAT 群組 $13. 清單 $419. 清單個數 8.0;
	SET WORK.序列後結果(KEEP=SerialNO Column1 Column2 Column3);
	BY Column2 Column3;
	清單個數+1;
	IF (NOT LAST.Column3) THEN
		DO;
			SELECT(MOD(SerialNO,20));
				WHEN (0) DO; 群組=CATS(Column2, Column3); 清單=CATS(清單, Column1); OUTPUT; END;
				WHEN (1) DO; 清單=CATS(Column1,","); 清單個數=1; END;
				OTHERWISE 清單=CATS(清單, Column1,",");
			END;
		END;
	ELSE DO; 群組=CATS(Column2, Column3); 清單=CATS(清單, Column1); OUTPUT; END;
RUN;