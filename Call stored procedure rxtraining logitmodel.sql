DECLARE @model VARBINARY(MAX);
EXEC RxTrainLogitModel @model OUTPUT;
INSERT INTO nyc_taxi_models (name, model) VALUES('RxTrainLogit_model', @model);