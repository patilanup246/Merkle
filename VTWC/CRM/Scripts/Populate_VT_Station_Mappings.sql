declare @Stations	int = (select TypeID from Reference.LocationMappingType where name='Stations')
declare @VT			int = (select LocationGroupID from Reference.LocationGroup where name='VT')

INSERT INTO [Reference].[LocationMapping]
           ([TypeID]
          ,[LocationGroupID]
          ,[CreatedDate]
          ,[CreatedBy]
          ,[LastModifiedDate]
          ,[LastModifiedBy]
          ,[ArchivedInd]
		  ,[LocationID])
select		@Stations, 
			@VT, 
			GETDATE(),
			0 ,
			GETDATE(),
			0,
			0, 
			value from string_split('158,232,236,263,491,570,503,665,681,895,1005,1093,1226,1301,1480,1535,1561,1699,1536,1563,958,1780,1835,1916,1917,2001,2089,2073,2137,2121,2219,2263,2266,2428,2380,2459,2661,2618,2943,2764,2809,2856,2964,2941',',')
