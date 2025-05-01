
# Nashville-Housing-Data-Cleaning-SQL-Project

## Project Overview  
This project focuses on cleaning and preparing the **Nashville Housing** dataset using **SQL**.  

I used **Microsoft SQL Server** to inspect, clean, and standardize housing data by handling null values, splitting composite fields, fixing data types, removing duplicates, and more.

---

## Dataset  
- **Nashville_Housing**: Contains housing sales records including addresses, sale dates and prices, ownership details, and other property-related information.

---

## Key SQL Concepts Applied  
- **Data Profiling**: Examining data types and identifying duplicates or anomalies.  
- **Data Type Conversion**: Formatting date fields for consistency.  
- **Self-Joins**: Filling missing values using matching rows.  
- **String Functions**: Using `SUBSTRING()`, `CHARINDEX()`, and `PARSENAME()` to split full addresses.  
- **Conditional Updates**: Standardizing inconsistent values using `CASE WHEN`.  
- **Window Functions**: Identifying and removing duplicate records using `ROW_NUMBER()`.  
- **CTEs (Common Table Expressions)**: Structuring deletion of duplicates for better readability.  
- **Schema Modification**: Adding and dropping columns as needed.

---

## Cleaning Highlights  
- Converted the `SaleDate` column into proper `DATE` format.  
- Filled missing `PropertyAddress` values based on shared `ParcelID`.  
- Split `PropertyAddress` into `Address` and `City` columns.  
- Split `OwnerAddress` into `OwnerStreet`, `OwnerCity`, and `OwnerState`.  
- Standardized `SoldAsVacant` values (e.g., Y → Yes, N → No).  
- Identified and removed exact duplicate rows.  
- Dropped unused columns like `PropertyAddress` and `OwnerAddress`.

---

## Sample Transformations

- Replace null `PropertyAddress` values using self join:
  ```sql
  UPDATE a
  SET a.PropertyAddress = b.PropertyAddress
  FROM Nashville_Housing a
  JOIN Nashville_Housing b ON a.ParcelID = b.ParcelID
  WHERE a.PropertyAddress IS NULL AND a.[UniqueID ] <> b.[UniqueID ];
