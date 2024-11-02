---Tính toán phần trăm thay đổi của mức lương (Rate) giữa lần tăng lương gần nhất và lần trước đó cho từng nhân viên										

WITH CTE AS 
( SELECT
        BusinessEntityID,
        PayRateNumber = ROW_NUMBER() OVER ( PARTITION BY BusinessEntityID ORDER BY RateChangeDate DESC ),
        RateChangeDate,
        Rate
    FROM HumanResources.EmployeePayHistory)
SELECT
    R1.BusinessEntityID,
    PriorRate = R2.Rate,
    LatestRate = R1.Rate,
    PercentChange = CONVERT(VARCHAR(10), (R1.Rate - R2.Rate) / R2.Rate * 100) + '%'
FROM CTE R1
LEFT JOIN CTE R2
    ON R1.BusinessEntityID = R2.BusinessEntityID
    AND R2.PayRateNumber = 2
where R1.PayRateNumber = 1
AND R2.Rate IS NOT NULL;

---Tìm 5 nhân viên bán hàng có doanh thu cao nhất và đồng thời ghép cặp với 5 nhân viên bán hàng có doanh thu thấp nhất trong năm 2013								

WITH SalesRank AS (
    SELECT
        SalesPersonID,
        SalesTotal = SUM(SubTotal),
        SalesRankTopDown = ROW_NUMBER() OVER ( ORDER BY SUM(Subtotal) DESC),
        SalesRankBotUp = ROW_NUMBER() OVER ( ORDER BY SUM(Subtotal) )
    FROM Sales.SalesOrderHeader
    WHERE YEAR(OrderDate) = 2013
    AND SalesPersonID IS NOT NULL
    GROUP BY SalesPersonID
)
SELECT TOP 5
 TopSalesPersonID = N1.SalesPersonID,
    TopRevenue = N1.SalesTotal,
    BotSalesPersonID = N2.SalesPersonID,
    BotRevenue = N2.SalesTotal
FROM SalesRank N1
INNER JOIN SalesRank N2
    ON N1.SalesRankTopDown = N2.SalesRankBotUp
ORDER BY N1.SalesRankTopDown;

---Lấy ra đơn hàng đầu tiên trong mỗi năm 2012, 2013 khi tổng doanh thu cộng dồn từ các đơn hàng vượt quá 10 triệu							
	
WITH CombinedData AS (
    SELECT
        YEAR(OrderDate) AS FiscalYear,
        OrderDate = CAST(OrderDate AS DATE),
        SalesOrderID,
        OrderNumber = ROW_NUMBER() OVER (ORDER BY SalesOrderID),
        RunningTotal = SUM(SubTotal) OVER (
            PARTITION BY YEAR(OrderDate)
            ORDER BY OrderDate, SalesOrderID
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        )
    FROM Sales.SalesOrderHeader
    WHERE YEAR(OrderDate) IN (2012, 2013)
),
RankedOrders AS (
    SELECT
        FiscalYear,
        OrderDate,
        SalesOrderID,
        OrderNumber,
        RunningTotal,
        ROW_NUMBER() OVER (PARTITION BY FiscalYear ORDER BY OrderDate) AS RowNum
    FROM CombinedData
    WHERE RunningTotal >= 10000000
)

SELECT FiscalYear, OrderDate, SalesOrderID, OrderNumber, RunningTotal
FROM RankedOrders
WHERE RowNum = 1; 

--Lấy ra 10% các lệnh sản xuất có tỷ lệ phế phẩm (scrap rate) lớn hơn 3%, sắp xếp theo ngày đáo hạn (DueDate) giảm dần							

WITH WorkOrderData AS (
    SELECT
        WorkOrderID,
        DueDate ,
        ProdName = N2.Name,
        ScrapReason = N3.Name,
        ScrappedQty,
        OrderQty,
        PercScrapped = ROUND(CAST(ScrappedQty AS FLOAT) / OrderQty * 100, 2)
    FROM Production.WorkOrder N1
    JOIN Production.Product N2 ON N1.ProductID = N2.ProductID
    LEFT JOIN Production.ScrapReason N3 ON N1.ScrapReasonID = N3.ScrapReasonID
    WHERE CAST(ScrappedQty AS FLOAT) / OrderQty  > 0.03
)
SELECT TOP (10) PERCENT *
FROM WorkOrderData
ORDER BY DueDate DESC;

