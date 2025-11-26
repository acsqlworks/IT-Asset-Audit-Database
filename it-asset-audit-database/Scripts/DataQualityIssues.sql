-- View all detected data quality issues
SELECT 
    IssueID,
    AssetID,
    IssueType,
    IssueDescription,
    DetectedOn
FROM [ITAssetAudit].[dbo].[DataQualityIssues]
ORDER BY IssueType, DetectedOn DESC;

-- Summary by issue type
SELECT 
    IssueType,
    COUNT(*) AS IssueCount
FROM [ITAssetAudit].[dbo].[DataQualityIssues]
GROUP BY IssueType
ORDER BY IssueCount DESC;
