WITH total_sales_per_quarter_and_year AS (
    SELECT
        DATEPART(q, [Invoice Date Key]) AS [Quarter],
        DATEPART(year, [Invoice Date Key]) AS [Year],
        SUM([Total Excluding Tax]) AS TotalSales,
        SUM([Quantity]) AS TotalQuantity
    FROM
        [Fact].[Sale]
    GROUP BY DATEPART(year, [Invoice Date Key]), DATEPART(q, [Invoice Date Key])
)

, customer_sales_per_quarter_and_year AS (
    SELECT
        DATEPART(q, [FS].[Invoice Date Key]) AS [Quarter],
        DATEPART(year, [FS].[Invoice Date Key]) AS [Year],
        [DC].[Customer] AS CustomerName,
        CAST(SUM([FS].[Quantity]) AS DECIMAL) AS SalesQuantity,
        SUM([FS].[Quantity] * [FS].[Unit Price]) AS SalesRevenue
    FROM [Fact].[Sale] FS
    JOIN [Dimension].[Customer] DC ON [FS].[Customer Key] = [DC].[Customer Key]
    GROUP BY [DC].[Customer], DATEPART(year, [FS].[Invoice Date Key]), DATEPART(q, [FS].[Invoice Date Key])
)

SELECT
    cs.CustomerName as CustomerName,
    ((cs.SalesRevenue * 100) / TotalSales) AS TotalRevenuePercentage,
    ((cs.SalesQuantity * 100) / TotalQuantity) AS TotalQuantityPercentage,
    cs.[Quarter] as Quarter,
    cs.[Year] as Year
FROM customer_sales_per_quarter_and_year cs
JOIN total_sales_per_quarter_and_year ts 
ON cs.[Quarter] = ts.[Quarter] AND cs.[Year] = ts.[Year]
