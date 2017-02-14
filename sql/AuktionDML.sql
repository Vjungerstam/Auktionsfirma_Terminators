-- USE Auktion2

-- - Skapa en auktion utifrån en viss produkt där man kan sätta utgångspris, acceptpris samt start och slutdatum för auktionen. Uppgift1 KLAR

DELIMITER //
CREATE PROCEDURE SkapaAuktion(IN AuktionId INT, IN Namn VARCHAR(100), IN UtgångsPris INT, IN AcceptPris INT, IN StartDatum DATE, IN SlutDatum DATE)
BEGIN
    DECLARE ProduktFinnsRedan BOOL DEFAULT FALSE;
    DECLARE CONTINUE HANDLER FOR 1062 SET ProduktFinnsRedan = TRUE;
    
    DECLARE EXIT HANDLER FOR 1048
    BEGIN
        ROLLBACK;
    END;
    
    START TRANSACTION;
        INSERT INTO Auktion VALUES (AuktionId, Namn, UtgångsPris, AcceptPris, StartDatum, SlutDatum);
        
        IF ProduktFinnsRedan THEN
        UPDATE Auktion
            SET Auktion.AuktionId = AuktionId,
				Produkt.Namn = Namn,
                Produkt.UtgångsPris = UtgångsPris,
                Produkt.AcceptPris = AcceptPris,
                Auktion.StartDatum = StartDatum,
                Auktion.SlutDatum = SlutDatum;
        END IF;
        COMMIT;
    
END //
DELIMITER ;
DROP PROCEDURE SkapaAuktion;
CALL SkapaAuktion(12, 'Bokhylla', 8500, 11900, '2017-02-09', '2017-02-12');

-- Skapa en auktion utifrån en viss produkt där man kan sätta utgångspris, acceptpris samt start och slutdatum för auktionen. UPPGIFT 2

DELIMITER //

CREATE PROCEDURE SkapaAuktion(IN UtGångsPris INT, IN AcceptPris INT, IN StartDatum DATE, IN SlutDatum DATE)

BEGIN

	DECLARE EXIT HANDLER FOR 1048
		BEGIN
			ROLLBACK;
		END;
        
	START TRANSACTION;
    
		UPDATE Produkt
			SET Produkt.UtGångsPris = UtGångsPris,
				Produkt.AcceptPris = AcceptPris
					WHERE Produkt.Namn = 'Tand från Mamut';
        
        UPDATE Auktion
			SET Auktion.StartDatum = StartDatum,
				Auktion.SlutDatum = SlutDatum
					WHERE Auktion.StartDatum IS NULL;
         
	COMMIT;				
END //

DELIMITER ;

DROP PROCEDURE SkapaAuktion;
CALL SkapaAuktion(13500, 22000, '2016-04-08', '2016-04-11');

-- Lista pågående auktioner samt kunna se det högsta budet och vilken kund som lagt det. UPPGIFT 3 KLAR

SELECT Kund.Förnamn, Kund.Efternamn, MAX(Bud.Budsumma) AS Högsta_bud, Produkt.Namn, Auktion.StartDatum, Auktion.SlutDatum FROM Kund
INNER JOIN Bud ON Kund.KundNummer = Bud.KundNummer
INNER JOIN Auktion ON Bud.AuktionId = Auktion.AuktionId
INNER JOIN auktionsprodukt ON Auktion.AuktionId = auktionsprodukt.AuktionId
INNER JOIN Produkt ON Auktionsprodukt.Produktnummer = Produkt.Produktnummer
WHERE SlutDatum > current_date()
GROUP BY Produkt.Namn;


--  Se budhistoriken på en viss auktion, samt vilka kunder som lagt buden(Löste med View) UPPGIFT 4 KLAR
DROP VIEW IF EXISTS KundBudHistorik; 

CREATE VIEW KundBudHistorik
AS SELECT Förnamn, Efternamn, Budsumma, AcceptPris, Namn AS Produkt_Namn FROM Kund
INNER JOIN Bud ON Kund.KundNummer = Bud.KundNummer
INNER JOIN Auktion ON Bud.AuktionId = Auktion.AuktionId
INNER JOIN auktionsprodukt ON Auktion.AuktionId = auktionsprodukt.AuktionId
INNER JOIN Produkt ON Auktionsprodukt.Produktnummer = Produkt.Produktnummer
WHERE Auktion.AuktionId = '2'
GROUP BY Kund.Förnamn;
SELECT * FROM KundBudHistorik;

-- Vilka auktioner avslutas under ett visst datumintervall? Samt vad blir provisionen för varje auktion inom det intervallet? UPPGIFT 5

DELIMITER //
CREATE PROCEDURE GetAvslutadeAuktioner(startdatum DATE, slutdatum DATE)
BEGIN
    SELECT Auktionshistorik.AuktionshistorikId, ROUND(Sum((Produkt.Provision* auktionshistorik.SlutPris))) AS Provision FROM Auktionshistorik
        INNER JOIN Produkt ON Produkt.Produktnummer = Auktionshistorik.Produktnummer
        WHERE Auktionshistorik.SlutDatum BETWEEN startdatum AND slutdatum
        GROUP BY Auktionshistorik.AuktionshistorikId;
END //
DELIMITER ;
-- drop PROCEDURE GetAvslutadeAuktioner;
call GetAvslutadeAuktioner('2016-01-03','2016-04-10');

-- UPPGIFT 6
CREATE TABLE AuktionerUtanKöpare(
AuktionId INT,
ProduktId INT,
Acceptpris INT,
SistaBud INT,
SlutDatum DATE,
PRIMARY KEY(AuktionId),
FOREIGN KEY (ProduktId) REFERENCES Produkt(Produktnummer) ON DELETE CASCADE ON UPDATE CASCADE
);

SHOW EVENTS;
SET GLOBAL event_scheduler = ON;
DELIMITER //
CREATE EVENT ArkiveraAuktionerUtanKöpare
ON SCHEDULE EVERY 10 SECOND
ON COMPLETION PRESERVE
DO
BEGIN
    INSERT INTO AuktionerUtanKöpare(SELECT Auktion.AuktionId, Produkt.Produktnummer, Produkt.AcceptPris,
        MAX(bud.Budsumma) as SistaBud, Auktion.SlutDatum FROM Bud
        INNER JOIN Auktion ON Bud.AuktionId = Auktion.AuktionId
        INNER JOIN auktionsprodukt ON Auktion.AuktionId = auktionsprodukt.AuktionId
        INNER JOIN Produkt ON auktionsprodukt.Produktnummer = Produkt.Produktnummer
        GROUP BY produkt.Produktnummer HAVING SistaBud < AcceptPris AND Auktion.SlutDatum < current_date());
    DELETE FROM Auktion WHERE Auktion.AuktionId IN (SELECT AuktionerUtanKöpare.AuktionId FROM AuktionerUtanKöpare);
END //
DELIMITER ;
 
-- DROP EVENT IF EXISTS ArkiveraAuktionerUtanKöpare;
SELECT * FROM AuktionerUtanKöpare;
SELECT * FROM Auktion;

-- När en auktion är avslutad och det finns en köpare så skall auktionen flyttas till en auktionshistoriktabell. UPPGIFT 7
-- ( köparens bud är >= accept pris.)
SHOW EVENTS;
SET GLOBAL event_scheduler = ON;
DELIMITER //
CREATE EVENT ArkiveraAuktion 
ON SCHEDULE EVERY 10 SECOND
ON COMPLETION PRESERVE
DO
BEGIN
    INSERT INTO auktionshistorik (SELECT Auktion.AuktionId, auktionsprodukt.Produktnummer, MAX(Bud.Budsumma), Auktion.SlutDatum FROM Kund
        INNER JOIN Bud ON Kund.KundNummer = Bud.KundNummer
        INNER JOIN Auktion ON Bud.AuktionId = Auktion.AuktionId
        INNER JOIN auktionsprodukt ON Auktion.AuktionId = auktionsprodukt.AuktionId
        INNER JOIN Produkt ON auktionsprodukt.Produktnummer = Produkt.Produktnummer
        WHERE Bud.Budsumma >= Produkt.AcceptPris AND Auktion.SlutDatum < current_date()
        GROUP BY auktionsprodukt.Produktnummer);
    DELETE FROM auktion WHERE auktion.AuktionId IN (SELECT auktionshistorik.AuktionsHistorikID FROM auktionshistorik);
END //
DELIMITER ;
-- DROP EVENT IF EXISTS ArkiveraAuktion;
SELECT * FROM Auktionshistorik;
SELECT * FROM Auktion;

-- Visa en kundlista på alla kunder som köpt något, samt vad deras totala ordervärde är. UPPGIFT 8  KLAR
DROP VIEW IF EXISTS KundLista;
CREATE VIEW KundLista AS
SELECT CONCAT_WS(' ', Kund.Förnamn, Kund.Efternamn) AS Kund, AuktionsHistorik.SlutPris AS Total FROM Kund
INNER JOIN AuktionsHistorik ON Kund.KundNummer = AuktionsHistorik.AuktionsHistorikID
-- WHERE KundNummer = Produktnummer
GROUP BY Kund, Total
ORDER BY Total DESC;
SELECT * FROM KundLista;

--  Vad den totala provisionen är per månad. UPPGIFT 9 KLAR
DROP VIEW IF EXISTS totalprovision; 

SELECT * FROM TotalProvision;

CREATE VIEW TotalProvision AS
SELECT MONTHNAME(AuktionsHistorik.SlutDatum) AS Månad, ROUND(SUM(Produkt.Provision * auktionshistorik.SlutPris))
AS TotalProvision_PerMånad FROM AuktionsHistorik
INNER JOIN produkt ON AuktionsHistorik.Produktnummer = produkt.Produktnummer
GROUP BY MONTHNAME(AuktionsHistorik.SlutDatum)
ORDER BY Månad DESC;
SELECT * FROM TotalProvision;
