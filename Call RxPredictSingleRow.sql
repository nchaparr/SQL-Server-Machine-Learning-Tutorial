EXEC [dbo].[RxPredictSingleRow] @model = 'RxTrainLogit_model1',
@passenger_count = 1,
@trip_distance = 2.5,
@trip_time_in_secs = 631,
@pickup_latitude = 40.763958,
@pickup_longitude = -73.973373,
@dropoff_latitude =  40.782139,
@dropoff_longitude = -73.977303