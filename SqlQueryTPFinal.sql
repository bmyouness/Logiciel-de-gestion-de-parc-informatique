CREATE VIEW Vue_AgeMat�riel AS
SELECT 
    m.IdMateriel,
    m.NomMachine,
    m.AdresseIP,
    m.Description,
    m.DateMiseEnService,
    c.NomEntreprise,
    tm.NomMateriel AS TypeMateriel,
    DATEDIFF(YEAR, m.DateMiseEnService, GETDATE()) AS AgeAnnees,
    DATEDIFF(MONTH, m.DateMiseEnService, GETDATE()) AS AgeMois,
    DATEDIFF(DAY, m.DateMiseEnService, GETDATE()) AS AgeJours
FROM Mat�riel m
INNER JOIN Client c ON m.IdClient = c.IdClient
INNER JOIN Type_Materiel tm ON m.IdTypeMateriel = tm.IdTypeMateriel;




CREATE PROCEDURE sp_AjouterMateriel
    @NomMachine VARCHAR(50),
    @AdresseIP VARCHAR(50),
    @Description VARCHAR(50),
    @DateMiseEnService DATETIME,
    @IdTypeMateriel INT,
    @IdClient INT
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        INSERT INTO Material (
            NomMachine, 
            AdresseIP, 
            Description, 
            DateMiseEnService, 
            IdTypeMateriel, 
            IdClient
        )
        VALUES (
            @NomMachine,
            @AdresseIP,
            @Description,
            @DateMiseEnService,
            @IdTypeMateriel,
            @IdClient
        );
        
        PRINT 'Mat�riel ajout� avec succ�s.';
    END TRY
    BEGIN CATCH
        PRINT 'Erreur lors de l''ajout du mat�riel: ' + ERROR_MESSAGE();
    END CATCH
END;





CREATE TRIGGER tr_VerifierDateMateriel
ON Mat�riel
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    IF EXISTS (SELECT 1 FROM inserted WHERE DateMiseEnService > GETDATE())
    BEGIN
        RAISERROR('Impossible d''ajouter du mat�riel avec une date future.', 16, 1);
        ROLLBACK TRANSACTION;
    END
    ELSE
    BEGIN
        INSERT INTO Material (
            NomMachine, 
            AdresseIP, 
            Description, 
            DateMiseEnService, 
            IdTypeMateriel, 
            IdClient
        )
        SELECT 
            NomMachine, 
            AdresseIP, 
            Description, 
            DateMiseEnService, 
            IdTypeMateriel, 
            IdClient
        FROM inserted;
    END
END;



-- Si la table Client existe d�j�
ALTER TABLE Client
ADD CONSTRAINT CHK_Siret_Length 
CHECK (LEN(Siret) = 14 OR Siret IS NULL);