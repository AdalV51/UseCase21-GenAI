SELECT
    ProductName,
    ((SalesRevenue - LAG (SalesRevenue) OVER (PARTITION BY ProductName ORDER BY Year, Quarter ASC)) / LAG (SalesRevenue) OVER (PARTITION BY ProductName ORDER BY Year, Quarter ASC)) * 100 AS GrowthRevenueRate,
    ((SalesQuantity - LAG (SalesQuantity) OVER (PARTITION BY ProductName ORDER BY Year, Quarter ASC)) / LAG (SalesQuantity) OVER (PARTITION BY ProductName ORDER BY Year, Quarter ASC)) * 100 AS GrowthQuantityRate,
    Quarter AS CurrentQuarter,
    Year AS CurrentYear,
    LAG (Quarter) OVER (PARTITION BY ProductName ORDER BY Year, Quarter ASC) AS PreviousQuarter,
    LAG (Year) OVER (PARTITION BY ProductName ORDER BY Year, Quarter ASC) AS PreviousYear
FROM (
    SELECT
        DATEPART(q, [FS].[Invoice Date Key]) AS [Quarter],
        DATEPART(year, [FS].[Invoice Date Key]) AS [Year],
        [DSI].[Stock Item] AS ProductName,
        CAST(SUM([FS].[Quantity]) AS DECIMAL) AS SalesQuantity,
        SUM([FS].[Quantity] * [FS].[Unit Price]) AS SalesRevenue
    FROM [Dimension].[Stock Item] DSI
    JOIN [Fact].[Sale] FS ON [DSI].[Stock Item Key] = [FS].[Stock Item Key]
    GROUP BY DATEPART(year, [FS].[Invoice Date Key]),DATEPART(q, [FS].[Invoice Date Key]), [DSI].[Stock Item]
) cte
