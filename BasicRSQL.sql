#Tutorial script

EXEC sp_execute_external_script
    @language = N'R',
    @script=N'OutputDataSet<-InputDataSet',
    @input_data_1=N'SELECT 1 AS hello'
    WITH RESULT SETS (([hello] int not null));
GO

CREATE TABLE RTestData ([col1] int not null) ON [PRIMARY]
INSERT INTO RTestData VALUES (1);
INSERT INTO RTestData VALUES (10);
INSERT INTO RTestData VALUES (100);
GO

SELECT * FROM RTestData



EXECUTE sp_execute_external_script
    @language=N'R'
    , @script=N' OutputDataSet <- InputDataSet;'
    , @input_data_1=N' SELECT * FROM RTestData;'
    WITH RESULT SETS (([NewColName] int NOT NULL));
    