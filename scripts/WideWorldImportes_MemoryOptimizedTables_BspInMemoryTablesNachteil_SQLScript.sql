/*

Beispiel: In Memory Table als Nachteil bei großen analytischen Abfrage mit Aggregation und Sortierung
Gruppierung (group by) und Sortierung (order by)
Grosser Aufwand für Sort / Aggregation vor allem bei vielen Zeilen (~ 3.65 Mio)
Wenig Paralellität, wenig Schreiboperationen

Bereits erstellte in Memory Tabellen aus Script https://github.com/vjaeggi/MemoryOptimizedTables_SQL/blob/main/scripts/WideWorldImportes_MemoryOptimizedTables_SQLScript.sql wird wiederverwendet 

Output: - Durchschnittstemperaturen pro Sensor



*/


USE WideWorldImporters;
GO



/* beide Tabellen einmal „anlesen“, damit sie im Buffer Cache liegen.  (Disk ≈ RAM).*/

SELECT COUNT(*) AS Anzahl_Count_Disk
FROM Warehouse.ColdRoomTemperatures_Archive;

SELECT COUNT(*) AS Anzahl_InMemory
FROM Warehouse.ColdRoomTemperatures_Archive_InMemoryT;

/*CREATE NONCLUSTERED COLUMNSTORE INDEX IX_ColdRoom_Archive_CCI
ON Warehouse.ColdRoomTemperatures_Archive
(
    ColdRoomSensorNumber,
    RecordedWhen,
    Temperature
);*/


SET NOCOUNT ON;
SET STATISTICS TIME ON;   

GO


PRINT 'Disk-based table – Aggregation (Durchschnittstemperaturen pro Sensor)';

SELECT 
    ColdRoomSensorNumber,
    AVG(Temperature) AS AvgTemperature,
    MIN(RecordedWhen) AS FirstMeasurement,
    MAX(RecordedWhen) AS LastMeasurement
FROM Warehouse.ColdRoomTemperatures_Archive
GROUP BY ColdRoomSensorNumber
ORDER BY ColdRoomSensorNumber;
GO


PRINT 'Memory-optimized table – Aggregation (Durchschnittstemperaturen pro Sensor)';

SELECT 
    ColdRoomSensorNumber,
    AVG(Temperature) AS AvgTemperature,
    MIN(RecordedWhen) AS FirstMeasurement,
    MAX(RecordedWhen) AS LastMeasurement
FROM Warehouse.ColdRoomTemperatures_Archive_InMemoryT
GROUP BY ColdRoomSensorNumber
ORDER BY ColdRoomSensorNumber;
GO


SET STATISTICS TIME OFF;   

GO