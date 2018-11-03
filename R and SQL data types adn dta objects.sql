Execute sp_execute_external_script
    @language=N'R'
    ,@script=N' mytextvariable<-c("hello", " ","world");
     OutputDataSet<-as.data.frame(mytextvariable);
     str(OutputDataSet)',
    @input_data_1=N' ';

EXECUTE sp_execute_external_script
    @language=N'R'
    ,@script=N' OutputDataSet<-data.frame(c("hello"), " ", c("world"));
    str(OutputDataSet)',
    @input_data_1=N' ';

CREATE TABLE RTestData ([col1] int not null) ON [PRIMARY]
INSERT INTO RTestData VALUES (1);
INSERT INTO RTestData VALUES (10);
INSERT INTO RTestData VALUES (100);
GO

EXECUTE sp_execute_external_script
    @language =N'R'
    , @script= N'
        x <- as.matrix(InputDataSet);
        y <- array(12:15);
    OutputDataSet <- as.data.frame(x %*% y);'
    , @input_data_1=N'SELECT [Col1] From RTestData;'
    WITH RESULT SETS (([Col1] int, [Col2] int, [Col3] int, [Col4] int));

CREATE TABLE RTestData ([col1] int not null) ON [PRIMARY]
INSERT INTO RTestData VALUES (1);
INSERT INTO RTestData VALUES (10);
INSERT INTO RTestData VALUES (100);
GO

EXECUTE sp_execute_external_script
    @language =N'R'
    , @script= N'
        x <- as.matrix(InputDataSet);
        y <- array(12:14);
    OutputDataSet <- as.data.frame(y %*% x);'
    , @input_data_1=N'SELECT [Col1] From RTestData;'
    WITH RESULT SETS (([Col1] int ));

EXECUTE sp_execute_external_script
    @language=N'R'
    , @script= N'
            df1<-as.data.frame( array(1:6) );
            df2<-as.data.frame( c( InputDataSet , df1 ));
            OutputDataSet<- df2'
    ,@input_data_1=N' SELECT [Col1] from RTestData;'
    WITH RESULT SETS (( [Col2] int not null, [Col3] int not null ));


SELECT ModifiedDate
    , CAST(Name as varchar(50)) as BusinessName
    , SalesPersonID
    FROM [AdventureWorks2014].Sales.Store
    WHERE [SalesPersonID] = 282
    ORDER BY ModifiedDate ASC

EXECUTE sp_execute_external_script
    @language=N'R'
    , @script=N' str(InputDataSet);
    OutputDataset<-InputDataSet;'
    , @input_data_1=N'
        SELECT ModifiedDate
        , CAST(Name as varchar(50)) as BusinessName
        , SalesPersonID
        FROM [AdventureWorks2014].Sales.Store
        WHERE [SalesPersonID] = 282
        ORDER BY ModifiedDate ASC;'
WITH RESULT SETS undefined;

EXEC sp_execute_external_script
    @language = N'R'
    ,@script = N'OutputDataSet <- as.data.frame(rnorm(100, mean=50, sd=3));'
    ,@input_data_1 = N'     ;'
WITH RESULT SETS (([Density] float NOT NULL));


