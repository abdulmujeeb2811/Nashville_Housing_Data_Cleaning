--STANDARDIZING THE DATE

ALTER TABLE PORTFOLIO_PROJECTS..NashvilleHousing
ADD Date_Of_Sale  Date

UPDATE PORTFOLIO_PROJECTS..NashvilleHousing
SET Date_Of_Sale = CONVERT(Date, SaleDate)


SELECT SaleDate, Date_Of_Sale
FROM PORTFOLIO_PROJECTS..NashvilleHousing

--Populate Missing Property Addresses

SELECT *
FROM PORTFOLIO_PROJECTS..NashvilleHousing
WHERE PropertyAddress is null  --this shows we do have some empty addresses

--Looking through the data showed that some of the ParcelIDs have different UniqueIDs. The addresses on thesame parcelIDs should be the same. 
SELECT A.ParcelID, B.ParcelID, A.[UniqueID ], B.[UniqueID ], A.PropertyAddress, B.PropertyAddress
FROM PORTFOLIO_PROJECTS..NashvilleHousing  A
JOIN  PORTFOLIO_PROJECTS..NashvilleHousing B
ON A.ParcelID = B.ParcelID
AND A.[UniqueID ] <> B.[UniqueID ]
WHERE B.PropertyAddress is null

	--This missing addresses can then be filled with the address on the corresponding ParcelID
UPDATE b
SET PropertyAddress = isnull(B.PropertyAddress, A.PropertyAddress)
FROM PORTFOLIO_PROJECTS..NashvilleHousing  A
JOIN  PORTFOLIO_PROJECTS..NashvilleHousing B
ON A.ParcelID = B.ParcelID
AND A.[UniqueID ] <> B.[UniqueID ]
WHERE B.PropertyAddress is null

--SEPARATE ADDRESS COMPONENTS INTO COLUMNS
SELECT PropertyAddress
FROM PORTFOLIO_PROJECTS..NashvilleHousing 


SELECT PropertyAddress
FROM PORTFOLIO_PROJECTS..NashvilleHousing  --View the current address format

SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Property_Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) as City
FROM PORTFOLIO_PROJECTS..NashvilleHousing


ALTER TABLE PORTFOLIO_PROJECTS..NashvilleHousing
ADD Property_Address nvarchar(250)

UPDATE PORTFOLIO_PROJECTS..NashvilleHousing
SET Property_Address = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)


ALTER TABLE PORTFOLIO_PROJECTS..NashvilleHousing
ADD City  nvarchar(250)

UPDATE PORTFOLIO_PROJECTS..NashvilleHousing
SET City = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))


--SEPARATE OWNER ADDRESS

SELECT owneraddress
FROM PORTFOLIO_PROJECTS..NashvilleHousing  --View OwnerAddress Column

SELECT PARSENAME(REPLACE(OwnerAddress,',','.'),3)  OwnerAddress,
PARSENAME(REPLACE(OwnerAddress,',','.'),2) City,
PARSENAME(REPLACE(OwnerAddress,',','.'),1)  State
FROM PORTFOLIO_PROJECTS..NashvilleHousing     --Using Parsename to separate components of the address

ALTER TABLE PORTFOLIO_PROJECTS..NashvilleHousing
ADD Owner__Address nvarchar(250)

UPDATE PORTFOLIO_PROJECTS..NashvilleHousing
SET Owner__Address = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE PORTFOLIO_PROJECTS..NashvilleHousing
ADD City__ nvarchar(250)

UPDATE PORTFOLIO_PROJECTS..NashvilleHousing
SET City__ = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE PORTFOLIO_PROJECTS..NashvilleHousing
ADD State nvarchar(250)

UPDATE PORTFOLIO_PROJECTS..NashvilleHousing
SET State = PARSENAME(REPLACE(OwnerAddress,',','.'),1)


--CHANGE 'y' and 'N' in SoldAsVacant to 'Yes' and 'No'

SELECT SoldAsVacant, COUNT(SoldasVacant)
FROM PORTFOLIO_PROJECTS..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2    --Views the column

SELECT SoldAsVacant, 
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
WHEN SoldasVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END
FROM PORTFOLIO_PROJECTS..NashvilleHousing   --Transforms "Y" and "N" to "Yes' and "No" respectively.

UPDATE PORTFOLIO_PROJECTS..NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
WHEN SoldasVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END   --Updates the values in the column.


--REMOVING DUPLICATES
WITH rownumber AS (SELECT *, 
ROW_NUMBER() OVER
(PARTITION BY ParcelID,
			  PropertyAddress,
			  SaleDate,
			  SalePrice,
			  LegalReference,
			  Ownername,
			  Owneraddress
			  ORDER BY UniqueID) row_num
FROM PORTFOLIO_PROJECTS..NashvilleHousing)   --Assigns numbers to duplicates of each row found
SELECT *  
FROM rownumber
WHERE row_num >1  --deletes duplicate rows. 


--DROP Unneeded Columns
ALTER TABLE PORTFOLIO_PROJECTS..NashvilleHousing
DROP COLUMN PropertyAddress, SaleDate, OwnerAddress, TaxDistrict   --PropertyAddress, SaleDate, OwnerAddress, have been transformed into more usable formats.








