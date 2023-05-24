const { createSchema } = require('genson-js');
const fs = require("fs");

fs.readFile("db.json", { encoding: "utf-8" }, async function (err, data) {
    const db = JSON.parse(data);
    // 1st item is Processors
    const ProcessorSchema = createSchema(db[0]);
    // 2nd item is Server Products
    const ServerProductSchema = createSchema(db[1]);
    // 3rd item is Intel NUCs
    const IntelNucSchema = createSchema(db[2]);
    // 4th item is Wireless
    const WirelessSchema = createSchema(db[3]);
    // 5th item is Ethernet Products
    const EthernetProductsSchema = createSchema(db[4]);
    // 6th item is Intel® FPGAs
    const IntelFPGAsSchema = createSchema(db[5]);
    // 7th item is Memory and Storage
    const MemoryandStorageSchema = createSchema(db[6]);
    // 8th item is Chipsets
    const ChipsetsSchema = createSchema(db[7]);
    // 9th item is Graphics
    const GraphicsSchema = createSchema(db[8]);

    // Save Schemas 
    await Promise.all([
        fs.promises.writeFile("schema.processor.json", JSON.stringify(ProcessorSchema, null, '\t'), "utf-8"),
        fs.promises.writeFile("schema.serverproducts.json", JSON.stringify(ServerProductSchema, null, '\t'), "utf-8"),
        fs.promises.writeFile("schema.intelnucs.json", JSON.stringify(IntelNucSchema, null, '\t'), "utf-8"),
        fs.promises.writeFile("schema.wireless.json", JSON.stringify(WirelessSchema, null, '\t'), "utf-8"),
        fs.promises.writeFile("schema.ethernetproducts.json", JSON.stringify(EthernetProductsSchema, null, '\t'), "utf-8"),
        fs.promises.writeFile("schema.intelfpgas.json", JSON.stringify(IntelFPGAsSchema, null, '\t'), "utf-8"),
        fs.promises.writeFile("schema.memoryandstorage.json", JSON.stringify(MemoryandStorageSchema, null, '\t'), "utf-8"),
        fs.promises.writeFile("schema.chipsets.json", JSON.stringify(ChipsetsSchema, null, '\t'), "utf-8"),
        fs.promises.writeFile("schema.graphics.json", JSON.stringify(GraphicsSchema, null, '\t'), "utf-8")
    ]);
});
