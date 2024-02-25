Select *
From PortfolioProject..NashvilleHousing

-- Standardize Data Format

Select SaleDate, convert(date,SaleDate)
From PortfolioProject..NashvilleHousing

Alter table NashvilleHousing
Alter column SaleDate date

-- Popoulate Property Address data

Select *
From PortfolioProject..NashvilleHousing
--where PropertyAddress is null
order by ParcelID

Select a.ParcelID, a. PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject..NashvilleHousing a
Join PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
Set PropertyAddress = isnull(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject..NashvilleHousing a
Join PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

-- Breaking out Address Into Individual Columns (Address, City, State)

Select PropertyAddress
from PortfolioProject..NashvilleHousing

Select
Substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) as Address,
Substring(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, len(PropertyAddress)) as Address
From PortfolioProject..NashvilleHousing

Alter table NashvilleHousing
Add PropertySlitAddress Nvarchar(255)

Update NashvilleHousing
Set PropertySlitAddress = Substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)

Alter table NashvilleHousing
Add PropertySlitCity Nvarchar(255)

Update NashvilleHousing
Set PropertySlitCity = Substring(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, len(PropertyAddress))

Select *
From PortfolioProject..NashvilleHousing

Select
PARSENAME(Replace(OwnerAddress, ',', '.'), 3),
PARSENAME(Replace(OwnerAddress, ',', '.'), 2),
PARSENAME(Replace(OwnerAddress, ',', '.'), 1)
From PortfolioProject..NashvilleHousing

Alter table NashvilleHousing
Add OwnerSlitAddress Nvarchar(255)

Update NashvilleHousing
Set OwnerSlitAddress = PARSENAME(Replace(OwnerAddress, ',', '.'), 3)

Alter table NashvilleHousing
Add OwnerSlitCity Nvarchar(255)

Update NashvilleHousing
Set OwnerSlitCity = PARSENAME(Replace(OwnerAddress, ',', '.'), 2)

Alter table NashvilleHousing
Add OwnerSlitState Nvarchar(255)

Update NashvilleHousing
Set OwnerSlitState = PARSENAME(Replace(OwnerAddress, ',', '.'), 1)

-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject..NashvilleHousing
Group by SoldAsVacant
order by 2

Select SoldAsVacant, 
Case when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
End
From PortfolioProject..NashvilleHousing

Update NashvilleHousing
Set SoldAsVacant = Case when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
End

-- Remove duplicates

With RowNumCTE as (
Select *, ROW_NUMBER() over (
	Partition by ParcelID, PropertyAddress, Saleprice, SaleDate, LegalReference
	Order by UniqueID) row_num
From PortfolioProject..NashvilleHousing
--Order by ParcelID 
)

--Delete 
--From RowNumCTE
--where row_num > 1
--Order by PropertyAddress

Select *
From RowNumCTE

-- Delete Unused Column

Alter table PortfolioProject.dbo.NashvilleHousing
Drop column OwnerAddress, TaxDistrict, PropertyAddress

Select *
From PortfolioProject..NashvilleHousing

Alter table PortfolioProject.dbo.NashvilleHousing
Drop column SaleDate
