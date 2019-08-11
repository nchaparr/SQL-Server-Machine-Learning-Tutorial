CREATE PROCEDURE [dbo].[RxTrainLogitModel] (@trained_model varbinary(max) OUTPUT)

AS
BEGIN
  DECLARE @inquery nvarchar(max) = N'
    select tipped, fare_amount, passenger_count,trip_time_in_secs,trip_distance,
    pickup_datetime, dropoff_datetime,
    dbo.fnCalculateDistance(pickup_latitude, pickup_longitude,  dropoff_latitude, dropoff_longitude) as direct_distance
    from nyctaxi_sample
    tablesample (70 percent) repeatable (98052)
'

  EXEC sp_execute_external_script @language = N'R',
                                  @script = N'
## Create model
logitObj <- rxLogit(tipped ~ passenger_count + trip_distance + trip_time_in_secs + direct_distance, data = InputDataSet)
summary(logitObj)

## Serialize model 
trained_model <- as.raw(serialize(logitObj, NULL));
',
  @input_data_1 = @inquery,
  @params = N'@trained_model varbinary(max) OUTPUT',
  @trained_model = @trained_model OUTPUT; 
END
GO
