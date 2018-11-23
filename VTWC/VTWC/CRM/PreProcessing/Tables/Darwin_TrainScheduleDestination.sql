CREATE TABLE [PreProcessing].[Darwin_TrainScheduleDestination] (
    [RTTIUniqueTrainID]              VARCHAR (512) NULL,
    [TrainUID]                       VARCHAR (512) NULL,
    [Headcode]                       VARCHAR (512) NULL,
    [ScheduledStartDate]             VARCHAR (512) NULL,
    [TIPLOC]                         VARCHAR (512) NULL,
    [CurrentActivityCodes]           VARCHAR (512) NULL,
    [PlannedActivityCodes]           VARCHAR (512) NULL,
    [IsCancelled]                    BIT           NULL,
    [PublicScheduledTimeOfArrival]   VARCHAR (512) NULL,
    [PublicScheduledTimeOfDeparture] VARCHAR (512) NULL,
    [WorkingTimeOfArrival]           VARCHAR (512) NULL,
    [WorkingTimeOfDeparture]         VARCHAR (512) NULL,
    [RouteDelay]                     VARCHAR (512) NULL
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'A delay value that is implied by a change to the services route. This value has been added to the forecast lateness of the service at the previous schedule location when calculating the expected lateness of arrival at this location.', @level0type = N'SCHEMA', @level0name = N'PreProcessing', @level1type = N'TABLE', @level1name = N'Darwin_TrainScheduleDestination', @level2type = N'COLUMN', @level2name = N'RouteDelay';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Working Time Of Departure - Working scheduled time as HH:MM[:SS]', @level0type = N'SCHEMA', @level0name = N'PreProcessing', @level1type = N'TABLE', @level1name = N'Darwin_TrainScheduleDestination', @level2type = N'COLUMN', @level2name = N'WorkingTimeOfDeparture';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Working time of arrival - Working scheduled time as HH:MM[:SS]', @level0type = N'SCHEMA', @level0name = N'PreProcessing', @level1type = N'TABLE', @level1name = N'Darwin_TrainScheduleDestination', @level2type = N'COLUMN', @level2name = N'WorkingTimeOfArrival';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Public Scheduled Time Of Departure - Time as HH:MM', @level0type = N'SCHEMA', @level0name = N'PreProcessing', @level1type = N'TABLE', @level1name = N'Darwin_TrainScheduleDestination', @level2type = N'COLUMN', @level2name = N'PublicScheduledTimeOfDeparture';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Public Scheduled Time Of Arrival - Time as HH:MM', @level0type = N'SCHEMA', @level0name = N'PreProcessing', @level1type = N'TABLE', @level1name = N'Darwin_TrainScheduleDestination', @level2type = N'COLUMN', @level2name = N'PublicScheduledTimeOfArrival';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Is train cancelled?', @level0type = N'SCHEMA', @level0name = N'PreProcessing', @level1type = N'TABLE', @level1name = N'Darwin_TrainScheduleDestination', @level2type = N'COLUMN', @level2name = N'IsCancelled';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Planned Activity Codes (if different to current activities) - Activity Type (a set of 6 x 2 character strings).  Full details are provided in Common Interface File End User Specification.', @level0type = N'SCHEMA', @level0name = N'PreProcessing', @level1type = N'TABLE', @level1name = N'Darwin_TrainScheduleDestination', @level2type = N'COLUMN', @level2name = N'PlannedActivityCodes';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Current Activity Codes - Activity Type (a set of 6 x 2 character strings).  Full details are provided in Common Interface File End User Specification.', @level0type = N'SCHEMA', @level0name = N'PreProcessing', @level1type = N'TABLE', @level1name = N'Darwin_TrainScheduleDestination', @level2type = N'COLUMN', @level2name = N'CurrentActivityCodes';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Optional TIPLOC where the reason refers to, e.g. "signalling failure at Cheadle Hulme".', @level0type = N'SCHEMA', @level0name = N'PreProcessing', @level1type = N'TABLE', @level1name = N'Darwin_TrainScheduleDestination', @level2type = N'COLUMN', @level2name = N'TIPLOC';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Scheduled Start Date', @level0type = N'SCHEMA', @level0name = N'PreProcessing', @level1type = N'TABLE', @level1name = N'Darwin_TrainScheduleDestination', @level2type = N'COLUMN', @level2name = N'ScheduledStartDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'A train reporting number in Great Britain identifies a particular train service. It consists of: 
* A single-digit number, indicating the class (type) of train
* A letter, indicating the destination area
* A two-digit number, identifying the individual train or indicating the route (the latter generally for suburban services).', @level0type = N'SCHEMA', @level0name = N'PreProcessing', @level1type = N'TABLE', @level1name = N'Darwin_TrainScheduleDestination', @level2type = N'COLUMN', @level2name = N'Headcode';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Train Unique ID', @level0type = N'SCHEMA', @level0name = N'PreProcessing', @level1type = N'TABLE', @level1name = N'Darwin_TrainScheduleDestination', @level2type = N'COLUMN', @level2name = N'TrainUID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'RTTI Train ID. Note that since this is an RID, the service must already exist within Darwin.', @level0type = N'SCHEMA', @level0name = N'PreProcessing', @level1type = N'TABLE', @level1name = N'Darwin_TrainScheduleDestination', @level2type = N'COLUMN', @level2name = N'RTTIUniqueTrainID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Defines a Passenger Destination Calling Point.', @level0type = N'SCHEMA', @level0name = N'PreProcessing', @level1type = N'TABLE', @level1name = N'Darwin_TrainScheduleDestination';

