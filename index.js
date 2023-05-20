const webdriver = require("selenium-webdriver");
const chrome = require("selenium-webdriver/chrome");
const { Builder, By } = webdriver;
const process = require("node:process");
const fs = require("fs");

const options = new chrome.Options().headless();
let exited = false;

const driver = new Builder()
  .forBrowser("chrome")
  .setChromeOptions(options)
  .build();

async function getListOfProductCategories(driver) {
  let result = [];
  let xpath =
    '//div[contains(@class,"product-categories")]//div[contains(@class,"product-category with-icons")]';
  let locator = By.xpath(xpath);
  let elements = await driver.wait(driver.findElements(locator));
  for (let i in elements) {
    const dataHashValue = await elements[i].getAttribute("data-hash-value");
    const innerText = (await elements[i].getAttribute("innerText")).trim();
    result.push({
      id: dataHashValue,
      name: innerText,
    });
  }

  return result;
}

async function getListOfProductsForCategory(driver, category) {
  let result = [];
  let xpath = `//div[contains(@class,"product-category ${category}")]`;
  let locator = By.xpath(xpath);
  let elements = await driver.wait(driver.findElements(locator));

  for (let i in elements) {
    const dataPanelKey = await elements[i].getAttribute("data-panel-key");
    const innerText = (await elements[i].getAttribute("innerText")).trim();
    result.push({
      id: dataPanelKey,
      name: innerText.trim(),
    });
  }

  return result;
}

async function getListOfSubProductsForProduct(driver, product) {
  let result = [];
  let xpath = `//div[@data-parent-panel-key="${product}"]//div[contains(@class,"product") and @data-order]//a`;
  let locator = By.xpath(xpath);
  let elements = await driver.wait(driver.findElements(locator));

  for (let i in elements) {
    const innerText = (await elements[i].getAttribute("innerText")).trim();
    const href = await elements[i].getAttribute("href");
    result.push({
      name: innerText,
      href: href,
    });
  }

  return result;
}

async function getListOfSKUsForSubProduct(driver) {
  let xpath = '//table[@id="product-table"]';
  let locator = By.xpath(xpath);
  let table = await driver.wait(driver.findElement(locator));

  let headers = await table.findElements(By.xpath("//thead//th"));
  let rows = await table.findElements(By.xpath("//tbody//tr"));

  let headersText = [];

  for (let i in headers) {
    headersText.push((await headers[i].getAttribute("innerText")).trim());
  }

  let headersLength = headersText.length;

  let result = [];

  for (let j = 0; j < rows.length; j++) {
    let item = {};

    for (let k = 0; k < headersLength; k++) {
      let xpath = `//table[@id="product-table"]//tbody//tr[${j + 1}]//td[${
        k + 1
      }]`;
      let locator = By.xpath(xpath);
      let td = await driver.findElement(locator);
      let text = (await td.getAttribute("innerText")).trim();
      item[headersText[k]] = text;

      if (k == 0) {
        let xpath = `//table[@id="product-table"]//tbody//tr[${j + 1}]//td[${
          k + 1
        }]//a`;
        let locator = By.xpath(xpath);
        let a = await driver.findElement(locator);
        let href = await a.getAttribute("href");
        item["Url"] = href;
      }
    }
    result.push(item);
  }

  return result;
}

async function main() {
  await driver.get("https://ark.intel.com/");

  let categoryList = await getListOfProductCategories(driver);
  for (let i in categoryList) {
    let category = categoryList[i];
    category.products = await getListOfProductsForCategory(driver, category.id);

    for (let j in category.products) {
      let product = category.products[j];
      product.subproducts = await getListOfSubProductsForProduct(
        driver,
        product.id
      );
    }
  }

  for (let i in categoryList) {
    let category = categoryList[i];
    for (let j in category.products) {
      let product = category.products[j];
      for (let k in product.subproducts) {
        let subproduct = product.subproducts[k];
        console.log(subproduct.href);
        await driver.get(subproduct.href);
        try {
          subproduct.skus = await getListOfSKUsForSubProduct(driver);
        } catch (e) {
          console.error(e);
        }
      }
    }
  }

  await fs.promises.writeFile("db.json", JSON.stringify(categoryList), "utf-8");
}

process.on("beforeExit", async () => {
  if (!exited) {
    exited = true;
    await driver.quit();
  }
});

main();
