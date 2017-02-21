/*
	After some simple proper data manipulation, this data step
	can combine two columns as a new column and generate 
	two whole new columns, one is for listing some sort of item 
	and the other one, counting number with the limitation of 20 
	in a record at most at once.
*/
DATA Outcome(DROP=Column2 Column3 Column1 SerialNO);
	RETAIN �s�� �M��;
	FORMAT �s�� $13. �M�� $419. �M��Ӽ� 8.0;
	SET WORK.�ǦC�ᵲ�G(KEEP=SerialNO Column1 Column2 Column3);
	BY Column2 Column3;
	�M��Ӽ�+1;
	IF (NOT LAST.Column3) THEN
		DO;
			SELECT(MOD(SerialNO,20));
				WHEN (0) DO; �s��=CATS(Column2, Column3); �M��=CATS(�M��, Column1); OUTPUT; END;
				WHEN (1) DO; �M��=CATS(Column1,","); �M��Ӽ�=1; END;
				OTHERWISE �M��=CATS(�M��, Column1,",");
			END;
		END;
	ELSE DO; �s��=CATS(Column2, Column3); �M��=CATS(�M��, Column1); OUTPUT; END;
RUN;