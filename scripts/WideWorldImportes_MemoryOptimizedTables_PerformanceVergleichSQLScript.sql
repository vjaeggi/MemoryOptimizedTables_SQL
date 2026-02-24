/*
Performance Vergleich ( Messung von Laufzeiten ) zwischen in Disk und in Memory Tables aufzeigen 

Total Einträge: 3'654'736

Erster Lauf misst "Disk + CPU"  danach nur CPU
Ab zweiten Lauf sind Daten im RAM, Plan im Cache → messe die stabile Laufzeit ohne Kompilierung & kalten Cache.



*/

USE WideWorldImporters;
GO

SET NOCOUNT ON;
SET STATISTICS IO ON;  /*Für die Logical reads nur in disk*/
SET STATISTICS TIME ON;  /*Für CPU time = Prozessor und Elapsed Time = Gesamtzeit inkl. Wartezeit*/
GO



/* in disk table Warehouse.ColdRoomTemperetaures_Archive */
PRINT 'Disk-based table';
SELECT --TOP(5000) 
	   ColdRoomTemperatureID,
       ColdRoomSensorNumber,
       RecordedWhen,
       Temperature,
       ValidFrom,
       ValidTo
FROM Warehouse.ColdRoomTemperatures_Archive 
ORDER BY ColdRoomTemperatureID;
GO


/* in memory table Warehouse.ColdRoomTemperetaures_Archive_inMemoryT */
PRINT 'Memory-optimized table';
SELECT --TOP (5000) 
       ColdRoomTemperatureID,
       ColdRoomSensorNumber,
       RecordedWhen,
       Temperature,
       ValidFrom,
       ValidTo
FROM Warehouse.ColdRoomTemperatures_Archive_InMemoryT
ORDER BY ColdRoomTemperatureID;
GO

SET STATISTICS TIME OFF; 
SET STATISTICS IO OFF;   


/*Ausführungsplan zurücksetzen*/
USE WideWorldImporters;
GO

ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE;
GO



/* Point Look up
Vorteil von MOT Ausgabe in 0 ms bei einem Datenset von 3.6 Mio Einträgen*/

USE WideWorldImporters;
GO

SET NOCOUNT ON;
SET STATISTICS IO ON;  /*Für die Logical reads nur in disk*/
SET STATISTICS TIME ON;  /*Für CPU time = Prozessor und Elapsed Time = Gesamtzeit inkl. Wartezeit*/
GO



/* in disk table Warehouse.ColdRoomTemperetaures_Archive */
PRINT 'Disk-based table';
SELECT ColdRoomTemperatureID,
       ColdRoomSensorNumber,
       RecordedWhen,
       Temperature,
       ValidFrom,
       ValidTo
FROM Warehouse.ColdRoomTemperatures_Archive 
WHERE ColdRoomTemperatureID = '5'
ORDER BY ColdRoomTemperatureID;
GO


/* in memory table Warehouse.ColdRoomTemperetaures_Archive_inMemoryT */
PRINT 'Memory-optimized table';
SELECT ColdRoomTemperatureID,
       ColdRoomSensorNumber,
       RecordedWhen,
       Temperature,
       ValidFrom,
       ValidTo
FROM Warehouse.ColdRoomTemperatures_Archive_InMemoryT
WHERE ColdRoomTemperatureID = '5'
ORDER BY ColdRoomTemperatureID;
GO

SET STATISTICS TIME OFF; 
SET STATISTICS IO OFF;   