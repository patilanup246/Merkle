-- Adding Sitecore Information Source
INSERT INTO Reference.InformationSource
( Name
, Description
, CreatedDate
, CreatedBy
, LastModifiedDate
, LastModifiedBy
, ArchivedInd
, DisplayName
, TypeCode
, ProspectInd
, AdditionalInformation)
VALUES
( 'Sitecore'
, 'IBM WCA Sitecore Newsletter form data'
, GETDATE()
, 0
, GETDATE()
, 0
, 0
, 'Sitecore'
, 'External'
, 1
, NULL)


-- Longer names are required
ALTER TABLE Reference.CVIQuestion ALTER COLUMN Name NVARCHAR(150) NOT NULL;

-- Adding new CVI Questions
INSERT INTO Reference.CVIQuestion
(CVIQuestionID, Name, Description, Type, CreatedBy, CreatedDate, LastModifiedBy, LastModifiedDate)
VALUES
(2,'NWL_FREQUENCY', 'How often do you travel?', 'STANDARD', 0, GETDATE(), 0, GETDATE()),
(3,'NWL_PURCHASE_TYPE','Where do you buy your tickets for Virgin Trains?', 'STANDARD', 0, GETDATE(), 0, GETDATE()),
(4,'NWL_RAILCARD_TYPE','What type of Railcard do you have?', 'STANDARD', 0, GETDATE(), 0, GETDATE()),
(5,'NWL_PREFERRED_VT_DEPARTURE_STATION','Please select your preferred Virgin Trains departure station', 'STANDARD', 0, GETDATE(), 0, GETDATE()),
(6,'NWL_GENERAL_REASON_FOR_TRAVEL','What is the main reason for your train travel?', 'STANDARD', 0, GETDATE(), 0, GETDATE());
SELECT * FROM Reference.CVIStandardAnswer
-- Adding new CVI Standard Answers
INSERT INTO Reference.CVIStandardAnswer
(CVIAnswerID, Value, Description, CreatedBy, CreatedDate, LastModifiedBy, LastModifiedDate ) 
VALUES
---- NWL_GENERAL_REASON_FOR_TRAVEL
(15,'THATS_FOR_ME_TO_KNOW', 'That''s for me to know', 0, GETDATE(), 0, GETDATE()),
(16,'HANGING_WITH_FRIENDS', 'Hanging with Friends', 0, GETDATE(), 0, GETDATE()),
(17,'SEEING_FAMILY', 'Seeing the Family', 0, GETDATE(), 0, GETDATE()),
(18,'ON_MY_HOLS', 'On My Hols', 0, GETDATE(), 0, GETDATE()),
(19,'DAY_TRIP', 'Day Tripping', 0, GETDATE(), 0, GETDATE()),
(20,'RETAIL_THERAPY', 'Retail Therapy', 0, GETDATE(), 0, GETDATE()),
(21,'EVENT', 'Event', 0, GETDATE(), 0, GETDATE()),
(22,'WORKING_9_5', 'Working 9-5', 0, GETDATE(), 0, GETDATE()),
(23,'ON_BUSINESS', 'On Business', 0, GETDATE(), 0, GETDATE()),
(24,'TO_FROM_UNI', 'To/From Uni', 0, GETDATE(), 0, GETDATE()),
(25,'SOMTHING_COMPLETELY_DIFFERENT', 'Something Completely Different', 0, GETDATE(), 0, GETDATE()),
---- NWL_PREFERRED_VT_DEPARTURE_STATION
(26,'VT_STATION_Bangor (Gwynedd)', 'Bangor (Gwynedd)', 0, GETDATE(), 0, GETDATE()),
(27,'VT_STATION_Birmingham International', 'Birmingham International', 0, GETDATE(), 0, GETDATE()),
(28,'VT_STATION_Birmingham New Street', 'Birmingham New Street', 0, GETDATE(), 0, GETDATE()),
(29,'VT_STATION_Blackpool North', 'Blackpool North', 0, GETDATE(), 0, GETDATE()),
(30,'VT_STATION_Carlisle', 'Carlisle', 0, GETDATE(), 0, GETDATE()),
(31,'VT_STATION_Chester', 'Chester', 0, GETDATE(), 0, GETDATE()),
(32,'VT_STATION_Colwyn Bay', 'Colwyn Bay', 0, GETDATE(), 0, GETDATE()),
(33,'VT_STATION_Coventry', 'Coventry', 0, GETDATE(), 0, GETDATE()),
(34,'VT_STATION_Crewe', 'Crewe', 0, GETDATE(), 0, GETDATE()),
(35,'VT_STATION_Edinburgh Waverley', 'Edinburgh Waverley', 0, GETDATE(), 0, GETDATE()),
(36,'VT_STATION_Flint', 'Flint', 0, GETDATE(), 0, GETDATE()),
(37,'VT_STATION_Glasgow Central', 'Glasgow Central', 0, GETDATE(), 0, GETDATE()),
(38,'VT_STATION_Haymarket (Edinburgh)', 'Haymarket (Edinburgh)', 0, GETDATE(), 0, GETDATE()),
(39,'VT_STATION_Holyhead', 'Holyhead', 0, GETDATE(), 0, GETDATE()),
(40,'VT_STATION_Kirkham and Wesham', 'Kirkham and Wesham', 0, GETDATE(), 0, GETDATE()),
(41,'VT_STATION_Lancaster', 'Lancaster', 0, GETDATE(), 0, GETDATE()),
(42,'VT_STATION_Lichfield Trent Valley', 'Lichfield Trent Valley', 0, GETDATE(), 0, GETDATE()),
(43,'VT_STATION_Liverpool Lime Street', 'Liverpool Lime Street', 0, GETDATE(), 0, GETDATE()),
(44,'VT_STATION_Llandudno Junction', 'Llandudno Junction', 0, GETDATE(), 0, GETDATE()),
(45,'VT_STATION_Lockerbie', 'Lockerbie', 0, GETDATE(), 0, GETDATE()),
(46,'VT_STATION_London Euston', 'London Euston', 0, GETDATE(), 0, GETDATE()),
(47,'VT_STATION_Macclesfield', 'Macclesfield', 0, GETDATE(), 0, GETDATE()),
(48,'VT_STATION_Manchester Piccadilly', 'Manchester Piccadilly', 0, GETDATE(), 0, GETDATE()),
(49,'VT_STATION_Milton Keynes Central', 'Milton Keynes Central', 0, GETDATE(), 0, GETDATE()),
(50,'VT_STATION_Motherwell', 'Motherwell', 0, GETDATE(), 0, GETDATE()),
(51,'VT_STATION_Northampton', 'Northampton', 0, GETDATE(), 0, GETDATE()),
(52,'VT_STATION_Nuneaton', 'Nuneaton', 0, GETDATE(), 0, GETDATE()),
(53,'VT_STATION_Oxenholme Lake District', 'Oxenholme Lake District', 0, GETDATE(), 0, GETDATE()),
(54,'VT_STATION_Penrith', 'Penrith', 0, GETDATE(), 0, GETDATE()),
(55,'VT_STATION_Poulton-Le-Fylde', 'Poulton-Le-Fylde', 0, GETDATE(), 0, GETDATE()),
(56,'VT_STATION_Prestatyn', 'Prestatyn', 0, GETDATE(), 0, GETDATE()),
(57,'VT_STATION_Preston', 'Preston', 0, GETDATE(), 0, GETDATE()),
(58,'VT_STATION_Rhyl', 'Rhyl', 0, GETDATE(), 0, GETDATE()),
(59,'VT_STATION_Rugby', 'Rugby', 0, GETDATE(), 0, GETDATE()),
(60,'VT_STATION_Runcorn', 'Runcorn', 0, GETDATE(), 0, GETDATE()),
(61,'VT_STATION_Sandwell &amp; Dudley', 'Sandwell &amp; Dudley', 0, GETDATE(), 0, GETDATE()),
(62,'VT_STATION_Shrewsbury', 'Shrewsbury', 0, GETDATE(), 0, GETDATE()),
(63,'VT_STATION_Stafford', 'Stafford', 0, GETDATE(), 0, GETDATE()),
(64,'VT_STATION_Stockport', 'Stockport', 0, GETDATE(), 0, GETDATE()),
(65,'VT_STATION_Stoke-on-Trent', 'Stoke-on-Trent', 0, GETDATE(), 0, GETDATE()),
(66,'VT_STATION_Tamworth', 'Tamworth', 0, GETDATE(), 0, GETDATE()),
(67,'VT_STATION_Telford Central', 'Telford Central', 0, GETDATE(), 0, GETDATE()),
(68,'VT_STATION_Warrington Bank Quay', 'Warrington Bank Quay', 0, GETDATE(), 0, GETDATE()),
(69,'VT_STATION_Watford Junction', 'Watford Junction', 0, GETDATE(), 0, GETDATE()),
(70,'VT_STATION_Wellington (Salop)', 'Wellington (Salop)', 0, GETDATE(), 0, GETDATE()),
(71,'VT_STATION_Wigan North Western', 'Wigan North Western', 0, GETDATE(), 0, GETDATE()),
(72,'VT_STATION_Wilmslow', 'Wilmslow', 0, GETDATE(), 0, GETDATE()),
(73,'VT_STATION_Wolverhampton', 'Wolverhampton', 0, GETDATE(), 0, GETDATE()),
(74,'VT_STATION_Wrexham General', 'Wrexham General', 0, GETDATE(), 0, GETDATE()),
---- NWL_RAILCARD_TYPE
(75,'16_25_RAILCARD', '16-25 Railcard', 0, GETDATE(), 0, GETDATE()),
(76,'ANNUAL_GOLD_CARD', 'Annual Gold Card', 0, GETDATE(), 0, GETDATE()),
(77,'DISABLED_ADULT_RAILCARD', 'Disabled Adult Railcard', 0, GETDATE(), 0, GETDATE()),
(78,'DISABLED_CHILD_RAILCARD', 'Disabled Child Railcard', 0, GETDATE(), 0, GETDATE()),
(79,'FAMILY_FRIENDS_RAILCARD', 'Family and Friends Railcard', 0, GETDATE(), 0, GETDATE()),
(80,'GROUP_SAVE_3', 'Groupsave 3', 0, GETDATE(), 0, GETDATE()),
(81,'GROUP_SAVE_4', 'Groupsave 4', 0, GETDATE(), 0, GETDATE()),
(82,'HIGHLANDS_RAILCARD', 'Highlands Railcard', 0, GETDATE(), 0, GETDATE()),
(83,'HM_FORCES_RAILCARD', 'HM Forces Railcard', 0, GETDATE(), 0, GETDATE()),
(84,'NETWORK_RAILCARD', 'Network Railcard', 0, GETDATE(), 0, GETDATE()),
(85,'NEW_DEAIL_PHOTOCARD', 'New deal Photocard', 0, GETDATE(), 0, GETDATE()),
(86,'SENIOR_RAILCARD', 'Senior Railcard', 0, GETDATE(), 0, GETDATE()),
---- NWL_PURCHASE_TYPE
(87,'VIRGINTRAINS.COM', 'virgintrains.com', 0, GETDATE(), 0, GETDATE()),
(88,'THETRAINLINE.COM', 'thetrainline.com', 0, GETDATE(), 0, GETDATE()),
(89,'OTHER_WEBSITE', 'Other website', 0, GETDATE(), 0, GETDATE()),
(90,'VT_CALL_CENTER', 'Virgin Trains call centre', 0, GETDATE(), 0, GETDATE()),
(91,'OTHER_CALL_CENTER', 'Other call centre', 0, GETDATE(), 0, GETDATE()),
(92,'TRAVEL_AGENT', 'Travel agent', 0, GETDATE(), 0, GETDATE()),
(93,'RS_TKT_OFFICE_OR_TRAVEL_AGENT', 'Railway station ticket office or travel centre', 0, GETDATE(), 0, GETDATE()),
(94,'SELF_SERV_TKT_MACH_AT_STATION', 'Self service ticket machine at station', 0, GETDATE(), 0, GETDATE()),
(95,'PURCHASED_BY_SOMEONE_ELSE', 'Purchased by someone else', 0, GETDATE(), 0, GETDATE()),
(96,'NOT_TRAVEL_WITH_VT', 'Not travelled with Virgin Trains', 0, GETDATE(), 0, GETDATE()),
(97,'OTHER', 'Other', 0, GETDATE(), 0, GETDATE()),
---- NWL_REASON_FOR_TRAVEL
(98,'5_OR_MORE_TIMES_X_WEEK', 'Five or more times a week', 0, GETDATE(), 0, GETDATE()),
(99,'1_TO_4_TIMES_X_WEEK', '1-4 times a Week', 0, GETDATE(), 0, GETDATE()),
(100,'1_TO_3_TIMES_X_MONTH', '1-3 times a Month', 0, GETDATE(), 0, GETDATE()),
(101,'A_FEW_TIMES_A_YEAR', 'A few times a Year', 0, GETDATE(), 0, GETDATE()),
(102,'TWICE_A_YEAR', 'Twice a Year', 0, GETDATE(), 0, GETDATE()),
(103,'ONCE_A_YEAR', 'Once a Year', 0, GETDATE(), 0, GETDATE()),
(104,'LESS_THAN_1_X_YEAR', 'Less than once a Year', 0, GETDATE(), 0, GETDATE());
