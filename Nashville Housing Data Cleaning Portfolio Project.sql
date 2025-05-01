
--Data Cleaning Project

Use [Nashville Housing Data Cleaning]


Select *
from Nashville_Housing;


--Understanding the table structure
select column_name, data_type
from information_schema.columns
where table_name = 'Nashville_Housing';

--------------------------------------------------------------------------------------------

--Checking duplicates
SELECT COUNT(*) 
FROM Nashville_Housing
GROUP BY ParcelID, PropertyAddress, SaleDate, SalePrice
HAVING COUNT(*) > 1
order by ParcelID;

--------------------------------------------------------------------------------------------

--SaleDate format is not appropriate => Converting the SaleDate column into date type 

alter table Nashville_Housing
alter column saledate date;

--Another way
/*update Nashville_Housing
set SaleDate = CONVERT(date, SaleDate)
*/

--------------------------------------------------------------------------------------------

--Checking missing or null values and trying fixing them

--Fixing null values at PropertyAddress column 
--based on the business of data the ParcelID is a unique ID for each property that might be sold more than once so => if the ParcelID is repeated with cases
--wehre the PropertyAddress is null and second is not null => we can populated the null with the not null values in PropertyAddress column

update a
set a.PropertyAddress = b.PropertyAddress --isnull(a.PropertyAddress, b.PropertyAddress)
from Nashville_Housing a join Nashville_Housing b
	on b.ParcelID = a.ParcelID
where b.[UniqueID ] <> a.[UniqueID ]  and a.PropertyAddress is null


--------------------------------------------------------------------------------------------

--Breaking out PropertyAddress into individual columns (Address, City)

--Adding column for Address
alter table Nashville_Housing add Address varchar(255);
go
--Extracting the Address from PropertyAddress and populating it in Address column
update Nashville_Housing
set Address = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

--Adding column for City
alter table Nashville_Housing add City varchar(255);
go
--Extracting the City from PropertyAddress and populating it in City column
update Nashville_Housing
set City = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

--------------------------------------------------------------------------------------------

--Breaking out OwnerAddress into individual columns (Street, City, State)

--Adding columns for them
alter table Nashville_Housing add OwnerStreet varchar(255);
alter table Nashville_Housing add OwnerCity varchar(255);
alter table Nashville_Housing add OwnerState varchar(255);

--Extracting the street, City, State from OwnerAddress column then adding them to the table
update Nashville_Housing
set OwnerStreet = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3), 
	OwnerCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2), 
	OwnerState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1);

--------------------------------------------------------------------------------------------

--Standardizing SoldAsVacant column Values (N => No, Y=> Yes)

--Exploring the column
select SoldAsVacant, count(*)
from Nashville_Housing
group by SoldAsVacant;

update Nashville_Housing
	set SoldAsVacant = case when SoldAsVacant = 'N' then'No'
	when SoldAsVacant = 'Y' then 'Yes'
	else SoldAsVacant --if the first two conditions didn't match, it will put NUll => so we have to use else here
	end

--------------------------------------------------------------------------------------------

--Renoving Duplicates

with Duplicates_CTE as (
select *, ROW_NUMBER() over (partition by ParcelID, PropertyAddress, SaleDate, SalePrice, LegalReference order by UniqueID) as RN
from Nashville_Housing
)

delete 
from Duplicates_CTE
where RN > 1

/*
ملاحظات:
لو الـ CTE مبني على Join مع جداول تانية، غالبًا مش هتقدر تحذف منه مباشرة، وهيظهرلك Error.

الحذف بيكون مسموح فقط لو الـ CTE بيعتمد على جدول واحد ومن غير عمليات تجميع (Aggregation أو Grouping).

❗تحذير:
استخدام DELETE أو UPDATE مباشرة من CTE محتاج حذر، لأنك بتتعامل فعليًا مع الجدول الأصلي، فلو الاستعلام فيه غلطة، هتمسح بياناتك الفعلية!
*/

--------------------------------------------------------------------------------------------

--Deleting Unused Columns

alter table Nashville_Housing
drop column PropertyAddress, OwnerAddress


select * from Nashville_Housing
