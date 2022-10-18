-- Cleaning Data in SQL Queries

select * from Portfolio_Project.dbo.NashvilleHousing

--Standardize Date Format / remove the time present in date

select SaleDateConverted , CONVERT(Date, SaleDate)
from Portfolio_Project.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate);

-- Populate Property Address Data which are null

select *
from Portfolio_Project.dbo.NashvilleHousing
--where PropertyAddress is NULL
order by ParcelID

select a.UniqueID, a.ParcelID, a.PropertyAddress, b.UniqueID, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from Portfolio_Project.dbo.NashvilleHousing a
join Portfolio_Project.dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

UPDATE a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from Portfolio_Project.dbo.NashvilleHousing a
join Portfolio_Project.dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


-- Breaking Down Address into Individual Columns

select PropertyAddress
from Portfolio_Project.dbo.NashvilleHousing


Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))
from Portfolio_Project.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255)

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress));


select OwnerAddress
from Portfolio_Project.dbo.NashvilleHousing

select 
PARSENAME(REPLACE(OwnerAddress, ',','.'),3),
PARSENAME(REPLACE(OwnerAddress, ',','.'),2),
PARSENAME(REPLACE(OwnerAddress, ',','.'),1)
from Portfolio_Project.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'),3)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.'),2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',','.'),1)


-- Change Y and N to Yes and No

select Distinct(SoldAsVacant), Count(SoldAsVacant)
from Portfolio_Project.dbo.NashvilleHousing
group by SoldAsVacant

select SoldAsVacant,
CASE When SoldAsVacant = 'Y' THEN 'Yes'
	 When SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
from Portfolio_Project.dbo.NashvilleHousing
Order by SoldAsVacant


Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	 When SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END

-- Remove Duplicates

WITH RowNumCTE AS(
select *,
ROW_NUMBER() OVER (
PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
ORDER BY UniqueID) row_num
from Portfolio_Project.dbo.NashvilleHousing
--order by ParcelID
)

DELETE from RowNumCTE
where row_num>1
--order by PropertyAddress

WITH RowNumCTE AS(
select *,
ROW_NUMBER() OVER (
PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
ORDER BY UniqueID) row_num
from Portfolio_Project.dbo.NashvilleHousing
--order by ParcelID
)

select * from RowNumCTE
where row_num>1


--Delete Unused Columns

select * from 
Portfolio_Project.dbo.NashvilleHousing

ALTER TABLE Portfolio_Project.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE Portfolio_Project.dbo.NashvilleHousing
DROP COLUMN SaleDate