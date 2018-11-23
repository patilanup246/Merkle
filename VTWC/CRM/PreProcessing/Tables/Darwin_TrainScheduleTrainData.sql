CREATE TABLE [PreProcessing].[Darwin_TrainScheduleTrainData] (
    [RTTIUniqueTrainID]  VARCHAR (512) NULL,
    [TrainUID]           VARCHAR (512) NULL,
    [Headcode]           VARCHAR (512) NULL,
    [ScheduledStartDate] VARCHAR (512) NULL,
    [ATOCCode]           VARCHAR (512) NULL,
    [TypeOfService]      VARCHAR (512) NULL,
    [CategoryOfService]  VARCHAR (512) NULL,
    [IsPassengerService] BIT           NULL,
    [IsActiveInDarwin]   BIT           NULL,
    [IsServiceDeleted]   BIT           NULL,
    [IsCharterService]   BIT           NULL
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Indicates if this service is a charter service.', @level0type = N'SCHEMA', @level0name = N'PreProcessing', @level1type = N'TABLE', @level1name = N'Darwin_TrainScheduleTrainData', @level2type = N'COLUMN', @level2name = N'IsCharterService';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Service has been deleted and should not be used/displayed.', @level0type = N'SCHEMA', @level0name = N'PreProcessing', @level1type = N'TABLE', @level1name = N'Darwin_TrainScheduleTrainData', @level2type = N'COLUMN', @level2name = N'IsServiceDeleted';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Indicates if this service is active in Darwin. Note that schedules should be assumed to be inactive until a message is received to indicate otherwise.', @level0type = N'SCHEMA', @level0name = N'PreProcessing', @level1type = N'TABLE', @level1name = N'Darwin_TrainScheduleTrainData', @level2type = N'COLUMN', @level2name = N'IsActiveInDarwin';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'True if Darwin classifies the train category as a passenger service.', @level0type = N'SCHEMA', @level0name = N'PreProcessing', @level1type = N'TABLE', @level1name = N'Darwin_TrainScheduleTrainData', @level2type = N'COLUMN', @level2name = N'IsPassengerService';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Defines the train category', @level0type = N'SCHEMA', @level0name = N'PreProcessing', @level1type = N'TABLE', @level1name = N'Darwin_TrainScheduleTrainData', @level2type = N'COLUMN', @level2name = N'CategoryOfService';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Type of service, i.e. Train/Bus/Ship.', @level0type = N'SCHEMA', @level0name = N'PreProcessing', @level1type = N'TABLE', @level1name = N'Darwin_TrainScheduleTrainData', @level2type = N'COLUMN', @level2name = N'TypeOfService';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Codes used to identify Train Operating Companies (TOCs) in the various data feeds available from Network Rail.', @level0type = N'SCHEMA', @level0name = N'PreProcessing', @level1type = N'TABLE', @level1name = N'Darwin_TrainScheduleTrainData', @level2type = N'COLUMN', @level2name = N'ATOCCode';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Scheduled Start Date', @level0type = N'SCHEMA', @level0name = N'PreProcessing', @level1type = N'TABLE', @level1name = N'Darwin_TrainScheduleTrainData', @level2type = N'COLUMN', @level2name = N'ScheduledStartDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'A train reporting number in Great Britain identifies a particular train service. It consists of: 
* A single-digit number, indicating the class (type) of train
* A letter, indicating the destination area
* A two-digit number, identifying the individual train or indicating the route (the latter generally for suburban services).', @level0type = N'SCHEMA', @level0name = N'PreProcessing', @level1type = N'TABLE', @level1name = N'Darwin_TrainScheduleTrainData', @level2type = N'COLUMN', @level2name = N'Headcode';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Train Unique ID', @level0type = N'SCHEMA', @level0name = N'PreProcessing', @level1type = N'TABLE', @level1name = N'Darwin_TrainScheduleTrainData', @level2type = N'COLUMN', @level2name = N'TrainUID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'RTTI Train ID. Note that since this is an RID, the service must already exist within Darwin.', @level0type = N'SCHEMA', @level0name = N'PreProcessing', @level1type = N'TABLE', @level1name = N'Darwin_TrainScheduleTrainData', @level2type = N'COLUMN', @level2name = N'RTTIUniqueTrainID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Train Schedule.', @level0type = N'SCHEMA', @level0name = N'PreProcessing', @level1type = N'TABLE', @level1name = N'Darwin_TrainScheduleTrainData';

