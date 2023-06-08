CREATE TABLE ProductTypes (
	Id 		INT NOT NULL,
	Name 	TEXT NOT NULL,
	
	CONSTRAINT PK_ProductTypes PRIMARY KEY (Id),
	CONSTRAINT UQ_ProductTypes_Name UNIQUE (Name)
);

CREATE TABLE ProductBrands (
	ProductType 	INT NOT NULL,
	Id 				INT NOT NULL,
	Name 			TEXT NOT NULL,
	
	CONSTRAINT PK_ProductBrands PRIMARY KEY (ProductType, Id),
	CONSTRAINT FK_ProductBrands_ProductTypes FOREIGN KEY (ProductType) REFERENCES ProductTypes,
	CONSTRAINT UQ_ProductBrands_Name UNIQUE (Name)
);

CREATE TABLE ProductSeries (
	ProductType 	INT NOT NULL,
	ProductBrand 	INT NOT NULL,
	Id 				INT NOT NULL,
	Name 			TEXT NOT NULL,
	Url				TEXT NOT NULL,
	
	CONSTRAINT PK_ProductSeries PRIMARY KEY (ProductType, ProductBrand, Id),
	CONSTRAINT FK_ProductSeries_ProductBrands FOREIGN KEY (ProductType, ProductBrand) REFERENCES ProductBrands (ProductType, Id),
	CONSTRAINT UQ_ProductSeries_Name UNIQUE (Name),
	CONSTRAINT UQ_ProductSeries_Url UNIQUE (Url)
);

CREATE TABLE Products (
	ProductType 	INT NOT NULL,
	ProductBrand 	INT NOT NULL,
	ProductSerie 	INT NOT NULL,
	Id 				INT NOT NULL,
	Name 			TEXT NOT NULL,
	Url				TEXT NOT NULL,
	
	CONSTRAINT PK_Product PRIMARY KEY (ProductType, ProductBrand, ProductSerie, Id),
	CONSTRAINT FK_Product_ProductSeries FOREIGN KEY (ProductType, ProductBrand, ProductSerie) REFERENCES ProductSeries (ProductType, ProductBrand, Id),
	CONSTRAINT UQ_Product_Name UNIQUE (Name),
	CONSTRAINT UQ_Product_Url UNIQUE (Url)
);

CREATE TABLE ProductsSpecifications (
	ProductType 			INT NOT NULL,
	ProductBrand 			INT NOT NULL,
	ProductSerie 			INT NOT NULL,
	ProductId				INT NOT NULL,
	Specification			TEXT NOT NULL,
	Value 					TEXT NOT NULL,
	
	CONSTRAINT PK_ProductsSpecifications PRIMARY KEY (ProductType, ProductBrand, ProductSerie, ProductId, Specification),
	CONSTRAINT FK_ProductsSpecifications_Products FOREIGN KEY (ProductType, ProductBrand, ProductSerie, ProductId) REFERENCES Products (ProductType, ProductBrand, ProductSerie, Id)
);

DROP TABLE ProductTypes;
DROP TABLE ProductBrands;
DROP TABLE ProductSeries;
DROP TABLE Products;
DROP TABLE ProductsSpecifications;
