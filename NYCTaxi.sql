SELECT TOP(10) * FROM dbo.nyctaxi_sample;
SELECT COUNT(*) FROM dbo.nyctaxi_sample;

SELECT DISTINCT [passenger_count]
    , ROUND (SUM ([fare_amount]),0) as TotalFares
    , ROUND (AVG ([fare_amount]),0) as AvgFares
FROM [dbo].[nyctaxi_sample]
GROUP BY [passenger_count]
ORDER BY  AvgFares DESC