
/*Grösse nach MB*/

SELECT TOP 10
    s.name AS SchemaName,
    t.name AS TableName,
    SUM(a.total_pages) * 8.0 / 1024 AS TotalSizeMB,
    SUM(a.data_pages)  * 8.0 / 1024 AS DataSizeMB,
    SUM(a.used_pages)  * 8.0 / 1024 AS UsedSizeMB
FROM sys.tables t
JOIN sys.schemas s        ON s.schema_id  = t.schema_id
JOIN sys.indexes i        ON i.object_id  = t.object_id
JOIN sys.partitions p     ON p.object_id  = i.object_id
                         AND p.index_id  = i.index_id
JOIN sys.allocation_units a ON a.container_id = p.partition_id
GROUP BY s.name, t.name
ORDER BY TotalSizeMB DESC;

/*Grösste Tabelle MB*/ 
SELECT COUNT(*) FROM WideWorldImporters.Sales.Invoices


/*Grösse nach Row entries*/
SELECT TOP 10 
    s.name  AS SchemaName,
    t.name  AS TableName,
    SUM(p.rows) AS Row_count
FROM sys.tables t
JOIN sys.schemas s     ON s.schema_id  = t.schema_id
JOIN sys.partitions p  ON p.object_id  = t.object_id
                      
GROUP BY s.name, t.name
ORDER BY Row_count DESC;

/*Grösste nach Row entries MB*/ 
SELECT COUNT(*) FROM WideWorldImporters.Warehouse.ColdRoomTemperatures_Archive
-- mit 3'654'736 Einträgen






