# README – SQL Server In-Memory OLTP (Memory-Optimized Tables) Demo

## Überblick
Dieses Projekt demonstriert den Unterschied zwischen **klassischen disk-based Tables** und **Memory-Optimized Tables (MOT / In-Memory OLTP)** in Microsoft SQL Server.  
Basis ist die Sample-Datenbank **WideWorldImporters (Full .bak)**, die via **Restore Database** in eine lokale SQL Server Instanz eingespielt wurde.

## Umgebung / Rahmenbedingungen
- **Microsoft SQL Server 2025 Developer Edition**
- **SQL Server Management Studio (SSMS) 2022**
- Sample DB: **WideWorldImporters-Full.bak** (Restore)

**Hinweis:** Developer Edition und SSMS sind ideal fürs Testing (voller Feature-Umfang, keine Lizenzkosten).  
Die SQL Server Version/Edition (z. B. 2019/2022/2025) ist grundsätzlich frei wählbar, solange **In-Memory OLTP** verfügbar ist.

## Datenquelle (Download)
WideWorldImporters Sample (GitHub):

- Repo (README / Inhalte):  
  https://github.com/microsoft/sql-server-samples/blob/master/samples/databases/wide-world-importers/README.md

- Releases (Download Full Backup):  
  https://github.com/Microsoft/sql-server-samples/releases/tag/wide-world-importers-v1.0

##  WideWorldImporters einlesen
1. SSMS → Connect zur Instanz  
2. Databases → **Restore Database…** → Device → `WideWorldImporters-Full.bak` wählen  
3. Files: Zielpfade für Data/Log prüfen/anpassen  
4. Restore ausführen

---

## Fragestellungen
1. **Was ist der Unterschied** zwischen Microsoft SQL Server **disk-based Tables** und **Memory-Optimized Tables (MOT)**?  
2. **Welche Vorteile** bieten **In-Memory Tables** (MOT) gegenüber disk-based Tables?  
3. **Wie erstellt** man eine Memory-Optimized Table inkl. erforderlicher **Konfigurationen (Create)** in einer SQL Server Datenbank?  
4. **Wie lädt** man Beispieldaten in eine Memory-Optimized Table (z. B. via `INSERT…SELECT`)?  
5. **In welchen Fällen** hat eine Memory-Optimized Table einen **Performance-Vorteil** – und **wann nicht**?  
6. **Wie lässt sich Performance messen** (Laufzeitvergleich) zwischen disk-based und in-memory (MOT) Tabellen?

---

## Ziel / Anforderungen (präzise formuliert)

### 1) Fachliche Anforderung: Vergleich disk-based vs. Memory-Optimized Tables
**Ziel:** Den Unterschied zwischen disk-based Tables und MOT erklären und die Vorteile von MOT begründet darstellen.

**Kernpunkte (Erwartung):**
- Architektur: page-/bufferpool-basiert vs. in-memory Strukturen
- Concurrency: Lock/Latch (klassisch) vs. MVCC/optimistisch (MOT)
- Indexing: B-Tree (disk) vs. Hash (angewendet) / BW-Tree Range (MOT)
- typische Stärken MOT: OLTP, hohe Parallelität, Point (hot data) Lookups

### 2) Technische Anforderung: MOT erstellen und mit Beispieldaten befüllen
**Ziel:** Ein T-SQL Script bereitstellen, das:
- `MEMORY_OPTIMIZED_DATA` Filegroup + Container prüft/erstellt
- eine Memory-Optimized Table erstellt (`MEMORY_OPTIMIZED=ON`, `DURABILITY=SCHEMA_AND_DATA`)
- Beispieldaten aus einer disk-based Table übernimmt
- Rowcount disk vs. MOT validiert

### 3) Nachweis-Anforderung: Vorteil/Nachteil anhand Messungen zeigen
**Ziel:** Ein Script bereitstellen, das anhand messbarer Kennzahlen zeigt:
- Beispiel **mit Vorteil**: OLTP-typischer Zugriff (z. B. Point Lookup über PK)
- Beispiel **ohne Vorteil / Nachteil**: Scan + Sort (`ORDER BY`) bzw. analytische Muster (`GROUP BY`)
- Messung über `SET STATISTICS TIME/IO`


## Fazit 
- **MOT ist nicht automatisch schneller** – der Vorteil hängt stark vom **Workload** und dem **Index-/Query-Design** ab.
- Typischer Vorteil: **OLTP**, hohe Parallelität, **Point Lookups** (Hash/Range Index passend).
- Potenzieller Nachteil: **Scan + Sort / analytische Abfragen** (GROUP BY / ORDER BY) – hier sind disk-based Tables (insb. mit Columnstore) oft im Vorteil oder mindestens gleichauf.
