-- =============================================
-- R Services Data Quality Check Script
-- Table: HardwareAssets
-- Purpose: Identify anomalies including duplicates, missing values, and mismatches
-- =============================================

-- First, let's view the results (optional - for testing)
EXEC sp_execute_external_script
    @language = N'R',
    @script = N'
        # Load the input data
        hardware_data <- InputDataSet
        
        # Initialize result data frame to store all anomalies
        anomaly_results <- data.frame(
            AssetID = integer(),
            SerialNumber = character(),
            AssetTag = character(),
            AssetStatus = character(),
            AnomalyType = character(),
            AnomalyDescription = character(),
            DetectedDate = character(),
            stringsAsFactors = FALSE
        )
        
        # Check 1: Identify duplicate serial numbers
        if ("SerialNumber" %in% colnames(hardware_data)) {
            # Find serial numbers that appear more than once (excluding NULL/empty)
            serial_counts <- table(hardware_data$SerialNumber[
                !is.na(hardware_data$SerialNumber) & 
                hardware_data$SerialNumber != ""
            ])
            duplicate_serials <- names(serial_counts[serial_counts > 1])
            
            if (length(duplicate_serials) > 0) {
                duplicate_rows <- hardware_data[
                    hardware_data$SerialNumber %in% duplicate_serials & 
                    !is.na(hardware_data$SerialNumber),
                ]
                
                for (i in 1:nrow(duplicate_rows)) {
                    anomaly_results <- rbind(anomaly_results, data.frame(
                        AssetID = duplicate_rows$AssetID[i],
                        SerialNumber = as.character(duplicate_rows$SerialNumber[i]),
                        AssetTag = as.character(ifelse(is.na(duplicate_rows$AssetTag[i]), "", duplicate_rows$AssetTag[i])),
                        AssetStatus = as.character(ifelse(is.na(duplicate_rows$Status[i]), "", duplicate_rows$Status[i])),
                        AnomalyType = "Duplicate Serial Number",
                        AnomalyDescription = paste("Serial number", duplicate_rows$SerialNumber[i], "appears", serial_counts[as.character(duplicate_rows$SerialNumber[i])], "times in the database"),
                        DetectedDate = as.character(Sys.Date()),
                        stringsAsFactors = FALSE
                    ))
                }
            }
        }
        
        # Check 2: Identify missing serial numbers
        if ("SerialNumber" %in% colnames(hardware_data)) {
            missing_serial_rows <- hardware_data[
                is.na(hardware_data$SerialNumber) | 
                hardware_data$SerialNumber == "" | 
                trimws(hardware_data$SerialNumber) == "",
            ]
            
            if (nrow(missing_serial_rows) > 0) {
                for (i in 1:nrow(missing_serial_rows)) {
                    anomaly_results <- rbind(anomaly_results, data.frame(
                        AssetID = missing_serial_rows$AssetID[i],
                        SerialNumber = "MISSING",
                        AssetTag = as.character(ifelse(is.na(missing_serial_rows$AssetTag[i]), "", missing_serial_rows$AssetTag[i])),
                        AssetStatus = as.character(ifelse(is.na(missing_serial_rows$Status[i]), "", missing_serial_rows$Status[i])),
                        AnomalyType = "Missing Serial Number",
                        AnomalyDescription = "Asset record exists but serial number is NULL or empty",
                        DetectedDate = as.character(Sys.Date()),
                        stringsAsFactors = FALSE
                    ))
                }
            }
        }
        
        # Check 3: Identify missing asset tags
        if ("AssetTag" %in% colnames(hardware_data)) {
            missing_tag_rows <- hardware_data[
                is.na(hardware_data$AssetTag) | 
                hardware_data$AssetTag == "" | 
                trimws(hardware_data$AssetTag) == "",
            ]
            
            if (nrow(missing_tag_rows) > 0) {
                for (i in 1:nrow(missing_tag_rows)) {
                    anomaly_results <- rbind(anomaly_results, data.frame(
                        AssetID = missing_tag_rows$AssetID[i],
                        SerialNumber = as.character(ifelse(is.na(missing_tag_rows$SerialNumber[i]), "MISSING", missing_tag_rows$SerialNumber[i])),
                        AssetTag = "MISSING",
                        AssetStatus = as.character(ifelse(is.na(missing_tag_rows$Status[i]), "", missing_tag_rows$Status[i])),
                        AnomalyType = "Missing Asset Tag",
                        AnomalyDescription = "Critical field AssetTag is NULL or empty",
                        DetectedDate = as.character(Sys.Date()),
                        stringsAsFactors = FALSE
                    ))
                }
            }
        }
        
        # Check 4: Identify expired warranties with Active status
        if ("WarrantyExpiration" %in% colnames(hardware_data) && "Status" %in% colnames(hardware_data)) {
            # Convert WarrantyExpiration to Date if needed
            hardware_data$WarrantyExpiration <- as.Date(hardware_data$WarrantyExpiration)
            current_date <- as.Date(Sys.Date())
            
            expired_warranty <- hardware_data[
                !is.na(hardware_data$WarrantyExpiration) & 
                !is.na(hardware_data$Status) &
                hardware_data$WarrantyExpiration < current_date &
                toupper(trimws(hardware_data$Status)) == "ACTIVE",
            ]
            
            if (nrow(expired_warranty) > 0) {
                for (i in 1:nrow(expired_warranty)) {
                    anomaly_results <- rbind(anomaly_results, data.frame(
                        AssetID = expired_warranty$AssetID[i],
                        SerialNumber = as.character(ifelse(is.na(expired_warranty$SerialNumber[i]), "MISSING", expired_warranty$SerialNumber[i])),
                        AssetTag = as.character(ifelse(is.na(expired_warranty$AssetTag[i]), "", expired_warranty$AssetTag[i])),
                        AssetStatus = as.character(expired_warranty$Status[i]),
                        AnomalyType = "Expired Warranty",
                        AnomalyDescription = paste("Active asset with warranty expired on", as.character(expired_warranty$WarrantyExpiration[i])),
                        DetectedDate = as.character(Sys.Date()),
                        stringsAsFactors = FALSE
                    ))
                }
            }
        }
        
        # Set the output dataset
        OutputDataSet <- anomaly_results
    ',
    @input_data_1 = N'
        SELECT 
            AssetID,
            SerialNumber,
            AssetTag,
            Status,
            Manufacturer,
            Model,
            PurchaseDate,
            WarrantyExpiration,
            LastAuditDate
        FROM [ITAssetAudit].[dbo].[HardwareAssets];
    ',
    @input_data_1_name = N'InputDataSet',
    @output_data_1_name = N'OutputDataSet'
WITH RESULT SETS ((
    AssetID INT,
    SerialNumber NVARCHAR(100),
    AssetTag NVARCHAR(50),
    AssetStatus NVARCHAR(50),
    AnomalyType NVARCHAR(100),
    AnomalyDescription NVARCHAR(500),
    DetectedDate NVARCHAR(50)
));
GO

-- =============================================
-- Execute and insert results into tracking table
-- =============================================

-- Create a temporary table to hold the results
IF OBJECT_ID('tempdb..#AnomalyTemp') IS NOT NULL
    DROP TABLE #AnomalyTemp;

CREATE TABLE #AnomalyTemp (
    AssetID INT,
    SerialNumber NVARCHAR(100),
    AssetTag NVARCHAR(50),
    AssetStatus NVARCHAR(50),
    AnomalyType NVARCHAR(100),
    AnomalyDescription NVARCHAR(500),
    DetectedDate NVARCHAR(50)
);

-- Insert results into temp table
INSERT INTO #AnomalyTemp
EXEC sp_execute_external_script
    @language = N'R',
    @script = N'
        # Load the input data
        hardware_data <- InputDataSet
        
        # Initialize result data frame to store all anomalies
        anomaly_results <- data.frame(
            AssetID = integer(),
            SerialNumber = character(),
            AssetTag = character(),
            AssetStatus = character(),
            AnomalyType = character(),
            AnomalyDescription = character(),
            DetectedDate = character(),
            stringsAsFactors = FALSE
        )
        
        # Check 1: Identify duplicate serial numbers
        if ("SerialNumber" %in% colnames(hardware_data)) {
            serial_counts <- table(hardware_data$SerialNumber[
                !is.na(hardware_data$SerialNumber) & 
                hardware_data$SerialNumber != ""
            ])
            duplicate_serials <- names(serial_counts[serial_counts > 1])
            
            if (length(duplicate_serials) > 0) {
                duplicate_rows <- hardware_data[
                    hardware_data$SerialNumber %in% duplicate_serials & 
                    !is.na(hardware_data$SerialNumber),
                ]
                
                for (i in 1:nrow(duplicate_rows)) {
                    anomaly_results <- rbind(anomaly_results, data.frame(
                        AssetID = duplicate_rows$AssetID[i],
                        SerialNumber = as.character(duplicate_rows$SerialNumber[i]),
                        AssetTag = as.character(ifelse(is.na(duplicate_rows$AssetTag[i]), "", duplicate_rows$AssetTag[i])),
                        AssetStatus = as.character(ifelse(is.na(duplicate_rows$Status[i]), "", duplicate_rows$Status[i])),
                        AnomalyType = "Duplicate Serial Number",
                        AnomalyDescription = paste("Serial number", duplicate_rows$SerialNumber[i], "appears", serial_counts[as.character(duplicate_rows$SerialNumber[i])], "times in the database"),
                        DetectedDate = as.character(Sys.Date()),
                        stringsAsFactors = FALSE
                    ))
                }
            }
        }
        
        # Check 2: Identify missing serial numbers
        if ("SerialNumber" %in% colnames(hardware_data)) {
            missing_serial_rows <- hardware_data[
                is.na(hardware_data$SerialNumber) | 
                hardware_data$SerialNumber == "" | 
                trimws(hardware_data$SerialNumber) == "",
            ]
            
            if (nrow(missing_serial_rows) > 0) {
                for (i in 1:nrow(missing_serial_rows)) {
                    anomaly_results <- rbind(anomaly_results, data.frame(
                        AssetID = missing_serial_rows$AssetID[i],
                        SerialNumber = "MISSING",
                        AssetTag = as.character(ifelse(is.na(missing_serial_rows$AssetTag[i]), "", missing_serial_rows$AssetTag[i])),
                        AssetStatus = as.character(ifelse(is.na(missing_serial_rows$Status[i]), "", missing_serial_rows$Status[i])),
                        AnomalyType = "Missing Serial Number",
                        AnomalyDescription = "Asset record exists but serial number is NULL or empty",
                        DetectedDate = as.character(Sys.Date()),
                        stringsAsFactors = FALSE
                    ))
                }
            }
        }
        
        # Check 3: Identify missing asset tags
        if ("AssetTag" %in% colnames(hardware_data)) {
            missing_tag_rows <- hardware_data[
                is.na(hardware_data$AssetTag) | 
                hardware_data$AssetTag == "" | 
                trimws(hardware_data$AssetTag) == "",
            ]
            
            if (nrow(missing_tag_rows) > 0) {
                for (i in 1:nrow(missing_tag_rows)) {
                    anomaly_results <- rbind(anomaly_results, data.frame(
                        AssetID = missing_tag_rows$AssetID[i],
                        SerialNumber = as.character(ifelse(is.na(missing_tag_rows$SerialNumber[i]), "MISSING", missing_tag_rows$SerialNumber[i])),
                        AssetTag = "MISSING",
                        AssetStatus = as.character(ifelse(is.na(missing_tag_rows$Status[i]), "", missing_tag_rows$Status[i])),
                        AnomalyType = "Missing Asset Tag",
                        AnomalyDescription = "Critical field AssetTag is NULL or empty",
                        DetectedDate = as.character(Sys.Date()),
                        stringsAsFactors = FALSE
                    ))
                }
            }
        }
        
        # Check 4: Identify expired warranties with Active status
        if ("WarrantyExpiration" %in% colnames(hardware_data) && "Status" %in% colnames(hardware_data)) {
            # Convert WarrantyExpiration to Date if needed
            hardware_data$WarrantyExpiration <- as.Date(hardware_data$WarrantyExpiration)
            current_date <- as.Date(Sys.Date())
            
            expired_warranty <- hardware_data[
                !is.na(hardware_data$WarrantyExpiration) & 
                !is.na(hardware_data$Status) &
                hardware_data$WarrantyExpiration < current_date &
                toupper(trimws(hardware_data$Status)) == "ACTIVE",
            ]
            
            if (nrow(expired_warranty) > 0) {
                for (i in 1:nrow(expired_warranty)) {
                    anomaly_results <- rbind(anomaly_results, data.frame(
                        AssetID = expired_warranty$AssetID[i],
                        SerialNumber = as.character(ifelse(is.na(expired_warranty$SerialNumber[i]), "MISSING", expired_warranty$SerialNumber[i])),
                        AssetTag = as.character(ifelse(is.na(expired_warranty$AssetTag[i]), "", expired_warranty$AssetTag[i])),
                        AssetStatus = as.character(expired_warranty$Status[i]),
                        AnomalyType = "Expired Warranty",
                        AnomalyDescription = paste("Active asset with warranty expired on", as.character(expired_warranty$WarrantyExpiration[i])),
                        DetectedDate = as.character(Sys.Date()),
                        stringsAsFactors = FALSE
                    ))
                }
            }
        }
        
        # Set the output dataset
        OutputDataSet <- anomaly_results
    ',
    @input_data_1 = N'
        SELECT 
            AssetID,
            SerialNumber,
            AssetTag,
            Status,
            Manufacturer,
            Model,
            PurchaseDate,
            WarrantyExpiration,
            LastAuditDate
        FROM [ITAssetAudit].[dbo].[HardwareAssets];
    ',
    @input_data_1_name = N'InputDataSet',
    @output_data_1_name = N'OutputDataSet';

-- Now insert from temp table to final table
INSERT INTO [ITAssetAudit].[dbo].[HardwareAssetAnomalies] (
    AssetID,
    SerialNumber,
    AssetTag,
    AssetStatus,
    AnomalyType,
    AnomalyDescription,
    DetectedDate,
    IsResolved
)
SELECT 
    AssetID,
    SerialNumber,
    AssetTag,
    AssetStatus,
    AnomalyType,
    AnomalyDescription,
    CONVERT(DATE, DetectedDate) AS DetectedDate,
    0 AS IsResolved
FROM #AnomalyTemp;

-- Clean up temp table
DROP TABLE #AnomalyTemp;
GO

-- =============================================
-- Query to view current unresolved anomalies
-- =============================================

SELECT 
    AnomalyID,
    AssetID,
    SerialNumber,
    AssetTag,
    AssetStatus,
    SCCMStatus,
    AnomalyType,
    AnomalyDescription,
    DetectedDate,
    CreatedDate
FROM [ITAssetAudit].[dbo].[HardwareAssetAnomalies]
WHERE IsResolved = 0
ORDER BY DetectedDate DESC, AnomalyType;
GO

-- =============================================
-- Summary report of anomalies by type
-- =============================================

SELECT 
    AnomalyType,
    COUNT(*) AS TotalAnomalies,
    SUM(CASE WHEN IsResolved = 0 THEN 1 ELSE 0 END) AS UnresolvedCount,
    SUM(CASE WHEN IsResolved = 1 THEN 1 ELSE 0 END) AS ResolvedCount,
    MIN(DetectedDate) AS FirstDetected,
    MAX(DetectedDate) AS LastDetected
FROM [ITAssetAudit].[dbo].[HardwareAssetAnomalies]
GROUP BY AnomalyType
ORDER BY UnresolvedCount DESC;
GO
