

/*
SKRIPT: Memory Optimized Table in einer Microsoft SQL Server Datenbank 
	Laden von Beispieldaten
	alle Operationen und Konfigurationen (Create) 
*/


-- Prüfen, ob die Datenbank schon ein MEMORY_OPTIMIZED_DATA-Filegroup hat

USE WideWorldImporters;
GO

SELECT name AS Filegroupname,
	   type ,
	   type_desc
    
FROM sys.filegroups;
GO

/*WWI_InMemory_Data = MEMORY_OPTIMIZED_DATA_FILEGROUP*/


/*Kopie der Tabelle mit den meisten Einträgen erstellen: 
WideWorldImporters.Warehouse.ColdRoomTemperatures_Archive 
*/

Use WideWorldImporters; 

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
GO

/*Erstellte leere Tabelle*/

SELECT * FROM WideWorldImporters.Warehouse.ColdRoomTemperatures_Archive_InMemoryT

SELECT COUNT(*) FROM WideWorldImporters.Warehouse.ColdRoomTemperatures_Archive_InMemoryT

/*Mit Daten Befüllen*/

USE WideWorldImporters;
GO

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

	
SELECT COUNT(*) FROM WideWorldImporters.Warehouse.ColdRoomTemperatures_Archive_InMemoryT

SELECT TOP (10) *
FROM Warehouse.ColdRoomTemperatures_Archive_InMemoryT
ORDER BY ColdRoomTemperatureID;
GO

/*Zeilenanzahl von "in disk" und "in memory" tables vergleichen, Anzahl sollte gleich sein */

SELECT COUNT(*) AS RowCount_Archive_Disk
FROM Warehouse.ColdRoomTemperatures_Archive;

SELECT COUNT(*) AS RowCount_Archive_InMemory
FROM Warehouse.ColdRoomTemperatures_Archive_InMemoryT;

