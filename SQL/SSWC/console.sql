CREATE DATABASE kgtestdb

USE kgtestdb
SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE'

INSERT INTO FEATURES VALUES (
	0,
	'Breckenridge Mountain',
	'Summit',
	352704,
	1183503,
	'Breckenridge Mountain',
	7510);
SELECT * FROM sightings

--------First question:
SELECT DISTINCT PERSON
FROM SIGHTINGS s
WHERE s.LOCATION = 'Alaska Flat';

--------second question:
SELECT DISTINCT s1.PERSON
FROM SIGHTINGS s1
JOIN SIGHTINGS s2 ON s1.PERSON = s2.PERSON
WHERE s1.LOCATION = 'Moreland Mill' AND s2.LOCATION = 'Steve Spring'
  AND s1.NAME = s2.NAME;

--------third question:
SELECT DISTINCT f.GENUS, f.SPECIES
FROM FLOWERS f
JOIN SIGHTINGS s ON f.COMNAME = s.NAME
JOIN PEOPLE p ON s.PERSON = p.PERSON
JOIN FEATURES fe ON s.LOCATION = fe.LOCATION
WHERE (p.PERSON = 'Michael' OR p.PERSON = 'Robert')
  AND fe.ELEV > 8250;
---------------------or--------------------
SELECT DISTINCT f.GENUS, f.SPECIES
FROM FLOWERS f
JOIN SIGHTINGS s ON f.COMNAME = s.NAME
JOIN FEATURES fe ON s.LOCATION = fe.LOCATION
WHERE (s.PERSON = 'Michael' OR s.PERSON = 'Robert')
  AND fe.ELEV > 8250;

--------fourth question:
SELECT DISTINCT fe.MAP
FROM FEATURES fe
JOIN SIGHTINGS s ON fe.LOCATION = s.LOCATION
JOIN FLOWERS f ON s.NAME = f.COMNAME
WHERE f.COMNAME = 'Alpine penstemon' AND MONTH(s.SIGHTED) = 8;

--------fifth question:
SELECT f.GENUS
FROM FLOWERS f
GROUP BY f.GENUS
HAVING COUNT(DISTINCT f.SPECIES) > 1;

--------sixth question:
SELECT COUNT(*)
FROM FEATURES
WHERE CLASS = 'Summit' AND MAP = 'Sawmill Mountain';

--------seventh question:
SELECT TOP 1 s.LOCATION, fe.LATITUDE
FROM SIGHTINGS s
JOIN PEOPLE p ON s.PERSON = p.PERSON
JOIN FEATURES fe ON s.LOCATION = fe.LOCATION
WHERE p.PERSON = 'James'
ORDER BY fe.LATITUDE asc;


--------eighth question:
SELECT DISTINCT p.PERSON
FROM PEOPLE p
WHERE p.PERSON NOT IN (
    SELECT DISTINCT s.PERSON
    FROM SIGHTINGS s
    JOIN FEATURES fe ON s.LOCATION = fe.LOCATION
    WHERE fe.CLASS = 'Tower'
);



-------ninth question:
SELECT TOP 1 s.PERSON, COUNT(DISTINCT s.LOCATION) AS NumDistinctLocations
FROM SIGHTINGS s
GROUP BY s.PERSON
ORDER BY NumDistinctLocations DESC;
-----------
    WITH FlowerLocations AS (
    SELECT
        s.PERSON,
        COUNT(DISTINCT s.LOCATION) AS DistinctLocations,
        COUNT(DISTINCT s.NAME) AS DistinctFlowers
    FROM
        SIGHTINGS s
    GROUP BY
        s.PERSON
)

SELECT TOP 1
    PERSON,
    DistinctLocations,
    DistinctFlowers
FROM
    FlowerLocations
ORDER BY
    DistinctLocations DESC, DistinctFlowers DESC;

--------
WITH AllFlowers AS (
    SELECT DISTINCT COMNAME
    FROM FLOWERS
)

SELECT
    s.PERSON,
    MAX(s.SIGHTED) AS LastUnseenFlowerDate
FROM
    SIGHTINGS s
JOIN
    AllFlowers af ON s.NAME = af.COMNAME
GROUP BY
    s.PERSON
HAVING
    COUNT(DISTINCT s.NAME) = (SELECT COUNT(DISTINCT COMNAME) FROM FLOWERS);


--------10th question:
WITH FlowerCounts AS (
    SELECT
        s.PERSON,
        COUNT(DISTINCT s.NAME) AS TotalFlowerCount
    FROM
        SIGHTINGS s
    GROUP BY
        s.PERSON
)
SELECT
    s.PERSON,
    MAX(s.SIGHTED) AS LastUnseenFlowerDate
FROM
    SIGHTINGS s
JOIN
    FlowerCounts fc ON s.PERSON = fc.PERSON
WHERE
    fc.TotalFlowerCount = (SELECT COUNT(DISTINCT COMNAME) FROM FLOWERS)
GROUP BY
    s.PERSON;


--------11th question:
    WITH JenniferSightings AS (
    SELECT
        MONTH(s.SIGHTED) AS Month,
        DATENAME(MONTH, s.SIGHTED) AS MonthName,
        COUNT(*) AS SightingsCount
    FROM
        SIGHTINGS s
    WHERE
        s.PERSON = 'Jennifer'
    GROUP BY
        MONTH(s.SIGHTED), DATENAME(MONTH, s.SIGHTED)
)
SELECT
    Month,
    MonthName,
    CAST(SightingsCount AS DECIMAL) / SUM(CAST(SightingsCount AS DECIMAL)) OVER () AS Fraction
FROM
    JenniferSightings;

--------12th question:
WITH JohnFlowerSet AS (
    SELECT DISTINCT s.NAME
    FROM SIGHTINGS s
    WHERE s.PERSON = 'John'
)

SELECT TOP 1
    s.PERSON AS SimilarPerson,
    COUNT(DISTINCT CASE WHEN s1.NAME IS NOT NULL THEN s.NAME END) AS IntersectionCount,
    COUNT(DISTINCT s.NAME) AS UnionCount,
    CAST(COUNT(DISTINCT CASE WHEN s1.NAME IS NOT NULL THEN s.NAME END) AS DECIMAL) /
    COUNT(DISTINCT s.NAME) AS JaccardIndex
FROM
    SIGHTINGS s
LEFT JOIN
    JohnFlowerSet s1 ON s.NAME = s1.NAME
WHERE
    s.PERSON <> 'John'
GROUP BY
    s.PERSON
ORDER BY
    JaccardIndex DESC;


--------

WITH JohnFlowerSet AS (
    SELECT DISTINCT s.NAME
    FROM SIGHTINGS s
    WHERE s.PERSON = 'John'
)

SELECT TOP 1
    s.PERSON AS SimilarPerson,
    COUNT(DISTINCT CASE WHEN s1.NAME IS NOT NULL THEN s.NAME END) AS IntersectionCount,
    COUNT(DISTINCT s.NAME) + COUNT(DISTINCT s1.NAME) AS UnionCount,
    CAST(COUNT(DISTINCT CASE WHEN s1.NAME IS NOT NULL THEN s.NAME END) AS DECIMAL) /
    (COUNT(DISTINCT s.NAME) + COUNT(DISTINCT s1.NAME)) AS JaccardIndex
FROM
    SIGHTINGS s
LEFT JOIN
    JohnFlowerSet s1 ON s.NAME = s1.NAME
WHERE
    s.PERSON <> 'John'
GROUP BY
    s.PERSON
ORDER BY
    JaccardIndex DESC;

=----
WITH JohnFlowerSet AS (
    SELECT DISTINCT s.NAME
    FROM SIGHTINGS s
    WHERE s.PERSON = 'John'
)

SELECT TOP 1
    s.PERSON AS SimilarPerson,
    COUNT(DISTINCT CASE WHEN s1.NAME IS NOT NULL THEN s.NAME END) AS IntersectionCount,
    COUNT(DISTINCT s.NAME) + COUNT(DISTINCT s1.NAME) - COUNT(DISTINCT CASE WHEN s1.NAME IS NOT NULL THEN s.NAME END) AS UnionCount,
    CAST(COUNT(DISTINCT CASE WHEN s1.NAME IS NOT NULL THEN s.NAME END) AS DECIMAL) /
    (COUNT(DISTINCT s.NAME) + COUNT(DISTINCT s1.NAME) - COUNT(DISTINCT CASE WHEN s1.NAME IS NOT NULL THEN s.NAME END)) AS JaccardIndex
FROM
    SIGHTINGS s
LEFT JOIN
    JohnFlowerSet s1 ON s.NAME = s1.NAME
WHERE
    s.PERSON <> 'John'
GROUP BY
    s.PERSON
ORDER BY
    JaccardIndex DESC;
-------- Step 1: Create a view of distinct flowers seen by John
CREATE VIEW JohnFlowers AS
SELECT DISTINCT NAME
FROM SIGHTINGS
WHERE PERSON = 'John';

-- Step 2: Create a view of the number of intersections for each person's (excluding John) flowers with John's flowers
CREATE VIEW IntersectionCounts AS
SELECT
    s.PERSON,
    COUNT(DISTINCT s.NAME) AS IntersectionCount
FROM
    SIGHTINGS s
JOIN
    JohnFlowers jf ON s.NAME = jf.NAME
WHERE
    s.PERSON <> 'John'
GROUP BY
    s.PERSON;

-- Step 3: Create a view of the number of unions for each person's (excluding John) flowers with John's flowers
CREATE VIEW UnionCounts AS
SELECT
    s.PERSON,
    COUNT(DISTINCT s.NAME) + COUNT(DISTINCT jf.NAME) AS UnionCount
FROM
    SIGHTINGS s
FULL OUTER JOIN
    JohnFlowers jf ON s.NAME = jf.NAME
WHERE
    s.PERSON <> 'John'
GROUP BY
    s.PERSON;

-- Step 4: Calculate Jaccard Index from the intersections and unions
CREATE VIEW JaccardIndex AS
SELECT
    ic.PERSON,
    ic.IntersectionCount,
    uc.UnionCount,
    CAST(ic.IntersectionCount AS DECIMAL) / NULLIF(uc.UnionCount, 0) AS JaccardIndex
FROM
    IntersectionCounts ic
JOIN
    UnionCounts uc ON ic.PERSON = uc.PERSON;

-- Step 5: Find the person with the maximum Jaccard Index
SELECT TOP 1
    PERSON,
    IntersectionCount,
    UnionCount,
    JaccardIndex
FROM
    JaccardIndex
ORDER BY
    JaccardIndex DESC;
-----


CREATE VIEW JohnFlowers AS
SELECT DISTINCT NAME
FROM SIGHTINGS
WHERE PERSON = 'John';

CREATE VIEW IntersectionCounts AS
SELECT
    s.PERSON,
    COUNT(DISTINCT s.NAME) AS IntersectionCount
FROM
    SIGHTINGS s
JOIN
    JohnFlowers jf ON s.NAME = jf.NAME
WHERE
    s.PERSON <> 'John'
GROUP BY
    s.PERSON;

CREATE VIEW UnionCounts AS
SELECT
    s.PERSON,
    COUNT(DISTINCT s.NAME) + ISNULL(COUNT(DISTINCT jf.NAME), 0) AS UnionCount
FROM
    SIGHTINGS s
LEFT JOIN
    JohnFlowers jf ON s.NAME = jf.NAME
WHERE
    s.PERSON <> 'John'
GROUP BY
    s.PERSON;

CREATE VIEW JaccardIndex AS
SELECT
    ic.PERSON,
    ic.IntersectionCount,
    uc.UnionCount,
    CAST(ic.IntersectionCount AS DECIMAL) / NULLIF(uc.UnionCount, 0) AS JaccardIndex
FROM
    IntersectionCounts ic
JOIN
    UnionCounts uc ON ic.PERSON = uc.PERSON;

SELECT TOP 1
    PERSON,
    IntersectionCount,
    UnionCount,
    JaccardIndex
FROM
    JaccardIndex
ORDER BY
    JaccardIndex DESC;

CREATE TABLE nodes (
paperID INTEGER,
paperTitle VARCHAR (100));
CREATE TABLE edges (
paperID INTEGER,
citedPaperID INTEGER);
select * from nodes


------------- -----------
------------Assignment 2
-------------------------


IF OBJECT_ID('FindConnectedComponents', 'P') IS NOT NULL
    DROP PROCEDURE FindConnectedComponents;

---------------------------1.1-------------------
IF OBJECT_ID('tempdb..#Visited') IS NOT NULL DROP TABLE #Visited;
IF OBJECT_ID('tempdb..#Queue') IS NOT NULL DROP TABLE #Queue;

-- Creating the Visited table
CREATE TABLE #Visited (
    paperID INT PRIMARY KEY,
    componentID INT
);

-- Creating the Queue table
CREATE TABLE #Queue (
    paperID INT,
    componentID INT
);

-- Creating the stored procedure to find connected components, using the BFS method like professor mentioned
IF OBJECT_ID('dbo.ConnectedComponents') IS NOT NULL
    DROP PROCEDURE dbo.ConnectedComponents;
GO

CREATE PROCEDURE dbo.ConnectedComponents
AS
BEGIN
    DECLARE @CurrentComponentID INT = 1;
    DECLARE @CurrentPaperID INT;

    -- Insert initial seed
    INSERT INTO #Queue
    SELECT TOP 1 paperID, @CurrentComponentID FROM nodes WHERE paperID NOT IN (SELECT paperID FROM #Visited);

    WHILE (SELECT COUNT(*) FROM #Queue) > 0
    BEGIN
        -- Dequeue
        SELECT TOP 1 @CurrentPaperID = paperID FROM #Queue;
        DELETE FROM #Queue WHERE paperID = @CurrentPaperID;

        -- Mark as visited
        IF NOT EXISTS (SELECT 1 FROM #Visited WHERE paperID = @CurrentPaperID)
        BEGIN
            INSERT INTO #Visited (paperID, componentID) VALUES (@CurrentPaperID, @CurrentComponentID);

            -- Enqueue unvisited adjacent nodes
            INSERT INTO #Queue (paperID, componentID)
            SELECT e.citedPaperID, @CurrentComponentID FROM edges e
            WHERE e.paperID = @CurrentPaperID AND e.citedPaperID NOT IN (SELECT paperID FROM #Visited)
            UNION
            SELECT e.paperID, @CurrentComponentID FROM edges e
            WHERE e.citedPaperID = @CurrentPaperID AND e.paperID NOT IN (SELECT paperID FROM #Visited);
        END

        -- If the queue is empty, move to the next component
        IF (SELECT COUNT(*) FROM #Queue WHERE componentID = @CurrentComponentID) = 0
        BEGIN
            IF (SELECT COUNT(*) FROM nodes WHERE paperID NOT IN (SELECT paperID FROM #Visited)) > 0
            BEGIN
                SET @CurrentComponentID = @CurrentComponentID + 1;
                INSERT INTO #Queue
                SELECT TOP 1 paperID, @CurrentComponentID FROM nodes WHERE paperID NOT IN (SELECT paperID FROM #Visited);
            END
        END
    END;
END;
GO

-- Executed in 51`60 secs
EXEC dbo.ConnectedComponents;

-- Aggregating the component sizes and print components with their sizes and titles
-- Note ComponentSize and componentID are different
WITH ComponentSizes AS (
    SELECT componentID, COUNT(*) AS ComponentSize
    FROM #Visited
    GROUP BY componentID
    HAVING COUNT(*) > 4 AND COUNT(*) <= 10
)
-- Printing Paper ID and title with component size >4 and  <=10
SELECT v.paperID, n.paperTitle
FROM #Visited v
JOIN ComponentSizes cs ON v.componentID = cs.componentID
JOIN nodes n ON v.paperID = n.paperID
ORDER BY v.componentID, v.paperID;









-----------1.2

IF OBJECT_ID('InitializePageRank', 'P') IS NOT NULL
    DROP PROCEDURE UpdatePageRank;

DROP PROCEDURE InitializePageRank;
DROP PROCEDURE UpdatePageRank;
DROP PROCEDURE PrintTop10Papers;
DROP TABLE nodes_copy;

--Initialization and nodes_copy from nodes table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'nodes_copy')
SELECT *
INTO nodes_copy
FROM nodes;
ALTER TABLE nodes_copy ADD pagerank FLOAT;
ALTER TABLE nodes_copy ADD previousPagerank FLOAT;
GO
CREATE PROCEDURE InitializePageRank AS
BEGIN
    DECLARE @totalPapers INT;
    SELECT @totalPapers = COUNT(*) FROM nodes_copy;
    UPDATE nodes_copy SET pagerank = 1.0 / @totalPapers, previousPagerank = 1.0 / @totalPapers;
END;

GO
DROP PROCEDURE UpdatePageRank;
--Iteration and Convergence Check procedure
CREATE PROCEDURE UpdatePageRank AS
BEGIN
    DECLARE @dampingFactor FLOAT = 0.85;
    DECLARE @totalPapers INT;
    DECLARE @delta FLOAT = 1.0;
    DECLARE @threshold FLOAT = 0.01;
    DECLARE @currentIteration INT = 0;
    SELECT @totalPapers = COUNT(*) FROM nodes_copy;

    -- Initialize previousPagerank before starting iterations
    UPDATE nodes_copy SET previousPagerank = pagerank;
    WHILE @delta > @threshold
    BEGIN
        DECLARE @tempRanks TABLE (PaperID INT, newRank FLOAT);
        INSERT INTO @tempRanks (PaperID, newRank)
        SELECT dst.PaperID,
               ((1 - @dampingFactor) / @totalPapers) + @dampingFactor * SUM(ISNULL(src.pagerank / od.OutDegree, 0))
        FROM nodes_copy dst
        LEFT JOIN edges e ON dst.PaperID = e.citedPaperID
        LEFT JOIN nodes_copy src ON e.paperID = src.PaperID
        LEFT JOIN (
            SELECT src.PaperID, COUNT(*) AS OutDegree
            FROM edges
            JOIN nodes_copy src ON edges.paperID = src.PaperID
            GROUP BY src.PaperID
        ) AS od ON e.paperID = od.PaperID
        GROUP BY dst.PaperID;
        -- Update PageRank in nodes_copy from @tempRanks
        UPDATE nodes_copy
        SET pagerank = tr.newRank
        FROM nodes_copy
        JOIN @tempRanks tr ON nodes_copy.PaperID = tr.PaperID;
        -- Normalization step
        DECLARE @totalRank FLOAT;
        SELECT @totalRank = SUM(pagerank) FROM nodes_copy;
        UPDATE nodes_copy SET pagerank = pagerank / @totalRank;
        -- Calculate delta for convergence check
        SELECT @delta = SUM(ABS(pagerank - previousPagerank)) FROM nodes_copy;
        UPDATE nodes_copy SET previousPagerank = pagerank;
        SET @currentIteration = @currentIteration + 1;
    END
END;
GO
--Retrieve and print top 10 papers by PageRank
DROP PROCEDURE PrintTop10Papers
CREATE PROCEDURE PrintTop10Papers
AS
BEGIN
    SELECT TOP 10 PaperID, paperTitle, pagerank FROM nodes_copy ORDER BY pagerank DESC;
    SELECT SUM(pagerank) AS TotalPageRank
    FROM nodes_copy;
END;


EXEC InitializePageRank;
EXEC UpdatePageRank;
EXEC PrintTop10Papers;


-------------1.22
-- Create nodes and edges tables (if not already exists)

-- Initialization and nodes_copy from nodes table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'nodes_copy')
BEGIN
    SELECT *
    INTO nodes_copy
    FROM nodes;

    ALTER TABLE nodes_copy ADD pagerank FLOAT;
    ALTER TABLE nodes_copy ADD previousPagerank FLOAT;
END;

-- InitializePageRank Procedure
CREATE OR ALTER PROCEDURE InitializePageRank AS
BEGIN
    DECLARE @totalPapers INT;

    SELECT @totalPapers = COUNT(*) FROM nodes_copy;

    UPDATE nodes_copy
    SET pagerank = 1.0 / @totalPapers,
        previousPagerank = 1.0 / @totalPapers
    WHERE pagerank IS NULL OR previousPagerank IS NULL;
END;
GO

-- DROP existing UpdatePageRank Procedure
IF OBJECT_ID('UpdatePageRank', 'P') IS NOT NULL
    DROP PROCEDURE UpdatePageRank;
GO

-- Iteration and Convergence Check Procedure
-- Iteration and Convergence Check Procedure
CREATE PROCEDURE UpdatePageRank AS
BEGIN
    DECLARE @dampingFactor FLOAT = 0.85;
    DECLARE @totalPapers INT;
    DECLARE @delta FLOAT = 1.0;
    DECLARE @threshold FLOAT = 0.01;
    DECLARE @currentIteration INT = 0;

    SELECT @totalPapers = COUNT(*) FROM nodes_copy;

    -- Create a temporary table to store previous pageranks
    CREATE TABLE #TempPreviousPagerank (PaperID INT, previousPagerank FLOAT);

    -- Initialize previousPagerank before starting iterations
    INSERT INTO #TempPreviousPagerank (PaperID, previousPagerank)
    SELECT PaperID, pagerank
    FROM nodes_copy
    WHERE pagerank IS NOT NULL;

    WHILE @delta > @threshold
    BEGIN
        DECLARE @tempRanks TABLE (PaperID INT, newRank FLOAT);

        INSERT INTO @tempRanks (PaperID, newRank)
        SELECT dst.PaperID,
               ((1 - @dampingFactor) / @totalPapers) + @dampingFactor * SUM(ISNULL(src.pagerank / od.OutDegree, 0))
        FROM nodes_copy dst
        LEFT JOIN edges e ON dst.PaperID = e.citedPaperID
        LEFT JOIN nodes_copy src ON e.paperID = src.PaperID
        LEFT JOIN (
            SELECT src.PaperID, COUNT(*) AS OutDegree
            FROM edges
            JOIN nodes_copy src ON edges.paperID = src.PaperID
            GROUP BY src.PaperID
        ) AS od ON e.paperID = od.PaperID
        GROUP BY dst.PaperID;

        -- Update PageRank in nodes_copy from @tempRanks
        UPDATE nc
        SET pagerank = tr.newRank
        FROM nodes_copy nc
        JOIN @tempRanks tr ON nc.PaperID = tr.PaperID
        WHERE nc.pagerank IS NOT NULL;

        -- Normalization step
        DECLARE @totalRank FLOAT;
        SELECT @totalRank = SUM(pagerank) FROM nodes_copy WHERE pagerank IS NOT NULL;

        UPDATE nc
        SET pagerank = pagerank / @totalRank
        FROM nodes_copy nc
        WHERE pagerank IS NOT NULL;

        -- Calculate delta for convergence check
        UPDATE nc
        SET previousPagerank = tr.previousPagerank
        FROM nodes_copy nc
        JOIN #TempPreviousPagerank tr ON nc.PaperID = tr.PaperID
        WHERE nc.pagerank IS NOT NULL;

        SELECT @delta = SUM(ABS(pagerank - previousPagerank)) FROM nodes_copy WHERE pagerank IS NOT NULL;

        SET @currentIteration = @currentIteration + 1;
    END

    -- Drop the temporary table
    DROP TABLE #TempPreviousPagerank;
END;

GO

-- DROP existing PrintTop10Papers Procedure
IF OBJECT_ID('PrintTop10Papers', 'P') IS NOT NULL
    DROP PROCEDURE PrintTop10Papers;
GO

-- Retrieve and print top 10 papers by PageRank Procedure
CREATE PROCEDURE PrintTop10Papers AS
BEGIN
    SELECT TOP 10 PaperID, paperTitle, pagerank
    FROM nodes_copy
    WHERE pagerank IS NOT NULL
    ORDER BY pagerank DESC;

    SELECT SUM(pagerank) AS TotalPageRank
    FROM nodes_copy
    WHERE pagerank IS NOT NULL;
END;


1.2222-------

IF OBJECT_ID('dbo.pagerankTop10') IS NOT NULL
    DROP PROCEDURE dbo.pagerankTop10;


CREATE or alter PROCEDURE pagerankTop10
AS
BEGIN
    SET NOCOUNT ON;
    -- Declaring variables
    DECLARE @dampingFactor FLOAT = 0.85;
    DECLARE @convergenceThreshold FLOAT = 0.0001;
    DECLARE @maxIterations INT = 100;
    DECLARE @iteration INT = 0;
    DECLARE @change FLOAT = 1;
    DECLARE @totalNodes INT;
    DECLARE @initialPageRank FLOAT;
    DECLARE @danglingPageRank FLOAT;

    -- Get the total number of nodes
    SELECT @totalNodes = COUNT(*) FROM nodes;
    SET @initialPageRank = 1.0 / @totalNodes;

    -- Prepare PageRank table
    IF OBJECT_ID('tempdb..#pagerank') IS NOT NULL DROP TABLE #pagerank;
    CREATE TABLE #pagerank (
        paperID INT PRIMARY KEY,
        currentRank FLOAT,
        previousRank FLOAT
    );
    INSERT INTO #pagerank (paperID, currentRank, previousRank)
    SELECT paperID, @initialPageRank, 0 FROM nodes;
    IF OBJECT_ID('tempdb..#od') IS NOT NULL DROP TABLE #od;
    CREATE TABLE #od (
        paperID INT PRIMARY KEY,
        outDegree INT
    );
    INSERT INTO #od (paperID, outDegree)
    SELECT paperID, COUNT(*) as outDegree
    FROM edges
    GROUP BY paperID;
    WHILE @iteration < @maxIterations AND @change > @convergenceThreshold
    BEGIN
        SELECT @danglingPageRank = SUM(pr.currentRank)
        FROM #pagerank pr
        LEFT JOIN #od od ON pr.paperID = od.paperID
        WHERE od.outDegree IS NULL OR od.outDegree = 0;
        UPDATE #pagerank SET previousRank = currentRank;
        UPDATE pr SET
            currentRank = (1.0 - @dampingFactor) / @totalNodes + @dampingFactor * (
                @danglingPageRank / @totalNodes +
                ISNULL((
                    SELECT SUM(linkPR.currentRank / od.outDegree)
                    FROM edges e
                    JOIN #pagerank linkPR ON e.paperID = linkPR.paperID
                    JOIN #od od ON e.paperID = od.paperID
                    WHERE pr.paperID = e.citedPaperID
                ), 0)
            )
        FROM #pagerank pr;
        SELECT @change = SUM(ABS(pr.currentRank - pr.previousRank)) FROM #pagerank pr;
        SET @iteration = @iteration + 1;
    END

    -- Normalizing PageRank to ensure total is approximately 1
    DECLARE @totalRank FLOAT;
    SELECT @totalRank = SUM(currentRank) FROM #pagerank;
    UPDATE #pagerank SET currentRank = currentRank / @totalRank;

    -- Returning top 10 PageRank values
    SELECT TOP 10 n.paperID, n.paperTitle, pr.currentRank AS PageRank
    FROM #pagerank pr
    INNER JOIN nodes n ON pr.paperID = n.paperID
    ORDER BY PageRank DESC;
    select top 10 sum(pr.currentRank) from #pagerank pr
    -- Cleanup
    DROP TABLE #pagerank;
    DROP TABLE #od;

    SET NOCOUNT OFF;
END
GO
-- took 1 min 2 sec
EXEC pagerankTop10;