

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