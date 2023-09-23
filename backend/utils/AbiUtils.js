const fs = require("fs");
const path = require("path");

const getTheAbi = (name) => {
  try {
    const dir = path.resolve(
      __dirname,
      `../artifacts/contracts/${name}.sol/${name}.json`
    );
    const file = fs.readFileSync(dir, "utf8");
    const json = JSON.parse(file);
    const abi = json.abi;
    // console.log(`abi`, abi)

    return abi;
  } catch (e) {
    console.log(`e`, e);
  }
};

const getFacetAbi = (diamondName, facetName) => {
  try {
    const dir = path.resolve(
      __dirname,
      `../artifacts/contracts/${diamondName}.sol/${facetName}.json`
    );
    const file = fs.readFileSync(dir, "utf8");
    const json = JSON.parse(file);
    const abi = json.abi;
    // console.log(`abi`, abi)

    return abi;
  } catch (e) {
    console.log(`e`, e);
  }
};

module.exports = {
  getTheAbi,
  getFacetAbi,
};
