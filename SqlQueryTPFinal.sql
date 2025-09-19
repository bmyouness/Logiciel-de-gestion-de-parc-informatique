CREATE VIEW Vue_AgeMatériel AS
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
FROM Matériel m
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
        
        PRINT 'Matériel ajouté avec succès.';
    END TRY
    BEGIN CATCH
        PRINT 'Erreur lors de l''ajout du matériel: ' + ERROR_MESSAGE();
    END CATCH
END;





CREATE TRIGGER tr_VerifierDateMateriel
ON Matériel
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    IF EXISTS (SELECT 1 FROM inserted WHERE DateMiseEnService > GETDATE())
    BEGIN
        RAISERROR('Impossible d''ajouter du matériel avec une date future.', 16, 1);
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



-- Si la table Client existe déjà
ALTER TABLE Client
ADD CONSTRAINT CHK_Siret_Length 
CHECK (LEN(Siret) = 14 OR Siret IS NULL);