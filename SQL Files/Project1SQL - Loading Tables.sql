USE [Project 1];
GO

-- Drop cleaned data tables if they exist
IF OBJECT_ID('dbo.Cleaned_AAPL', 'U') IS NOT NULL
    DROP TABLE dbo.Cleaned_AAPL;
GO

IF OBJECT_ID('dbo.Cleaned_JNJ', 'U') IS NOT NULL
    DROP TABLE dbo.Cleaned_JNJ;
GO

IF OBJECT_ID('dbo.Cleaned_JPM', 'U') IS NOT NULL
    DROP TABLE dbo.Cleaned_JPM;
GO

IF OBJECT_ID('dbo.Cleaned_MSFT', 'U') IS NOT NULL
    DROP TABLE dbo.Cleaned_MSFT;
GO

IF OBJECT_ID('dbo.Cleaned_SPY', 'U') IS NOT NULL
    DROP TABLE dbo.Cleaned_SPY;
GO

IF OBJECT_ID('dbo.Cleaned_VTI', 'U') IS NOT NULL
    DROP TABLE dbo.Cleaned_VTI;
GO

IF OBJECT_ID('dbo.Cleaned_EURUSD', 'U') IS NOT NULL
    DROP TABLE dbo.Cleaned_EURUSD;
GO

IF OBJECT_ID('dbo.Cleaned_USDJPY', 'U') IS NOT NULL
    DROP TABLE dbo.Cleaned_USDJPY;
GO

IF OBJECT_ID('dbo.Cleaned_NDX', 'U') IS NOT NULL
    DROP TABLE dbo.Cleaned_NDX;
GO

-- Create cleaned data tables for each asset

CREATE TABLE Cleaned_AAPL (
    Date DATE,
    Volume FLOAT,
    VolumeWeightedAvgPrice FLOAT,
    OpenPrice FLOAT,
    ClosePrice FLOAT,
    HighestPrice FLOAT,
    LowestPrice FLOAT,
    UnixTimestamp BIGINT,
    NumberOfTransactions INT
);
GO

CREATE TABLE Cleaned_JNJ (
    Date DATE,
    Volume FLOAT,
    VolumeWeightedAvgPrice FLOAT,
    OpenPrice FLOAT,
    ClosePrice FLOAT,
    HighestPrice FLOAT,
    LowestPrice FLOAT,
    UnixTimestamp BIGINT,
    NumberOfTransactions INT
);
GO

CREATE TABLE Cleaned_JPM (
    Date DATE,
    Volume FLOAT,
    VolumeWeightedAvgPrice FLOAT,
    OpenPrice FLOAT,
    ClosePrice FLOAT,
    HighestPrice FLOAT,
    LowestPrice FLOAT,
    UnixTimestamp BIGINT,
    NumberOfTransactions INT
);
GO

CREATE TABLE Cleaned_MSFT (
    Date DATE,
    Volume FLOAT,
    VolumeWeightedAvgPrice FLOAT,
    OpenPrice FLOAT,
    ClosePrice FLOAT,
    HighestPrice FLOAT,
    LowestPrice FLOAT,
    UnixTimestamp BIGINT,
    NumberOfTransactions INT
);
GO

CREATE TABLE Cleaned_SPY (
    Date DATE,
    Volume FLOAT,
    VolumeWeightedAvgPrice FLOAT,
    OpenPrice FLOAT,
    ClosePrice FLOAT,
    HighestPrice FLOAT,
    LowestPrice FLOAT,
    UnixTimestamp BIGINT,
    NumberOfTransactions INT
);
GO

CREATE TABLE Cleaned_VTI (
    Date DATE,
    Volume FLOAT,
    VolumeWeightedAvgPrice FLOAT,
    OpenPrice FLOAT,
    ClosePrice FLOAT,
    HighestPrice FLOAT,
    LowestPrice FLOAT,
    UnixTimestamp BIGINT,
    NumberOfTransactions INT
);
GO

CREATE TABLE Cleaned_EURUSD (
    Date DATE,
    Volume FLOAT,
    VolumeWeightedAvgPrice FLOAT,
    OpenPrice FLOAT,
    ClosePrice FLOAT,
    HighestPrice FLOAT,
    LowestPrice FLOAT,
    UnixTimestamp BIGINT,
    NumberOfTransactions INT
);
GO

CREATE TABLE Cleaned_USDJPY (
    Date DATE,
    Volume FLOAT,
    VolumeWeightedAvgPrice FLOAT,
    OpenPrice FLOAT,
    ClosePrice FLOAT,
    HighestPrice FLOAT,
    LowestPrice FLOAT,
    UnixTimestamp BIGINT,
    NumberOfTransactions INT
);
GO

CREATE TABLE Cleaned_NDX (
    Date DATE,
    OpenPrice FLOAT,
    ClosePrice FLOAT,
    HighestPrice FLOAT,
    LowestPrice FLOAT,
    UnixTimestamp BIGINT
);
GO

-- Select all statements to verify data
SELECT * FROM Cleaned_AAPL;
SELECT * FROM Cleaned_JNJ;
SELECT * FROM Cleaned_JPM;
SELECT * FROM Cleaned_MSFT;
SELECT * FROM Cleaned_SPY;
SELECT * FROM Cleaned_VTI;
SELECT * FROM Cleaned_EURUSD;
SELECT * FROM Cleaned_USDJPY;
SELECT * FROM Cleaned_NDX;
