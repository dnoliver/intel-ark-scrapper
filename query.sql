-- 1.	Which is the latest Intel Core Processor released?

select IntelCoreProducts.Name, IntelCoreProducts.Url, LatestProducts.Value as "Launch Date"
from (
	select ProductType, ProductBrand, ProductSerie, Id, Name, Url
	from Products
	where (ProductType, ProductBrand) in (
		select ProductType, Id as ProductBrand
		from ProductBrands
		where name = 'Intel® Core™ Processors'
	)
) IntelCoreProducts
join (
	select *
	from ProductsSpecifications
	where Specification = 'Supplemental Information.Launch Date'
	and Value = (
		select Value as "Max Launch Date"
		from ProductsSpecifications
		where (ProductType, ProductBrand, ProductSerie, ProductId) in (
			select ProductType, ProductBrand, ProductSerie, Id as ProductId
			from Products
			where (ProductType, ProductBrand) in (
				select ProductType, Id as ProductBrand
				from ProductBrands
				where name = 'Intel® Core™ Processors'
			)
		)
		and Specification = 'Supplemental Information.Launch Date'
		order by substring(Value from 4 for 2) desc, substring(Value from 2 for 1) desc
		limit 1
	)
) LatestProducts
on IntelCoreProducts.ProductType = LatestProducts.ProductType
and IntelCoreProducts.ProductBrand = LatestProducts.ProductBrand
and IntelCoreProducts.ProductSerie = LatestProducts.ProductSerie
and IntelCoreProducts.Id = LatestProducts.ProductId

-- 2.	Which is the latest Intel Xeon Processor released?

select IntelXeonProducts.Name, IntelXeonProducts.Url, LatestProducts.Value as "Launch Date"
from (
	select ProductType, ProductBrand, ProductSerie, Id, Name, Url
	from Products
	where (ProductType, ProductBrand) in (
		select ProductType, Id as ProductBrand
		from ProductBrands
		where name = 'Intel® Xeon® Processors'
	)
) IntelXeonProducts
join (
	select *
	from ProductsSpecifications
	where Specification = 'Supplemental Information.Launch Date'
	and Value = (
		select Value as "Max Launch Date"
		from ProductsSpecifications
		where (ProductType, ProductBrand, ProductSerie, ProductId) in (
			select ProductType, ProductBrand, ProductSerie, Id as ProductId
			from Products
			where (ProductType, ProductBrand) in (
				select ProductType, Id as ProductBrand
				from ProductBrands
				where name = 'Intel® Xeon® Processors'
			)
		)
		and Specification = 'Supplemental Information.Launch Date'
		order by substring(Value from 4 for 2) desc, substring(Value from 2 for 1) desc
		limit 1
	)
) LatestProducts
on IntelXeonProducts.ProductType = LatestProducts.ProductType
and IntelXeonProducts.ProductBrand = LatestProducts.ProductBrand
and IntelXeonProducts.ProductSerie = LatestProducts.ProductSerie
and IntelXeonProducts.Id = LatestProducts.ProductId;

-- 3.	Which processors works with a Thermal Design Power between 95 and 105 W?

select Name, Url
from Products
where (ProductType, ProductBrand, ProductSerie, Id) in (
	select ProductType, ProductBrand, ProductSerie, ProductId as Id
	from ProductsSpecifications
	where Specification = 'CPU Specifications.TDP'
	and left(Value, -2)::numeric >= 95
	and left(Value, -2)::numeric <= 105
);

-- 4.	Which processors were launched in 2021?

select Name, Url
from Products
join (
	select ProductType, ProductBrand, ProductSerie, ProductId
	from ProductsSpecifications
	where Specification = 'Supplemental Information.Launch Date'
	and substring(Value from 4 for 2) = '21'
) ProductsLaunchedIn2021
on Products.ProductType = ProductsLaunchedIn2021.ProductType
and Products.ProductBrand = ProductsLaunchedIn2021.ProductBrand
and Products.ProductSerie = ProductsLaunchedIn2021.ProductSerie
and Products.Id = ProductsLaunchedIn2021.ProductId
where Products.ProductType = (
	select Id
	from ProductTypes
	where name = 'Processors'
);

-- 5.	Which is the processor with the maximum base frequency available?

select Name, Url
from Products
join (
	select ProductType, ProductBrand, ProductSerie, ProductId
	from ProductsSpecifications
	where ProductType = (
			select Id
			from ProductTypes
			where Name = 'Processors'
		)
	and Specification = 'CPU Specifications.Processor Base Frequency'
	and right(Value, 3) = 'GHz' 
	and left(Value, -4)::numeric = (
		select max(left(Value, -4)::numeric) as "Max Processor Base Frequency"
		from ProductsSpecifications
		where ProductType = (
			select Id
			from ProductTypes
			where Name = 'Processors'
		)
		and Specification = 'CPU Specifications.Processor Base Frequency'
		and right(Value, 3) = 'GHz'
	)
) ProcessorsWithMaxBaseFrequency
on Products.ProductType = ProcessorsWithMaxBaseFrequency.ProductType
and Products.ProductBrand = ProcessorsWithMaxBaseFrequency.ProductBrand
and Products.ProductSerie = ProcessorsWithMaxBaseFrequency.ProductSerie
and Products.Id = ProcessorsWithMaxBaseFrequency.ProductId;

-- 6.	Which processor generation was available in 2018?

select Name, Url
from ProductSeries
join (
	select ProductType, ProductBrand, ProductSerie
	from ProductsSpecifications
	where Specification = 'Supplemental Information.Launch Date'
	and substring(Value from 4 for 2) = '18'
	and (ProductType, ProductBrand) = (
		select ProductType, Id as ProductBrand
		from ProductBrands
		where name = 'Intel® Core™ Processors'
	)
) IntelCoreProcessorsLaunchedIn2018
on ProductSeries.ProductType = IntelCoreProcessorsLaunchedIn2018.ProductType
and ProductSeries.ProductBrand = IntelCoreProcessorsLaunchedIn2018.ProductBrand
and ProductSeries.Id = IntelCoreProcessorsLaunchedIn2018.ProductSerie
group by Name, Url

-- 7.	Which is the most inexpensive NUC mini-PC?

select Name, Url
from Products
join (
	select ProductType, ProductBrand, ProductSerie, ProductId
	from ProductsSpecifications
	where Specification = 'Essentials.Recommended Customer Price'
	and split_part(split_part(Value, ' ', 1), '$', 2)::numeric = (
		select min("Min Price")
		from (
			select split_part(split_part(Value, ' ', 1), '$', 2)::numeric as "Min Price"
			from ProductsSpecifications
			where Specification = 'Essentials.Recommended Customer Price'
			and ProductType = (
				select Id
				from ProductTypes
				where Name = 'Intel® NUC'
			)
		) IntelNucMinPrices
	)
	and ProductType = (
		select Id
		from ProductTypes
		where Name = 'Intel® NUC'
	)
) MinPriceIntelNuc
on Products.ProductType = MinPriceIntelNuc.ProductType
and Products.ProductBrand = MinPriceIntelNuc.ProductBrand
and Products.ProductSerie = MinPriceIntelNuc.ProductSerie
and Products.Id = MinPriceIntelNuc.ProductId

-- 8.	Which is the most expensive NUC mini-PC?

select Name, Url
from Products
join (
	select ProductType, ProductBrand, ProductSerie, ProductId
	from ProductsSpecifications
	where Specification = 'Essentials.Recommended Customer Price'
	and split_part(split_part(Value, ' ', 1), '$', 2)::numeric = (
		select max("Max Price")
		from (
			select split_part(split_part(Value, ' ', 1), '$', 2)::numeric as "Max Price"
			from ProductsSpecifications
			where Specification = 'Essentials.Recommended Customer Price'
			and ProductType = (
				select Id
				from ProductTypes
				where Name = 'Intel® NUC'
			)
		) IntelNucMaxPrices
	)
	and ProductType = (
		select Id
		from ProductTypes
		where Name = 'Intel® NUC'
	)
) MinPriceIntelNuc
on Products.ProductType = MinPriceIntelNuc.ProductType
and Products.ProductBrand = MinPriceIntelNuc.ProductBrand
and Products.ProductSerie = MinPriceIntelNuc.ProductSerie
and Products.Id = MinPriceIntelNuc.ProductId

-- 9.	Which are the vPro enabled platforms in the 11th generation of Core products?

select Name, Url
from Products
join (
	select ProductType, ProductBrand, ProductSerie, ProductId
	from ProductsSpecifications
	where Specification = 'Advanced Technologies.Intel vPro® Platform Eligibility ‡'
	and Value = 'Yes'
	and (ProductType, ProductBrand, ProductSerie) in (
		select ProductType, ProductBrand, Id as ProductSerie
		from ProductSeries
		where Name like '%' || '11th Generation Intel® Core™' || '%'
	)
) IntelVProEnabledProducts
on Products.ProductType = IntelVProEnabledProducts.ProductType
and Products.ProductBrand = IntelVProEnabledProducts.ProductBrand
and Products.ProductSerie = IntelVProEnabledProducts.ProductSerie
and Products.Id = IntelVProEnabledProducts.ProductId;

-- 10.	Which are the different Intel FPGA platforms?

select Name, Url
from Products
where ProductType = (
	select Id
	from ProductTypes
	where Name = 'Intel® FPGAs'
);

-- 11.	Which is the latest available Intel IPU platforms?

select Name, Url
from Products
join (
	select distinct ProductType, ProductBrand, ProductSerie, ProductId
	from ProductsSpecifications
	where value like '%' || 'IPU' || '%'
) IntelProductsWithIPU
on Products.ProductType = IntelProductsWithIPU.ProductType
and Products.ProductBrand = IntelProductsWithIPU.ProductBrand
and Products.ProductSerie = IntelProductsWithIPU.ProductSerie
and Products.Id = IntelProductsWithIPU.ProductId;

-- 12.	Which is the average price of a Intel Core CPU by Generation?

select Name, Url, "Avg Price"
from ProductSeries
join (
	select ProductType, ProductBrand, ProductSerie,
		trunc(avg(split_part(split_part(Value, ' ', 1), '$', 2)::numeric), 2)::money as "Avg Price"
	from ProductsSpecifications
	where (ProductType, ProductBrand) in (
		select ProductType, Id as ProductBrand
		from ProductBrands
		where Name = 'Intel® Core™ Processors'
	)
	and Specification = 'Essentials.Recommended Customer Price'
	group by ProductType, ProductBrand, ProductSerie
) ProductSeriesAvgPrices
on ProductSeries.ProductType = ProductSeriesAvgPrices.ProductType
and ProductSeries.ProductBrand = ProductSeriesAvgPrices.ProductBrand
and ProductSeries.Id = ProductSeriesAvgPrices.ProductSerie;

-- 13.	Which platforms have more than 20 Cores and a Frequency Grater Than 4.5 GHz? 

select Products.Name, Products.Url
from Products
join (
	(
		select ProductType, ProductBrand, ProductSerie, ProductId
		from ProductsSpecifications
		where Specification = 'CPU Specifications.Total Cores'
		and Value::numeric > 20
	)
	INTERSECT
	(
		select ProductType, ProductBrand, ProductSerie, ProductId
		from ProductsSpecifications
		where Specification = 'CPU Specifications.Processor Base Frequency'
		and right(Value, 3) = 'GHz' 
		and left(Value, -4)::numeric >= 4.5
	)
) ProductsWithMoreThan20CoresAndMoreThan45Ghz
on Products.ProductType = ProductsWithMoreThan20CoresAndMoreThan45Ghz.ProductType
and Products.ProductBrand = ProductsWithMoreThan20CoresAndMoreThan45Ghz.ProductBrand
and Products.ProductSerie = ProductsWithMoreThan20CoresAndMoreThan45Ghz.ProductSerie
and Products.Id = ProductsWithMoreThan20CoresAndMoreThan45Ghz.ProductId;
	
-- 14.	Which platforms supports Intel Boot Guard?

select Name, Url
from Products
join (
	select distinct ProductType, ProductBrand, ProductSerie, ProductId
	from ProductsSpecifications
	where Specification = 'Security & Reliability.Intel® Boot Guard'
	and Value = 'Yes'
) IntelProductsWithIntelBootGuard
on Products.ProductType = IntelProductsWithIntelBootGuard.ProductType
and Products.ProductBrand = IntelProductsWithIntelBootGuard.ProductBrand
and Products.ProductSerie = IntelProductsWithIntelBootGuard.ProductSerie
and Products.Id = IntelProductsWithIntelBootGuard.ProductId;

-- 15.	Which platforms supports Intel Remote Platform Erase?

select Name, Url
from Products
join (
	select distinct ProductType, ProductBrand, ProductSerie, ProductId
	from ProductsSpecifications
	where Specification = 'Security & Reliability.Intel® Remote Platform Erase (RPE) ‡'
	and Value = 'Yes'
) IntelProductsWithIntelBootGuard
on Products.ProductType = IntelProductsWithIntelBootGuard.ProductType
and Products.ProductBrand = IntelProductsWithIntelBootGuard.ProductBrand
and Products.ProductSerie = IntelProductsWithIntelBootGuard.ProductSerie
and Products.Id = IntelProductsWithIntelBootGuard.ProductId;

-- 16.	Which is the maximum Temperature Junction allowed by the 9th Gen Intel Core processor that has the greater number of cores?

select 
	Products.Name,
	Products.Url,
	ProductsWithMaxTJunction.Value as "Maximum Temperature Junction"
from Products
join (
	select ProductsSpecifications.*
	from ProductsSpecifications
	join (
		select distinct
			ProductsSpecifications.ProductType,
			ProductsSpecifications.ProductBrand,
			ProductsSpecifications.ProductSerie,
			ProductsSpecifications.ProductId
		from ProductsSpecifications 
		join (
			select ProductType, ProductBrand, ProductSerie, max(Value::numeric) as "Max Total Cores"
			from ProductsSpecifications P2
			where (ProductType, ProductBrand, ProductSerie) in (
				select ProductType, ProductBrand, Id as ProductSerie
				from ProductSeries
				where Name like '9th Generation Intel® Core™' || '%' || 'Processors'
			)
			and Specification = 'CPU Specifications.Total Cores'
			group by ProductType, ProductBrand, ProductSerie
		) MaxCoresBySeries
		on ProductsSpecifications.ProductType = MaxCoresBySeries.ProductType
		and ProductsSpecifications.ProductBrand = MaxCoresBySeries.ProductBrand
		and ProductsSpecifications.ProductSerie = MaxCoresBySeries.ProductSerie
		where Specification = 'CPU Specifications.Total Cores'
		and Value::numeric = "Max Total Cores"
	) ProductsWithMaxCores
	on ProductsSpecifications.ProductType = ProductsWithMaxCores.ProductType
	and ProductsSpecifications.ProductBrand = ProductsWithMaxCores.ProductBrand
	and ProductsSpecifications.ProductSerie = ProductsWithMaxCores.ProductSerie
	and ProductsSpecifications.ProductId = ProductsWithMaxCores.ProductId
	and Specification = 'Package Specifications.TJUNCTION'
) ProductsWithMaxTJunction
on Products.ProductType = ProductsWithMaxTJunction.ProductType
and Products.ProductBrand = ProductsWithMaxTJunction.ProductBrand
and Products.ProductSerie = ProductsWithMaxTJunction.ProductSerie
and Products.Id = ProductsWithMaxTJunction.ProductId;

-- 17.	Which platforms are “Edge” enabled? (prepared for “Edge Applications”)

select Name, Url
from Products
join (
	select distinct ProductType, ProductBrand, ProductSerie, ProductId
	from ProductsSpecifications
	where value like '%' || 'Edge Enhanced' || '%'
) IntelEdgeProducts
on Products.ProductType = IntelEdgeProducts.ProductType
and Products.ProductBrand = IntelEdgeProducts.ProductBrand
and Products.ProductSerie = IntelEdgeProducts.ProductSerie
and Products.Id = IntelEdgeProducts.ProductId;

-- 18.	Which are the different Code Names?

select distinct Value as "Code Names"
from ProductsSpecifications
where Specification = 'Essentials.Code Name'

-- 19. Which are the different Intel GPUs?

select Name, Url
from Products
where ProductType = (
	select Id
	from ProductTypes
	where Name = 'Graphics'
);

-- 20. Which are the different Elkhart Lake Products?

select Products.Name, Products.Url
from Products
join (
	select distinct ProductType, ProductBrand, ProductSerie, ProductId
	from ProductsSpecifications
	where Specification = 'Essentials.Code Name'
	and Value = 'Products formerly Elkhart Lake'
) ElkhartLakeProducts
on Products.ProductType = ElkhartLakeProducts.ProductType
and Products.ProductBrand = ElkhartLakeProducts.ProductBrand
and Products.ProductSerie = ElkhartLakeProducts.ProductSerie
and Products.Id = ElkhartLakeProducts.ProductId;
