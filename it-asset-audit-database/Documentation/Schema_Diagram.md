# 🗄️ Database Schema Documentation

## IT Asset Audit Database - Schema Reference

---

## 📊 Entity Relationship Diagram

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         IT ASSET AUDIT DATABASE                              │
└─────────────────────────────────────────────────────────────────────────────┘

┌──────────────────────┐
│    Departments       │
├──────────────────────┤
│ PK │ DepartmentID   │─────┐
│    │ DepartmentName │     │
│    │ DepartmentCode │     │
│    │ ManagerName    │     │
│    │ CostCenter     │     │
│    │ Location       │     │
│    │ CreatedDate    │     │
│    │ ModifiedDate   │     │
└──────────────────────┘     │
                             │
                             │ (1:N)
                             │
         ┌───────────────────┼───────────────────┐
         │                   │                   │
         ▼                   ▼                   │
┌──────────────────────┐ ┌──────────────────────┐
│       Users          │ │   HardwareAssets     │
├──────────────────────┤ ├──────────────────────┤
│ PK │ UserID         │ │ PK │ AssetID         │
│    │ FirstName      │ │    │ SerialNumber    │
│    │ LastName       │ │    │ AssetTag        │
│    │ EmployeeID     │ │    │ DeviceType      │
│    │ Email          │ │    │ Manufacturer    │
│ FK │ DepartmentID   │─┘    │ Model           │
│    │ JobTitle       │      │ FK │ UserID     │─┐
│    │ HireDate       │      │ FK │ DepartmentID│─┘
│    │ TerminationDate│      │    │ PurchaseDate│
│    │ Status         │      │    │ PurchaseCost│
│    │ CreatedDate    │      │    │ WarrantyExp │
│    │ ModifiedDate   │      │    │ Status      │
└──────────────────────┘      │    │ SourceSystem│
                              │    │ LastAuditDate│
                              │    │ Notes       │
                              │    │ CreatedDate │
                              │    │ ModifiedDate│
                              └──────────────────┘
                                      │
                                      │ (1:N)
                                      │
                    ┌─────────────────┼─────────────────┐
                    │                 │                 │
                    ▼                 ▼                 ▼
         ┌─────────────────────┐ ┌──────────────┐ ┌──────────────────┐
         │ SoftwareInstallations│ │ DataQuality  │ │ ReconciliationR. │
         ├─────────────────────┤ │   Issues     │ ├──────────────────┤
         │ PK │ InstallID      │ ├──────────────┤ │ PK │Reconciliat..│
         │ FK │ AssetID        │─┤ PK │IssueID  │ │    │ReconcilDate │
         │    │ SoftwareName   │ │ FK │AssetID  │─┤    │SerialNumber │
         │    │ Version        │ │    │IssueType│ │ FK │InventoryA..│
         │    │ Publisher      │ │    │IssueDes.│ │ FK │SCCM_ID     │
         │    │ LicenseKey     │ │    │DetectedOn│ │    │MatchStatus │
         │    │ LicenseType    │ └──────────────┘ │    │ConflictType│
         │    │ InstallDate    │                  │    │ConflictDet.│
         │    │ ExpirationDate │                  │    │ResolutionS.│
         │    │ IsCompliant    │                  │    │CreatedDate │
         │    │ SourceSystem   │                  └──────────────────┘
         │    │ CreatedDate    │
         │    │ ModifiedDate   │
         └─────────────────────┘

┌──────────────────────┐         ┌──────────────────────┐
│    SCCM_Assets       │         │     AuditLog         │
├──────────────────────┤         ├──────────────────────┤
│ PK │ SCCM_ID        │         │ PK │ AuditID         │
│    │ SerialNumber   │         │    │ AuditDate       │
│    │ DeviceName     │         │    │ AuditType       │
│    │ ComputerName   │         │    │ Severity        │
│    │ LastSeenDate   │         │    │ EntityType      │
│    │ DeviceType     │         │    │ EntityID        │
│    │ Manufacturer   │         │    │ IssueDescription│
│    │ Model          │         │    │ RecommendedActn │
│    │ OperatingSystem│         │    │ Status          │
│    │ OSVersion      │         │    │ ResolvedDate    │
│    │ IPAddress      │         │    │ ResolvedBy      │
│    │ MACAddress     │         │    │ Notes           │
│    │ Status         │         └──────────────────────┘
│    │ Domain         │
│    │ LastUser       │         ┌──────────────────────┐
│    │ ImportDate     │         │ DataQualityMetrics   │
│    │ CreatedDate    │         ├──────────────────────┤
│    │ ModifiedDate   │         │ PK │ MetricID        │
└──────────────────────┘         │    │ MetricDate      │
                                 │    │ TotalAssets     │
                                 │    │ AssetsWithUsers │
                                 │    │ AssetsW/oUsers  │
                                 │    │ DuplicateSerials│
                                 │    │ MissingSerials  │
                                 │    │ ExpiredWarranties│
                                 │    │ OrphanedSoftware│
                                 │    │ SCCMDiscrepancy │
                                 │    │ ComplianceScore │
                                 │    │ DataQualityScore│
                                 │    │ CreatedDate     │
                                 └──────────────────────┘

Legend:
  PK = Primary Key
  FK = Foreign Key
  (1:N) = One-to-Many Relationship
```

---

## 📋 Table Definitions

### 1. **Departments**

Core organizational structure table.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| DepartmentID | INT | PK, IDENTITY | Unique department identifier |
| DepartmentName | NVARCHAR(100) | NOT NULL, UNIQUE | Department name |
| DepartmentCode | NVARCHAR(20) | NOT NULL | Short code for department |
| ManagerName | NVARCHAR(100) | NULL | Department manager |
| CostCenter | NVARCHAR(50) | NULL | Financial cost center code |
| Location | NVARCHAR(100) | NULL | Physical location |
| CreatedDate | DATETIME | DEFAULT GETDATE() | Record creation timestamp |
| ModifiedDate | DATETIME | DEFAULT GETDATE() | Last modification timestamp |

**Sample Data:** 15 departments (IT, HR, Finance, Sales, etc.)

---

### 2. **Users**

Employee information and status tracking.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| UserID | INT | PK, IDENTITY | Unique user identifier |
| FirstName | NVARCHAR(50) | NOT NULL | Employee first name |
| LastName | NVARCHAR(50) | NOT NULL | Employee last name |
| EmployeeID | NVARCHAR(20) | NOT NULL, UNIQUE | Company employee ID |
| Email | NVARCHAR(100) | NULL | Email address |
| DepartmentID | INT | FK → Departments | Associated department |
| JobTitle | NVARCHAR(100) | NULL | Current job title |
| HireDate | DATE | NULL | Date of hire |
| TerminationDate | DATE | NULL | Termination date if applicable |
| Status | NVARCHAR(20) | DEFAULT 'Active' | Active, Inactive, Terminated |
| CreatedDate | DATETIME | DEFAULT GETDATE() | Record creation timestamp |
| ModifiedDate | DATETIME | DEFAULT GETDATE() | Last modification timestamp |

**Constraints:**
- CHECK: `Status IN ('Active', 'Inactive', 'Terminated')`

**Sample Data:** 800 users with realistic names and assignments

---

### 3. **HardwareAssets**

Central inventory of all hardware assets.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| AssetID | INT | PK, IDENTITY | Unique asset identifier |
| SerialNumber | NVARCHAR(100) | NOT NULL | Manufacturer serial number |
| AssetTag | NVARCHAR(50) | NULL | Company asset tag |
| DeviceType | NVARCHAR(50) | NOT NULL | Type of device |
| Manufacturer | NVARCHAR(100) | NULL | Device manufacturer |
| Model | NVARCHAR(100) | NULL | Device model |
| UserID | INT | FK → Users | Currently assigned user |
| DepartmentID | INT | FK → Departments | Associated department |
| PurchaseDate | DATE | NULL | Date of purchase |
| PurchaseCost | DECIMAL(10,2) | NULL | Original purchase cost |
| WarrantyExpiration | DATE | NULL | Warranty end date |
| Status | NVARCHAR(20) | DEFAULT 'Active' | Current asset status |
| SourceSystem | NVARCHAR(50) | NULL | Data source system |
| LastAuditDate | DATE | NULL | Last physical audit date |
| Notes | NVARCHAR(MAX) | NULL | Additional notes |
| CreatedDate | DATETIME | DEFAULT GETDATE() | Record creation timestamp |
| ModifiedDate | DATETIME | DEFAULT GETDATE() | Last modification timestamp |

**Constraints:**
- CHECK: `DeviceType IN ('Laptop', 'Desktop', 'Monitor', 'Printer', 'Server', 'Tablet', 'Phone')`
- CHECK: `Status IN ('Active', 'Retired', 'Lost', 'Disposed', 'In Repair', 'In Storage')`
- CHECK: `SourceSystem IN ('Inventory', 'SCCM', 'Manual', 'ServiceNow')`

**Sample Data:** 1,000 assets (600 laptops, 300 desktops, 100 servers)

**Indexes:**
- `IX_HardwareAssets_UserID`
- `IX_HardwareAssets_DepartmentID`
- `IX_HardwareAssets_Status`
- `IX_HardwareAssets_SerialNumber`

---

### 4. **SoftwareInstallations**

Software installed on hardware assets.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| InstallID | INT | PK, IDENTITY | Unique installation identifier |
| AssetID | INT | FK → HardwareAssets, NOT NULL | Associated hardware asset |
| SoftwareName | NVARCHAR(200) | NOT NULL | Software product name |
| Version | NVARCHAR(50) | NULL | Software version |
| Publisher | NVARCHAR(100) | NULL | Software publisher |
| LicenseKey | NVARCHAR(100) | NULL | License key |
| LicenseType | NVARCHAR(50) | NULL | Type of license |
| InstallDate | DATE | NULL | Installation date |
| ExpirationDate | DATE | NULL | License expiration date |
| IsCompliant | BIT | DEFAULT 1 | Compliance status flag |
| SourceSystem | NVARCHAR(50) | NULL | Data source |
| CreatedDate | DATETIME | DEFAULT GETDATE() | Record creation timestamp |
| ModifiedDate | DATETIME | DEFAULT GETDATE() | Last modification timestamp |

**Constraints:**
- CHECK: `LicenseType IN ('Commercial', 'Open Source', 'Freeware', 'Trial', 'Enterprise', 'Subscription', 'Perpetual', 'Freemium', 'Free')`
- ON DELETE CASCADE (when parent asset is deleted)

**Sample Data:** 2,000 software installations across assets

**Indexes:**
- `IX_SoftwareInstallations_AssetID`

---

### 5. **SCCM_Assets**

Data imported from System Center Configuration Manager.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| SCCM_ID | INT | PK, IDENTITY | Unique SCCM record identifier |
| SerialNumber | NVARCHAR(100) | NOT NULL | Device serial number |
| DeviceName | NVARCHAR(100) | NULL | SCCM device name |
| ComputerName | NVARCHAR(100) | NULL | Network computer name |
| LastSeenDate | DATETIME | NULL | Last time device was seen |
| DeviceType | NVARCHAR(50) | NULL | Type of device |
| Manufacturer | NVARCHAR(100) | NULL | Device manufacturer |
| Model | NVARCHAR(100) | NULL | Device model |
| OperatingSystem | NVARCHAR(100) | NULL | Installed OS |
| OSVersion | NVARCHAR(50) | NULL | OS version number |
| IPAddress | NVARCHAR(50) | NULL | Current IP address |
| MACAddress | NVARCHAR(50) | NULL | MAC address |
| Status | NVARCHAR(20) | NULL | SCCM status |
| Domain | NVARCHAR(100) | NULL | Network domain |
| LastUser | NVARCHAR(100) | NULL | Last logged in user |
| ImportDate | DATETIME | DEFAULT GETDATE() | Date imported from SCCM |
| CreatedDate | DATETIME | DEFAULT GETDATE() | Record creation timestamp |
| ModifiedDate | DATETIME | DEFAULT GETDATE() | Last modification timestamp |

**Constraints:**
- CHECK: `Status IN ('Active', 'Retired', 'Offline', 'Unknown', 'Online')`

**Sample Data:** 900 SCCM records (700 matching inventory + 200 "ghost" assets)

**Indexes:**
- `IX_SCCM_Assets_SerialNumber`
- `IX_SCCM_Assets_LastSeenDate`

---

### 6. **DataQualityIssues**

Tracks identified data quality problems.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| IssueID | INT | PK, IDENTITY | Unique issue identifier |
| AssetID | INT | FK → HardwareAssets, NULL | Related asset if applicable |
| IssueType | NVARCHAR(100) | NOT NULL | Category of issue |
| IssueDescription | NVARCHAR(MAX) | NULL | Detailed description |
| DetectedOn | DATETIME | DEFAULT GETDATE() | When issue was detected |

**Common Issue Types:**
- Duplicate Serial Number
- Missing Serial Number
- Missing Asset Tag
- Software on Retired Asset
- No Assigned User
- No Department Assigned
- SCCM Ghost Asset
- Missing from SCCM
- Expired Warranty
- Expired Software License
- User Without Assets
- Asset Assigned to Terminated User

**Sample Data:** Auto-populated with ~200+ detected issues

---

### 7. **AuditLog**

Comprehensive audit trail for all quality checks.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| AuditID | INT | PK, IDENTITY | Unique audit record identifier |
| AuditDate | DATETIME | DEFAULT GETDATE() | Audit timestamp |
| AuditType | NVARCHAR(100) | NOT NULL | Type of audit performed |
| Severity | NVARCHAR(20) | NULL | Issue severity level |
| EntityType | NVARCHAR(50) | NULL | Type of entity audited |
| EntityID | INT | NULL | ID of audited entity |
| IssueDescription | NVARCHAR(MAX) | NULL | Description of finding |
| RecommendedAction | NVARCHAR(MAX) | NULL | Suggested remediation |
| Status | NVARCHAR(50) | DEFAULT 'Open' | Current status |
| ResolvedDate | DATETIME | NULL | Resolution date |
| ResolvedBy | NVARCHAR(100) | NULL | Who resolved the issue |
| Notes | NVARCHAR(MAX) | NULL | Additional notes |

**Constraints:**
- CHECK: `Severity IN ('Critical', 'High', 'Medium', 'Low', 'Info')`
- CHECK: `Status IN ('Open', 'In Progress', 'Resolved', 'Ignored')`

**Indexes:**
- `IX_AuditLog_AuditDate`
- `IX_AuditLog_Status`

---

### 8. **DataQualityMetrics**

Time-series metrics for trend analysis.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| MetricID | INT | PK, IDENTITY | Unique metric record identifier |
| MetricDate | DATE | DEFAULT GETDATE() | Date of metric snapshot |
| TotalAssets | INT | NULL | Total asset count |
| AssetsWithUsers | INT | NULL | Assets with assigned users |
| AssetsWithoutUsers | INT | NULL | Unassigned assets |
| DuplicateSerialNumbers | INT | NULL | Count of duplicate serials |
| MissingSerialNumbers | INT | NULL | Count of missing serials |
| ExpiredWarranties | INT | NULL | Count of expired warranties |
| OrphanedSoftware | INT | NULL | Software on inactive assets |
| SCCMDiscrepancies | INT | NULL | SCCM reconciliation issues |
| ComplianceScore | DECIMAL(5,2) | NULL | Overall compliance percentage |
| DataQualityScore | DECIMAL(5,2) | NULL | Overall data quality score |
| CreatedDate | DATETIME | DEFAULT GETDATE() | Record creation timestamp |

**Purpose:** Track data quality improvements over time

---

### 9. **ReconciliationResults**

Results of inventory vs SCCM matching process.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| ReconciliationID | INT | PK, IDENTITY | Unique reconciliation record |
| ReconciliationDate | DATETIME | DEFAULT GETDATE() | When reconciliation was run |
| SerialNumber | NVARCHAR(100) | NULL | Serial number being matched |
| InventoryAssetID | INT | FK → HardwareAssets, NULL | Inventory record ID |
| SCCM_ID | INT | FK → SCCM_Assets, NULL | SCCM record ID |
| MatchStatus | NVARCHAR(50) | NULL | Result of matching |
| ConflictType | NVARCHAR(100) | NULL | Type of conflict if any |
| ConflictDetails | NVARCHAR(MAX) | NULL | Details of conflict |
| ResolutionStatus | NVARCHAR(50) | DEFAULT 'Pending' | Resolution status |
| CreatedDate | DATETIME | DEFAULT GETDATE() | Record creation timestamp |

**Constraints:**
- CHECK: `MatchStatus IN ('Matched', 'Inventory Only', 'SCCM Only', 'Conflict')`

**Match Status Types:**
- **Matched**: Serial number found in both systems
- **Inventory Only**: Asset in inventory but not in SCCM
- **SCCM Only**: Device in SCCM but not in inventory ("ghost asset")
- **Conflict**: Found in both but with conflicting data

---

## 🔗 Relationships

### One-to-Many Relationships

1. **Departments → Users** (1:N)
   - One department has many users
   - FK: `Users.DepartmentID → Departments.DepartmentID`

2. **Departments → HardwareAssets** (1:N)
   - One department has many assets
   - FK: `HardwareAssets.DepartmentID → Departments.DepartmentID`

3. **Users → HardwareAssets** (1:N)
   - One user can have multiple assets
   - FK: `HardwareAssets.UserID → Users.UserID`

4. **HardwareAssets → SoftwareInstallations** (1:N)
   - One asset can have multiple software installations
   - FK: `SoftwareInstallations.AssetID → HardwareAssets.AssetID`
   - CASCADE DELETE enabled

5. **HardwareAssets → DataQualityIssues** (1:N)
   - One asset can have multiple quality issues
   - FK: `DataQualityIssues.AssetID → HardwareAssets.AssetID`

6. **HardwareAssets → ReconciliationResults** (1:N)
   - One asset can have multiple reconciliation records
   - FK: `ReconciliationResults.InventoryAssetID → HardwareAssets.AssetID`

7. **SCCM_Assets → ReconciliationResults** (1:N)
   - One SCCM record can have multiple reconciliation records
   - FK: `ReconciliationResults.SCCM_ID → SCCM_Assets.SCCM_ID`

---

## 🔍 Indexes

### Performance Optimization

All indexes are **NONCLUSTERED** to optimize query performance without affecting primary key clustering.

| Table | Index Name | Columns | Purpose |
|-------|-----------|---------|---------|
| HardwareAssets | IX_HardwareAssets_UserID | UserID | Fast user-based lookups |
| HardwareAssets | IX_HardwareAssets_DepartmentID | DepartmentID | Department filtering |
| HardwareAssets | IX_HardwareAssets_Status | Status | Status-based queries |
| HardwareAssets | IX_HardwareAssets_SerialNumber | SerialNumber | Serial number searches |
| SoftwareInstallations | IX_SoftwareInstallations_AssetID | AssetID | Software by asset queries |
| SCCM_Assets | IX_SCCM_Assets_SerialNumber | SerialNumber | SCCM reconciliation |
| SCCM_Assets | IX_SCCM_Assets_LastSeenDate | LastSeenDate | Time-based queries |
| Users | IX_Users_EmployeeID | EmployeeID | Employee ID lookups |
| Users | IX_Users_DepartmentID | DepartmentID | Department user queries |
| AuditLog | IX_AuditLog_AuditDate | AuditDate | Temporal audit queries |
| AuditLog | IX_AuditLog_Status | Status | Status filtering |

---

## 📊 Data Integrity Rules

### Check Constraints

1. **Users.Status**
   - Must be: 'Active', 'Inactive', or 'Terminated'

2. **HardwareAssets.DeviceType**
   - Must be: 'Laptop', 'Desktop', 'Monitor', 'Printer', 'Server', 'Tablet', or 'Phone'

3. **HardwareAssets.Status**
   - Must be: 'Active', 'Retired', 'Lost', 'Disposed', 'In Repair', or 'In Storage'

4. **HardwareAssets.SourceSystem**
   - Must be: 'Inventory', 'SCCM', 'Manual', or 'ServiceNow'

5. **SoftwareInstallations.LicenseType**
   - Must be: 'Commercial', 'Open Source', 'Freeware', 'Trial', 'Enterprise', 'Subscription', 'Perpetual', 'Freemium', or 'Free'

6. **SCCM_Assets.Status**
   - Must be: 'Active', 'Retired', 'Offline', 'Unknown', or 'Online'

7. **AuditLog.Severity**
   - Must be: 'Critical', 'High', 'Medium', 'Low', or 'Info'

8. **AuditLog.Status**
   - Must be: 'Open', 'In Progress', 'Resolved', or 'Ignored'

9. **ReconciliationResults.MatchStatus**
   - Must be: 'Matched', 'Inventory Only', 'SCCM Only', or 'Conflict'

### Foreign Key Constraints

- **Cascading Deletes**: Only enabled on `SoftwareInstallations.AssetID`
  - When a hardware asset is deleted, all associated software installations are automatically removed
- **All other FKs**: Standard referential integrity (no cascade)

---

## 📈 Sample Data Statistics

| Table | Record Count | Notes |
|-------|--------------|-------|
| Departments | 15 | IT, HR, Finance, Sales, etc. |
| Users | 800 | 4% terminated, 96% active |
| HardwareAssets | 1,000 | 60% laptops, 30% desktops, 10% servers |
| SoftwareInstallations | 2,000 | Multiple software per device |
| SCCM_Assets | 900 | 700 matched + 200 ghost assets |
| DataQualityIssues | 200+ | Auto-generated from quality checks |
| AuditLog | Variable | Grows with each audit |
| DataQualityMetrics | Variable | Time-series data |
| ReconciliationResults | Variable | Updated with each reconciliation |

---

## 🎯 Key Design Decisions

### 1. **Serial Number Handling**
- Serial numbers are NOT NULL in HardwareAssets but can be empty strings
- This allows data quality checks to identify missing serial numbers
- Reconciliation uses serial numbers as the primary matching key

### 2. **Status Fields**
- Multiple status fields (User.Status, HardwareAssets.Status, SCCM_Assets.Status)
- Allows independent lifecycle tracking for different entities
- Status values enforced via CHECK constraints

### 3. **Temporal Tracking**
- CreatedDate and ModifiedDate on all core tables
- Separate audit tables for historical analysis
- LastSeenDate in SCCM for staleness detection

### 4. **Data Quality First**
- Dedicated tables for tracking issues (DataQualityIssues)
- Metrics table for trending (DataQualityMetrics)
- R Services integration for advanced analytics

### 5. **Flexible Relationships**
- Users can have multiple assets (common for laptop + phone)
- Assets can temporarily have no user (in storage, unassigned)
- Software can exist on retired hardware (for cleanup tracking)

---

## 🔄 Common Query Patterns

### Find Assets by User
```sql
SELECT * FROM HardwareAssets 
WHERE UserID = @UserID AND Status = 'Active';
```

### Find Software on Asset
```sql
SELECT * FROM SoftwareInstallations 
WHERE AssetID = @AssetID;
```

### Find Unmatched SCCM Devices
```sql
SELECT s.* FROM SCCM_Assets s
LEFT JOIN HardwareAssets h ON s.SerialNumber = h.SerialNumber
WHERE h.AssetID IS NULL;
```

### Find Data Quality Issues by Type
```sql
SELECT * FROM DataQualityIssues 
WHERE IssueType = 'Duplicate Serial Number';
```

### Department Asset Summary
```sql
SELECT d.DepartmentName, COUNT(h.AssetID) AS AssetCount
FROM Departments d
LEFT JOIN HardwareAssets h ON d.DepartmentID = h.DepartmentID
GROUP BY d.DepartmentName;
```

---

## 📝 Notes

- All NVARCHAR fields support Unicode characters
- DATETIME fields use SQL Server's default precision
- DECIMAL(10,2) used for currency values (purchase cost)
- IDENTITY columns start at 1 with increment of 1
- All tables include audit timestamps (CreatedDate, ModifiedDate)

---

## 🔧 Maintenance Considerations

### Index Maintenance
- Rebuild indexes quarterly: `ALTER INDEX ALL ON [TableName] REBUILD;`
- Update statistics weekly: `UPDATE STATISTICS [TableName];`

### Data Archival
- Archive resolved AuditLog records older than 2 years
- Keep DataQualityMetrics for trending (do not archive)
- Retain ReconciliationResults for 1 year

### Backup Strategy
- Full backup: Daily
- Differential backup: Every 6 hours
- Transaction log backup: Every 15 minutes

---

<div align="center">

**📚 For implementation details, see [Asset Audit Script.sql](../Asset%20Audit%20Script.sql)**

**🔬 For R Services analytics, see [R Data Quality Check Script.sql](../R%20Data%20Quality%20Check%20Script.sql)**

</div>