USE [Project 1];
GO


--DROPing the tables if they already exist

-- Drop DimAssets table if it exists
IF OBJECT_ID('dbo.DimAssets', 'U') IS NOT NULL
    DROP TABLE dbo.DimAssets;
GO

-- Drop DimDate table if it exists
IF OBJECT_ID('dbo.DimDate', 'U') IS NOT NULL
    DROP TABLE dbo.DimDate;
GO

-- Drop FactInvestmentMetrics table if it exists
IF OBJECT_ID('dbo.FactInvestmentMetrics', 'U') IS NOT NULL
    DROP TABLE dbo.FactInvestmentMetrics;
GO

-- Drop AssetAllocation table if it exists
IF OBJECT_ID('dbo.AssetAllocation', 'U') IS NOT NULL
    DROP TABLE dbo.AssetAllocation;
GO






--Creating the Tables:



-- Create DimAssets table
CREATE TABLE DimAssets (
    AssetID INT PRIMARY KEY,
    AssetType NVARCHAR(50),
    Ticker NVARCHAR(10),
    AssetName NVARCHAR(100),
    MarketIndex NVARCHAR(10)
);
GO

-- Insert data into DimAssets
INSERT INTO DimAssets (AssetID, AssetType, Ticker, AssetName, MarketIndex) VALUES
(1, 'Stock', 'AAPL', 'Apple Inc.', 'NDX'),
(2, 'Stock', 'JNJ', 'Johnson & Johnson', 'NDX'),
(3, 'Stock', 'JPM', 'JPMorgan Chase & Co.', 'NDX'),
(4, 'Stock', 'MSFT', 'Microsoft Corporation', 'NDX'),
(5, 'ETF', 'SPY', 'SPDR S&P 500 ETF Trust', 'NDX'),
(6, 'ETF', 'VTI', 'Vanguard Total Stock Market ETF', 'NDX'),
(7, 'Forex', 'EURUSD', 'Euro to US Dollar', NULL),
(8, 'Forex', 'USDJPY', 'US Dollar to Japanese Yen', NULL),
(9, 'Index', 'NDX', 'Nasdaq 100 Index', NULL);
GO


-- Create DimDate table
CREATE TABLE DimDate (
    Date DATE PRIMARY KEY,
    Year INT,
    Quarter INT,
    Month INT,
    DayOfMonth INT,
    DayOfWeek INT
);
GO

-- Insert data into DimDate
WITH DateCTE AS (
    SELECT CAST('2023-01-01' AS DATE) AS Date
    UNION ALL
    SELECT DATEADD(DAY, 1, Date)
    FROM DateCTE
    WHERE Date < GETDATE()
)
INSERT INTO DimDate (Date, Year, Quarter, Month, DayOfMonth, DayOfWeek)
SELECT Date,
       YEAR(Date) AS Year,
       DATEPART(QUARTER, Date) AS Quarter,
       MONTH(Date) AS Month,
       DAY(Date) AS DayOfMonth,
       DATEPART(WEEKDAY, Date) AS DayOfWeek
FROM DateCTE
OPTION (MAXRECURSION 0);
GO






-- Create FactInvestmentMetrics table
CREATE TABLE FactInvestmentMetrics (
    Date DATE,
    AssetID INT,
    ClosePrice FLOAT,
    Volume FLOAT,
    VolumeWeightedAvgPrice FLOAT,
    OpenPrice FLOAT,
    HighestPrice FLOAT,
    LowestPrice FLOAT,
    UnixTimestamp BIGINT,
    NumberOfTransactions INT,
    FOREIGN KEY (Date) REFERENCES DimDate(Date),
    FOREIGN KEY (AssetID) REFERENCES DimAssets(AssetID)
);
GO




-- Create Allocation Table
CREATE TABLE AssetAllocation (
    AssetID INT,
    AllocationAmount FLOAT
);
GO

-- Insert allocation amounts
INSERT INTO AssetAllocation (AssetID, AllocationAmount)
VALUES 
(1, 12500),  -- AAPL
(2, 12500),  -- JNJ
(3, 12500),  -- JPM
(4, 12500),  -- MSFT
(5, 12500),  -- SPY
(6, 12500),  -- VTI
(7, 12500),  -- EURUSD
(8, 12500);  -- USDJPY
GO







-- Insert data into FactInvestmentMetrics for each cleaned data table
-- AAPL
INSERT INTO FactInvestmentMetrics (Date, AssetID, ClosePrice, Volume, VolumeWeightedAvgPrice, OpenPrice, HighestPrice, LowestPrice, UnixTimestamp, NumberOfTransactions)
SELECT Date, 1, ClosePrice, Volume, VolumeWeightedAvgPrice, OpenPrice, HighestPrice, LowestPrice, UnixTimestamp, NumberOfTransactions
FROM Cleaned_AAPL;
GO

-- JNJ
INSERT INTO FactInvestmentMetrics (Date, AssetID, ClosePrice, Volume, VolumeWeightedAvgPrice, OpenPrice, HighestPrice, LowestPrice, UnixTimestamp, NumberOfTransactions)
SELECT Date, 2, ClosePrice, Volume, VolumeWeightedAvgPrice, OpenPrice, HighestPrice, LowestPrice, UnixTimestamp, NumberOfTransactions
FROM Cleaned_JNJ;
GO

-- JPM
INSERT INTO FactInvestmentMetrics (Date, AssetID, ClosePrice, Volume, VolumeWeightedAvgPrice, OpenPrice, HighestPrice, LowestPrice, UnixTimestamp, NumberOfTransactions)
SELECT Date, 3, ClosePrice, Volume, VolumeWeightedAvgPrice, OpenPrice, HighestPrice, LowestPrice, UnixTimestamp, NumberOfTransactions
FROM Cleaned_JPM;
GO

-- MSFT
INSERT INTO FactInvestmentMetrics (Date, AssetID, ClosePrice, Volume, VolumeWeightedAvgPrice, OpenPrice, HighestPrice, LowestPrice, UnixTimestamp, NumberOfTransactions)
SELECT Date, 4, ClosePrice, Volume, VolumeWeightedAvgPrice, OpenPrice, HighestPrice, LowestPrice, UnixTimestamp, NumberOfTransactions
FROM Cleaned_MSFT;
GO

-- SPY
INSERT INTO FactInvestmentMetrics (Date, AssetID, ClosePrice, Volume, VolumeWeightedAvgPrice, OpenPrice, HighestPrice, LowestPrice, UnixTimestamp, NumberOfTransactions)
SELECT Date, 5, ClosePrice, Volume, VolumeWeightedAvgPrice, OpenPrice, HighestPrice, LowestPrice, UnixTimestamp, NumberOfTransactions
FROM Cleaned_SPY;
GO

-- VTI
INSERT INTO FactInvestmentMetrics (Date, AssetID, ClosePrice, Volume, VolumeWeightedAvgPrice, OpenPrice, HighestPrice, LowestPrice, UnixTimestamp, NumberOfTransactions)
SELECT Date, 6, ClosePrice, Volume, VolumeWeightedAvgPrice, OpenPrice, HighestPrice, LowestPrice, UnixTimestamp, NumberOfTransactions
FROM Cleaned_VTI;
GO

-- EURUSD
INSERT INTO FactInvestmentMetrics (Date, AssetID, ClosePrice, Volume, VolumeWeightedAvgPrice, OpenPrice, HighestPrice, LowestPrice, UnixTimestamp, NumberOfTransactions)
SELECT Date, 7, ClosePrice, Volume, VolumeWeightedAvgPrice, OpenPrice, HighestPrice, LowestPrice, UnixTimestamp, NumberOfTransactions
FROM Cleaned_EURUSD;
GO

-- USDJPY
INSERT INTO FactInvestmentMetrics (Date, AssetID, ClosePrice, Volume, VolumeWeightedAvgPrice, OpenPrice, HighestPrice, LowestPrice, UnixTimestamp, NumberOfTransactions)
SELECT Date, 8, ClosePrice, Volume, VolumeWeightedAvgPrice, OpenPrice, HighestPrice, LowestPrice, UnixTimestamp, NumberOfTransactions
FROM Cleaned_USDJPY;
GO

-- NDX
INSERT INTO FactInvestmentMetrics (Date, AssetID, ClosePrice, Volume, VolumeWeightedAvgPrice, OpenPrice, HighestPrice, LowestPrice, UnixTimestamp, NumberOfTransactions)
SELECT Date, 9, ClosePrice, NULL, NULL, OpenPrice, HighestPrice, LowestPrice, UnixTimestamp, NULL
FROM Cleaned_NDX;
GO





--Testing

-- Select all data from DimAssets
SELECT * FROM DimAssets;
GO

-- Select all data from DimDate
SELECT * FROM DimDate;
GO

-- Select all data from FactInvestmentMetrics
SELECT * FROM FactInvestmentMetrics;
GO

-- Select all data from Cleaned_AAPL
SELECT * FROM Cleaned_AAPL;
GO

-- Select all data from Cleaned_JNJ
SELECT * FROM Cleaned_JNJ;
GO

-- Select all data from Cleaned_JPM
SELECT * FROM Cleaned_JPM;
GO

-- Select all data from Cleaned_MSFT
SELECT * FROM Cleaned_MSFT;
GO

-- Select all data from Cleaned_SPY
SELECT * FROM Cleaned_SPY;
GO

-- Select all data from Cleaned_VTI
SELECT * FROM Cleaned_VTI;
GO

-- Select all data from Cleaned_EURUSD
SELECT * FROM Cleaned_EURUSD;
GO

-- Select all data from Cleaned_USDJPY
SELECT * FROM Cleaned_USDJPY;
GO

-- Select all data from Cleaned_NDX
SELECT * FROM Cleaned_NDX;
GO
