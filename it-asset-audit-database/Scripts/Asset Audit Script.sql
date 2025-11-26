-- =============================================
-- IT Asset Audit Database - Complete Script
-- =============================================

-- Create Database
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'ITAssetAudit')
BEGIN
    CREATE DATABASE ITAssetAudit;
END
GO

USE ITAssetAudit;
GO

-- =============================================
-- Table: Departments
-- =============================================
IF OBJECT_ID('DataQualityIssues', 'U') IS NOT NULL DROP TABLE DataQualityIssues;
IF OBJECT_ID('SoftwareInstallations', 'U') IS NOT NULL DROP TABLE SoftwareInstallations;
IF OBJECT_ID('ReconciliationResults', 'U') IS NOT NULL DROP TABLE ReconciliationResults;
IF OBJECT_ID('DataQualityMetrics', 'U') IS NOT NULL DROP TABLE DataQualityMetrics;
IF OBJECT_ID('AuditLog', 'U') IS NOT NULL DROP TABLE AuditLog;
IF OBJECT_ID('SCCM_Assets', 'U') IS NOT NULL DROP TABLE SCCM_Assets;
IF OBJECT_ID('HardwareAssets', 'U') IS NOT NULL DROP TABLE HardwareAssets;
IF OBJECT_ID('Users', 'U') IS NOT NULL DROP TABLE Users;
IF OBJECT_ID('Departments', 'U') IS NOT NULL DROP TABLE Departments;
GO

CREATE TABLE Departments (
    DepartmentID INT PRIMARY KEY IDENTITY(1,1),
    DepartmentName NVARCHAR(100) NOT NULL UNIQUE,
    DepartmentCode NVARCHAR(20) NOT NULL,
    ManagerName NVARCHAR(100),
    CostCenter NVARCHAR(50),
    Location NVARCHAR(100),
    CreatedDate DATETIME DEFAULT GETDATE(),
    ModifiedDate DATETIME DEFAULT GETDATE()
);

-- =============================================
-- Table: Users
-- =============================================
CREATE TABLE Users (
    UserID INT PRIMARY KEY IDENTITY(1,1),
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    EmployeeID NVARCHAR(20) NOT NULL UNIQUE,
    Email NVARCHAR(100),
    DepartmentID INT,
    JobTitle NVARCHAR(100),
    HireDate DATE,
    TerminationDate DATE NULL,
    Status NVARCHAR(20) DEFAULT 'Active' CHECK (Status IN ('Active', 'Inactive', 'Terminated')),
    CreatedDate DATETIME DEFAULT GETDATE(),
    ModifiedDate DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_Users_Departments FOREIGN KEY (DepartmentID) 
        REFERENCES Departments(DepartmentID)
);

-- =============================================
-- Table: HardwareAssets
-- =============================================
CREATE TABLE HardwareAssets (
    AssetID INT PRIMARY KEY IDENTITY(1,1),
    SerialNumber NVARCHAR(100) NOT NULL,
    AssetTag NVARCHAR(50),
    DeviceType NVARCHAR(50) NOT NULL CHECK (DeviceType IN ('Laptop', 'Desktop', 'Monitor', 'Printer', 'Server', 'Tablet', 'Phone')),
    Manufacturer NVARCHAR(100),
    Model NVARCHAR(100),
    UserID INT NULL,
    DepartmentID INT,
    PurchaseDate DATE,
    PurchaseCost DECIMAL(10,2),
    WarrantyExpiration DATE,
    Status NVARCHAR(20) DEFAULT 'Active' CHECK (Status IN ('Active', 'Retired', 'Lost', 'Disposed', 'In Repair', 'In Storage')),
    SourceSystem NVARCHAR(50) CHECK (SourceSystem IN ('Inventory', 'SCCM', 'Manual', 'ServiceNow')),
    LastAuditDate DATE,
    Notes NVARCHAR(MAX),
    CreatedDate DATETIME DEFAULT GETDATE(),
    ModifiedDate DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_HardwareAssets_Users FOREIGN KEY (UserID) 
        REFERENCES Users(UserID),
    CONSTRAINT FK_HardwareAssets_Departments FOREIGN KEY (DepartmentID) 
        REFERENCES Departments(DepartmentID)
);

-- =============================================
-- Table: SoftwareInstallations
-- =============================================
CREATE TABLE SoftwareInstallations (
    InstallID INT PRIMARY KEY IDENTITY(1,1),
    AssetID INT NOT NULL,
    SoftwareName NVARCHAR(200) NOT NULL,
    Version NVARCHAR(50),
    Publisher NVARCHAR(100),
    LicenseKey NVARCHAR(100),
    LicenseType NVARCHAR(50) CHECK (LicenseType IN ('Commercial', 'Open Source', 'Freeware', 'Trial', 'Enterprise', 'Subscription', 'Perpetual', 'Freemium', 'Free')),
    InstallDate DATE,
    ExpirationDate DATE NULL,
    IsCompliant BIT DEFAULT 1,
    SourceSystem NVARCHAR(50),
    CreatedDate DATETIME DEFAULT GETDATE(),
    ModifiedDate DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_SoftwareInstallations_HardwareAssets FOREIGN KEY (AssetID) 
        REFERENCES HardwareAssets(AssetID) ON DELETE CASCADE
);

-- =============================================
-- Table: SCCM_Assets
-- =============================================
CREATE TABLE SCCM_Assets (
    SCCM_ID INT PRIMARY KEY IDENTITY(1,1),
    SerialNumber NVARCHAR(100) NOT NULL,
    DeviceName NVARCHAR(100),
    ComputerName NVARCHAR(100),
    LastSeenDate DATETIME,
    DeviceType NVARCHAR(50),
    Manufacturer NVARCHAR(100),
    Model NVARCHAR(100),
    OperatingSystem NVARCHAR(100),
    OSVersion NVARCHAR(50),
    IPAddress NVARCHAR(50),
    MACAddress NVARCHAR(50),
    Status NVARCHAR(20) CHECK (Status IN ('Active', 'Retired', 'Offline', 'Unknown', 'Online')),
    Domain NVARCHAR(100),
    LastUser NVARCHAR(100),
    ImportDate DATETIME DEFAULT GETDATE(),
    CreatedDate DATETIME DEFAULT GETDATE(),
    ModifiedDate DATETIME DEFAULT GETDATE()
);

-- =============================================
-- Table: AuditLog
-- =============================================
CREATE TABLE AuditLog (
    AuditID INT PRIMARY KEY IDENTITY(1,1),
    AuditDate DATETIME DEFAULT GETDATE(),
    AuditType NVARCHAR(100) NOT NULL,
    Severity NVARCHAR(20) CHECK (Severity IN ('Critical', 'High', 'Medium', 'Low', 'Info')),
    EntityType NVARCHAR(50),
    EntityID INT,
    IssueDescription NVARCHAR(MAX),
    RecommendedAction NVARCHAR(MAX),
    Status NVARCHAR(50) DEFAULT 'Open' CHECK (Status IN ('Open', 'In Progress', 'Resolved', 'Ignored')),
    ResolvedDate DATETIME NULL,
    ResolvedBy NVARCHAR(100),
    Notes NVARCHAR(MAX)
);

-- =============================================
-- Table: DataQualityMetrics
-- =============================================
CREATE TABLE DataQualityMetrics (
    MetricID INT PRIMARY KEY IDENTITY(1,1),
    MetricDate DATE DEFAULT CAST(GETDATE() AS DATE),
    TotalAssets INT,
    AssetsWithUsers INT,
    AssetsWithoutUsers INT,
    DuplicateSerialNumbers INT,
    MissingSerialNumbers INT,
    ExpiredWarranties INT,
    OrphanedSoftware INT,
    SCCMDiscrepancies INT,
    ComplianceScore DECIMAL(5,2),
    DataQualityScore DECIMAL(5,2),
    CreatedDate DATETIME DEFAULT GETDATE()
);

-- =============================================
-- Table: ReconciliationResults
-- =============================================
CREATE TABLE ReconciliationResults (
    ReconciliationID INT PRIMARY KEY IDENTITY(1,1),
    ReconciliationDate DATETIME DEFAULT GETDATE(),
    SerialNumber NVARCHAR(100),
    InventoryAssetID INT NULL,
    SCCM_ID INT NULL,
    MatchStatus NVARCHAR(50) CHECK (MatchStatus IN ('Matched', 'Inventory Only', 'SCCM Only', 'Conflict')),
    ConflictType NVARCHAR(100),
    ConflictDetails NVARCHAR(MAX),
    ResolutionStatus NVARCHAR(50) DEFAULT 'Pending',
    CreatedDate DATETIME DEFAULT GETDATE()
);

-- =============================================
-- Table: DataQualityIssues
-- =============================================
CREATE TABLE DataQualityIssues (
    IssueID INT IDENTITY(1,1) PRIMARY KEY,
    AssetID INT NULL,
    IssueType NVARCHAR(100) NOT NULL,
    IssueDescription NVARCHAR(MAX) NULL,
    DetectedOn DATETIME DEFAULT GETDATE()
);
GO

-- =============================================
-- Performance Indexes
-- =============================================
CREATE NONCLUSTERED INDEX IX_HardwareAssets_UserID ON HardwareAssets(UserID);
CREATE NONCLUSTERED INDEX IX_HardwareAssets_DepartmentID ON HardwareAssets(DepartmentID);
CREATE NONCLUSTERED INDEX IX_HardwareAssets_Status ON HardwareAssets(Status);
CREATE NONCLUSTERED INDEX IX_HardwareAssets_SerialNumber ON HardwareAssets(SerialNumber);
CREATE NONCLUSTERED INDEX IX_SoftwareInstallations_AssetID ON SoftwareInstallations(AssetID);
CREATE NONCLUSTERED INDEX IX_SCCM_Assets_SerialNumber ON SCCM_Assets(SerialNumber);
CREATE NONCLUSTERED INDEX IX_SCCM_Assets_LastSeenDate ON SCCM_Assets(LastSeenDate);
CREATE NONCLUSTERED INDEX IX_Users_EmployeeID ON Users(EmployeeID);
CREATE NONCLUSTERED INDEX IX_Users_DepartmentID ON Users(DepartmentID);
CREATE NONCLUSTERED INDEX IX_AuditLog_AuditDate ON AuditLog(AuditDate);
CREATE NONCLUSTERED INDEX IX_AuditLog_Status ON AuditLog(Status);
GO

-- =============================================
-- INSERT DATA: Departments
-- =============================================
SET IDENTITY_INSERT Departments ON;

INSERT INTO Departments 
([DepartmentID], [DepartmentName], [DepartmentCode], [ManagerName], [CostCenter], [Location])
VALUES
(1, 'Information Technology', 'IT', 'Sarah Johnson', 'CC-1001', 'Building A - Floor 3'),
(2, 'Human Resources', 'HR', 'Michael Chen', 'CC-1002', 'Building A - Floor 2'),
(3, 'Finance', 'FIN', 'Jennifer Martinez', 'CC-1003', 'Building B - Floor 1'),
(4, 'Sales', 'SALES', 'Robert Williams', 'CC-1004', 'Building C - Floor 2'),
(5, 'Marketing', 'MKT', 'Emily Davis', 'CC-1005', 'Building C - Floor 3'),
(6, 'Operations', 'OPS', 'David Brown', 'CC-1006', 'Building B - Floor 2'),
(7, 'Customer Service', 'CS', 'Lisa Anderson', 'CC-1007', 'Building D - Floor 1'),
(8, 'Research & Development', 'RND', 'James Wilson', 'CC-1008', 'Building E - Floor 4'),
(9, 'Legal', 'LEGAL', 'Patricia Taylor', 'CC-1009', 'Building A - Floor 1'),
(10, 'Procurement', 'PROC', 'Christopher Moore', 'CC-1010', 'Building B - Floor 3'),
(11, 'Quality Assurance', 'QA', 'Amanda Jackson', 'CC-1011', 'Building E - Floor 2'),
(12, 'Engineering', 'ENG', 'Daniel White', 'CC-1012', 'Building E - Floor 3'),
(13, 'Product Management', 'PM', 'Michelle Harris', 'CC-1013', 'Building C - Floor 1'),
(14, 'Business Intelligence', 'BI', 'Kevin Martin', 'CC-1014', 'Building A - Floor 4'),
(15, 'Facilities', 'FAC', 'Nancy Thompson', 'CC-1015', 'Building D - Floor 2');

SET IDENTITY_INSERT Departments OFF;
GO

-- =============================================
-- INSERT DATA: Users (800 users)
-- =============================================
SET IDENTITY_INSERT Users ON;

DECLARE @UserCounter INT = 1;
DECLARE @FirstNames TABLE (Name NVARCHAR(50));
DECLARE @LastNames TABLE (Name NVARCHAR(50));

INSERT INTO @FirstNames VALUES 
('James'),('Mary'),('John'),('Patricia'),('Robert'),('Jennifer'),('Michael'),('Linda'),
('William'),('Barbara'),('David'),('Elizabeth'),('Richard'),('Susan'),('Joseph'),('Jessica'),
('Thomas'),('Sarah'),('Charles'),('Karen'),('Christopher'),('Nancy'),('Daniel'),('Lisa'),
('Matthew'),('Betty'),('Anthony'),('Margaret'),('Mark'),('Sandra'),('Donald'),('Ashley'),
('Steven'),('Kimberly'),('Paul'),('Emily'),('Andrew'),('Donna'),('Joshua'),('Michelle'),
('Kenneth'),('Dorothy'),('Kevin'),('Carol'),('Brian'),('Amanda'),('George'),('Melissa'),
('Edward'),('Deborah'),('Ronald'),('Stephanie'),('Timothy'),('Rebecca'),('Jason'),('Sharon'),
('Jeffrey'),('Laura'),('Ryan'),('Cynthia'),('Jacob'),('Kathleen'),('Gary'),('Amy'),
('Nicholas'),('Shirley'),('Eric'),('Angela'),('Jonathan'),('Helen'),('Stephen'),('Anna'),
('Larry'),('Brenda'),('Justin'),('Pamela'),('Scott'),('Nicole'),('Brandon'),('Emma'),
('Benjamin'),('Samantha'),('Samuel'),('Katherine'),('Raymond'),('Christine'),('Gregory'),('Debra'),
('Frank'),('Rachel'),('Alexander'),('Catherine'),('Patrick'),('Carolyn'),('Jack'),('Ruth'),
('Dennis'),('Maria'),('Jerry'),('Heather'),('Tyler'),('Diane'),('Aaron'),('Virginia'),
('Jose'),('Julie'),('Adam'),('Joyce'),('Henry'),('Victoria'),('Nathan'),('Olivia'),
('Douglas'),('Kelly'),('Zachary'),('Christina'),('Peter'),('Lauren'),('Kyle'),('Joan'),
('Walter'),('Evelyn'),('Ethan'),('Judith'),('Jeremy'),('Megan'),('Harold'),('Cheryl'),
('Keith'),('Andrea'),('Christian'),('Hannah'),('Roger'),('Martha'),('Noah'),('Jacqueline'),
('Gerald'),('Frances'),('Carl'),('Gloria'),('Terry'),('Ann'),('Sean'),('Teresa'),
('Austin'),('Kathryn'),('Arthur'),('Sara'),('Lawrence'),('Janice'),('Jesse'),('Jean'),
('Dylan'),('Alice'),('Jordan'),('Madison'),('Bryan'),('Doris'),('Billy'),('Abigail'),
('Bruce'),('Julia'),('Albert'),('Judy'),('Willie'),('Grace'),('Gabriel'),('Denise'),
('Logan'),('Amber'),('Alan'),('Marilyn'),('Juan'),('Beverly'),('Wayne'),('Danielle'),
('Roy'),('Theresa'),('Ralph'),('Sophia'),('Randy'),('Marie'),('Eugene'),('Diana'),
('Vincent'),('Brittany'),('Russell'),('Natalie'),('Louis'),('Isabella'),('Philip'),('Charlotte'),
('Bobby'),('Rose'),('Johnny'),('Alexis');

INSERT INTO @LastNames VALUES
('Smith'),('Johnson'),('Williams'),('Brown'),('Jones'),('Garcia'),('Miller'),('Davis'),
('Rodriguez'),('Martinez'),('Hernandez'),('Lopez'),('Gonzalez'),('Wilson'),('Anderson'),('Thomas'),
('Taylor'),('Moore'),('Jackson'),('Martin'),('Lee'),('Perez'),('Thompson'),('White'),
('Harris'),('Sanchez'),('Clark'),('Ramirez'),('Lewis'),('Robinson'),('Walker'),('Young'),
('Allen'),('King'),('Wright'),('Scott'),('Torres'),('Nguyen'),('Hill'),('Flores'),
('Green'),('Adams'),('Nelson'),('Baker'),('Hall'),('Rivera'),('Campbell'),('Mitchell'),
('Carter'),('Roberts'),('Gomez'),('Phillips'),('Evans'),('Turner'),('Diaz'),('Parker'),
('Cruz'),('Edwards'),('Collins'),('Reyes'),('Stewart'),('Morris'),('Morales'),('Murphy'),
('Cook'),('Rogers'),('Gutierrez'),('Ortiz'),('Morgan'),('Cooper'),('Peterson'),('Bailey'),
('Reed'),('Kelly'),('Howard'),('Ramos'),('Kim'),('Cox'),('Ward'),('Richardson'),
('Watson'),('Brooks'),('Chavez'),('Wood'),('James'),('Bennett'),('Gray'),('Mendoza'),
('Ruiz'),('Hughes'),('Price'),('Alvarez'),('Castillo'),('Sanders'),('Patel'),('Myers'),
('Long'),('Ross'),('Foster'),('Jimenez'),('Powell'),('Jenkins'),('Perry'),('Russell'),
('Sullivan'),('Bell'),('Coleman'),('Butler'),('Henderson'),('Barnes'),('Gonzales'),('Fisher'),
('Vasquez'),('Simmons'),('Romero'),('Jordan'),('Patterson'),('Alexander'),('Hamilton'),('Graham'),
('Reynolds'),('Griffin'),('Wallace'),('Moreno'),('West'),('Cole'),('Hayes'),('Bryant'),
('Herrera'),('Gibson'),('Ellis'),('Tran'),('Medina'),('Aguilar'),('Stevens'),('Murray'),
('Ford'),('Castro'),('Marshall'),('Owens'),('Harrison'),('Fernandez'),('McDonald'),('Woods'),
('Washington'),('Kennedy'),('Wells'),('Vargas'),('Henry'),('Chen'),('Freeman'),('Webb'),
('Tucker'),('Guzman'),('Burns'),('Crawford'),('Olson'),('Simpson'),('Porter'),('Hunter'),
('Gordon'),('Mendez'),('Silva'),('Shaw'),('Snyder'),('Mason'),('Dixon'),('Munoz'),
('Hunt'),('Hicks'),('Holmes'),('Palmer'),('Wagner'),('Black'),('Robertson'),('Boyd'),
('Rose'),('Stone'),('Salazar'),('Fox'),('Warren'),('Mills'),('Meyer'),('Rice'),
('Schmidt'),('Garza'),('Daniels'),('Ferguson'),('Nichols'),('Stephens'),('Soto'),('Weaver'),
('Ryan'),('Gardner'),('Payne'),('Grant'),('Dunn'),('Kelley'),('Spencer'),('Hawkins');

-- Generate 800 users
WHILE @UserCounter <= 800
BEGIN
    INSERT INTO Users 
    ([UserID], [FirstName], [LastName], [EmployeeID], [Email], [DepartmentID], [JobTitle], [HireDate], [TerminationDate], [Status])
    SELECT 
        @UserCounter,
        (SELECT TOP 1 Name FROM @FirstNames ORDER BY NEWID()),
        (SELECT TOP 1 Name FROM @LastNames ORDER BY NEWID()),
        'EMP' + RIGHT('00000' + CAST(@UserCounter AS VARCHAR(5)), 5),
        LOWER((SELECT TOP 1 Name FROM @FirstNames ORDER BY NEWID())) + '.' + 
        LOWER((SELECT TOP 1 Name FROM @LastNames ORDER BY NEWID())) + '@company.com',
        CASE 
            WHEN @UserCounter % 50 = 0 THEN NULL
            ELSE (ABS(CHECKSUM(NEWID())) % 15) + 1 
        END,
        CASE (ABS(CHECKSUM(NEWID())) % 20)
            WHEN 0 THEN 'Senior Manager'
            WHEN 1 THEN 'Manager'
            WHEN 2 THEN 'Team Lead'
            WHEN 3 THEN 'Senior Analyst'
            WHEN 4 THEN 'Analyst'
            WHEN 5 THEN 'Specialist'
            WHEN 6 THEN 'Coordinator'
            WHEN 7 THEN 'Administrator'
            WHEN 8 THEN 'Developer'
            WHEN 9 THEN 'Engineer'
            WHEN 10 THEN 'Technician'
            WHEN 11 THEN 'Consultant'
            WHEN 12 THEN 'Associate'
            WHEN 13 THEN 'Representative'
            WHEN 14 THEN 'Assistant'
            WHEN 15 THEN 'Director'
            WHEN 16 THEN 'Vice President'
            WHEN 17 THEN 'Supervisor'
            WHEN 18 THEN 'Officer'
            ELSE 'Staff'
        END,
        DATEADD(DAY, -ABS(CHECKSUM(NEWID())) % 3650, GETDATE()),
        CASE 
            WHEN @UserCounter % 25 = 0 THEN DATEADD(DAY, -ABS(CHECKSUM(NEWID())) % 365, GETDATE())
            ELSE NULL 
        END,
        CASE 
            WHEN @UserCounter % 25 = 0 THEN 'Terminated'
            ELSE 'Active'
        END;
    
    SET @UserCounter = @UserCounter + 1;
END

SET IDENTITY_INSERT Users OFF;
GO

-- =============================================
-- INSERT DATA: HardwareAssets (1000 assets)
-- =============================================
SET IDENTITY_INSERT HardwareAssets ON;

DECLARE @AssetCounter INT = 1;
DECLARE @Manufacturers TABLE (Name NVARCHAR(100));
DECLARE @LaptopModels TABLE (Mfg NVARCHAR(100), Model NVARCHAR(100));
DECLARE @DesktopModels TABLE (Mfg NVARCHAR(100), Model NVARCHAR(100));
DECLARE @ServerModels TABLE (Mfg NVARCHAR(100), Model NVARCHAR(100));

INSERT INTO @Manufacturers VALUES ('Dell'),('HP'),('Lenovo'),('Apple'),('Microsoft'),('Asus'),('Acer');

INSERT INTO @LaptopModels VALUES
('Dell', 'Latitude 5420'),('Dell', 'Latitude 7420'),('Dell', 'XPS 13'),('Dell', 'Precision 5560'),
('HP', 'EliteBook 840 G8'),('HP', 'ProBook 450 G8'),('HP', 'ZBook Firefly 14 G8'),('HP', 'Spectre x360'),
('Lenovo', 'ThinkPad X1 Carbon'),('Lenovo', 'ThinkPad T14'),('Lenovo', 'ThinkPad P15'),('Lenovo', 'Yoga 9i'),
('Apple', 'MacBook Pro 14"'),('Apple', 'MacBook Pro 16"'),('Apple', 'MacBook Air M1'),('Apple', 'MacBook Air M2'),
('Microsoft', 'Surface Laptop 4'),('Microsoft', 'Surface Book 3'),('Asus', 'ZenBook 14'),('Acer', 'Swift 3');

INSERT INTO @DesktopModels VALUES
('Dell', 'OptiPlex 7090'),('Dell', 'OptiPlex 5090'),('Dell', 'Precision 3650'),
('HP', 'EliteDesk 800 G8'),('HP', 'ProDesk 400 G7'),('HP', 'Z2 Tower G9'),
('Lenovo', 'ThinkCentre M90a'),('Lenovo', 'ThinkStation P340'),
('Apple', 'iMac 24"'),('Apple', 'Mac Mini M1'),('Asus', 'ExpertCenter D7');

INSERT INTO @ServerModels VALUES
('Dell', 'PowerEdge R740'),('Dell', 'PowerEdge R640'),('Dell', 'PowerEdge T340'),
('HP', 'ProLiant DL380 Gen10'),('HP', 'ProLiant DL360 Gen10'),('HP', 'ProLiant ML350 Gen10'),
('Lenovo', 'ThinkSystem SR650'),('Lenovo', 'ThinkSystem SR630');

WHILE @AssetCounter <= 1000
BEGIN
    DECLARE @DeviceType NVARCHAR(50);
    DECLARE @Manufacturer NVARCHAR(100);
    DECLARE @Model NVARCHAR(100);
    DECLARE @SerialNumber NVARCHAR(100);
    DECLARE @UserID INT;
    DECLARE @DepartmentID INT;
    DECLARE @Status NVARCHAR(20);
    DECLARE @PurchaseDate DATE;
    DECLARE @SourceSystem NVARCHAR(50);
    
    -- Determine device type (60% Laptop, 30% Desktop, 10% Server)
    SET @DeviceType = CASE 
        WHEN @AssetCounter % 10 = 0 THEN 'Server'
        WHEN @AssetCounter % 10 IN (1,2,3) THEN 'Desktop'
        ELSE 'Laptop'
    END;
    
    -- Select manufacturer and model based on device type
    IF @DeviceType = 'Laptop'
    BEGIN
        SELECT TOP 1 @Manufacturer = Mfg, @Model = Model FROM @LaptopModels ORDER BY NEWID();
    END
    ELSE IF @DeviceType = 'Desktop'
    BEGIN
        SELECT TOP 1 @Manufacturer = Mfg, @Model = Model FROM @DesktopModels ORDER BY NEWID();
    END
    ELSE
    BEGIN
        SELECT TOP 1 @Manufacturer = Mfg, @Model = Model FROM @ServerModels ORDER BY NEWID();
    END
    
    -- Generate serial number with intentional issues (but never NULL for constraint)
    SET @SerialNumber = CASE
        WHEN @AssetCounter % 100 = 1 THEN ''    -- Empty serial numbers (will be caught as data quality issue)
        WHEN @AssetCounter % 50 = 0 THEN 'SN' + RIGHT('0000000' + CAST((@AssetCounter - 50) AS VARCHAR(7)), 7)  -- Duplicate serials
        ELSE 'SN' + RIGHT('0000000' + CAST(@AssetCounter AS VARCHAR(7)), 7)
    END;
    
    -- Determine status (85% Active, 10% Retired, 5% In Storage)
    SET @Status = CASE 
        WHEN @AssetCounter % 20 = 0 THEN 'Retired'
        WHEN @AssetCounter % 20 = 1 THEN 'In Storage'
        ELSE 'Active'
    END;
    
    -- Assign user (15% no user for laptops/desktops, servers typically have no user)
    SET @UserID = CASE
        WHEN @DeviceType = 'Server' THEN NULL
        WHEN @AssetCounter % 7 = 0 THEN NULL
        WHEN @AssetCounter % 200 = 0 THEN (ABS(CHECKSUM(NEWID())) % 800) + 1
        ELSE (ABS(CHECKSUM(NEWID())) % 800) + 1
    END;
    
    -- Assign department (5% no department)
    SET @DepartmentID = CASE
        WHEN @AssetCounter % 20 = 0 THEN NULL
        ELSE (ABS(CHECKSUM(NEWID())) % 15) + 1
    END;
    
    -- Purchase date (within last 5 years)
    SET @PurchaseDate = DATEADD(DAY, -ABS(CHECKSUM(NEWID())) % 1825, GETDATE());
    
    -- Source System - Fixed to match CHECK constraint
    SET @SourceSystem = CASE (ABS(CHECKSUM(NEWID())) % 4)
        WHEN 0 THEN 'Manual'
        WHEN 1 THEN 'SCCM'
        WHEN 2 THEN 'Inventory'
        ELSE 'ServiceNow'
    END;
    
    INSERT INTO HardwareAssets
    ([AssetID], [SerialNumber], [AssetTag], [DeviceType], [Manufacturer], [Model], [UserID], [DepartmentID], 
     [PurchaseDate], [PurchaseCost], [WarrantyExpiration], [Status], [SourceSystem], [LastAuditDate])
    VALUES
    (
        @AssetCounter,
        @SerialNumber,
        'AT' + RIGHT('000000' + CAST(@AssetCounter AS VARCHAR(6)), 6),
        @DeviceType,
        @Manufacturer,
        @Model,
        @UserID,
        @DepartmentID,
        @PurchaseDate,
        CASE @DeviceType
            WHEN 'Laptop' THEN ROUND(800 + (RAND(CHECKSUM(NEWID())) * 1200), 2)
            WHEN 'Desktop' THEN ROUND(600 + (RAND(CHECKSUM(NEWID())) * 800), 2)
            WHEN 'Server' THEN ROUND(2000 + (RAND(CHECKSUM(NEWID())) * 8000), 2)
        END,
        DATEADD(YEAR, 3, @PurchaseDate),
        @Status,
        @SourceSystem,
        CASE 
            WHEN @AssetCounter % 10 = 0 THEN NULL
            ELSE DATEADD(DAY, -ABS(CHECKSUM(NEWID())) % 180, GETDATE())
        END
    );
    
    SET @AssetCounter = @AssetCounter + 1;
END

SET IDENTITY_INSERT HardwareAssets OFF;
GO

-- =============================================
-- INSERT DATA: SCCM_Assets
-- =============================================
SET IDENTITY_INSERT SCCM_Assets ON;

-- Insert matching assets from HardwareAssets (first 700)
INSERT INTO SCCM_Assets
([SCCM_ID], [SerialNumber], [DeviceName], [ComputerName], [LastSeenDate], [DeviceType], 
 [Manufacturer], [Model], [OperatingSystem], [OSVersion], [IPAddress], [MACAddress], [Status], [Domain], [LastUser])
SELECT 
    AssetID,
    SerialNumber,
    'PC-' + AssetTag,
    UPPER(LEFT(Manufacturer, 3)) + '-' + AssetTag,
    DATEADD(DAY, -ABS(CHECKSUM(NEWID())) % 30, GETDATE()),
    DeviceType,
    Manufacturer,
    Model,
    CASE DeviceType
        WHEN 'Server' THEN 'Windows Server 2019'
        WHEN 'Laptop' THEN CASE (ABS(CHECKSUM(NEWID())) % 3)
            WHEN 0 THEN 'Windows 10 Pro'
            WHEN 1 THEN 'Windows 11 Pro'
            ELSE 'macOS Monterey'
        END
        ELSE 'Windows 10 Pro'
    END,
    CASE 
        WHEN DeviceType = 'Server' THEN '10.0.17763'
        ELSE '10.0.19044'
    END,
    CAST((ABS(CHECKSUM(NEWID())) % 254) + 1 AS VARCHAR) + '.' +
    CAST((ABS(CHECKSUM(NEWID())) % 254) + 1 AS VARCHAR) + '.' +
    CAST((ABS(CHECKSUM(NEWID())) % 254) + 1 AS VARCHAR) + '.' +
    CAST((ABS(CHECKSUM(NEWID())) % 254) + 1 AS VARCHAR),
    SUBSTRING(REPLACE(CAST(NEWID() AS VARCHAR(36)), '-', ''), 1, 12),
    CASE 
        WHEN Status = 'Active' THEN 'Online'
        WHEN Status = 'Retired' THEN 'Offline'
        ELSE 'Unknown'
    END,
    'CORP.COMPANY.COM',
    'CORP\User' + CAST(ISNULL(UserID, 0) AS VARCHAR(10))
FROM HardwareAssets
WHERE AssetID <= 700 AND SerialNumber IS NOT NULL AND SerialNumber <> '';

-- Insert ghost assets (assets in SCCM but not in inventory) - 200 assets
DECLARE @GhostCounter INT = 1001;
WHILE @GhostCounter <= 1200
BEGIN
    INSERT INTO SCCM_Assets
    ([SCCM_ID], [SerialNumber], [DeviceName], [ComputerName], [LastSeenDate], [DeviceType], 
     [Manufacturer], [Model], [OperatingSystem], [OSVersion], [IPAddress], [MACAddress], [Status], [Domain], [LastUser])
    VALUES
    (
        @GhostCounter,
        'GHOST-SN' + RIGHT('0000000' + CAST(@GhostCounter AS VARCHAR(7)), 7),
        'PC-GHOST' + CAST(@GhostCounter AS VARCHAR(10)),
        'GHOST-' + CAST(@GhostCounter AS VARCHAR(10)),
        DATEADD(DAY, -ABS(CHECKSUM(NEWID())) % 365, GETDATE()),
        CASE (ABS(CHECKSUM(NEWID())) % 2) WHEN 0 THEN 'Laptop' ELSE 'Desktop' END,
        CASE (ABS(CHECKSUM(NEWID())) % 3) WHEN 0 THEN 'Dell' WHEN 1 THEN 'HP' ELSE 'Lenovo' END,
        'Unknown Model',
        'Windows 10 Pro',
        '10.0.19041',
        CAST((ABS(CHECKSUM(NEWID())) % 254) + 1 AS VARCHAR) + '.' +
        CAST((ABS(CHECKSUM(NEWID())) % 254) + 1 AS VARCHAR) + '.' +
        CAST((ABS(CHECKSUM(NEWID())) % 254) + 1 AS VARCHAR) + '.' +
        CAST((ABS(CHECKSUM(NEWID())) % 254) + 1 AS VARCHAR),
        SUBSTRING(REPLACE(CAST(NEWID() AS VARCHAR(36)), '-', ''), 1, 12),
        'Offline',
        'CORP.COMPANY.COM',
        'CORP\UnknownUser'
    );
    
    SET @GhostCounter = @GhostCounter + 1;
END

SET IDENTITY_INSERT SCCM_Assets OFF;
GO

-- =============================================
-- INSERT DATA: SoftwareInstallations (2000 installations)
-- =============================================
SET IDENTITY_INSERT SoftwareInstallations ON;

DECLARE @SoftwareList TABLE (SoftwareName NVARCHAR(200), Publisher NVARCHAR(100), LicenseType NVARCHAR(50));

INSERT INTO @SoftwareList VALUES
('Microsoft Office 365', 'Microsoft Corporation', 'Subscription'),
('Microsoft Office 2019', 'Microsoft Corporation', 'Perpetual'),
('Adobe Acrobat Pro DC', 'Adobe Systems', 'Subscription'),
('Adobe Creative Cloud', 'Adobe Systems', 'Subscription'),
('AutoCAD 2022', 'Autodesk', 'Subscription'),
('Zoom Client', 'Zoom Video Communications', 'Free'),
('Slack', 'Slack Technologies', 'Freemium'),
('Google Chrome', 'Google LLC', 'Free'),
('Mozilla Firefox', 'Mozilla Foundation', 'Free'),
('7-Zip', '7-Zip', 'Free'),
('WinRAR', 'RARLAB', 'Commercial'),
('Tableau Desktop', 'Tableau Software', 'Subscription'),
('Power BI Desktop', 'Microsoft Corporation', 'Free'),
('Visual Studio 2022', 'Microsoft Corporation', 'Subscription'),
('IntelliJ IDEA', 'JetBrains', 'Subscription'),
('Salesforce Desktop', 'Salesforce', 'Subscription'),
('SAP GUI', 'SAP SE', 'Enterprise'),
('Oracle Database Client', 'Oracle Corporation', 'Enterprise'),
('VMware Workstation', 'VMware', 'Perpetual'),
('Citrix Workspace', 'Citrix Systems', 'Enterprise');

DECLARE @InstallCounter INT = 1;

WHILE @InstallCounter <= 2000
BEGIN
    DECLARE @TargetAssetID INT;
    DECLARE @AssetStatus NVARCHAR(20);
    
    -- Select random asset from valid assets only
    SELECT TOP 1 
        @TargetAssetID = AssetID,
        @AssetStatus = Status
    FROM HardwareAssets
    WHERE DeviceType IN ('Laptop', 'Desktop')
        AND SerialNumber IS NOT NULL 
        AND SerialNumber <> ''
    ORDER BY NEWID();
    
    -- Only proceed if we found a valid asset
    IF @TargetAssetID IS NOT NULL
    BEGIN
        DECLARE @SoftwareName NVARCHAR(200);
        DECLARE @Publisher NVARCHAR(100);
        DECLARE @LicenseType NVARCHAR(50);
        
        SELECT TOP 1 
            @SoftwareName = SoftwareName,
            @Publisher = Publisher,
            @LicenseType = LicenseType
        FROM @SoftwareList
        ORDER BY NEWID();
        
        DECLARE @InstallDate DATE = DATEADD(DAY, -ABS(CHECKSUM(NEWID())) % 730, GETDATE());
        
        INSERT INTO SoftwareInstallations
        ([InstallID], [AssetID], [SoftwareName], [Version], [Publisher], [LicenseKey], [LicenseType], 
         [InstallDate], [ExpirationDate], [IsCompliant], [SourceSystem])
        VALUES
        (
            @InstallCounter,
            @TargetAssetID,
            @SoftwareName,
            CAST((ABS(CHECKSUM(NEWID())) % 10) + 1 AS VARCHAR) + '.' + 
            CAST((ABS(CHECKSUM(NEWID())) % 10) AS VARCHAR) + '.' +
            CAST((ABS(CHECKSUM(NEWID())) % 100) AS VARCHAR),
            @Publisher,
            CASE 
                WHEN @LicenseType IN ('Free', 'Freemium') THEN NULL
                ELSE UPPER(SUBSTRING(CAST(NEWID() AS VARCHAR(36)), 1, 8)) + '-' +
                     UPPER(SUBSTRING(CAST(NEWID() AS VARCHAR(36)), 10, 4)) + '-' +
                     UPPER(SUBSTRING(CAST(NEWID() AS VARCHAR(36)), 15, 4)) + '-' +
                     UPPER(SUBSTRING(CAST(NEWID() AS VARCHAR(36)), 20, 4))
            END,
            @LicenseType,
            @InstallDate,
            CASE 
                WHEN @LicenseType = 'Subscription' THEN DATEADD(YEAR, 1, @InstallDate)
                ELSE NULL
            END,
            CASE 
                WHEN @AssetStatus = 'Retired' THEN 0
                WHEN @LicenseType = 'Subscription' AND DATEADD(YEAR, 1, @InstallDate) < GETDATE() THEN 0
                ELSE 1
            END,
            'SCCM'
        );
    END
    
    SET @InstallCounter = @InstallCounter + 1;
END

SET IDENTITY_INSERT SoftwareInstallations OFF;
GO

-- =============================================
-- INSERT DATA QUALITY ISSUES
-- =============================================

-- Issue 1: Missing/Empty Serial Numbers
INSERT INTO DataQualityIssues 
([AssetID], [IssueType], [IssueDescription], [DetectedOn])
SELECT 
    AssetID, 
    'Missing Serial Number', 
    'Asset ' + CAST(AssetID AS VARCHAR(10)) + ' (' + DeviceType + ') is missing or has empty serial number', 
    GETDATE()
FROM HardwareAssets
WHERE SerialNumber IS NULL OR SerialNumber = '';

-- Issue 2: Duplicate Serial Numbers
INSERT INTO DataQualityIssues 
([AssetID], [IssueType], [IssueDescription], [DetectedOn])
SELECT 
    ha.AssetID,
    'Duplicate Serial Number',
    'Serial number "' + ha.SerialNumber + '" is used by ' + CAST(dup.DuplicateCount AS VARCHAR(10)) + ' assets (AssetIDs: ' + dup.AssetList + ')',
    GETDATE()
FROM HardwareAssets ha
INNER JOIN (
    SELECT 
        SerialNumber,
        COUNT(*) AS DuplicateCount,
        STRING_AGG(CAST(AssetID AS VARCHAR(10)), ', ') AS AssetList
    FROM HardwareAssets
    WHERE SerialNumber IS NOT NULL AND SerialNumber <> ''
    GROUP BY SerialNumber
    HAVING COUNT(*) > 1
) dup ON ha.SerialNumber = dup.SerialNumber;

-- Issue 3: Users with Multiple Assets
INSERT INTO DataQualityIssues 
([AssetID], [IssueType], [IssueDescription], [DetectedOn])
SELECT 
    ha.AssetID,
    'Multiple Assets Per User',
    'User ' + u.FirstName + ' ' + u.LastName + ' (UserID: ' + CAST(ha.UserID AS VARCHAR(10)) + 
    ') has ' + CAST(ua.AssetCount AS VARCHAR(10)) + ' assets assigned - potential duplicate assignment',
    GETDATE()
FROM HardwareAssets ha
INNER JOIN Users u ON ha.UserID = u.UserID
INNER JOIN (
    SELECT UserID, COUNT(*) AS AssetCount
    FROM HardwareAssets
    WHERE UserID IS NOT NULL AND DeviceType IN ('Laptop', 'Desktop')
    GROUP BY UserID
    HAVING COUNT(*) > 2
) ua ON ha.UserID = ua.UserID;

-- Issue 4: Software Installed on Retired Hardware
INSERT INTO DataQualityIssues 
([AssetID], [IssueType], [IssueDescription], [DetectedOn])
SELECT DISTINCT
    si.AssetID,
    'Software on Retired Asset',
    'Asset ' + CAST(si.AssetID AS VARCHAR(10)) + ' has ' + 
    CAST(COUNT(si.InstallID) OVER (PARTITION BY si.AssetID) AS VARCHAR(10)) + 
    ' software installations but is marked as ' + ha.Status,
    GETDATE()
FROM SoftwareInstallations si
INNER JOIN HardwareAssets ha ON si.AssetID = ha.AssetID
WHERE ha.Status IN ('Retired', 'In Storage');

-- Issue 5: Laptops/Desktops with No Assigned User
INSERT INTO DataQualityIssues 
([AssetID], [IssueType], [IssueDescription], [DetectedOn])
SELECT 
    AssetID,
    'No Assigned User',
    DeviceType + ' (AssetID: ' + CAST(AssetID AS VARCHAR(10)) + ', ' + 
    ISNULL(Manufacturer, 'Unknown') + ' ' + ISNULL(Model, 'Unknown') + 
    ') with status "' + Status + '" has no assigned user',
    GETDATE()
FROM HardwareAssets
WHERE UserID IS NULL 
  AND DeviceType IN ('Laptop', 'Desktop')
  AND Status = 'Active';

-- Issue 6: Assets with No Department
INSERT INTO DataQualityIssues 
([AssetID], [IssueType], [IssueDescription], [DetectedOn])
SELECT 
    AssetID,
    'No Department Assigned',
    'Asset ' + CAST(AssetID AS VARCHAR(10)) + ' (' + DeviceType + ', ' + 
    ISNULL(Manufacturer, 'Unknown') + ' ' + ISNULL(Model, 'Unknown') + 
    ') has no department assignment',
    GETDATE()
FROM HardwareAssets
WHERE DepartmentID IS NULL AND Status = 'Active';

-- Issue 7: SCCM Ghost Assets
INSERT INTO DataQualityIssues 
([AssetID], [IssueType], [IssueDescription], [DetectedOn])
SELECT 
    NULL,
    'SCCM Ghost Asset',
    'Device "' + sccm.ComputerName + '" (Serial: ' + sccm.SerialNumber + 
    ', SCCM_ID: ' + CAST(sccm.SCCM_ID AS VARCHAR(10)) + 
    ') exists in SCCM but not in Hardware Asset inventory. Last seen: ' + 
    CONVERT(VARCHAR(10), sccm.LastSeenDate, 120),
    GETDATE()
FROM SCCM_Assets sccm
LEFT JOIN HardwareAssets ha 
    ON sccm.SerialNumber = ha.SerialNumber
WHERE ha.AssetID IS NULL;

-- Issue 8: Assets in Inventory but Not in SCCM
INSERT INTO DataQualityIssues 
([AssetID], [IssueType], [IssueDescription], [DetectedOn])
SELECT 
    ha.AssetID,
    'Missing from SCCM',
    'Asset ' + CAST(ha.AssetID AS VARCHAR(10)) + ' (' + ha.DeviceType + 
    ', Serial: ' + ISNULL(ha.SerialNumber, 'N/A') + 
    ') exists in inventory but not found in SCCM - may be offline or not managed',
    GETDATE()
FROM HardwareAssets ha
LEFT JOIN SCCM_Assets sccm 
    ON ha.SerialNumber = sccm.SerialNumber
WHERE sccm.SCCM_ID IS NULL 
  AND ha.SerialNumber IS NOT NULL 
  AND ha.SerialNumber <> ''
  AND ha.Status = 'Active'
  AND ha.DeviceType IN ('Laptop', 'Desktop');

-- Issue 9: Expired Warranties on Active Assets
INSERT INTO DataQualityIssues 
([AssetID], [IssueType], [IssueDescription], [DetectedOn])
SELECT 
    AssetID,
    'Expired Warranty',
    'Asset ' + CAST(AssetID AS VARCHAR(10)) + ' (' + DeviceType + ', ' + 
    ISNULL(Manufacturer, 'Unknown') + ' ' + ISNULL(Model, 'Unknown') + 
    ') has an expired warranty (expired on ' + CONVERT(VARCHAR(10), WarrantyExpiration, 120) + ')',
    GETDATE()
FROM HardwareAssets
WHERE WarrantyExpiration < GETDATE()
  AND Status = 'Active';

-- Issue 10: Expired Software Licenses
INSERT INTO DataQualityIssues 
([AssetID], [IssueType], [IssueDescription], [DetectedOn])
SELECT 
    si.AssetID,
    'Expired Software License',
    'Software "' + si.SoftwareName + '" on Asset ' + CAST(si.AssetID AS VARCHAR(10)) + 
    ' has an expired license (expired on ' + CONVERT(VARCHAR(10), si.ExpirationDate, 120) + ')',
    GETDATE()
FROM SoftwareInstallations si
INNER JOIN HardwareAssets ha ON si.AssetID = ha.AssetID
WHERE si.ExpirationDate < GETDATE()
  AND ha.Status = 'Active';

-- Issue 11: Active Users with No Assets Assigned
INSERT INTO DataQualityIssues 
([AssetID], [IssueType], [IssueDescription], [DetectedOn])
SELECT 
    NULL,
    'User Without Assets',
    'Active user ' + u.FirstName + ' ' + u.LastName + ' (UserID: ' + CAST(u.UserID AS VARCHAR(10)) + 
    ', ' + ISNULL(u.JobTitle, 'No Title') + ') has no hardware assets assigned',
    GETDATE()
FROM Users u
LEFT JOIN HardwareAssets ha ON u.UserID = ha.UserID
WHERE ha.AssetID IS NULL 
  AND u.Status = 'Active'
  AND u.JobTitle NOT LIKE '%Intern%'
  AND u.JobTitle NOT LIKE '%Contractor%';

-- Issue 12: Assets Assigned to Terminated Users
INSERT INTO DataQualityIssues 
([AssetID], [IssueType], [IssueDescription], [DetectedOn])
SELECT 
    ha.AssetID,
    'Asset Assigned to Terminated User',
    'Asset ' + CAST(ha.AssetID AS VARCHAR(10)) + ' (' + ha.DeviceType + ') is assigned to terminated user ' + 
    u.FirstName + ' ' + u.LastName + ' (terminated on ' + CONVERT(VARCHAR(10), u.TerminationDate, 120) + ')',
    GETDATE()
FROM HardwareAssets ha
INNER JOIN Users u ON ha.UserID = u.UserID
WHERE u.Status = 'Terminated'
  AND ha.Status = 'Active';

GO

-- =============================================
-- Summary Queries
-- =============================================
PRINT '=== Database Setup Complete ===';
PRINT 'Departments: ' + CAST((SELECT COUNT(*) FROM Departments) AS VARCHAR(10));
PRINT 'Users: ' + CAST((SELECT COUNT(*) FROM Users) AS VARCHAR(10));
PRINT 'Hardware Assets: ' + CAST((SELECT COUNT(*) FROM HardwareAssets) AS VARCHAR(10));
PRINT 'SCCM Assets: ' + CAST((SELECT COUNT(*) FROM SCCM_Assets) AS VARCHAR(10));
PRINT 'Software Installations: ' + CAST((SELECT COUNT(*) FROM SoftwareInstallations) AS VARCHAR(10));
PRINT 'Data Quality Issues: ' + CAST((SELECT COUNT(*) FROM DataQualityIssues) AS VARCHAR(10));
GO
