# Intel Ark Scrapper

## Scrapper Execution

```bash
time node index.js 2>&1

real    262m20.010s
user    0m0.295s
sys     0m0.983s
```

## Schema Induction

```bash
node schema.js
```

## Database Overview

### Product Types

```bash
jq '.[].name' db.json
```

### Product Brands

```bash
jq '.[0].products[].name' db.json
```

### Product Series

```bash
jq '.[0].products[0].subproducts[].name' db.json
```

### Products

```bash
jq '.[0].products[0].subproducts[0].skus[]."Product Name"' db.json
```

### Specification Categories

```bash
jq '.[0].products[0].subproducts[0].skus[0].specs | keys' db.json
```

## Data Loading

```bash
\copy ProductTypes FROM 'ProductTypes.csv' DELIMITER ',' CSV HEADER ENCODING 'UTF8';
\copy ProductBrands FROM 'ProductBrands.csv' DELIMITER ',' CSV HEADER ENCODING 'UTF8';
\copy ProductSeries FROM 'ProductSeries.csv' DELIMITER ',' CSV HEADER ENCODING 'UTF8';
\copy Products FROM 'Products.csv' DELIMITER ',' CSV HEADER ENCODING 'UTF8';
\copy ProductsSpecifications FROM 'ProductsSpecifications.csv' DELIMITER ',' CSV HEADER ENCODING 'UTF8';
```