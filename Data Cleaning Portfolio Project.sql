--Cleaning Data in SQL Queries 

-- Standardize Date Format)
UPDATE PortfolioProject.dbo.NashvilleHousing
SET SaleDateConvert = CONVERT(DATE, SaleDate);

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing

-- Populate Property Address Data 
-- Check if there is null values 
SELECT PropertyAddress
FROM PortfolioProject.dbo.NashvilleHousing
--WHERE PropertyAddress is null
Order by ParcelID

-- Based on our obersvation of the data, we can tell that Parcel ID represents different Property Address
-- Now we can check the NULL property address has dulpicate ParcelID in the table then backtrack the corespond property address 
--Use Join Function to show whats the null value for property address should be based on the information inside the table 
-- Use ISNULL function to show the values that is going to update to NULL 

Select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a 
JOIN PortfolioProject.dbo.NashvilleHousing b 
on a.ParcelID = b.ParcelID
-- Check if its the same row 
AND a.[UniqueID ]<> b.[UniqueID ]
WHERE a.PropertyAddress is NUll


UPDATE a 
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a 
JOIN PortfolioProject.dbo.NashvilleHousing b 
on a.ParcelID = b.ParcelID
-- Check if its the same row 
AND a.[UniqueID ]<> b.[UniqueID ] 

-- Breaking out Address into Individual Columns (Address, City, State)
SELECT PropertyAddress
FROM PortfolioProject.dbo.NashvilleHousing

-- Use Substring function to only select the address before comma 
-- CharIndex return the specific character in the column in this case, its the comma; -1 is to exclude the comma in the select statement 
-- To get the city, we will +1 of the comma index to avoid the comma in our result
SELECT 
Substring(PropertyAddress,1,CharIndex(',',PropertyAddress)-1) as PropertyStreet ,
Substring(PropertyAddress,CharIndex(',',PropertyAddress)+1,Len(PropertyAddress)) as PropertyCity 
From PortfolioProject.dbo.NashvilleHousing
-- Add the new column to the table 
Alter table PortfolioProject.dbo.NashvilleHousing
add PropertyStreet Nvarchar(255);
add PropertyCity  Nvarchar(255);
Update PortfolioProject.dbo.NashvilleHousing
SET PropertyStreet = Substring(PropertyAddress,1,CharIndex(',',PropertyAddress)-1) 
SET PropertyCity = Substring(PropertyAddress,CharIndex(',',PropertyAddress)+1,Len(PropertyAddress))

SELECT*
FROM PortfolioProject.dbo.NashvilleHousing
-- Now, split the owner address 
-- ParseName function, use period to separate the text, if its not period, we can replace it with period so we can use parse function 
-- Parse Function look from the end of the string, works backward 
Select 
PARSENAME(replace(OwnerAddress,',','.'),3) as OwnerStreet,
PARSENAME(replace(OwnerAddress,',','.'),2) as OwnerCity,
PARSENAME(replace(OwnerAddress,',','.'),1) as OwnerState
FROM PortfolioProject.dbo.NashvilleHousing

Alter table PortfolioProject.dbo.NashvilleHousing
add OwnerStreet Nvarchar(255);
add OwnerCity  Nvarchar(255);
add OwnerState  Nvarchar(255);
Update PortfolioProject.dbo.NashvilleHousing
SET OwnerStreet = PARSENAME(replace(OwnerAddress,',','.'),3) 
SET OwnerCity = PARSENAME(replace(OwnerAddress,',','.'),2)
SET OwnerState = PARSENAME(replace(OwnerAddress,',','.'),1)

SELECT*
FROM PortfolioProject.dbo.NashvilleHousing

-- Change Sold as vacant to the same format for all answer(Y/N)]
-- Check how many type of answers are in SoldAsVacant 
SELECT distinct(SoldAsVacant)
FROM PortfolioProject.dbo.NashvilleHousing
-- We gpt N,Y,No,Yes 

select SoldAsVacant,
Case when SoldAsVacant ='Y' THEN'YES'
	 when SoldAsVacant ='N' THEN'No'
	 ELSE SoldAsVacant
END 
FROM PortfolioProject.dbo.NashvilleHousing

Update PortfolioProject.dbo.NashvilleHousing
SET SoldAsVacant = 
Case when SoldAsVacant ='Y' THEN'YES'
	 when SoldAsVacant ='N' THEN'No'
	 ELSE SoldAsVacant
	 END 
SELECT*
FROM PortfolioProject.dbo.NashvilleHousing


-- Remove Dulplicate 
;WITH RowNumCTE As(
	SELECT*,
		ROW_NUMBER() OVER(
		Partition by 
		ParcelID,
		PropertyAddress,
		SalePrice,
		SaleDate,
		LegalReference
		ORDER By UniqueID ) row_num

	FROM PortfolioProject.dbo.NashvilleHousing
 )
DELETE 
From RowNumCTE
WHERE row_num >1


-- Delete UnusedColumns 
Alter Table PortfolioProject.dbo.NashvilleHousing
drop column OwnerAddress, TaxDistrict,PropertyAddress,SaleDate

SELECT*
FROM PortfolioProject.dbo.NashvilleHousing