/*
Performance Vergleich ( Messung von Laufzeiten ) zwischen in Disk und in Memory Tables aufzeigen 

Total Einträge: 3'654'736

Erster Lauf misst "Disk + CPU" danach nur CPU
Ab zweiten Lauf sind Daten im RAM, Plan im Cache → messe die stabile Laufzeit ohne Kompilierung & kalten Cache.
*/

USE WideWorldImporters;
GO

SET NOCOUNT ON;
SET STATISTICS IO ON;   /*Für die Logical reads nur in disk*/
SET STATISTICS TIME ON; /*Für CPU time = Prozessor und Elapsed Time = Gesamtzeit inkl. Wartezeit*/
GO



/* IDs  */
DECLARE @ExistingID INT = 5;
DECLARE @NonExistingID INT = (SELECT MAX(ColdRoomTemperatureID) + 1 
FROM Warehouse.ColdRoomTemperatures_Archive);  




/* Test 1: Full Scan + ORDER BY */
PRINT CHAR(10) + 'Test 1: Full Scan + ORDER BY';
PRINT 'Disk-based table';
SELECT
    ColdRoomTemperatureID,
    ColdRoomSensorNumber,
    RecordedWhen,
    Temperature,
    ValidFrom,
    ValidTo
FROM Warehouse.ColdRoomTemperatures_Archive
ORDER BY ColdRoomTemperatureID;

PRINT 'Memory-optimized table';
SELECT
    ColdRoomTemperatureID,
    ColdRoomSensorNumber,
    RecordedWhen,
    Temperature,
    ValidFrom,
    ValidTo
FROM Warehouse.ColdRoomTemperatures_Archive_InMemoryT
ORDER BY ColdRoomTemperatureID;


/* Ausführungsplan zurücksetzen (Plan Cache) */
ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE;


/* Test 2: Point Lookup (Datensatz vorhanden) */
PRINT CHAR(10) + 'Test 2: Point Lookup (Datensatz vorhanden)';
PRINT 'Disk-based table';
SELECT
    ColdRoomTemperatureID,
    ColdRoomSensorNumber,
    RecordedWhen,
    Temperature,
    ValidFrom,
    ValidTo
FROM Warehouse.ColdRoomTemperatures_Archive
WHERE ColdRoomTemperatureID = @ExistingID;

PRINT 'Memory-optimized table';
SELECT
    ColdRoomTemperatureID,
    ColdRoomSensorNumber,
    RecordedWhen,
    Temperature,
    ValidFrom,
    ValidTo
FROM Warehouse.ColdRoomTemperatures_Archive_InMemoryT
WHERE ColdRoomTemperatureID = @ExistingID;


/* Test 3: Negative Lookup (Datensatz nicht vorhanden) */
PRINT CHAR(10) + 'Test 3: Negative Lookup (Datensatz nicht vorhanden)';
PRINT 'Disk-based table';
SELECT ColdRoomTemperatureID
FROM Warehouse.ColdRoomTemperatures_Archive
WHERE ColdRoomTemperatureID = @NonExistingID;

PRINT 'Memory-optimized table';
SELECT ColdRoomTemperatureID
FROM Warehouse.ColdRoomTemperatures_Archive_InMemoryT
WHERE ColdRoomTemperatureID = @NonExistingID;


SET STATISTICS TIME OFF;
SET STATISTICS IO OFF;
GO