SELECT
    ProductName,
    SalesQuantity,
    SalesRevenue,
    Quarter,
    Year
FROM (
    SELECT
        DATEPART(q, [FS].[Invoice Date Key]) AS [Quarter],
        DATEPART(year, [FS].[Invoice Date Key]) AS [Year],
        [DSI].[Stock Item] AS ProductName,
        SUM([FS].[Quantity]) AS SalesQuantity,
        SUM([FS].[Quantity]) * SUM([FS].[Unit Price]) AS SalesRevenue,
        ROW_NUMBER() OVER(PARTITION BY DATEPART(year, [FS].[Invoice Date Key]), DATEPART(q, [FS].[Invoice Date Key]) ORDER BY SUM([FS].[Quantity]) DESC) AS QuantityPartitioned
    FROM [Dimension].[Stock Item] DSI
    JOIN [Fact].[Sale] FS ON [DSI].[Stock Item Key] = [FS].[Stock Item Key]
    GROUP BY DATEPART(year, [FS].[Invoice Date Key]),DATEPART(q, [FS].[Invoice Date Key]), [DSI].[Stock Item]
) cte
WHERE cte.[QuantityPartitioned] <= 10
