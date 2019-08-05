DECLARE @query_string nvarchar(max)
SET @query_string='
select top 10 a.passenger_count as passenger_count, 
	a.trip_time_in_secs as trip_time_in_secs,
	a.trip_distance as trip_distance,
	a.dropoff_datetime as dropoff_datetime,  
	dbo.fnCalculateDistance(pickup_latitude, pickup_longitude, dropoff_latitude,dropoff_longitude) as direct_distance 
from
(
	select medallion, hack_license, pickup_datetime, passenger_count,trip_time_in_secs,trip_distance,  
		dropoff_datetime, pickup_latitude, pickup_longitude, dropoff_latitude, dropoff_longitude
	from nyctaxi_joined_1_percent
)a
left outer join
(
select medallion, hack_license, pickup_datetime
from nyctaxi_joined_1_percent
tablesample (70 percent) repeatable (98052)
)b
on a.medallion=b.medallion and a.hack_license=b.hack_license and a.pickup_datetime=b.pickup_datetime
where b.medallion is null
'
EXEC [dbo].[PredictTip] @inquery = @query_string;