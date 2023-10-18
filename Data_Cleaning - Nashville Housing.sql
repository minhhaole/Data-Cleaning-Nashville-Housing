-- Cleaning Data in SQL Queries
-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Overview of the data

SELECT *
FROM DataClean.dbo.NashvilleHousing


-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

-- 1. Understand the SaleDate column 

SELECT SaleDate
FROM DataClean.dbo.NashvilleHousing

-- 2. Goal: convert the the SaleDate into Date format prior to adding the column

SELECT SaleDate, CONVERT(Date,SaleDate)
FROM DataClean.dbo.NashvilleHousing

-- 3. Update Table NashvilleHousing's SaleDate column type to Date. Result: column did not update 

UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

-- 4.  Use the ALTER clause to add a new Date column to replace and delete SaleDate 

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date

-- 5. Convert SaleDate values to Date type in SaleDateConverted

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

-- 6. Validate SaleDateConverted column 

SELECT SaleDateConverted
FROM DataClean.dbo.NashvilleHousing



-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

-- 1. Understand the data where PropertyAddress column has NULL values

SELECT *
FROM DataClean.dbo.NashvilleHousing
WHERE PropertyAddress IS NULL

-- Each ParcelID value is associated to a PropertyAddress: populate the address according to the ParcelID

-- 2. Self join table to visualize ParcelID and PropertyAddress based on UniqueID

SELECT a.ParcelId, a.PropertyAddress, b.ParcelId, b.PropertyAddress
FROM DataClean.dbo.NashvilleHousing a
JOIN DataClean.dbo.NashvilleHousing b
ON a.ParcelId = b.ParcelID
AND a.[UniqueID] <> b.[UniqueID] 
WHERE b.PropertyAddress IS NULL

-- 3. Populate the NULL values 

UPDATE b
SET b.PropertyAddress =  ISNULL(b.PropertyAddress, a.PropertyAddress)
FROM DataClean.dbo.NashvilleHousing a
JOIN DataClean.dbo.NashvilleHousing b
ON a.ParcelId = b.ParcelID
AND a.[UniqueID] <> b.[UniqueID] 
WHERE b.PropertyAddress IS NULL

-- 4. Validate that PropertyAddress does not contain NULL values

SELECT PropertyAddress
FROM DataClean.dbo.NashvilleHousing
WHERE PropertyAddress IS NULL

-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

-- 1. Show new columns with proper values seperated from PropertAddress

SELECT
REPLACE (SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress)), ',','') AS Addresses,
REPLACE (SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress), LEN(PropertyAddress)), ',', '') AS City 
FROM DataClean.dbo.NashvilleHousing

-- 2. Alter and Update Table to add the column Addresses 

ALTER TABLE NashvilleHousing
ADD Addresses NVARCHAR(255)

UPDATE NashvilleHousing
SET Addresses = REPLACE (SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress)), ',','')

-- 3. Alter and Update Table to add the column City 

ALTER TABLE NashvilleHousing
ADD City NVARCHAR(255)

UPDATE NashvilleHousing
SET City = REPLACE (SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress), LEN(PropertyAddress)), ',', '')

-- 5. Validate new columns and their new values 

SELECT PropertyAddress, Addresses, City
FROM DataClean.dbo.NashvilleHousing


-- Create a new column for PropertyAddress number 


-- Split owner's address in 3 columns 

-----------------------------------------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

-- 1. Validate the variations of answers under SoldAsVacant

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM DataClean.dbo.NashvilleHousing
GROUP BY SoldAsVacant

-- 2. Replace the values. If they are already correct, keept them as is 
SELECT SoldAsVacant,
CASE 
	WHEN SoldAsVacant = 'N' THEN 'No'
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	ELSE SoldAsVacant
END
FROM DataClean.dbo.NashvilleHousing

-- 3. Update the values in the table 

UPDATE NashvilleHousing
SET SoldAsVacant = CASE 
	WHEN SoldAsVacant = 'N' THEN 'No'
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	ELSE SoldAsVacant
END

-- 4. Validate the table was updated

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM DataClean.dbo.NashvilleHousing
GROUP BY SoldAsVacant

-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

-- 1. Validate if there are duplicate: rows tagged 2 under rownumber column are duplicates 

SELECT *, ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
	ORDER BY UniqueID
) AS rownumber
FROM DataClean.dbo.NashvilleHousing
ORDER BY rownumber DESC

-- 2. Remove the duplicate wors using CTE

WITH RowCTE AS (
SELECT *, ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
	ORDER BY UniqueID
) rownumber
FROM DataClean.dbo.NashvilleHousing
)
DELETE
FROM RowCTE
WHERE rownumber > 1

-- 3. Validate that all duplicates were deleted 

WITH RowCTE AS (
SELECT *, ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
	ORDER BY UniqueID
) rownumber
FROM DataClean.dbo.NashvilleHousing
)
SELECT *
FROM RowCTE
WHERE rownumber > 1

---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

-- 1. ID unecessary columns in the table 

SELECT *
FROM DataClean.dbo.NashvilleHousing

-- 2. Drop the columns in the table 

ALTER TABLE DataClean.dbo.NashvilleHousing
DROP COLUMN SaleDate, PropertyAddress, OwnerAddress





