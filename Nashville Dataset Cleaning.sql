select * from Portfolioproject..Housingdata;

--Change Sale date format

alter table Housingdata
add dateconverted date;

update Housingdata
set dateconverted=CONVERT(date,SaleDate);

select SaleDate, dateconverted
from Portfolioproject..Housingdata;

--Property Address Data

select PropertyAddress
from Portfolioproject..Housingdata;

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress) as PropertyAddress2
from Housingdata a
join
Housingdata b
on a.ParcelID=b.ParcelID
and a.UniqueID != b.UniqueID
where a.PropertyAddress is null

update a
set PropertyAddress=ISNULL(a.PropertyAddress,b.PropertyAddress) 
from Housingdata a
join
Housingdata b
on a.ParcelID=b.ParcelID
and a.UniqueID != b.UniqueID
where a.PropertyAddress is null

--seperating address into region and individual address

select
SUBSTRING (PropertyAddress,1,CHARINDEX(',',PropertyAddress,1)-1) as Address,
SUBSTRING (PropertyAddress,CHARINDEX(',',PropertyAddress,1) +1,LEN(PropertyAddress)) as Region
from Portfolioproject..Housingdata;

alter table HousingData
add NewAddress nvarchar(255);

update HousingData
set NewAddress = SUBSTRING (PropertyAddress,1,CHARINDEX(',',PropertyAddress,1)-1);

alter table HousingData
add AddressCity nvarchar(255);

update HousingData 
set AddressCity=SUBSTRING (PropertyAddress,CHARINDEX(',',PropertyAddress,1) +1,LEN(PropertyAddress));

-- Splitting owner address into different components. 

select
parsename(replace(OwnerAddress, ',','.'),3) as owneraddress1,
parsename(replace(OwnerAddress, ',','.'),2)as ownercity,
parsename(replace(OwnerAddress, ',','.'),1) as ownerstate
from Portfolioproject..Housingdata;

alter table Portfolioproject..Housingdata
add owneraddress1 nvarchar(255);

update Portfolioproject..Housingdata
set owneraddress1= parsename(replace(OwnerAddress, ',','.'),3);


alter table Portfolioproject..Housingdata
add ownercity nvarchar(255);

update Portfolioproject..Housingdata
set ownercity= parsename(replace(OwnerAddress, ',','.'),2);


alter table Portfolioproject..Housingdata
add ownerstate nvarchar(255);

update Portfolioproject..Housingdata
set ownerstate= parsename(replace(OwnerAddress, ',','.'),3);

--Cleaning the 'SoleasVacant' collumn

select SoldAsVacant,
case when SoldAsVacant='Y' then 'Yes'
	 when SoldAsVacant= 'N' then 'No'
	 else SoldAsVacant
	 end
	 as Sold_modified
from Portfolioproject..Housingdata;

update Portfolioproject..Housingdata
set SoldAsVacant= case when SoldAsVacant='Y' then 'Yes'
	 when SoldAsVacant= 'N' then 'No'
	 else SoldAsVacant
	 end;

--Removing Duplicates

With RowNumCTE as(
select *,
	row_number() over (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 order by
					UniqueID
					) row_num

From PortfolioProject..Housingdata
--order by ParcelID
)
delete
from RowNumCTE
where row_num > 1


--Removing all the original and unused collums we came across during this process

Select *
From PortfolioProject..Housingdata


ALTER TABLE PortfolioProject..Housingdata
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate




