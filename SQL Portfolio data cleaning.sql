--Cleaning data in SQL queries
SELECT *
FROM [Portfolio Project]..[Nashville housing]

--standardize date format
SELECT SaleDate,
Convert(date, saledate)
FROM [Portfolio Project]..[Nashville housing]

UPDATE [Portfolio Project]..[Nashville housing]
SET SaleDate = Convert(date, saledate)

--alternatively
ALTER TABLE [Portfolio Project]..[Nashville housing]
ADD SalesDate DATE

UPDATE [Portfolio Project]..[Nashville housing]
SET SalesDate = Convert(date, saledate)

--populate property address data
SELECT *
FROM [Portfolio Project]..[Nashville housing]
WHERE PropertyAddress is Null

SELECT *
FROM [Portfolio Project]..[Nashville housing]
--WHERE PropertyAddress is Null
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [Portfolio Project]..[Nashville housing] a
Join [Portfolio Project]..[Nashville housing] b
	ON a.ParcelID=b.ParcelID
	AND a.[UniqueID ]<>b.[UniqueID ]
WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [Portfolio Project]..[Nashville housing] a
Join [Portfolio Project]..[Nashville housing] b
	ON a.ParcelID=b.ParcelID
	AND a.[UniqueID ]<>b.[UniqueID ]
WHERE a.PropertyAddress is null

--breaking property address into individual columns (using substrings)
SELECT PropertyAddress
FROM [Portfolio Project]..[Nashville housing]
--Removing the city
SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as address
FROM [Portfolio Project]..[Nashville housing]
--Removing the street
SELECT
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(propertyaddress)) as address
FROM [Portfolio Project]..[Nashville housing]

-- effecting the changes on the table
--for address number
ALTER TABLE [Portfolio Project]..[Nashville housing]
ADD PropertyAddressNumber NVARCHAR(255)

UPDATE [Portfolio Project]..[Nashville housing]
SET PropertyAddressNumber = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)
--for addresscity
ALTER TABLE [Portfolio Project]..[Nashville housing]
ADD PropertyCity NVARCHAR(255)

UPDATE [Portfolio Project]..[Nashville housing]
SET PropertyCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(propertyaddress))

--breaking down owner address into columns (using parsename)
SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) as address,
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) as city,
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) as state
FROM [Portfolio Project]..[Nashville housing]

-- effecting the changes
--for address
ALTER TABLE [Portfolio Project]..[Nashville housing]
ADD OwnerStreetAddress NVARCHAR(255)

UPDATE [Portfolio Project]..[Nashville housing]
SET OwnerStreetAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

--for city
ALTER TABLE [Portfolio Project]..[Nashville housing]
ADD OwnerCity NVARCHAR(255)

UPDATE [Portfolio Project]..[Nashville housing]
SET OwnerCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

--for state
ALTER TABLE [Portfolio Project]..[Nashville housing]
ADD OwnerState NVARCHAR(255)

UPDATE [Portfolio Project]..[Nashville housing]
SET OwnerState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

--Fixing sold as vacant column
SELECT DISTINCT (SoldAsVacant)
FROM [Portfolio Project]..[Nashville housing]

SELECT DISTINCT (SoldAsVacant), COUNT(SoldAsVacant)
FROM [Portfolio Project]..[Nashville housing]
GROUP BY (SoldAsVacant)


SELECT 
    SoldAsVacant,
    CASE 
        WHEN soldasvacant = 'Y' THEN 'Yes'
        WHEN soldasvacant = 'N' THEN 'No'
        ELSE soldasvacant
    END AS soldasvacant_corrected
FROM 
    [Portfolio Project]..[Nashville Housing]

--effecting the changes
UPDATE [Portfolio Project]..[Nashville Housing]
SET soldasvacant = CASE 
                      WHEN soldasvacant = 'Y' THEN 'Yes'
                      WHEN soldasvacant = 'N' THEN 'No'
                      ELSE soldasvacant
                   END

--Removing duplicates (using CTE)
WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER() OVER( 
	PARTITION BY ParcelId, Propertyaddress, saleprice, saledate, legalreference
	ORDER BY UniqueId
	) AS row_num
FROM [Portfolio Project]..[Nashville housing]
)

SELECT * 
FROM RowNumCTE
WHERE row_num>1

--Delete unused columns
SELECT *
FROM [Portfolio Project]..[Nashville housing]

ALTER TABLE [Portfolio Project]..[Nashville housing]
DROP COLUMN owneraddress, taxdistrict, propertyaddress, saledate