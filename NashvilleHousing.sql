
-- Fixing date format

ALTER TABLE Housing
Add SaleDateConverted Date;

UPDATE Housing
SET SaleDateConverted = CONVERT(Date, SaleDate)

Select SaleDateConverted, CONVERT(Date, SaleDate)
From NashvilleHousing.dbo.Housing


-- Populate Property Address data

Select *
From NashvilleHousing.dbo.Housing
--Where PropertyAddress is null
Order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From NashvilleHousing.dbo.Housing as a
JOIN NashvilleHousing.dbo.Housing as b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From NashvilleHousing.dbo.Housing as a
JOIN NashvilleHousing.dbo.Housing as b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


-- Breaking out Address into indivisual columns (Address, City)

Select PropertyAddress
From NashvilleHousing.dbo.Housing
--Where PropertyAddress is null
--Order by ParcelID

Select
SUBSTRING (PropertyAddress, 1, CHARINDEX(',' , PropertyAddress) -1 ) as Address
,SUBSTRING (PropertyAddress, CHARINDEX(',' , PropertyAddress) +1, LEN(PropertyAddress) ) as City
From NashvilleHousing.dbo.Housing


ALTER TABLE NashvilleHousing.dbo.Housing
Add PropertySplitAddress Nvarchar(255);

Update Housing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',' , PropertyAddress) -1)

ALTER TABLE Housing
Add PropertySplitCity Nvarchar(255);

Update Housing 
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',' , PropertyAddress) +1 , LEN(PropertyAddress))



-- Breaking out OwnerAddress into indivisual columns (Address, City, State)

Select OwnerAddress 
From NashvilleHousing.dbo.Housing

Select
PARSENAME(REPLACE(OwnerAddress, ',' , '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',' , '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',' , '.') , 1)
From NashvilleHousing.dbo.Housing


ALTER TABLE NashvilleHousing.dbo.Housing
Add OwnerSplitAddress Nvarchar(255);

Update Housing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',' , '.') , 3)

ALTER TABLE Housing
Add OwnerSplitCity Nvarchar(255);

Update Housing 
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',' , '.') , 2)

ALTER TABLE Housing
Add OwnerSplitState Nvarchar(255);

Update Housing 
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',' , '.') , 1)



-- Change Y and N to Yes and No in "Sold as Vacant" column

Select Distinct (SoldAsVacant), COUNT(SoldAsVacant)
From NashvilleHousing.dbo.Housing
Group by SoldAsVacant
Order by 2


Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
       When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From NashvilleHousing.dbo.Housing

UPDATE Housing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
       When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END




-- Remove Duplicates
-- CTE

WITH RowNUMCTE AS(
Select *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY
				UniqueID
				) row_num

From NashvilleHousing.dbo.Housing
--ORDER BY ParcelID
)
Select *
From RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress


DELETE
From RowNumCTE
WHERE row_num > 1




-- Delete Unused Columns


ALTER TABLE NashvilleHousing.dbo.Housing 
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate