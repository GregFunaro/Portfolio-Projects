select *
from DataCleanPortfolioProject.dbo.NashvilleHousing

-- Standardize date format

select SaleDateConverted, convert(date, saledate) 
from DataCleanPortfolioProject.dbo.NashvilleHousing

update NashvilleHousing
set saledate = convert(date, saledate) 

alter table NashvilleHousing
add saledateconverted date;

update NashvilleHousing
set saledateconverted = convert(date, saledate) 


-- Property Address 
select *
from DataCleanPortfolioProject.dbo.NashvilleHousing
order by ParcelID

select a.parcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.propertyaddress, b.PropertyAddress)
from DataCleanPortfolioProject.dbo.NashvilleHousing a
join DataCleanPortfolioProject.dbo.NashvilleHousing b
	on a.parcelID = b.parcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a 
set propertyaddress = isnull(a.propertyaddress, b.PropertyAddress)
from DataCleanPortfolioProject.dbo.NashvilleHousing a
join DataCleanPortfolioProject.dbo.NashvilleHousing b
	on a.parcelID = b.parcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


-- Breaking out address into individual columns (address, city, state)
-- substrings

select 
substring(propertyaddress, 1, CHARINDEX(',', propertyaddress) - 1) as Address
	,substring(propertyaddress, CHARINDEX(',', propertyaddress) + 1, len(PropertyAddress))as Address
from DataCleanPortfolioProject.dbo.NashvilleHousing

alter table NashvilleHousing
add PropertySplitAddress nvarchar(255);

update NashvilleHousing
set PropertySplitAddress = substring(propertyaddress, 1, CHARINDEX(',', propertyaddress) - 1)

alter table NashvilleHousing
add PropertySplitCity nvarchar(255);

update NashvilleHousing
set PropertySplitCity = substring(propertyaddress, CHARINDEX(',', propertyaddress) + 1, len(PropertyAddress))
	

-- parse name
select OwnerAddress
from DataCleanPortfolioProject.dbo.NashvilleHousing


select
PARSENAME(replace(owneraddress, ',', '.'),3)
 ,PARSENAME(replace(owneraddress, ',', '.'),2)
 ,PARSENAME(replace(owneraddress, ',', '.'),1)
from DataCleanPortfolioProject.dbo.NashvilleHousing


alter table NashvilleHousing
add OwnerSplitAddress nvarchar(255);

update NashvilleHousing
set OwnerSplitAddress = PARSENAME(replace(owneraddress, ',', '.'),3)

alter table NashvilleHousing
add OwnerSplitCity nvarchar(255);

update NashvilleHousing
set OwnerSplitCity = PARSENAME(replace(owneraddress, ',', '.'),2)

alter table NashvilleHousing
add OwnerSplitState nvarchar(255);

update NashvilleHousing
set OwnerSplitState = PARSENAME(replace(owneraddress, ',', '.'),1)

select *
from DataCleanPortfolioProject.dbo.NashvilleHousing

-- Standardizing - Change Y/N to Yes and No in 'Sold as Vacant'

select distinct(SoldAsVacant), count(SoldAsVacant)
from DataCleanPortfolioProject.dbo.NashvilleHousing
group by SoldAsVacant
order by 2 


select soldasvacant
,	 case when soldasvacant = 'Y' then 'Yes'
	 when soldasvacant = 'N' then 'No'
	 else soldasvacant
	 end
from DataCleanPortfolioProject.dbo.NashvilleHousing

update NashvilleHousing
set SoldAsVacant = 
case when soldasvacant = 'Y' then 'Yes'
	 when soldasvacant = 'N' then 'No'
	 else soldasvacant
	 end


-- Remove duplicates (using CTE)

select *
from DataCleanPortfolioProject.dbo.NashvilleHousing

with RowNumCTE as(
select *,
	ROW_NUMBER() over(
	partition by parcelid, 
				 propertyaddress,
				saleprice,
				saledate,
				legalreference
				order by
					uniqueid
					) row_num

from DataCleanPortfolioProject.dbo.NashvilleHousing
)
delete
from RowNumCTE
where row_num > 1


-- Delete unusred columns


alter table DataCleanPortfolioProject.dbo.NashvilleHousing
drop column owneraddress, taxdistrict, propertyaddress

alter table DataCleanPortfolioProject.dbo.NashvilleHousing
drop column saledate

select *
from DataCleanPortfolioProject.dbo.NashvilleHousing