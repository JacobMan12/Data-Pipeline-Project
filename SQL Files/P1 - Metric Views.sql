USE [Project 1];
GO


--*******************
--Deletion Statements
--*******************


-- Portfolio Metrics
IF OBJECT_ID('dbo.vwPortfolioReturns', 'V') IS NOT NULL
    DROP VIEW dbo.vwPortfolioReturns;
GO

IF OBJECT_ID('dbo.vwAggregatedPortfolio', 'V') IS NOT NULL
    DROP VIEW dbo.vwAggregatedPortfolio;
GO

IF OBJECT_ID('dbo.vwCumulativeReturns', 'V') IS NOT NULL
    DROP VIEW dbo.vwCumulativeReturns;
GO

IF OBJECT_ID('dbo.vwAnnualizedReturns', 'V') IS NOT NULL
    DROP VIEW dbo.vwAnnualizedReturns;
GO

IF OBJECT_ID('dbo.vwPortfolioVolatility', 'V') IS NOT NULL
    DROP VIEW dbo.vwPortfolioVolatility;
GO

IF OBJECT_ID('dbo.vwSharpeRatio', 'V') IS NOT NULL
    DROP VIEW dbo.vwSharpeRatio;
GO

-- Stocks and ETFs Metrics
IF OBJECT_ID('dbo.vwStockETFTotalReturn', 'V') IS NOT NULL
    DROP VIEW dbo.vwStockETFTotalReturn;
GO

IF OBJECT_ID('dbo.vwStockETFCumulativeReturn', 'V') IS NOT NULL
    DROP VIEW dbo.vwStockETFCumulativeReturn;
GO

IF OBJECT_ID('dbo.vwStockETFVolatility', 'V') IS NOT NULL
    DROP VIEW dbo.vwStockETFVolatility;
GO

IF OBJECT_ID('dbo.vwStockETFMovingAverages', 'V') IS NOT NULL
    DROP VIEW dbo.vwStockETFMovingAverages;
GO

IF OBJECT_ID('dbo.vwStockETFSharpeRatio', 'V') IS NOT NULL
    DROP VIEW dbo.vwStockETFSharpeRatio;
GO

IF OBJECT_ID('dbo.vwStockETFReturnsWithNDX', 'V') IS NOT NULL
    DROP VIEW dbo.vwStockETFReturnsWithNDX;
GO

IF OBJECT_ID('dbo.vwStockETFCovariance', 'V') IS NOT NULL
    DROP VIEW dbo.vwStockETFCovariance;
GO

IF OBJECT_ID('dbo.vwStockETFBeta', 'V') IS NOT NULL
    DROP VIEW dbo.vwStockETFBeta;
GO

-- Indices Metrics
IF OBJECT_ID('dbo.vwNDXPriceIndex', 'V') IS NOT NULL
    DROP VIEW dbo.vwNDXPriceIndex;
GO

IF OBJECT_ID('dbo.vwNDXReturns', 'V') IS NOT NULL
    DROP VIEW dbo.vwNDXReturns;
GO

IF OBJECT_ID('dbo.vwNDXVolatility', 'V') IS NOT NULL
    DROP VIEW dbo.vwNDXVolatility;
GO

IF OBJECT_ID('dbo.vwAAPLReturns', 'V') IS NOT NULL
    DROP VIEW dbo.vwAAPLReturns;
GO

IF OBJECT_ID('dbo.vwAAPL_NDXComparison', 'V') IS NOT NULL
    DROP VIEW dbo.vwAAPL_NDXComparison;
GO

-- Forex Metrics
IF OBJECT_ID('dbo.vwForexReturns', 'V') IS NOT NULL
    DROP VIEW dbo.vwForexReturns;
GO

IF OBJECT_ID('dbo.vwForexCumulativeReturns', 'V') IS NOT NULL
    DROP VIEW dbo.vwForexCumulativeReturns;
GO

IF OBJECT_ID('dbo.vwForexPercentageChange', 'V') IS NOT NULL
    DROP VIEW dbo.vwForexPercentageChange;
GO











--*****************
--Portfolio Metrics
--*****************

-- Create vwPortfolioReturns to calculate daily returns for each asset
CREATE VIEW vwPortfolioReturns AS
WITH PortfolioReturns AS (
    SELECT 
        f.Date,
        a.AssetID,
        a.AssetType,
        a.Ticker,
        a.MarketIndex,
        al.AllocationAmount,
        LAG(f.ClosePrice) OVER (PARTITION BY f.AssetID ORDER BY f.Date) AS PreviousClosePrice,
        f.ClosePrice,
        CASE 
            WHEN LAG(f.ClosePrice) OVER (PARTITION BY f.AssetID ORDER BY f.Date) = 0 THEN NULL
            ELSE (f.ClosePrice - LAG(f.ClosePrice) OVER (PARTITION BY f.AssetID ORDER BY f.Date)) / LAG(f.ClosePrice) OVER (PARTITION BY f.AssetID ORDER BY f.Date)
        END AS [Return],
        CASE 
            WHEN LAG(f.ClosePrice) OVER (PARTITION BY f.AssetID ORDER BY f.Date) = 0 THEN NULL
            ELSE al.AllocationAmount * ((f.ClosePrice - LAG(f.ClosePrice) OVER (PARTITION BY f.AssetID ORDER BY f.Date)) / LAG(f.ClosePrice) OVER (PARTITION BY f.AssetID ORDER BY f.Date))
        END AS WeightedReturn
    FROM FactInvestmentMetrics f
    JOIN DimAssets a ON f.AssetID = a.AssetID
    JOIN AssetAllocation al ON a.AssetID = al.AssetID
)
SELECT *
FROM PortfolioReturns;
GO






-- Create vwAggregatedPortfolio to calculate the total return of the portfolio for each day
CREATE VIEW vwAggregatedPortfolio AS
WITH AggregatedPortfolio AS (
    SELECT
        Date,
        SUM(WeightedReturn) AS PortfolioReturn,
        SUM(al.AllocationAmount) AS TotalWeight
    FROM vwPortfolioReturns pr
    JOIN AssetAllocation al ON pr.AssetID = al.AssetID
    GROUP BY Date
)
SELECT 
    Date,
    PortfolioReturn / NULLIF(TotalWeight, 0) AS PortfolioReturn
FROM AggregatedPortfolio;
GO





-- Create vwCumulativeReturns to calculate the cumulative return of the portfolio
CREATE VIEW vwCumulativeReturns AS
WITH CumulativeReturns AS (
    SELECT 
        Date,
        PortfolioReturn,
        EXP(SUM(LOG(1 + PortfolioReturn)) OVER (ORDER BY Date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)) - 1 AS CumulativeReturn
    FROM vwAggregatedPortfolio
)
SELECT *
FROM CumulativeReturns;
GO





-- Create vwAnnualizedReturns to calculate the annualized return of the portfolio
CREATE VIEW vwAnnualizedReturns AS
WITH AnnualizedReturns AS (
    SELECT 
        Date,
        PortfolioReturn,
        EXP(SUM(LOG(1 + PortfolioReturn)) OVER (ORDER BY Date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)) - 1 AS CumulativeReturn
    FROM vwAggregatedPortfolio
),
Annualized AS (
    SELECT 
        Date,
        PortfolioReturn,
        CumulativeReturn,
        CASE 
            WHEN DATEDIFF(DAY, MIN(Date) OVER (), Date) = 0 THEN NULL
            ELSE POWER(1 + CumulativeReturn, 365.0 / DATEDIFF(DAY, MIN(Date) OVER (), Date)) - 1
        END AS AnnualizedReturn
    FROM AnnualizedReturns
)
SELECT *
FROM Annualized;
GO





-- Create vwPortfolioVolatility to calculate the volatility of the portfolio
CREATE VIEW vwPortfolioVolatility AS
WITH PortfolioVolatility AS (
    SELECT 
        Date,
        PortfolioReturn,
        STDEV(PortfolioReturn) OVER (ORDER BY Date ROWS BETWEEN 29 PRECEDING AND CURRENT ROW) AS PortfolioVolatility
    FROM vwAggregatedPortfolio
)
SELECT *
FROM PortfolioVolatility;
GO




-- Create vwSharpeRatio to calculate the Sharpe Ratio of the portfolio
CREATE VIEW vwSharpeRatio AS
WITH SharpeRatio AS (
    SELECT 
        Date,
        PortfolioReturn,
        PortfolioVolatility,
        (AVG(PortfolioReturn) OVER (ORDER BY Date) - 0.02) / NULLIF(PortfolioVolatility, 0) AS SharpeRatio -- Assuming a risk-free rate of 2%
    FROM vwPortfolioVolatility
)
SELECT *
FROM SharpeRatio;
GO





--Tests for Portfolio Metrics:

-- Verify vwPortfolioReturns
SELECT * FROM vwPortfolioReturns;
GO

-- Verify vwAggregatedPortfolio
SELECT * FROM vwAggregatedPortfolio;
GO

-- Verify vwCumulativeReturns
SELECT * FROM vwCumulativeReturns;
GO

-- Verify vwAnnualizedReturns
SELECT * FROM vwAnnualizedReturns;
GO

-- Test the view
SELECT * FROM vwPortfolioVolatility;
GO

-- Verify vwSharpeRatio
SELECT * FROM vwSharpeRatio;
GO












--***********************
--Stocks and ETFs Metrics
--***********************


-- Create vwStockETFTotalReturn to calculate the total return for each stock and ETF
CREATE VIEW vwStockETFTotalReturn AS
WITH StockETFReturns AS (
    SELECT 
        f.Date,
        a.AssetID,
        a.Ticker,
        a.AssetType,
        LAG(f.ClosePrice) OVER (PARTITION BY f.AssetID ORDER BY f.Date) AS PreviousClosePrice,
        f.ClosePrice,
        CASE 
            WHEN LAG(f.ClosePrice) OVER (PARTITION BY f.AssetID ORDER BY f.Date) IS NULL THEN NULL
            ELSE (f.ClosePrice - LAG(f.ClosePrice) OVER (PARTITION BY f.AssetID ORDER BY f.Date)) / LAG(f.ClosePrice) OVER (PARTITION BY f.AssetID ORDER BY f.Date)
        END AS TotalReturn
    FROM FactInvestmentMetrics f
    JOIN DimAssets a ON f.AssetID = a.AssetID
    WHERE a.AssetType IN ('Stock', 'ETF')
)
SELECT *
FROM StockETFReturns;
GO





-- Create vwStockETFCumulativeReturn to calculate the cumulative return for each stock and ETF
CREATE VIEW vwStockETFCumulativeReturn AS
WITH StockETFCumulative AS (
    SELECT 
        Date,
        AssetID,
        Ticker,
        AssetType,
        TotalReturn,
        EXP(SUM(LOG(1 + TotalReturn)) OVER (PARTITION BY AssetID ORDER BY Date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)) - 1 AS CumulativeReturn
    FROM vwStockETFTotalReturn
)
SELECT *
FROM StockETFCumulative;
GO



-- Create vwStockETFVolatility to calculate the volatility for each stock and ETF
CREATE VIEW vwStockETFVolatility AS
WITH StockETFVolatility AS (
    SELECT 
        Date,
        AssetID,
        Ticker,
        AssetType,
        TotalReturn,
        STDEV(TotalReturn) OVER (PARTITION BY AssetID ORDER BY Date ROWS BETWEEN 29 PRECEDING AND CURRENT ROW) AS Volatility
    FROM vwStockETFTotalReturn
)
SELECT *
FROM StockETFVolatility;
GO




-- Create vwStockETFMovingAverages to calculate the 10-day and 100-day moving averages for each stock and ETF
CREATE VIEW vwStockETFMovingAverages AS
WITH StockETFMovingAverages AS (
    SELECT 
        f.Date,
        a.AssetID,
        a.Ticker,
        a.AssetType,
        f.ClosePrice,
        AVG(f.ClosePrice) OVER (PARTITION BY f.AssetID ORDER BY f.Date ROWS BETWEEN 9 PRECEDING AND CURRENT ROW) AS MovingAvg10Day,
        AVG(f.ClosePrice) OVER (PARTITION BY f.AssetID ORDER BY f.Date ROWS BETWEEN 99 PRECEDING AND CURRENT ROW) AS MovingAvg100Day
    FROM FactInvestmentMetrics f
    JOIN DimAssets a ON f.AssetID = a.AssetID
    WHERE a.AssetType IN ('Stock', 'ETF')
)
SELECT *
FROM StockETFMovingAverages;
GO




-- Create vwStockETFSharpeRatio to calculate the Sharpe Ratio for each stock and ETF
CREATE VIEW vwStockETFSharpeRatio AS
WITH StockETFSharpe AS (
    SELECT 
        Date,
        AssetID,
        Ticker,
        AssetType,
        TotalReturn,
        Volatility,
        (AVG(TotalReturn) OVER (PARTITION BY AssetID ORDER BY Date) - 0.02) / NULLIF(Volatility, 0) AS SharpeRatio -- Assuming a risk-free rate of 2%
    FROM vwStockETFVolatility
)
SELECT *
FROM StockETFSharpe;
GO




-- Create vwStockETFReturnsWithNDX to join stock and ETF returns with NDX returns
CREATE OR ALTER VIEW vwStockETFReturnsWithNDX AS
SELECT 
    f.Date,
    f.AssetID,
    da.Ticker,
    da.AssetType,
    f.ClosePrice,
    ndx.ClosePrice AS NDXClosePrice,
    LAG(f.ClosePrice) OVER (PARTITION BY f.AssetID ORDER BY f.Date) AS PreviousClosePrice,
    ndx.PreviousClosePrice AS PreviousNDXClosePrice,
    (f.ClosePrice - LAG(f.ClosePrice) OVER (PARTITION BY f.AssetID ORDER BY f.Date)) / LAG(f.ClosePrice) OVER (PARTITION BY f.AssetID ORDER BY f.Date) AS StockReturn,
    ndx.[Return] AS NDXReturn
FROM FactInvestmentMetrics f
JOIN DimAssets da ON f.AssetID = da.AssetID
JOIN vwNDXReturns ndx ON f.Date = ndx.Date
WHERE da.AssetType IN ('Stock', 'ETF');
GO




-- Create vwStockETFCovariance to calculate the covariance and variance for Beta calculation
CREATE OR ALTER VIEW vwStockETFCovariance AS
WITH CovarianceData AS (
    SELECT 
        f.Date,
        f.AssetID,
        da.Ticker,
        da.AssetType,
        f.StockReturn,
        f.NDXReturn,
        AVG(f.StockReturn) OVER (PARTITION BY f.AssetID ORDER BY f.Date) AS AvgStockReturn,
        AVG(f.NDXReturn) OVER (PARTITION BY f.AssetID ORDER BY f.Date) AS AvgNDXReturn
    FROM vwStockETFReturnsWithNDX f
    JOIN DimAssets da ON f.AssetID = da.AssetID
),
CovarianceCalc AS (
    SELECT
        Date,
        AssetID,
        Ticker,
        AssetType,
        StockReturn,
        NDXReturn,
        AvgStockReturn,
        AvgNDXReturn,
        (StockReturn - AvgStockReturn) * (NDXReturn - AvgNDXReturn) AS CovarianceTerm,
        POWER(NDXReturn - AvgNDXReturn, 2) AS NDXVarianceTerm
    FROM CovarianceData
),
CovarianceAgg AS (
    SELECT
        Date,
        AssetID,
        Ticker,
        AssetType,
        SUM(CovarianceTerm) OVER (PARTITION BY AssetID ORDER BY Date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS Covariance,
        SUM(NDXVarianceTerm) OVER (PARTITION BY AssetID ORDER BY Date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS NDXVariance
    FROM CovarianceCalc
)
SELECT
    Date,
    AssetID,
    Ticker,
    AssetType,
    Covariance,
    NDXVariance
FROM CovarianceAgg;
GO





-- Create vwStockETFBeta to calculate the Beta for each stock and ETF
CREATE OR ALTER VIEW vwStockETFBeta AS
WITH StockETFBeta AS (
    SELECT 
        Date,
        AssetID,
        Ticker,
        AssetType,
        Covariance,
        NDXVariance,
        CASE 
            WHEN NDXVariance != 0 THEN Covariance / NDXVariance
            ELSE NULL
        END AS Beta
    FROM vwStockETFCovariance
)
SELECT
    Date,
    AssetID,
    Ticker,
    AssetType,
    Beta
FROM StockETFBeta;
GO







--Test for Stocks and ETFs metrics:

-- Test the view for Total Return
SELECT * FROM vwStockETFTotalReturn;
GO

-- Test the view for Cumulative Return
SELECT * FROM vwStockETFCumulativeReturn;
GO

-- Test the view for Volatility
SELECT * FROM vwStockETFVolatility;
GO

-- Test the view for Moving Averages
SELECT * FROM vwStockETFMovingAverages;
GO

-- Test the view for Sharpe Ratio
SELECT * FROM vwStockETFSharpeRatio;
GO

-- Test the view for Stock and ETF returns with NDX
SELECT * FROM vwStockETFReturnsWithNDX;
GO

-- Test the view for Covariance
SELECT * FROM vwStockETFCovariance;
GO

-- Test the view for Beta
SELECT * FROM vwStockETFBeta;
GO













--****************
--Indices Metrics
--****************

-- Create vwNDXPriceIndex to calculate the price index for the NDX
CREATE VIEW vwNDXPriceIndex AS
SELECT 
    Date,
    ClosePrice AS PriceIndex
FROM Cleaned_NDX;
GO




-- Create vwNDXReturns to calculate daily returns for NDX
CREATE VIEW vwNDXReturns AS
WITH NDXReturns AS (
    SELECT 
        Date,
        ClosePrice,
        LAG(ClosePrice) OVER (ORDER BY Date) AS PreviousClosePrice,
        CASE 
            WHEN LAG(ClosePrice) OVER (ORDER BY Date) IS NULL THEN NULL
            ELSE (ClosePrice - LAG(ClosePrice) OVER (ORDER BY Date)) / LAG(ClosePrice) OVER (ORDER BY Date)
        END AS [Return]
    FROM Cleaned_NDX
)
SELECT *
FROM NDXReturns;
GO


-- Create vwNDXVolatility to calculate the volatility for the NDX
CREATE VIEW vwNDXVolatility AS
WITH NDXVolatility AS (
    SELECT 
        Date,
        [Return],
        STDEV([Return]) OVER (ORDER BY Date ROWS BETWEEN 29 PRECEDING AND CURRENT ROW) AS Volatility
    FROM vwNDXReturns
)
SELECT 
    Date,
    Volatility
FROM NDXVolatility;
GO




-- Create vwAAPLReturns to calculate daily returns for AAPL
CREATE OR ALTER VIEW vwAAPLReturns AS
WITH AAPLReturns AS (
    SELECT 
        f.Date,
        f.ClosePrice AS AAPLPrice,
        LAG(f.ClosePrice) OVER (ORDER BY f.Date) AS PreviousAAPLPrice,
        CASE 
            WHEN LAG(f.ClosePrice) OVER (ORDER BY f.Date) IS NULL THEN NULL
            ELSE (f.ClosePrice - LAG(f.ClosePrice) OVER (ORDER BY f.Date)) / LAG(f.ClosePrice) OVER (ORDER BY f.Date)
        END AS AAPLReturn
    FROM FactInvestmentMetrics f
    JOIN DimAssets da ON f.AssetID = da.AssetID
    WHERE da.Ticker = 'AAPL'
)
SELECT * FROM AAPLReturns;
GO

-- Create vwNDXReturns to calculate daily returns for NDX (assuming it's already created)
-- SELECT * FROM vwNDXReturns;

-- Create vwAAPL_NDXComparison to compare AAPL to NDX
CREATE OR ALTER VIEW vwAAPL_NDXComparison AS
WITH AAPL_NDXComparison AS (
    SELECT 
        a.Date,
        a.AAPLPrice,
        n.ClosePrice AS NDXPrice,
        a.AAPLReturn,
        n.[Return] AS NDXReturn
    FROM vwAAPLReturns a
    JOIN vwNDXReturns n ON a.Date = n.Date
)
SELECT 
    Date,
    AAPLPrice,
    NDXPrice,
    AAPLReturn,
    NDXReturn
FROM AAPL_NDXComparison;
GO


--Testing for Indices:

-- Verify vwNDXPriceIndex
SELECT * FROM vwNDXPriceIndex;
GO

-- Verify vwNDXReturns
SELECT * FROM vwNDXReturns;
GO

-- Verify vwNDXVolatility
SELECT * FROM vwNDXVolatility;
GO

-- Verify vwAAPLReturns
SELECT * FROM vwAAPLReturns;
GO

-- Verify vwNDXComparison
SELECT * FROM vwAAPL_NDXComparison;
GO






--***************
-- Forex Metrics
--***************

-- Create vwForexReturns to calculate daily returns for Forex pairs
CREATE VIEW vwForexReturns AS
WITH ForexReturns AS (
    SELECT 
        f.Date,
        a.AssetID,
        a.Ticker,
        a.AssetType,
        f.ClosePrice,
        LAG(f.ClosePrice) OVER (PARTITION BY f.AssetID ORDER BY f.Date) AS PreviousClosePrice,
        CASE 
            WHEN LAG(f.ClosePrice) OVER (PARTITION BY f.AssetID ORDER BY f.Date) IS NULL THEN NULL
            ELSE (f.ClosePrice - LAG(f.ClosePrice) OVER (PARTITION BY f.AssetID ORDER BY f.Date)) / LAG(f.ClosePrice) OVER (PARTITION BY f.AssetID ORDER BY f.Date)
        END AS [Return]
    FROM FactInvestmentMetrics f
    JOIN DimAssets a ON f.AssetID = a.AssetID
    WHERE a.AssetType = 'Forex'
)
SELECT *
FROM ForexReturns;
GO







-- Create vwForexCumulativeReturns to calculate the cumulative return for Forex pairs
CREATE OR ALTER VIEW vwForexCumulativeReturns AS
WITH ForexCumulativeReturns AS (
    SELECT 
        f.Date,
        f.AssetID,
        a.Ticker,
        f.[Return],
        EXP(SUM(LOG(1 + f.[Return])) OVER (PARTITION BY f.AssetID ORDER BY f.Date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)) - 1 AS CumulativeReturn
    FROM vwForexReturns f
    JOIN DimAssets a ON f.AssetID = a.AssetID
)
SELECT 
    Date,
    AssetID,
    Ticker,
    CumulativeReturn
FROM ForexCumulativeReturns;
GO



-- Create vwForexPercentageChange to calculate the percentage change for Forex pairs
CREATE VIEW vwForexPercentageChange AS
WITH ForexPercentageChange AS (
    SELECT 
        f.Date,
        f.AssetID,
        a.Ticker,
        f.ClosePrice,
        LAG(f.ClosePrice) OVER (PARTITION BY f.AssetID ORDER BY f.Date) AS PreviousClosePrice,
        CASE 
            WHEN LAG(f.ClosePrice) OVER (PARTITION BY f.AssetID ORDER BY f.Date) IS NULL THEN NULL
            ELSE (f.ClosePrice - LAG(f.ClosePrice) OVER (PARTITION BY f.AssetID ORDER BY f.Date)) / LAG(f.ClosePrice) OVER (PARTITION BY f.AssetID ORDER BY f.Date) * 100
        END AS PercentageChange
    FROM FactInvestmentMetrics f
    JOIN DimAssets a ON f.AssetID = a.AssetID
    WHERE a.AssetType = 'Forex'
)
SELECT *
FROM ForexPercentageChange;
GO



--Testing for Forex Metrics:

-- Verify vwForexReturns
SELECT * FROM vwForexReturns;
GO

-- Verify vwForexCumulativeReturns
SELECT * FROM vwForexCumulativeReturns;
GO

-- Verify vwForexPercentageChange
SELECT * FROM vwForexPercentageChange;
GO