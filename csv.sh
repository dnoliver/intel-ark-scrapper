#!/bin/bash

# This script reads a db.json file, and convert it into a series of CSV files:
# ProductTypes.csv
# ProductBrands.csv
# ProductSeries.csv
# Products.csv
# ProductsSpecifications.csv

PRODUCT_TYPES=$(jq '.[].name' db.json | tr -d '"')
PRODUCT_TYPE_ID=1
rm -fr ProductTypes.csv
rm -fr ProductBrands.csv
rm -fr ProductSeries.csv
rm -fr Products.csv

echo "Id,Name" >> ProductTypes.csv
echo "ProductType,Id,Name" >> ProductBrands.csv
echo "ProductType,ProductBrand,Id,Name,Url" >> ProductSeries.csv
echo "ProductType,ProductBrand,ProductSerie,Id,Name,Url" >> Products.csv

while IFS= read -r PRODUCT_TYPE ; do
    echo "$PRODUCT_TYPE_ID,$PRODUCT_TYPE" >> ProductTypes.csv

    PRODUCT_BRANDS=$(jq \
        --arg product_type "$(echo "$PRODUCT_TYPE")" \
        '.[] | select(.name == $product_type) | .products[].name' db.json | tr -d '"')
    PRODUCT_BRAND_ID=1

    while IFS= read -r PRODUCT_BRAND ; do
        echo "$PRODUCT_TYPE_ID,$PRODUCT_BRAND_ID,$PRODUCT_BRAND" >> ProductBrands.csv

        PRODUCT_SERIES=$(jq \
            --arg product_type "$(echo "$PRODUCT_TYPE")" \
            --arg product_brand "$(echo "$PRODUCT_BRAND")" \
            '.[] | select(.name == $product_type) | .products[] | select(.name == $product_brand) | .subproducts[].name' db.json | tr -d '"')
        PRODUCT_SERIE_ID=1
        
        while IFS= read -r PRODUCT_SERIE ; do
            PRODUCT_SERIE_URL=$(jq \
                --arg product_serie "$(echo "$PRODUCT_SERIE")" \
                '.[].products[].subproducts[] | select(.name == $product_serie) | .href' db.json | tr -d '"')
            PRODUCT_SERIE=$(echo "$PRODUCT_SERIE" | tr -d '\r')
            echo "$PRODUCT_TYPE_ID,$PRODUCT_BRAND_ID,$PRODUCT_SERIE_ID,$PRODUCT_SERIE,$PRODUCT_SERIE_URL" >> ProductSeries.csv

            PRODUCTS=$(jq \
                --arg product_type "$(echo "$PRODUCT_TYPE")" \
                --arg product_brand "$(echo "$PRODUCT_BRAND")" \
                --arg product_serie "$(echo "$PRODUCT_SERIE")" \
                '.[] | select(.name == $product_type) | .products[] | select(.name == $product_brand) | .subproducts[] | select(.name == $product_serie) | .skus[]."Product Name"' db.json | tr -d '"')
            PRODUCT_ID=1

            while IFS= read -r PRODUCT ; do
                PRODUCT_URL=$(jq \
                    --arg product "$(echo "$PRODUCT")" \
                    '.[].products[].subproducts[].skus[] | select(."Product Name" == $product) | .Url' db.json | tr -d '"')
                PRODUCT=$(echo "$PRODUCT" | tr -d '\r')
                echo "$PRODUCT_TYPE_ID,$PRODUCT_BRAND_ID,$PRODUCT_SERIE_ID,$PRODUCT_ID,$PRODUCT,$PRODUCT_URL" >> Products.csv
                PRODUCT_ID=$((PRODUCT_ID + 1))
            done <<< "$PRODUCTS"
            PRODUCT_SERIE_ID=$((PRODUCT_SERIE_ID + 1))
        done <<< "$PRODUCT_SERIES"
        PRODUCT_BRAND_ID=$((PRODUCT_BRAND_ID + 1))
    done <<< "$PRODUCT_BRANDS"
    PRODUCT_TYPE_ID=$((PRODUCT_TYPE_ID + 1))
done <<< "$PRODUCT_TYPES"

echo "ProductType,ProductBrand,ProductSerie,ProductId,Specification,Value" >> ProductsSpecifications.csv
sed 1d Products.csv | while IFS= read -r LINE; do
    PRODUCT_TYPE=$(echo $LINE | awk -F, '{print $1}')
    PRODUCT_BRAND=$(echo $LINE | awk -F, '{print $2}')
    PRODUCT_SERIE=$(echo $LINE | awk -F, '{print $3}')
    PRODUCT_ID=$(echo $LINE | awk -F, '{print $4}')
    PRODUCT_NAME=$(echo $LINE | awk -F, '{print $5}')

    jq \
        --arg product "$(echo  "$PRODUCT_NAME")" \
        '.[].products[].subproducts[].skus[] | select(."Product Name" == $product) | .specs | [leaf_paths as $path | {"key": $path | join("."), "value": getpath($path)}] | (map(keys) | add | unique) as $cols | map(. as $row | $cols | map($row[.])) as $rows | $rows[] | @csv'\
        db.json | sed -e "s/^/${PRODUCT_TYPE},${PRODUCT_BRAND},${PRODUCT_SERIE},${PRODUCT_ID},/" >> ProductsSpecifications.csv
done