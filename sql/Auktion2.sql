DROP DATABASE IF EXISTS Auktion2;
CREATE DATABASE Auktion2;
USE Auktion2;

CREATE TABLE Leverantör(
LeverantörId INT AUTO_INCREMENT PRIMARY KEY,
Namn VARCHAR(100) NOT NULL,
Epost VARCHAR(100) NOT NULL,
Telefonnummer CHAR(20) NOT NULL
);
CREATE INDEX IX_Leverantör_Namn ON Leverantör(Namn);

CREATE TABLE Produkt(
Produktnummer INT AUTO_INCREMENT PRIMARY KEY,
Namn VARCHAR(100) NOT NULL,
Provision FLOAT NOT NULL,
UtgångsPris INT NOT NULL,
AcceptPris INT NOT NULL,
Beskrivning VARCHAR(200)
);
CREATE INDEX IX_Produkt_Namn ON Produkt(Namn);

CREATE TABLE ProduktLeverantör(
LeverantörId INT,
Produktnummer INT,
PRIMARY KEY(LeverantörId, Produktnummer),
FOREIGN KEY (LeverantörId) REFERENCES Leverantör(LeverantörId) ON DELETE CASCADE ON UPDATE CASCADE,
FOREIGN KEY (Produktnummer) REFERENCES Produkt(Produktnummer) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Auktion(
AuktionId INT AUTO_INCREMENT PRIMARY KEY,
StartDatum DATE, -- fråga 2 ändrat -tagit bort NOT NULL
SlutDatum DATE -- fråga 2 ändrat -tagit bort NOT NULL
);

CREATE TABLE AuktionsProdukt(
AuktionId INT,
Produktnummer INT,
PRIMARY KEY(AuktionId, Produktnummer),
FOREIGN KEY (AuktionId) REFERENCES Auktion(AuktionId) ON DELETE CASCADE ON UPDATE CASCADE,
FOREIGN KEY (Produktnummer) REFERENCES Produkt(Produktnummer) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Kund(
KundNummer INT AUTO_INCREMENT PRIMARY KEY,
Förnamn VARCHAR(100) NOT NULL,
Efternamn VARCHAR(100) NOT NULL,
Gata VARCHAR(100) NOT NULL,
Ort VARCHAR(50) NOT NULL,
Epost VARCHAR(100) NOT NULL
);
CREATE INDEX IX_Kund_Efternamn ON kund(Efternamn);

CREATE TABLE Bud(
AuktionId INT,
KundNummer INT,
BudDatum DATE,
Tid TIME,
Budsumma INT,
PRIMARY KEY(AuktionId,KundNummer),
FOREIGN KEY(AuktionId) REFERENCES Auktion(AuktionId) ON DELETE CASCADE ON UPDATE CASCADE,
FOREIGN KEY(KundNummer) REFERENCES Kund(KundNummer) ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE TABLE auktionshistorik(
AuktionsHistorikID INT,
Produktnummer INT,
SlutPris INT,
SlutDatum DATE,
PRIMARY KEY(AuktionsHistorikID),
FOREIGN KEY (Produktnummer) REFERENCES Produkt(Produktnummer) ON DELETE CASCADE ON UPDATE CASCADE
); 
-- Leverantör
INSERT INTO Leverantör(Namn, epost, telefonnummer) VALUES('AntikButiken', 'antik@hotmail.com', '08231192');
INSERT INTO Leverantör(Namn, epost, telefonnummer) VALUES('AuktionsAffären', 'aa@mail.com', '08222444');
INSERT INTO Leverantör(Namn, epost, telefonnummer) VALUES('ItBeasten', 'thebeast@mail.com', '0702929292');
INSERT INTO Leverantör(Namn, epost, telefonnummer) VALUES('GammaltOchNytt', 'gon@mail.com', '080328928');
INSERT INTO Leverantör(Namn, epost, telefonnummer) VALUES('MöbelJätten', 'jatten@hotmail.com', '0764266262');
INSERT INTO Leverantör(Namn, epost, telefonnummer) VALUES('TavlorDeluxe', 'deluxe@mail.com', '0721616111');

-- Produkter
INSERT INTO Produkt(Namn, provision, utgångspris, acceptpris, beskrivning) VALUE('OljeTavla', 0.05, 4000, 9000, 'Fin tavla från Italien');
INSERT INTO Produkt(Namn, provision, utgångspris, acceptpris, beskrivning) VALUE('Mahogny Bord', 0.07, 17000, 19000, 'Fint bord från Grekland');
INSERT INTO Produkt(Namn, provision, utgångspris, acceptpris, beskrivning) VALUE('Mahogny Stol', 0.04, 15000, 20000, 'Fin stol från 1600-talet');
INSERT INTO Produkt(Namn, provision, utgångspris, acceptpris, beskrivning) VALUE('Persiskt Matta', 0.10, 20000, 30000, 'Äkta persisk matta från 1800-talet');
INSERT INTO Produkt(Namn, provision, utgångspris, acceptpris, beskrivning) VALUE('Guld Ring', 0.02, 30000, 50000, 'Guld Ring från StormaktsTiden');
INSERT INTO Produkt(Namn, provision, utgångspris, acceptpris, beskrivning) VALUE('Gevär', 0.09, 14000, 19000, 'Gammalt gevär från 1700-talet');
INSERT INTO Produkt(Namn, provision, utgångspris, acceptpris, beskrivning) VALUE('Kinesisk Kruka', 0.05, 25000, 40000, 'Porslin från ming dynastin');
INSERT INTO Produkt(Namn, provision, utgångspris, acceptpris, beskrivning) VALUE('Antik Guld klocka', 0.05, 30000, 50000, 'Antik Guld klocka från Italien'); -- test fråga 7
INSERT INTO Produkt(Namn, provision, utgångspris, acceptpris, beskrivning) VALUE('Tand från mamut', 0.08, 0, 0, 'Gammal tand från en gigantisk mamut'); -- fråga 2

-- ProduktLeverantör
INSERT INTO ProduktLeverantör (LeverantörId, ProduktNummer) VALUES(1,1);
INSERT INTO ProduktLeverantör (LeverantörId, ProduktNummer) VALUES(2,2);
INSERT INTO ProduktLeverantör (LeverantörId, ProduktNummer) VALUES(3,3);
INSERT INTO ProduktLeverantör (LeverantörId, ProduktNummer) VALUES(4,4);
INSERT INTO ProduktLeverantör (LeverantörId, ProduktNummer) VALUES(5,5);
INSERT INTO ProduktLeverantör (LeverantörId, ProduktNummer) VALUES(6,6);
INSERT INTO ProduktLeverantör (LeverantörId, ProduktNummer) VALUES(1,7);
INSERT INTO ProduktLeverantör (LeverantörId, ProduktNummer) VALUES(2,8); -- fråga 7
INSERT INTO ProduktLeverantör (LeverantörId, ProduktNummer) VALUES(4,9); -- fråga 2

-- Auktion
INSERT INTO Auktion(StartDatum, SlutDatum) VALUES('2017-02-01', '2017-02-23'); -- 1 Ange bud på en produkt om ni vill
INSERT INTO Auktion(StartDatum, SlutDatum) VALUES('2017-02-01', '2017-02-20'); -- 2 Ange bud på en produkt om ni vill
INSERT INTO Auktion(StartDatum, SlutDatum) VALUES('2017-02-01', '2017-02-22'); -- 3 Ange bud på en produkt om ni vill
INSERT INTO Auktion(StartDatum, SlutDatum) VALUES('2017-02-01', '2017-02-03'); -- 4 uppdaterat
INSERT INTO Auktion(StartDatum, SlutDatum) VALUES('2017-02-01', '2017-02-12'); -- 5 test fråga 6 
INSERT INTO Auktion(StartDatum, SlutDatum) VALUES('2017-02-01', '2017-02-12'); -- 6 test fråga 6 
INSERT INTO Auktion(StartDatum, SlutDatum) VALUES('2017-02-11', '2017-02-13'); -- 7 
INSERT INTO Auktion(StartDatum, SlutDatum) VALUES('2017-02-08', '2017-02-10'); -- 8  testa fråga 7
INSERT INTO Auktion(StartDatum, SlutDatum) VALUES(NULL, NULL); -- fråga 2

-- AuktionsProdukt
INSERT INTO AuktionsProdukt(AuktionId, ProduktNummer) VALUES(1,1);
INSERT INTO AuktionsProdukt(AuktionId, ProduktNummer) VALUES(2,2);
INSERT INTO AuktionsProdukt(AuktionId, ProduktNummer) VALUES(3,3);
INSERT INTO AuktionsProdukt(AuktionId, ProduktNummer) VALUES(4,4);
INSERT INTO AuktionsProdukt(AuktionId, ProduktNummer) VALUES(5,5);
INSERT INTO AuktionsProdukt(AuktionId, ProduktNummer) VALUES(6,6); -- Auktion nr7 lagts inte bud på någon produkt 
INSERT INTO AuktionsProdukt(AuktionId, ProduktNummer) VALUES(8,8);

-- Kund
INSERT INTO Kund (Förnamn, Efternamn, Gata, Ort, Epost) VALUES('Lisa', 'Strömberg', 'Körsbärsgatan 5', 'Stockholm', 'lisa@mail.com,');
INSERT INTO Kund (Förnamn, Efternamn, Gata, Ort, Epost) VALUES('Arnold', 'Johansson', 'terminategatan 12', 'Göteborg', 'ilbeback@mail.com');
INSERT INTO Kund (Förnamn, Efternamn, Gata, Ort, Epost) VALUES('Erik', 'Eriksson', 'kylgatan 25', 'Linköping', 'erikeriksson@mail.com');
INSERT INTO Kund (Förnamn, Efternamn, Gata, Ort, Epost) VALUES('Gunde', 'Svan', 'FortBoyard 23', 'Stockholm', 'theshit@mail.com');
INSERT INTO Kund (Förnamn, Efternamn, Gata, Ort, Epost) VALUES('Sven', 'Svensson', 'svennegatan 100', 'Göteborg', 'svensson@yahoo.com');
INSERT INTO Kund (Förnamn, Efternamn, Gata, Ort, Epost) VALUES('Rolf', 'Nilsson', 'stigen 26', 'Linköping', 'nilssson@mail.co,');
INSERT INTO Kund (Förnamn, Efternamn, Gata, Ort, Epost) VALUES('Anders', 'Larsson', 'hackestifen 1', 'Gotland', 'larsson@gmail.com');

-- Bud
INSERT INTO Bud (AuktionId, KundNummer, BudDatum, Tid, Budsumma) VALUES(1,2, '2016-01-03', '11:10', 9000); -- Lisa,OljeTavla
INSERT INTO Bud (AuktionId, KundNummer, BudDatum, Tid, Budsumma) VALUES(2,2, '2016-04-09', '15:00', 17400);
INSERT INTO Bud (AuktionId, KundNummer, BudDatum, Tid, Budsumma) VALUES(2,3, '2016-04-10', '16:30', 17550);
INSERT INTO Bud (AuktionId, KundNummer, BudDatum, Tid, Budsumma) VALUES(2,4, '2016-04-10', '16:50', 19550); -- Gunde,Mahogny Bord
INSERT INTO Bud (AuktionId, KundNummer, BudDatum, Tid, Budsumma) VALUES(3,3, '2016-07-12', '11:00', 16000);
INSERT INTO Bud (AuktionId, KundNummer, BudDatum, Tid, Budsumma) VALUES(3,7, '2016-07-12', '12:00', 20000); -- Anders,Mahogny Stol
INSERT INTO Bud (AuktionId, KundNummer, BudDatum, Tid, Budsumma) VALUES(4,4, '2017-02-03', '13:00', 22000); -- inte såld
INSERT INTO Bud (AuktionId, KundNummer, BudDatum, Tid, Budsumma) VALUES(5,5, '2017-02-07', '10:00', 31700);
INSERT INTO Bud (AuktionId, KundNummer, BudDatum, Tid, Budsumma) VALUES(5,2, '2017-02-01', '15:00', 33200); -- inte såld
INSERT INTO Bud (AuktionId, KundNummer, BudDatum, Tid, Budsumma) VALUES(6,6, '2017-02-01', '14:00', 14300);
INSERT INTO Bud (AuktionId, KundNummer, BudDatum, Tid, Budsumma) VALUES(6,4, '2017-02-05', '15:00', 15000); -- inte såld
INSERT INTO Bud (AuktionId, KundNummer, BudDatum, Tid, Budsumma) VALUES(4,7, '2017-02-03', '13:30', 23400);
INSERT INTO Bud (AuktionId, KundNummer, BudDatum, Tid, Budsumma) VALUES(4,1, '2017-02-03', '13:40', 30000); -- såld acceptpris= budsumma
INSERT INTO Bud (AuktionId, KundNummer, BudDatum, Tid, Budsumma) VALUES(8,1, '2017-02-09', '13:40', 35000); -- 
INSERT INTO Bud (AuktionId, KundNummer, BudDatum, Tid, Budsumma) VALUES(8,2, '2017-02-09', '15:00', 51000); -- testa fråga 7
INSERT INTO Bud (AuktionId, KundNummer, BudDatum, Tid, Budsumma) VALUES(8,3, '2017-02-09', '15:10', 52000); -- testa fråga 7

-- auktionshistorik
INSERT INTO Auktionshistorik(auktionshistorikId,Produktnummer,SlutPris,SlutDatum) VALUES(1,1,9000,'2016-01-03'); -- Lisa
INSERT INTO Auktionshistorik(auktionshistorikId,Produktnummer,SlutPris,SlutDatum) VALUES(2,2,19550,'2016-04-10'); -- Gunde Svan
INSERT INTO Auktionshistorik(auktionshistorikId,Produktnummer,SlutPris,SlutDatum) VALUES(3,3,20000,'2016-07-12'); -- Anders Larsson