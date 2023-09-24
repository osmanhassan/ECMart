-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: localhost
-- Generation Time: Sep 24, 2023 at 05:25 PM
-- Server version: 10.4.21-MariaDB
-- PHP Version: 8.1.4

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `ECMart`
--

-- --------------------------------------------------------

--
-- Table structure for table `delivery_items`
--

CREATE TABLE `delivery_items` (
  `ID` int(100) NOT NULL,
  `ORDER_ID` int(100) NOT NULL,
  `PRODUCT_ID` int(100) NOT NULL,
  `UNITS` int(10) NOT NULL,
  `UNIT_PRICE` varchar(100) NOT NULL,
  `TOTAL` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `delivery_items`
--

INSERT INTO `delivery_items` (`ID`, `ORDER_ID`, `PRODUCT_ID`, `UNITS`, `UNIT_PRICE`, `TOTAL`) VALUES
(4, 1, 53, 1, '37500000000000000000', '37500000000000000000'),
(5, 1, 54, 1, '69000000000000000000', '69000000000000000000'),
(6, 1, 55, 2, '27000000000000000000', '54000000000000000000'),
(10, 2, 53, 2, '37500000000000000000', '75000000000000000000'),
(11, 2, 54, 1, '69000000000000000000', '69000000000000000000'),
(12, 2, 55, 2, '27000000000000000000', '54000000000000000000'),
(13, 14, 53, 2, '37500000000000000000', '75000000000000000000');

-- --------------------------------------------------------

--
-- Table structure for table `orders`
--

CREATE TABLE `orders` (
  `ID` int(11) NOT NULL,
  `BUYER_ID` int(11) NOT NULL,
  `BUYER_ADDRESS` varchar(255) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL,
  `TOTAL` varchar(100) NOT NULL,
  `DELIVERMAN_ID` int(11) DEFAULT NULL,
  `ORDER_PK` varchar(100) DEFAULT NULL,
  `STATUS` int(1) NOT NULL DEFAULT 0 COMMENT '0:order placed, 1:deliveryman set, 2: delivered & paid'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `orders`
--

INSERT INTO `orders` (`ID`, `BUYER_ID`, `BUYER_ADDRESS`, `TOTAL`, `DELIVERMAN_ID`, `ORDER_PK`, `STATUS`) VALUES
(1, 137, 'Green Road, Dhanmondi, Dhaka', '417000000000000000000', 138, '0xD0392A29A366fA6443C05f7B1C969D51D811fcb6', 2),
(2, 137, 'Green Road, Dhanmondi, Dhaka', '198000000000000000000', 138, '0x4a0Bb9f17406D6A974ff94B028760cdDC4864FAc', 2),
(3, 137, 'Green Road, Dhanmondi, Dhaka', '66000000000000000000', NULL, NULL, 0),
(4, 137, 'Green Road, Dhanmondi, Dhaka', '82500000000000000000', NULL, '0xA312a76d92c20bD137c84dBdF613c6671aC4926e', 0),
(5, 137, 'Green Road, Dhanmondi, Dhaka', '75000000000000000000', NULL, NULL, 0),
(6, 137, 'Green Road, Dhanmondi, Dhaka', '75000000000000000000', NULL, NULL, 0),
(7, 137, 'Green Road, Dhanmondi, Dhaka', '75000000000000000000', NULL, NULL, 0),
(8, 137, 'Green Road, Dhanmondi, Dhaka', '75000000000000000000', NULL, NULL, 0),
(9, 137, 'Green Road, Dhanmondi, Dhaka', '75000000000000000000', NULL, NULL, 0),
(10, 137, 'Green Road, Dhanmondi, Dhaka', '75000000000000000000', NULL, NULL, 0),
(11, 137, 'Green Road, Dhanmondi, Dhaka', '75000000000000000000', NULL, NULL, 0),
(12, 137, 'Green Road, Dhanmondi, Dhaka', '75000000000000000000', NULL, NULL, 0),
(13, 137, 'Green Road, Dhanmondi, Dhaka', '75000000000000000000', 138, '0xD0392A29A366fA6443C05f7B1C969D51D811fcb6', 1),
(14, 137, 'Green Road, Dhanmondi, Dhaka', '75000000000000000000', 138, '0x4a0Bb9f17406D6A974ff94B028760cdDC4864FAc', 2);

-- --------------------------------------------------------

--
-- Table structure for table `order_items`
--

CREATE TABLE `order_items` (
  `ID` int(11) NOT NULL,
  `ORDER_ID` int(11) NOT NULL,
  `PRODUCT_ID` int(11) NOT NULL,
  `SELLER_ID` int(11) NOT NULL,
  `SELLER_ADDRESS` varchar(255) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL,
  `UNITS` int(11) NOT NULL,
  `UNIT_PRICE` varchar(100) NOT NULL,
  `ITEM_TOTAL` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `order_items`
--

INSERT INTO `order_items` (`ID`, `ORDER_ID`, `PRODUCT_ID`, `SELLER_ID`, `SELLER_ADDRESS`, `UNITS`, `UNIT_PRICE`, `ITEM_TOTAL`) VALUES
(1, 1, 53, 136, 'Shewrapara, Mirpur, Dhaka', 2, '37500000000000000000', '75000000000000000000'),
(2, 1, 54, 136, 'Shewrapara, Mirpur, Dhaka', 3, '69000000000000000000', '207000000000000000000'),
(3, 1, 55, 136, 'Shewrapara, Mirpur, Dhaka', 5, '27000000000000000000', '135000000000000000000'),
(4, 2, 53, 136, 'Shewrapara, Mirpur, Dhaka', 2, '37500000000000000000', '75000000000000000000'),
(5, 2, 54, 136, 'Shewrapara, Mirpur, Dhaka', 1, '69000000000000000000', '69000000000000000000'),
(6, 2, 55, 136, 'Shewrapara, Mirpur, Dhaka', 2, '27000000000000000000', '54000000000000000000'),
(7, 3, 56, 136, 'Shewrapara, Mirpur, Dhaka', 4, '16500000000000000000', '66000000000000000000'),
(8, 4, 56, 136, 'Shewrapara, Mirpur, Dhaka', 5, '16500000000000000000', '82500000000000000000'),
(9, 5, 53, 136, 'Shewrapara, Mirpur, Dhaka', 2, '37500000000000000000', '75000000000000000000'),
(10, 6, 53, 136, 'Shewrapara, Mirpur, Dhaka', 2, '37500000000000000000', '75000000000000000000'),
(11, 7, 53, 136, 'Shewrapara, Mirpur, Dhaka', 2, '37500000000000000000', '75000000000000000000'),
(12, 8, 53, 136, 'Shewrapara, Mirpur, Dhaka', 2, '37500000000000000000', '75000000000000000000'),
(13, 9, 53, 136, 'Shewrapara, Mirpur, Dhaka', 2, '37500000000000000000', '75000000000000000000'),
(14, 10, 53, 136, 'Shewrapara, Mirpur, Dhaka', 2, '37500000000000000000', '75000000000000000000'),
(15, 11, 53, 136, 'Shewrapara, Mirpur, Dhaka', 2, '37500000000000000000', '75000000000000000000'),
(16, 12, 53, 136, 'Shewrapara, Mirpur, Dhaka', 2, '37500000000000000000', '75000000000000000000'),
(17, 13, 53, 136, 'Shewrapara, Mirpur, Dhaka', 2, '37500000000000000000', '75000000000000000000'),
(18, 14, 53, 136, 'Shewrapara, Mirpur, Dhaka', 2, '37500000000000000000', '75000000000000000000');

-- --------------------------------------------------------

--
-- Table structure for table `products`
--

CREATE TABLE `products` (
  `ID` int(11) NOT NULL,
  `NAME` varchar(255) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL,
  `SELLER_ID` int(11) NOT NULL,
  `STOCK` int(11) NOT NULL,
  `PRICE` varchar(30) NOT NULL,
  `FINAL_PRICE` varchar(40) DEFAULT NULL,
  `VARIANT` varchar(255) CHARACTER SET utf8 COLLATE utf8_unicode_ci DEFAULT NULL,
  `RATING` float DEFAULT NULL,
  `IMAGE` blob DEFAULT NULL,
  `ADDRESS` varchar(1500) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `products`
--

INSERT INTO `products` (`ID`, `NAME`, `SELLER_ID`, `STOCK`, `PRICE`, `FINAL_PRICE`, `VARIANT`, `RATING`, `IMAGE`, `ADDRESS`) VALUES
(53, 'iPhone', 136, 140, '30000000000000000000', '37500000000000000000', 'Iphone 11 Pro 256GB White', NULL, NULL, '0x19b53E7768eb93fF454CB963c56755FeAFC39171'),
(54, 'Camera', 136, 13, '60000000000000000000', '69000000000000000000', 'Nikon DSLR', NULL, NULL, '0x16AfD44F1b617612d0DeE6c6DfDBD71B736dEa05'),
(55, 'Watch', 136, 14, '20000000000000000000', '27000000000000000000', 'Apple Watch Series 5', NULL, NULL, '0x0Ad8a755C3E3aC3D44E92665E61F6bc1c054A57E'),
(56, 'Headphone', 136, 123, '10000000000000000000', '16500000000000000000', 'JBL Headphone', NULL, NULL, '0x7777ABa81420d5974915D6bbC0A036dA41eB94C2');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `ID` int(10) NOT NULL,
  `USER_NAME` varchar(30) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL,
  `PASSWORD` varchar(64) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL,
  `ROLE` int(3) NOT NULL,
  `EMAIL` varchar(40) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL,
  `PHONE` int(11) NOT NULL,
  `SHOP_NAME` varchar(40) CHARACTER SET utf8 COLLATE utf8_unicode_ci DEFAULT NULL,
  `NID` int(20) DEFAULT NULL,
  `ADDRESS` varchar(1500) CHARACTER SET utf8 COLLATE utf8_unicode_ci DEFAULT NULL,
  `PK` varchar(42) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`ID`, `USER_NAME`, `PASSWORD`, `ROLE`, `EMAIL`, `PHONE`, `SHOP_NAME`, `NID`, `ADDRESS`, `PK`) VALUES
(136, 'seller', '1', 1, 'seller@gmail.com', 174444444, 'Electronics', 8787878, 'Shewrapara, Mirpur, Dhaka', '0xdD2FD4581271e230360230F9337D5c0430Bf44C0'),
(137, 'buyer', '2', 2, 'buyer@gmail.com', 19454544, NULL, NULL, 'Green Road, Dhanmondi, Dhaka', '0x8626f6940E2eb28930eFb4CeF49B2d1F2C9C1199'),
(138, 'dm', '3', 3, 'dm@gmail.com', 13457592, NULL, 2133131, 'Kolabagan, Dhaka', '0xcd3B766CCDd6AE721141F452C550Ca635964ce71');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `delivery_items`
--
ALTER TABLE `delivery_items`
  ADD PRIMARY KEY (`ID`);

--
-- Indexes for table `orders`
--
ALTER TABLE `orders`
  ADD PRIMARY KEY (`ID`),
  ADD KEY `BUYER_ID` (`BUYER_ID`),
  ADD KEY `DELIVERMAN_ID` (`DELIVERMAN_ID`);

--
-- Indexes for table `order_items`
--
ALTER TABLE `order_items`
  ADD PRIMARY KEY (`ID`),
  ADD KEY `ORDER_ID` (`ORDER_ID`),
  ADD KEY `PRODUCT_ID` (`PRODUCT_ID`),
  ADD KEY `SELLER_ID` (`SELLER_ID`);

--
-- Indexes for table `products`
--
ALTER TABLE `products`
  ADD PRIMARY KEY (`ID`),
  ADD KEY `SELLER_ID` (`SELLER_ID`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`ID`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `delivery_items`
--
ALTER TABLE `delivery_items`
  MODIFY `ID` int(100) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

--
-- AUTO_INCREMENT for table `orders`
--
ALTER TABLE `orders`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

--
-- AUTO_INCREMENT for table `order_items`
--
ALTER TABLE `order_items`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=19;

--
-- AUTO_INCREMENT for table `products`
--
ALTER TABLE `products`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=57;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `ID` int(10) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=139;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `orders`
--
ALTER TABLE `orders`
  ADD CONSTRAINT `orders_ibfk_1` FOREIGN KEY (`BUYER_ID`) REFERENCES `users` (`ID`),
  ADD CONSTRAINT `orders_ibfk_2` FOREIGN KEY (`DELIVERMAN_ID`) REFERENCES `users` (`ID`);

--
-- Constraints for table `order_items`
--
ALTER TABLE `order_items`
  ADD CONSTRAINT `order_items_ibfk_1` FOREIGN KEY (`ORDER_ID`) REFERENCES `orders` (`ID`),
  ADD CONSTRAINT `order_items_ibfk_2` FOREIGN KEY (`PRODUCT_ID`) REFERENCES `products` (`ID`),
  ADD CONSTRAINT `order_items_ibfk_3` FOREIGN KEY (`SELLER_ID`) REFERENCES `users` (`ID`);

--
-- Constraints for table `products`
--
ALTER TABLE `products`
  ADD CONSTRAINT `products_ibfk_1` FOREIGN KEY (`SELLER_ID`) REFERENCES `users` (`ID`) ON DELETE CASCADE ON UPDATE NO ACTION;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
