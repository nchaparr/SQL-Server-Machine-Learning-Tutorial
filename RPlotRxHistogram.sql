CREATE PROCEDURE [dbo].[RxPlotHistogram]
AS
BEGIN
  SET NOCOUNT ON;
  DECLARE @query nvarchar(max) =  
  N'SELECT tipped FROM nyctaxi_sample'  
  EXECUTE sp_execute_external_script @language = N'R',  
                                     @script = N'  
   image_file = tempfile();  
   jpeg(filename = image_file);  
   #Plot histogram  
   rxHistogram(~tipped, data=InputDataSet, col=''lightgreen'',   
   title = ''Tip Histogram'', xlab =''Tipped or not'', ylab =''Counts'');  
   dev.off();  
   OutputDataSet <- data.frame(data=readBin(file(image_file, "rb"), what=raw(), n=1e6));  
   ',  
   @input_data_1 = @query  
   WITH RESULT SETS ((plot varbinary(max)));  
END
GO