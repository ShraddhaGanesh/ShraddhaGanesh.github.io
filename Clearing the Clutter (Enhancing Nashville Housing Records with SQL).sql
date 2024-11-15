
----------------------------------------------------------------------------------------------------------------------------------

-- Data Source and Related Information 
-- Online Community Platform: Kaggle 
-- Webpage Title: Nashville Housing Data 
-- Time Period: 2013-2016
-- Link to Dataset - https://www.kaggle.com/datasets/tmthyjames/nashville-housing-data

----------------------------------------------------------------------------------------------------------------------------------

-- Defining Primary Objectives for the Project

-- Objective 1: The "SaleDate" column could be refined to enhance readability and simplify analysis. It is 
-- currently formatted with both date and time, the time values are consistently 00:00:00:00, offering no 
-- meaningful information. Presenting just the date would make the data cleaner and more relevant. 

-- Objective 2: The "PropertyAddress" column conains NULL values, which can be populated by referencing the 
-- corresponding property address for the same "ParcelID" in other rows. 

-- Objective 3: The "PropertyAddress" column currently combines property address and city. Seperating them 
-- into distinct fields would make the data more accessible for analysis. 

-- Objective 4: The "OwnerAddress" column currently combines owner address, city, and state. Seperating them 
-- into distinct fields would make the data more accessible for analysis. 

-- Objective 5: The "SoldAsVacant" column has four distict variables: Yes, No, Y, and N. Standardizing these 
-- by converting "Y" to "Yes" and "N" to "No" would improve consistency and accuracy. 

-- Objective 6: The final step is to remove irrelevant columns. For instance, after splitting "PropertyAddress"
-- into "PropertyAddressConverted" and "PropertyCityConverted", deleting "PropertyAddress" ensures the dataset retains only
-- relevant information. 

----------------------------------------------------------------------------------------------------------------------------------

-- Objective/Task 1: 

ALTER TABLE HousingData
ALTER COLUMN SaleDate date; 

----------------------------------------------------------------------------------------------------------------------------------

-- Objective/Task 2: 

Update one
SET PropertyAddress = ISNULL(one.PropertyAddress, two.PropertyAddress)
From Portfolio..HousingData one
Join Portfolio..HousingData two
	on one.ParcelID = two.ParcelID 
	and one.[UniqueID ] <> two.[UniqueID ]
Where one.PropertyAddress is NULL

----------------------------------------------------------------------------------------------------------------------------------

-- Objective/Task 3: 

ALTER TABLE HousingData
ADD PropertyAddressConverted varchar(255); 
ALTER TABLE HousingData
ADD PropertyAddressCity varchar(255);

Update HousingData
SET PropertyAddressConverted = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)
Update HousingData
SET PropertyAddressCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

----------------------------------------------------------------------------------------------------------------------------------

-- Objective/Task 4: 

ALTER TABLE HousingData
ADD OwnerAddressConverted varchar(255);
ALTER TABLE HousingData
ADD OwnerCity varchar(255);
ALTER TABLE HousingData
ADD OwnerState varchar(255);

Update HousingData
SET OwnerAddressConverted = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)
Update HousingData
SET OwnerCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)
Update HousingData
SET OwnerState = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)

----------------------------------------------------------------------------------------------------------------------------------

-- Objective/Task 5: 

select distinct(SoldAsVacant)
From Portfolio..HousingData

Update HousingData
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'YES' 
WHEN SoldAsVacant = 'N' THEN 'NO' 
ELSE SoldAsVacant
END

----------------------------------------------------------------------------------------------------------------------------------

-- Objective/Task 6: 

ALTER TABLE HousingData
DROP COLUMN OwnerAddress, PropertyAddress; 

----------------------------------------------------------------------------------------------------------------------------------




