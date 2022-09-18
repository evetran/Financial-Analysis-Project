-- Based on the database I created, I am going to use SQL to answer some questions about financial analysis


-- LOOKING AT THE ^DJI --

-- Calculate number of tickers in ^DJI index
SELECT COUNT(DISTINCT Symbol) FROM DJIA;


-- The ^DJI comprises 30 blue-chip stocks that are tops in their industries. But what are the TOP 3 Dow Jones stocks that are better buys than others?
-- Looking at the TOP 3 stocks of ^DJI that have the most days in which close prices higher than open prices in 2020-2022
SELECT Symbol, COUNT(*) AS days
FROM DJIA d 
WHERE ("Close" > "Open") AND STRFTIME('%Y', Date) BETWEEN '2020' AND '2022' 
GROUP BY Symbol
ORDER BY days DESC 
LIMIT 3;



-- Looking at the change of close price with close price of the date before
SELECT 
	Symbol, Date, Close,
	ROUND((Close - previous_close), 2) AS 'Change',
	ROUND(((Close - previous_close)*100/previous_close),2) AS '%Change',
	CASE 
		WHEN Close > previous_close THEN 'Up'
		WHEN Close < previous_close THEN 'Down'
	END AS 'Indicator'
FROM
	(SELECT 
		Symbol, DATE(date) AS Date, ROUND(Close, 2) AS Close, 
		LAG (Close, 1, 0) OVER (PARTITION  BY Symbol ORDER BY Date) AS previous_close
	FROM DJIA d 
	WHERE STRFTIME('%Y', date) BETWEEN '2020' AND '2022'
	ORDER BY Symbol, date DESC)
	

--Looking at the total yearly trading volume and fundamental information of ^DJI stocks
SELECT 
	d1.Symbol,
	d2.sector,
	d1.Yearly_Aggregrate_Volume,
	d2.totalRevenue,
	d2.revenueGrowth,
	d2.returnOnEquity 
FROM
	(SELECT Symbol, SUM(Volume) AS Yearly_Aggregrate_Volume FROM DJIA GROUP BY Symbol) d1
LEFT JOIN DOWFundamental d2 
ON d1.Symbol = d2.symbol

	
	
	
-- LOOKING AT APPLE STOCK --
	
-- Calculate number of days that close price of AAPL is higher than open price
SELECT COUNT(*) 
FROM DJIA d 
WHERE 
	("Close" > "Open") AND 
	(Symbol = 'AAPL') AND 
	(STRFTIME('%Y', Date) = '2022');


-- Calculate the 50 days moving average of Apple stock
SELECT 
	DATE(Date), 
	Close,
	AVG(Close) OVER (PARTITION BY Symbol ORDER BY Date ROWS 50 PRECEDING) AS MA50
FROM DJIA
WHERE Symbol = 'AAPL' AND (STRFTIME('%Y', Date) BETWEEN '2000' AND '2022')
ORDER BY Date DESC;



-- Compare the 50 days moving average with 100 days moving average of APPL from 2020-2022, 
-- we can judge whether the stock is bullish if MA50 > MA100, or bearish by versa
SELECT 
	DATE(Date) AS Date, ROUND(Close,2), ROUND(MA50, 2) AS MA50, ROUND(MA100, 2) AS MA100,
	CASE 
		WHEN MA50 > MA100 THEN 'Bullish'
		WHEN MA50 < MA100 THEN 'Bearish'
	END AS 'Indicator'
FROM
	(SELECT 
		DATE(Date) AS Date, 
		Close,
		AVG(Close) OVER (PARTITION BY Symbol ORDER BY Date ROWS 50 PRECEDING) AS MA50,
		AVG(Close) OVER (PARTITION BY Symbol ORDER BY Date ROWS 100 PRECEDING) AS MA100
	FROM DJIA
	WHERE Symbol = 'AAPL' AND (STRFTIME('%Y', Date) BETWEEN '2000' AND '2022')) AS i
WHERE STRFTIME('%Y', i.Date) BETWEEN '2020' AND '2022'
ORDER BY Date DESC;



-- Counting the number of days that the close price is higher than close price of the date before 
-- of AAPL stock in 2020
SELECT COUNT(*)
FROM
	(SELECT 
		Symbol, Date, Close,
		ROUND((Close - previous_close), 2) AS 'Change',
		ROUND(((Close - previous_close)*100/previous_close),2) AS '%Change',
		CASE 
			WHEN Close > previous_close THEN 'Up'
			WHEN Close < previous_close THEN 'Down'
		END AS 'Indicator'
	FROM
		(SELECT 
			Symbol, DATE(date) AS Date, ROUND(Close, 2) AS Close, 
			LAG (Close, 1, 0) OVER (PARTITION  BY Symbol ORDER BY Date) AS previous_close
		FROM DJIA d 
		WHERE STRFTIME('%Y', date) = '2022'
		ORDER BY Symbol, date DESC))
WHERE Indicator = 'Up'



-- LOOKING AT MARKETS --

-- Looking at the latest market indexes--
SELECT 
	Symbol, DATE(date) Date, ROUND(Close,2) Value, Volume
FROM 
	markets
WHERE Date = (SELECT MAX(Date) FROM markets)
GROUP BY Symbol 
ORDER BY Date;


-- Looking at the change of close price with close price of the date before
SELECT 
	Symbol, Date, Close, 
	ROUND((Close - previous_close), 2) AS Gain,
	ROUND(((Close - previous_close)*100/previous_close),2) AS '% Change',
	Volume
FROM
	(SELECT 
		Symbol, DATE(date) AS Date, ROUND(Close, 2) AS Close, Volume/1000 AS Volume,
		LAG (Close, 1, 0) OVER (PARTITION  BY Symbol ORDER BY Date) AS previous_close
	FROM markets m  
	WHERE STRFTIME('%Y', date) BETWEEN '2020' AND '2022'
	ORDER BY Symbol, date DESC)
	

-- Looking at the recent change of the market indexes
SELECT 
		Symbol, Date, Close, 
		ROUND((Close - previous_close), 2) AS Gain,
		ROUND(((Close - previous_close)*100/previous_close),2) AS '% Change',
		Volume
FROM
		(SELECT 
			Symbol, DATE(date) AS Date, ROUND(Close, 2) AS Close, Volume/1000 AS Volume,
			LAG (Close, 1, 0) OVER (PARTITION  BY Symbol ORDER BY Date) AS previous_close
		FROM markets m  
		WHERE STRFTIME('%Y', date) BETWEEN '2020' AND '2022'
		ORDER BY date DESC)
LIMIT 3;




-- Extract data for visualization
-- DJIA Historical Prices and Moving Average 
SELECT 
	*,
	AVG(Close) OVER (PARTITION BY Symbol ORDER BY Date ROWS 50 PRECEDING) AS MA50,
	AVG(Close) OVER (PARTITION BY Symbol ORDER BY Date ROWS 100 PRECEDING) AS MA100,
	AVG(Close) OVER (PARTITION BY Symbol ORDER BY Date ROWS 200 PRECEDING) AS MA200
FROM DJIA
WHERE STRFTIME('%Y', Date) >= '2000';


--DJIA Fundamental Information
SELECT * FROM DOWFundamental


-- TSX60
SELECT 
	*,
	AVG(Close) OVER (PARTITION BY Symbol ORDER BY Date ROWS 50 PRECEDING) AS MA50,
	AVG(Close) OVER (PARTITION BY Symbol ORDER BY Date ROWS 100 PRECEDING) AS MA100,
	AVG(Close) OVER (PARTITION BY Symbol ORDER BY Date ROWS 200 PRECEDING) AS MA200
FROM TSX60 
WHERE STRFTIME('%Y', Date) >= '2000';


-- TSX60 Fundamental Information
SELECT * FROM TSX60Fundamental;


-- Market information
SELECT 
	*,
	AVG(Close) OVER (PARTITION BY Symbol ORDER BY Date ROWS 50 PRECEDING) AS MA50,
	AVG(Close) OVER (PARTITION BY Symbol ORDER BY Date ROWS 100 PRECEDING) AS MA100,
	AVG(Close) OVER (PARTITION BY Symbol ORDER BY Date ROWS 200 PRECEDING) AS MA200
FROM markets
WHERE STRFTIME('%Y', Date) >= '2000';

