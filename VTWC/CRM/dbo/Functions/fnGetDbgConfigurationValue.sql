/*===========================================================================================
Name:		[fnGetDbgConfigurationValue]
Purpose:	Return a the value corresponding to the passed in paramater 
			from the dbgConfigurationParameters table

Parameters:	@Parameter - The configuration parameter being queried.

			
Created:	2014-06-18
Modified:	201X-XX-XX 


Peer Review:	
Call script:	exec dbo.fnGetDbgConfigurationValue
				    @Parameter = '' -- varchar(50)
=================================================================================================*/
create function [dbo].[fnGetDbgConfigurationValue] ( @Parameter varchar(50) )
returns varchar(500)
as
begin
    declare @Result as varchar(500)

    select  @Result = Value
    from    dbo.dbgConfigurationParameters
    where   Parameter = @Parameter

    return @Result
end