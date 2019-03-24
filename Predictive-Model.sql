DROP TABLE CarSpeed
CREATE TABLE CarSpeed ([speed] int not null, [distance] int not null)
INSERT INTO CarSpeed
EXEC sp_execute_external_script
    @language=N'R'
    , @script = N'car_speed <- cars;'
    , @input_data_1 = N''
    , @output_data_1_name = N'car_speed'
SELECT * FROM CarSpeed

DROP PROCEDURE IF EXISTS generate_linear_model;
GO
CREATE PROCEDURE generate_linear_model
AS
BEGIN
    EXEC sp_execute_external_script
    @language = N'R'
    , @script = N'lrmodel <- rxLinMod(formula = distance ~ speed, data = CarsData);
        trained_model <- data.frame(payload = as.raw(serialize(lrmodel, connection=NULL)));'
    , @input_data_1 = N'SELECT speed, distance FROM CarSpeed'
    , @input_data_1_name = N'CarsData'
    , @output_data_1_name = N'trained_model'
    WITH RESULT SETS ((model VARBINARY(max)));
END;
GO

DROP TABLE stopping_distance_models
CREATE TABLE stopping_distance_models (
    model_name varchar(20) not null default('default model') primary key,
    model varbinary(max) not null);

UPDATE stopping_distance_models
SET model_name = 'rxLinMod ' + format(getdate(), 'yyy.MM.HH.mm', 'en-gb')
WHERE model_name = 'default model'

INSERT INTO stopping_distance_models (model)
EXEC generate_linear_model;

DECLARE @model varbinary(max), @modelname varchar(30)
EXEC sp_execute_external_script
    @language = N'R'
    , @script = N'
        speedmodel <- rxLinMod(distance ~ speed, CarsData)
        modelbin <- serialize(speedmodel, NULL)
        OutputDataSet <- data.frame(coefficients(speedmodel));'
    , @input_data_1 = N'SELECT speed, distance FROM CarSpeed'
    , @input_data_1_name = N'CarsData'
    , @params = N'@modelbin varbinary(max) OUTPUT'
    , @modelbin = @model OUTPUT
    WITH RESULT SETS (([Coefficient] float not null))

INSERT INTO [dbo].[stopping_distance_models] (model_name, model)
VALUES ('latest model', @model)

-- Predict and plot from model
CREATE TABLE [dbo].[NewCarSpeed]([speed] [int] NOT NULL, [distance] [int] NULL) ON [PRIMARY]
GO
INSERT [dbo].[NewCarSpeed] (speed)
VALUES (40), (50), (60), (70), (80), (90), (100)

-- DECLARE @speedmodel varbinary(max) = (SELECT model FROM [dbo].[stopping_distance_models] WHERE model_name = 'latest model');
-- EXEC sp_execute_external_script
--     @language=N'R'
--     , @script = N'
--             current_model <- unserialize(as.raw(speedmodel));
--             new <- data.frame(NewCarData);
--             predicted.distance <- rxPredict(current_model, new);
--             str(predicted.distance);
--             OutputDataset <- cbind(new, predicted.distance)'
--     , @input_data_1 = N' SELECT speed FROM [dbo].[NewCarSpeed]'
--     , @input_data_1_name = N'NewCarData'
--     , @params = N'@speedmodel varbinary(max) OUTPUT'
--     ,@speedmodel = @speedmodel OUTPUT
-- WITH RESULT SETS (([new_speed] INT, [predicted_distance] INT))

DECLARE @speedmodel varbinary(max) = 
    (SELECT model FROM [dbo].[stopping_distance_models] WHERE model_name = 'latest model');

EXEC sp_execute_external_script
    @language = N'R'
    , @script = N'
            current_model <- unserialize(as.raw(speedmodel));
            new <- data.frame(NewCarSpeed);
            predicted.distance <- rxPredict(current_model, new, type = "response");
            str(predicted.distance);
            OutputDataSet <- cbind(new, predicted.distance);
            '
    , @input_data_1 = N'SELECT speed FROM [dbo].[NewCarSpeed]'
    , @input_data_1_name = N'NewCarSpeed'
    , @params = N'@speedmodel varbinary(max)'
    , @speedmodel = @speedmodel
WITH RESULT SETS ((new_speed INT, predicted_distance INT));

