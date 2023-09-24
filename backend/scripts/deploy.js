const { ethers, run, network } = require("hardhat");
const fs = require("fs");
const path = require("path");

const ecmartPublicAddress = "0xbda5747bfd65f08deb54cb465eb87d40e51b197e"; //17
const ecmartPrivateKey =
  "0x689af8efa8c651a91ad287602527f3af2fe9f6501a7ac4b061667b5a93e037fd";
// Seller Wallet
const sellerPublicAddress = "0xdd2fd4581271e230360230f9337d5c0430bf44c0"; //18
const sellerWalletPrivateKey =
  "0xde9be858da4a475276426320d5e9262ecfc3ba460bfac56360bfa6c4c28b4ee0";
// Seller Wallet_2
const seller_2_PublicAddress = "0x2546bcd3c84621e976d8185a91a922ae77ecec30"; //16
const seller_2_WalletPrivateKey =
  "0xea6c44ac03bff858b476bba40716402b03e41b8e97e276d1baec7c37d42484a0";
// Buyer
const buyerPublicAddress = "0x8626f6940e2eb28930efb4cef49b2d1f2c9c1199"; //19
const buyerWalletPrivateKey =
  "0xdf57089febbacf7ba0bc227dafbffa9fc08a93fdc68e1e42411a14efcf23656e";
// Deliveryman
const dmPublicAddress = "0xcd3b766ccdd6ae721141f452c550ca635964ce71"; //15
const dmWalletPrivateKey =
  "0x8166f546bab6da521a8369cab06c5d2b9e46670292d85c875ee9ec20e84ffb61";

// Using Hardhat's default network
const provider = ethers.provider;

// tahole ki deploy js ei db connect kore update korbo??????????? aso??? hae... I don't see any other option.... let me chatgpt the issue
async function main() {
  //connect wallet
  const ecmartWallet = new ethers.Wallet(ecmartPrivateKey, ethers.provider);
  const sellerWallet = new ethers.Wallet(
    sellerWalletPrivateKey,
    ethers.provider
  );
  const buyerWallet = new ethers.Wallet(buyerWalletPrivateKey, ethers.provider);
  const dmWallet = new ethers.Wallet(dmWalletPrivateKey, ethers.provider);

  // connect wallet with ecmart_wallet for deployment
  const DiamondContractFactory = await ethers.getContractFactory("Diamond");
  //Contract Deployment
  // const gasLimit = 20000000000000;

  console.log("Deploying contract...");
  const ecmart = await DiamondContractFactory.connect(ecmartWallet).deploy();
  // deployed() checks whether the contract is deployed properly, returns `undefined` if it doesn't
  await ecmart.deployed();
  // in current hardhat version, you might need to write ${simpleStorage.target}
  console.log(`Deployed ECMART contract to: ${ecmart.address}`);

  // connect to registration Facet
  const registrationFacet = await ethers.getContractAt(
    "RegistrationFacet",
    ecmart.address
  );
  console.log(`Registration Facet initiated`);

  // registrationFacet.on("sellerRegistered", (address) => {
  //   console.log("Event data:", address); // Access event data here
  // });

  // register as seller
  let tx_seller = await registrationFacet
    .connect(sellerWallet)
    .registerSeller(136);
  console.log("Seller Registered");

  //register as buyer
  let tx_buyer = await registrationFacet
    .connect(buyerWallet)
    .registerBuyer(137);
  console.log("Buyer Registered");

  //register as DM
  let tx_dm = await registrationFacet
    .connect(dmWallet)
    .registerDeliveryMan(138);
  console.log("Deliveryman Registered");

  //connect to Product Facet
  const productFacet = await ethers.getContractAt(
    "ProductFacet",
    ecmart.address
  );
  console.log(`Product Facet initiated`);
  console;

  //add product as seller
  let tx_addProduct = await productFacet
    .connect(sellerWallet)
    .addProduct(
      "iPhone",
      "30000000000000000000",
      "Iphone 11 Pro 256GB White",
      140,
      53
    );
  // await tx_3.wait(1);
  console.log("Product Added 1");

  tx_addProduct = await productFacet
    .connect(sellerWallet)
    .addProduct("Camera", "60000000000000000000", "Nikon DSLR", 13, 54);
  console.log("Product Added 2");

  tx_addProduct = await productFacet
    .connect(sellerWallet)
    .addProduct(
      "Watch",
      "20000000000000000000",
      "Apple Watch Series 5",
      14,
      55
    );
  console.log("Product Added 3");

  //view Products
  console.log("Product addresses :");
  let tx_viewProduct = await productFacet.viewProducts(sellerPublicAddress);
  console.log(tx_viewProduct);

  // //order
  // console.log("----------------  Order PREVIEW  ---------------------");
  // const orderFacet = await ethers.getContractAt("OrderFacet", ecmart.address);
  // console.log(`PlaceOrder Facet initiated`);

  // let tx_order = await orderFacet
  //   .connect(buyerWallet)
  //   .placeOrder([tx_viewProduct[0], tx_viewProduct[1]], [2, 3], {
  //     value: ethers.utils.parseEther("135.1"),
  //   });

  // const deliveryFacet = await ethers.getContractAt(
  //   "DeliveryFacet",
  //   ecmart.address
  // );
  // console.log(`Delivery Facet initiated`);

  // //addOrder eventListener
  // orderFacet.on("Save", (_orderAddress) => {
  //   console.log("Order address ---->" + _orderAddress);
  //   setDM(_orderAddress);
  // });

  // //set DM
  // async function setDM(orderAddress) {
  //   let tx_setDM = await deliveryFacet
  //     .connect(dmWallet)
  //     .setDeliveryMan(orderAddress);
  //   console.log("DM is set");
  //   await orderShow(orderAddress);
  //   await deliverOrder(orderAddress);
  //   await paymentOfOrder(orderAddress);
  //   await productView();
  // }

  // //Order details all show
  // async function orderShow(_orderAddress) {
  //   let orderAddress = _orderAddress;
  //   let abi = getTheAbi("Order");
  //   const orderContract = new ethers.Contract(orderAddress, abi, provider);

  //   console.log(
  //     "--------------- ORDERS PREVIEW BEFORE DELIVERY ----------------"
  //   );
  //   console.log(
  //     `Deliveryman of order is : ${await orderContract
  //       .connect(buyerWallet)
  //       .getDeliveryMan()}`
  //   );
  //   console.log(
  //     `order items : ${await orderContract
  //       .connect(buyerWallet)
  //       .getOrderItems()}`
  //   );
  //   console.log(
  //     `Buyer of Order : ${await orderContract.connect(buyerWallet).getBuyer()}`
  //   );
  //   console.log(
  //     `Order units: ${await orderContract.connect(buyerWallet).getOrderUnits()}`
  //   );
  //   console.log(
  //     `Delivered Items should be null : ${await orderContract
  //       .connect(buyerWallet)
  //       .getDeliveredItems()}`
  //   );
  //   console.log(
  //     `Delivered Units should be null : ${await orderContract
  //       .connect(buyerWallet)
  //       .getDeliveredUnits()}`
  //   );

  //   console.log(
  //     `Order Final Price: ${await orderContract
  //       .connect(buyerWallet)
  //       .getOrderUnitFinalPrice()}`
  //   );
  //   console.log(
  //     `Order delivered: ${await orderContract
  //       .connect(buyerWallet)
  //       .getIsDelivered()}`
  //   );
  //   console.log(
  //     `Buyer Paid: ${await orderContract
  //       .connect(buyerWallet)
  //       .getBuyerTotalPaid()}`
  //   );

  //   //Current Buyer Balance
  //   const balanceEtherOfBuyer = ethers.utils.formatEther(
  //     await provider.getBalance(buyerPublicAddress)
  //   );
  //   console.log(`Buyer Balance After Purchase: ${balanceEtherOfBuyer}`);
  //   //Current Seller Balance
  //   const balanceEtherOfSeller = ethers.utils.formatEther(
  //     await provider.getBalance(sellerPublicAddress)
  //   );
  //   console.log(`Seller Balance After Purchase: ${balanceEtherOfSeller}`);
  //   //Balance of ECMART
  //   const contractBalanceEther = ethers.utils.formatEther(
  //     await ethers.provider.getBalance(ecmart.address)
  //   );
  //   console.log(`ECMART BALANCE After Purchase: ${contractBalanceEther}`);

  //   //Balance of deliveryman
  //   const balanceEtherOfDM = ethers.utils.formatEther(
  //     await ethers.provider.getBalance(dmPublicAddress)
  //   );
  //   console.log(`Deliveryman BALANCE Before Delivery: ${balanceEtherOfDM}`);
  // }

  // async function deliverOrder(orderAddress) {
  //   console.log(
  //     "----------------- ORDER PREVIEW DURING DELIVERY -------------- "
  //   );
  //   let abi = getTheAbi("Order");
  //   const orderContract = new ethers.Contract(orderAddress, abi, provider);

  //   //Set Delivery by DM
  //   let tx_setDelivery = await deliveryFacet
  //     .connect(dmWallet)
  //     .setDelivery(
  //       orderAddress,
  //       [tx_viewProduct[0], tx_viewProduct[1]],
  //       [2, 3]
  //     );
  //   console.log("Delivery Items and Quantity is SET by delivery man");
  //   //Get Delivery Items and Units
  //   console.log(
  //     `Delivered Items Should APPEAR NOW : ${await orderContract
  //       .connect(buyerWallet)
  //       .getDeliveredItems()}`
  //   );
  //   console.log(
  //     `Delivered Units Should APPEAR NOW : ${await orderContract
  //       .connect(buyerWallet)
  //       .getDeliveredUnits()}`
  //   );
  // }

  // async function paymentOfOrder(orderAddress) {
  //   console.log("----------------- PAYMENT PREVIEW -------------- ");

  //   // connect to PayOrder Facet
  //   const orderFacet = await ethers.getContractAt("OrderFacet", ecmart.address);
  //   console.log(`Order Facet initiated`);

  //   //Current Buyer Balance
  //   orderFacet.on("OrderPaid", (_isPaid) => {
  //     if (_isPaid) {
  //       console.log(
  //         "paid ----------------------------------------------------------"
  //       );
  //       async function logBal() {
  //         const balanceEtherOfBuyer = ethers.utils.formatEther(
  //           await provider.getBalance(buyerPublicAddress)
  //         );
  //         console.log(`Buyer Balance After Delivery: ${balanceEtherOfBuyer}`);
  //         //Current Seller Balance
  //         const balanceEtherOfSeller = ethers.utils.formatEther(
  //           await provider.getBalance(sellerPublicAddress)
  //         );
  //         console.log(`Seller Balance After Delivery: ${balanceEtherOfSeller}`);

  //         //Balance of ECMART
  //         const contractBalanceEther = ethers.utils.formatEther(
  //           await ethers.provider.getBalance(ecmart.address)
  //         );
  //         console.log(`ECMART BALANCE After Delivery: ${contractBalanceEther}`);
  //         //Balance of deliveryman
  //         const balanceEtherOfDM = ethers.utils.formatEther(
  //           await ethers.provider.getBalance(dmPublicAddress)
  //         );
  //         console.log(
  //           `Deliveryman BALANCE After Delivery: ${balanceEtherOfDM}`
  //         );
  //       }
  //       logBal();
  //     } else {
  //       console.log("Order is not paid");
  //     }
  //   });
  //   // console.log("///// ERROR occured Here!! ");
  //   // Pay to seller
  //   let tx_payOrder = await orderFacet
  //     .connect(buyerWallet)
  //     .payOrder(orderAddress);
  //   console.log(
  //     "Payment Provided to Buyer, Seller, and Deliveryman. \nShould get review-rating amount back."
  //   );
  // }

  // //Product Post-mortem
  // async function productView() {
  //   console.log(
  //     "------------------  Product PREVIEW  -------------------------"
  //   );
  //   //tx_viewProduct[]
  //   let abi = getTheAbi("Product");
  //   const productContract_1 = new ethers.Contract(
  //     tx_viewProduct[0],
  //     abi,
  //     provider
  //   );

  //   //getQuantity()
  //   console.log(
  //     `Quantity of Product 1 : ${await productContract_1
  //       .connect(sellerWallet)
  //       .getQuantity()}`
  //   );

  //   // getPrice()
  //   console.log(
  //     `Price of Product 1 : ${await productContract_1
  //       .connect(sellerWallet)
  //       .getPrice()}`
  //   );

  //   //getProductFinalPrice()
  //   console.log(
  //     `Final Price of Product 1 : ${await productContract_1
  //       .connect(buyerWallet)
  //       .getProductFinalPrice()}`
  //   );

  //   //getSeller()
  //   console.log(
  //     `Seller of Product 1 : ${await productContract_1
  //       .connect(buyerWallet)
  //       .getSeller()}`
  //   );

  //   //getEcmartAmount()
  //   console.log(
  //     `ECMart Amount on Product 1 : ${await provider.getBalance(
  //       ecmart.address
  //     )}`
  //   );

  //   // //getReviewRatingAmount()
  //   // console.log(
  //   //   `Review-Rating Amount on Product 1 : ${await productContract_1
  //   //     .connect(ecmart.address)
  //   //     .getReviewRatingAmount()}`
  //   // );
  // }
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

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
