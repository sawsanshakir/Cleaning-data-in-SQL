



/*

Cleaning data in SQL queries

*/

select *
from housing_dataset
order by ParcelID
-------------------------------------------------------------------------------

select *
from INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME = 'housing_dataset'



-------------------------------------------------------------------------------

-- Format and Convert the SaleDate column from varchar to date data type

select *, format(Cast( SaleDate as date), 'dd-MM-yyyy') as converted_date    
from housing_dataset

-- add new column 
alter table housing_dataset
add converted_date varchar(50)

-- convert the Saledate column to date as data type in converted_date column
update housing_dataset
set converted_date  = format(Cast( SaleDate as date), 'dd-MM-yyyy')  



select SaleDate, converted_date
from housing_dataset

-------------------------------------------------------------------------------
---dublecate

select *, ROW_NUMBER() over 
		 (partition by  PropertyAddress, SaleDate, SalePrice, legalReference, OwnerAddress 
		  order by UniqueID ) as row_num
from housing_dataset
order by PropertyAddress desc


--------------------------------------------------------------------------------

---dealinig with missing address 

 
select h2.PropertyAddress, h2.ParcelID, h2.UniqueID, h1.*
from housing_dataset h1
inner join housing_dataset h2
on h1.ParcelID = h2.ParcelID and h1.UniqueID <> h2.UniqueID
where   h2.PropertyAddress like ''
--order by ParcelID


update h2 
set  h2.PropertyAddress =  h1.PropertyAddress

from housing_dataset h1
inner join housing_dataset h2
on h1.ParcelID = h2.ParcelID and h1.UniqueID <> h2.UniqueID
where   h2.PropertyAddress like ''
--order by ParcelID



-----------------------------------------------------------------------------------------------------------------

--- Breaking out Address into Individual Columns (Address, City)


select PropertyAddress, 
       
	  left(ltrim (RTRIM(PropertyAddress)), CHARINDEX(',', PropertyAddress)-1),

	  right(ltrim (RTRIM(PropertyAddress)), datalength (ltrim (RTRIM(PropertyAddress))) - CHARINDEX(',', PropertyAddress))

from housing_dataset


alter table housing_dataset
add Street_name varchar(50)


alter table housing_dataset
add City varchar(50)


update housing_dataset
set Street_name = left(ltrim (RTRIM(PropertyAddress)), CHARINDEX(',', PropertyAddress)-1)



update housing_dataset
set City = right(ltrim (RTRIM(PropertyAddress)), datalength (ltrim (RTRIM(PropertyAddress))) - CHARINDEX(',', PropertyAddress))

-------------------------------------------------------------------------------------------------------------------------

--- Breaking out Address into Individual Columns (Address, City, State)

select OwnerAddress,
parsename(a, 3),
parsename(a, 2),
parsename(a, 1)

from housing_dataset
 cross apply (select replace(OwnerAddress, ',', '.')) as T(a)



alter table housing_dataset
add OwnerAddress_StreetName varchar(50)


alter table housing_dataset
add OwnerAddress_City varchar(50)


alter table housing_dataset
add OwnerAddress_State varchar(50)



update housing_dataset
set OwnerAddress_StreetName = parsename(replace(OwnerAddress, ',', '.'), 3)



update housing_dataset
set OwnerAddress_City = parsename(replace(OwnerAddress, ',', '.'), 2)



update housing_dataset
set OwnerAddress_State = parsename(replace(OwnerAddress, ',', '.'), 1)




------------------------------------------------------------------------------------------------------

--- Change Y and N to Yes and No in "Sold as Vacant" field

select *,
case 
when SoldAsVacant = 'N' then  'No'
when SoldAsVacant = 'Y' then 'Yes'
else SoldAsVacant
end as SoldAsVacant_modified

from housing_dataset 


update housing_dataset
set SoldAsVacant = 
	case 
    when SoldAsVacant = 'N' then  'No'
	when SoldAsVacant = 'Y' then 'Yes'
	else SoldAsVacant
	end

------------------------------------------------------------------------------

-- Drop the unused field

alter table housing_dataset
drop PropertyAddress


alter table housing_dataset
drop OwnerAddress

alter table housing_dataset
drop SaleDate

