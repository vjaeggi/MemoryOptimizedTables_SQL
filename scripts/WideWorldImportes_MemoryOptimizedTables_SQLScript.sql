/*
SKRIPT: Memory Optimized Table in einer Microsoft SQL Server Datenbank 
       Laden von Beispieldaten
       Alle Operationen und Konfigurationen (Create) 
*/

USE WideWorldImporters;
GO

/*Grösse nach Row entries*/
SELECT TOP 10 
    s.name  AS SchemaName,
    t.name  AS TableName,
    SUM(p.rows) AS Row_count
FROM sys.tables t
JOIN sys.schemas s     ON s.schema_id  = t.schema_id
JOIN sys.partitions p  ON p.object_id  = t.object_id
WHERE p.index_id IN (0,1)          -- nur Heap/Clustered zählen
GROUP BY s.name, t.name
ORDER BY Row_count DESC;
GO

/*Grösste nach Row entries - Zieltable prüfen (Disk)*/
SELECT COUNT(*) AS RowCount_ColdRoomTemps_Archive_Disk
FROM WideWorldImporters.Warehouse.ColdRoomTemperatures_Archive;
GO
-- mit 3'654'736 Einträgen


/* Prüfen, ob die Datenbank schon ein MEMORY_OPTIMIZED_DATA-Filegroup hat */
SELECT 
    name AS Filegroupname,
    type,
    type_desc
FROM sys.filegroups;
GO


/* Aktuelle Datenbank-Dateipfade */
SELECT
    name,
    type_desc,
    physical_name
FROM sys.database_files
ORDER BY type_desc, name;
GO


/* Memory-Optimized Filegroup + Container-Datei anlegen, falls noch nicht vorhanden */
USE WideWorldImporters;
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.filegroups
    WHERE type_desc = 'MEMORY_OPTIMIZED_DATA_FILEGROUP'
)
BEGIN
    PRINT 'MEMORY_OPTIMIZED_DATA Filegroup fehlt -> wird angelegt.';

    ALTER DATABASE WideWorldImporters 
      ADD FILEGROUP WWI_InMemory_Data CONTAINS MEMORY_OPTIMIZED_DATA;
    
    ALTER DATABASE WideWorldImporters 
      ADD FILE (
            NAME = N'WWI_InMemory_Data',
            FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL17.MSSQLSERVER\MSSQL\DATA\WWI_InMemory_Data'
      )
      TO FILEGROUP WWI_InMemory_Data;
END
ELSE
BEGIN
    PRINT 'MEMORY_OPTIMIZED_DATA Filegroup ist vorhanden.';
END
GO

/*Überprüfen Duplikate des BK*/
SELECT ColdRoomTemperatureID, COUNT(*) AS Anzahl
FROM Warehouse.ColdRoomTemperatures_Archive
GROUP BY ColdRoomTemperatureID
HAVING COUNT(*) > 1
ORDER BY Anzahl DESC;



/* Falls re-run des Scriptes */
IF OBJECT_ID(N'Warehouse.ColdRoomTemperatures_Archive_InMemoryT', N'U') IS NOT NULL
    DROP TABLE Warehouse.ColdRoomTemperatures_Archive_InMemoryT;
GO


CREATE TABLE Warehouse.ColdRoomTemperatures_Archive_InMemoryT
( 
    ColdRoomTemperatureID   INT           NOT NULL,
    ColdRoomSensorNumber    INT           NOT NULL,
    RecordedWhen            DATETIME2(7)  NOT NULL,
    Temperature             DECIMAL(10,2) NOT NULL,
    ValidFrom               DATETIME2(7)  NOT NULL,
    ValidTo                 DATETIME2(7)  NOT NULL,

    CONSTRAINT PK_ColdRoomTemperatures_Archive_InMem
        PRIMARY KEY NONCLUSTERED HASH (ColdRoomTemperatureID)
        WITH (BUCKET_COUNT = 1000000)
)
WITH
(
    MEMORY_OPTIMIZED = ON,
    DURABILITY       = SCHEMA_AND_DATA
);



/* Erstellte leere Tabelle */
SELECT COUNT(*) AS RowCount_InMemory_Empty
FROM Warehouse.ColdRoomTemperatures_Archive_InMemoryT;
GO


/* Mit Daten befüllen */
INSERT INTO Warehouse.ColdRoomTemperatures_Archive_InMemoryT
(
    ColdRoomTemperatureID,
    ColdRoomSensorNumber,
    RecordedWhen,
    Temperature,
    ValidFrom,
    ValidTo
)
SELECT
    ColdRoomTemperatureID,
    ColdRoomSensorNumber,
    RecordedWhen,
    Temperature,
    ValidFrom,
    ValidTo
FROM Warehouse.ColdRoomTemperatures_Archive;
GO


/* Rowcount nach Load */
SELECT COUNT(*) AS RowCount_InMemory_Loaded
FROM Warehouse.ColdRoomTemperatures_Archive_InMemoryT;
GO


/* Stichprobe */
SELECT TOP (10) *
FROM Warehouse.ColdRoomTemperatures_Archive_InMemoryT
ORDER BY ColdRoomTemperatureID;
GO


/* Zeilenanzahl vergleichen */
SELECT COUNT(*) AS RowCount_Archive_Disk
FROM Warehouse.ColdRoomTemperatures_Archive;

SELECT COUNT(*) AS RowCount_Archive_InMemory
FROM Warehouse.ColdRoomTemperatures_Archive_InMemoryT;
GO