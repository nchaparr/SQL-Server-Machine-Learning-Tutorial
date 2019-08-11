-- Define the input data
DECLARE @query_string nvarchar(max)
SET @query_string='

SELECT TOP 10 

a.passenger_count AS passenger_count, 
a.trip_time_in_secs AS trip_time_in_secs, 
a.trip_distance AS trip_distance, 
a.dropoff_datetime AS dropoff_datetime, 
dbo.fnCalculateDistance(pickup_latitude, 
pickup_longitude, dropoff_latitude,dropoff_longitude) AS direct_distance

FROM 
(SELECT 
medallion, 
hack_license, 
pickup_datetime, 
passenger_count,
trip_time_in_secs,
trip_distance, 
dropoff_datetime, 
pickup_latitude, 
pickup_longitude, 
dropoff_latitude, 
dropoff_longitude 
FROM nyctaxi_sample)a

LEFT OUTER JOIN

(SELECT 
medallion, 
hack_license, 
pickup_datetime 
FROM nyctaxi_sample TABLESAMPLE (70 percent) REPEATABLE (98052)    )b

ON a.medallion=b.medallion AND a.hack_license=b.hack_license 
AND a.pickup_datetime=b.pickup_datetime
WHERE b.medallion IS NULL
'

-- Call the stored procedure for scoring and pass the input data
EXEC [dbo].[RxPredictBatchOutput] @model = 'RxTrainLogit_model', @inquery = @query_string;
