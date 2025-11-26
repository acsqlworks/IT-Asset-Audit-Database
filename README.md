# 🖥️ IT Asset Audit Database

<div align="center">

![SQL Server](https://img.shields.io/badge/SQL%20Server-2016%2B-CC2927?style=for-the-badge&logo=microsoft-sql-server&logoColor=white)
![R Services](https://img.shields.io/badge/R%20Services-Enabled-276DC3?style=for-the-badge&logo=r&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)
![Status](https://img.shields.io/badge/Status-Production%20Ready-success?style=for-the-badge)

**A comprehensive SQL Server solution for enterprise IT asset management with automated data quality monitoring**

[Features](#-features) • [Installation](#-installation) • [Usage](#-usage) • [Documentation](#-documentation) • [Contact](#-contact)

</div>

---

## 📖 Overview

The **IT Asset Audit Database** is an enterprise-grade SQL Server solution designed to streamline hardware asset tracking, software license management, and data quality assurance. Built with real-world IT operations in mind, this system integrates seamlessly with Microsoft SCCM and leverages SQL Server R Services for intelligent anomaly detection.

### Why This Project?

- **Automate Manual Processes**: Eliminate spreadsheet chaos with centralized asset tracking
- **Ensure Compliance**: Track software licenses and warranty expirations automatically
- **Data Quality First**: Built-in validation rules catch errors before they become problems
- **SCCM Integration**: Reconcile discovered devices with your inventory records
- **Audit-Ready**: Comprehensive logging and reporting for compliance requirements

---

## ✨ Features

### 🎯 Core Capabilities

- **Complete Asset Lifecycle Management**
  - Track hardware from procurement to disposal
  - Monitor warranty status and depreciation
  - Support for laptops, desktops, servers, and peripherals

- **Software License Compliance**
  - Track installations across all devices
  - Monitor subscription expirations
  - Identify unlicensed or non-compliant software

- **SCCM Reconciliation**
  - Automated matching between inventory and SCCM data
  - Identify "ghost assets" and missing devices
  - Network information tracking (IP, MAC addresses)

- **Intelligent Data Quality Monitoring**
  - 12+ automated data quality checks
  - R Services-powered anomaly detection
  - Real-time alerting for critical issues

### 🔍 Automated Quality Checks

| Check Type | Description |
|-----------|-------------|
| 🔄 Duplicate Serial Numbers | Identifies assets with identical serial numbers |
| ❌ Missing Identifiers | Flags assets without serial numbers or asset tags |
| 👻 Ghost Assets | Devices in SCCM but not in inventory |
| 📵 Offline Devices | Inventory items not appearing in SCCM |
| 👤 Assignment Issues | Unassigned devices or terminated user assets |
| ⚠️ Expired Warranties | Active assets with expired warranty coverage |
| 📜 License Violations | Expired software licenses on active devices |
| 🔢 Multiple Assignments | Users with excessive hardware allocations |

---

## 🗄️ Database Architecture

```
┌─────────────────┐     ┌──────────────┐     ┌─────────────────┐
│   Departments   │────▶│    Users     │────▶│ HardwareAssets  │
└─────────────────┘     └──────────────┘     └─────────────────┘
                                                       │
                                                       ▼
┌─────────────────┐     ┌──────────────┐     ┌─────────────────┐
│  SCCM_Assets    │────▶│Reconciliation│     │   Software      │
└─────────────────┘     │   Results    │     │ Installations   │
                        └──────────────┘     └─────────────────┘
                                                       │
┌─────────────────┐     ┌──────────────┐              │
│   AuditLog      │     │ DataQuality  │◀─────────────┘
└─────────────────┘     │   Issues     │
                        └──────────────┘
```

### Key Tables

- **`Departments`** - Organizational structure with cost centers
- **`Users`** - Employee records with status tracking
- **`HardwareAssets`** - Central inventory (1,000 sample records)
- **`SoftwareInstallations`** - License tracking (2,000 sample records)
- **`SCCM_Assets`** - Network discovery data (900 sample records)
- **`DataQualityIssues`** - Automated issue tracking
- **`AuditLog`** - Comprehensive audit trails
- **`ReconciliationResults`** - Inventory vs SCCM matching

---

## 🚀 Installation

### Prerequisites

```plaintext
✅ SQL Server 2016 or later
✅ SQL Server Management Studio (SSMS) or Azure Data Studio
✅ SQL Server R Services (optional, for advanced analytics)
```

### Quick Start

1. **Clone the repository**
   ```bash
   git clone https://github.com/acsqlworks/it-asset-audit-database.git
   cd it-asset-audit-database
   ```

2. **Create the database**
   ```sql
   -- Open 'Asset Audit Script.sql' in SSMS
   -- Execute the entire script (F5)
   -- This creates the database, tables, and sample data
   ```

3. **Enable R Services** (Optional)
   ```sql
   EXEC sp_configure 'external scripts enabled', 1;
   RECONFIGURE WITH OVERRIDE;
   -- Restart SQL Server service
   ```

4. **Run data quality checks**
   ```sql
   -- Execute 'R Data Quality Check Script.sql'
   -- This populates anomaly detection results
   ```

### Sample Data

The installation includes production-ready sample data:
- 15 departments across business functions
- 800 users with realistic job titles
- 1,000 hardware assets (600 laptops, 300 desktops, 100 servers)
- 2,000 software installations with various license types
- Pre-configured data quality issues for testing

---

## 💻 Usage

### Common Queries

#### Asset Inventory by Department
```sql
SELECT 
    d.DepartmentName,
    COUNT(ha.AssetID) AS TotalAssets,
    SUM(CASE WHEN ha.DeviceType = 'Laptop' THEN 1 ELSE 0 END) AS Laptops,
    SUM(CASE WHEN ha.DeviceType = 'Desktop' THEN 1 ELSE 0 END) AS Desktops,
    SUM(CASE WHEN ha.Status = 'Active' THEN 1 ELSE 0 END) AS ActiveAssets
FROM Departments d
LEFT JOIN HardwareAssets ha ON d.DepartmentID = ha.DepartmentID
GROUP BY d.DepartmentName
ORDER BY TotalAssets DESC;
```

#### Critical Data Quality Issues
```sql
SELECT 
    IssueType,
    COUNT(*) AS IssueCount,
    MIN(DetectedOn) AS FirstDetected
FROM DataQualityIssues
GROUP BY IssueType
HAVING COUNT(*) > 5
ORDER BY IssueCount DESC;
```

#### Software License Compliance Report
```sql
SELECT 
    si.SoftwareName,
    si.Publisher,
    COUNT(*) AS TotalInstallations,
    SUM(CASE WHEN si.IsCompliant = 0 THEN 1 ELSE 0 END) AS NonCompliant,
    SUM(CASE WHEN si.ExpirationDate < GETDATE() THEN 1 ELSE 0 END) AS Expired
FROM SoftwareInstallations si
INNER JOIN HardwareAssets ha ON si.AssetID = ha.AssetID
WHERE ha.Status = 'Active'
GROUP BY si.SoftwareName, si.Publisher
ORDER BY NonCompliant DESC;
```

#### SCCM Reconciliation Dashboard
```sql
SELECT 
    MatchStatus,
    COUNT(*) AS RecordCount,
    CAST(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER() AS DECIMAL(5,2)) AS PercentageOfTotal
FROM ReconciliationResults
GROUP BY MatchStatus
ORDER BY RecordCount DESC;
```

---

## 📊 R Services Integration

The system uses SQL Server R Services for advanced statistical analysis:

```sql
EXEC sp_execute_external_script
    @language = N'R',
    @script = N'
        # Analyze hardware asset data
        hardware_data <- InputDataSet
        
        # Detect duplicate serial numbers
        serial_counts <- table(hardware_data$SerialNumber)
        duplicates <- names(serial_counts[serial_counts > 1])
        
        # Identify warranty expiration patterns
        # Statistical outlier detection
        # Pattern recognition for assignment anomalies
        
        OutputDataSet <- anomaly_results
    ',
    @input_data_1 = N'SELECT * FROM HardwareAssets';
```

**Benefits:**
- Complex pattern recognition beyond SQL capabilities
- Statistical outlier detection
- Machine learning readiness
- Scalable processing for large datasets

---

## 📁 Project Structure

```
it-asset-audit-database/
├── README.md
├── Scripts/
│   ├── Asset Audit Script.sql          # Main database creation (37 KB)
│   ├── R Data Quality Check Script.sql # R Services analytics (17 KB)
│   └── DataQualityIssues.sql           # Issue tracking queries (1 KB)
├── Reports/
│   ├── DataQualityIssues.xlsx     # Excel dashboard (280 KB)
│   ├── Report Of Anomalies.xlsx   # Summary report (1 KB)
│   ├── Unresolved Anomalies.xlsx  # Active issues (53 KB)
│   └── IssueCount.xlsx            # Metrics dashboard (1 KB)
└── Documentation/
    └── Schema_Diagram.md          # Database schema reference
```

---

## 🛠️ Maintenance

### Recommended Schedule

| Task | Frequency | Command |
|------|-----------|---------|
| Data Quality Checks | Weekly | Execute R Services script |
| SCCM Import | Daily | Run reconciliation stored proc |
| Metrics Snapshot | Monthly | Insert into DataQualityMetrics |
| Archive Resolved Issues | Quarterly | Archive AuditLog records |

### Performance Tuning

The database includes optimized indexes on:
- `SerialNumber` (HardwareAssets, SCCM_Assets)
- `UserID`, `DepartmentID` (foreign keys)
- `Status` fields (for filtering)
- `AuditDate`, `LastSeenDate` (temporal queries)

---

## 🎯 Use Cases

This solution is perfect for:

- **IT Asset Management Teams** - Centralized tracking and lifecycle management
- **Compliance Officers** - Audit-ready reporting and license tracking
- **Finance Departments** - Capital equipment tracking and depreciation
- **Help Desk Teams** - Quick asset lookup and user assignment
- **Security Teams** - Endpoint device inventory and monitoring
- **Procurement Planning** - Warranty and refresh cycle management

---

## 🤝 Contributing

Contributions are welcome! Here are some areas for enhancement:

- [ ] PowerBI dashboard templates
- [ ] ServiceNow integration module
- [ ] Mobile app for physical asset auditing
- [ ] Additional R-based predictive analytics
- [ ] Automated email alerting for critical issues
- [ ] REST API for external system integration

### How to Contribute

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 📞 Contact

**Allen Close**  
SQL Database Architect | Data Quality Specialist

[![Email](https://img.shields.io/badge/Email-acsqlworks%40gmail.com-D14836?style=for-the-badge&logo=gmail&logoColor=white)](mailto:acsqlworks@gmail.com)
[![LinkedIn](https://img.shields.io/badge/LinkedIn-Allen%20Close-0077B5?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/allen-close-6a77ab391/)
[![GitHub](https://img.shields.io/badge/GitHub-acsqlworks-181717?style=for-the-badge&logo=github&logoColor=white)](https://github.com/acsqlworks)

---

## 🌟 Acknowledgments

- Built with Microsoft SQL Server and R Services
- Inspired by real-world IT asset management challenges
- Sample data generation techniques from enterprise implementations

---

<div align="center">

**⭐ If you find this project useful, please consider giving it a star!**

Made with ❤️ by [Allen Close](https://github.com/acsqlworks)

</div>
