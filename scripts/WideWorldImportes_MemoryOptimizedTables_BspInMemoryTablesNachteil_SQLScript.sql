/*
Ziel: Aufzeigen, wo der in memory table (MOT) einen Nachteil haben kann.

Fazit: Ein klarer Fall, wo die disk table schneller sein kann als MOT, ist ein Lookup auf nicht vorhandenen Datensatz (negative lookup) – hier entsteht Overhead ohne Nutzen.

Weiteres mögliches Beispiel: analytische Abfrage mit Aggregation und Sortierung (GROUP BY / ORDER BY). 
In dem zweiten Beispiem mit 3.65 Mio Zeilen (inkl. Indexes) war die Datenmenge/Query jedoch zu wenig ausgeprägt, 
um einen stabilen Vorteil der disk table gegenüber dem in memory table zu zeigen.


*/


SET NOCOUNT ON;
SET STATISTICS TIME ON;   
SET STATISTICS IO ON
SET STATISTICS XML ON;

USE WideWorldImporters;
GO


/*Einziges Beispiel wo Disk Table schneller ist als MOT 
ist wenn der Datensatz nicht vorhanden ist*/

PRINT CHAR(10) + '*** GROUP BY + AGG (letzte 24h) ***';
PRINT CHAR(10) + 'Disk-based table ';
SELECT 
    ColdRoomSensorNumber,
    AVG(Temperature) AS AvgTemp,
    COUNT(*) AS RecordCount,
    MIN(RecordedWhen) AS FirstReading,
    MAX(RecordedWhen) AS LastReading
FROM Warehouse.ColdRoomTemperatures_Archive
WHERE RecordedWhen >= DATEADD(HOUR, -24, SYSDATETIME())
GROUP BY ColdRoomSensorNumber
ORDER BY ColdRoomSensorNumber;

PRINT CHAR(10) + 'Memory-optimized table ';
SELECT 
    ColdRoomSensorNumber,
    AVG(Temperature) AS AvgTemp,
    COUNT(*) AS RecordCount,
    MIN(RecordedWhen) AS FirstReading,
    MAX(RecordedWhen) AS LastReading
FROM Warehouse.ColdRoomTemperatures_Archive_InMemoryT
WHERE RecordedWhen >= DATEADD(HOUR, -24, SYSDATETIME())
GROUP BY ColdRoomSensorNumber



PRINT CHAR(10) + '*** POINT LOOKUP + RANGE SCAN ***';
PRINT 'Disk-based table  - Datensatz nicht vorhanden';
SELECT COUNT(*), AVG(Temperature) 
FROM Warehouse.ColdRoomTemperatures_Archive 
WHERE ColdRoomSensorNumber = 2
  AND RecordedWhen BETWEEN '2020-01-01' AND '2020-01-02';

PRINT 'Memory-optimized table - Datensatz nicht vorhanden';
SELECT COUNT(*), AVG(Temperature)
FROM Warehouse.ColdRoomTemperatures_Archive_InMemoryT 
WHERE ColdRoomSensorNumber = 2
  AND RecordedWhen BETWEEN '2020-01-01' AND '2020-01-02';

SET NOCOUNT ON;
SET STATISTICS TIME ON;   
SET STATISTICS IO ON
SET STATISTICS XML ON;

/*
Output: - Durchschnittstemperaturen pro Sensor*/
/* beide Tabellen einmal „anlesen“, damit sie im Buffer Cache liegen.  (Disk ≈ RAM).*/
PRINT + CHAR(10) + '*** Anzahl Einträge ***' 
PRINT 'Disk-based table'
SELECT COUNT(*) AS Anzahl_Count_Disk
FROM Warehouse.ColdRoomTemperatures_Archive;

PRINT 'Memory-optimized table'
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

PRINT CHAR(10) + '*** Aggregation und Group by ***';

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


/*Table Scan*/

PRINT CHAR(10) + '*** FULL TABLE SCAN***';
PRINT 'Disk-based table'
SELECT COUNT(DISTINCT ColdRoomSensorNumber) 
FROM Warehouse.ColdRoomTemperatures_Archive;

PRINT 'Memory-optimized table'
SELECT COUNT(DISTINCT ColdRoomSensorNumber) 
FROM Warehouse.ColdRoomTemperatures_Archive_InMemoryT;

SET STATISTICS IO OFF;
SET STATISTICS XML OFF;

SET STATISTICS TIME OFF;   

GO