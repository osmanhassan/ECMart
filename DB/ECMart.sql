-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: localhost
-- Generation Time: Aug 15, 2023 at 04:39 PM
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
-- Table structure for table `products`
--

CREATE TABLE `products` (
  `ID` int(11) NOT NULL,
  `NAME` varchar(255) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL,
  `SELLER_ID` int(11) NOT NULL,
  `QUANTITY` int(11) NOT NULL,
  `PRICE` float NOT NULL,
  `VARIANT` varchar(255) CHARACTER SET utf8 COLLATE utf8_unicode_ci DEFAULT NULL,
  `RATING` float DEFAULT NULL,
  `IMAGE` blob DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `products`
--

INSERT INTO `products` (`ID`, `NAME`, `SELLER_ID`, `QUANTITY`, `PRICE`, `VARIANT`, `RATING`, `IMAGE`) VALUES
(2, 'Under Wear men', 4, 500, 5.5, 'Red, Purple, Pink, Orange', 3.3, NULL);

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
  `NID` int(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`ID`, `USER_NAME`, `PASSWORD`, `ROLE`, `EMAIL`, `PHONE`, `SHOP_NAME`, `NID`) VALUES
(4, 'osman', 'password', 1, 'asdas', 1323123, 'aadsasd', NULL),
(5, 'enan', 'password', 2, 'enan@gmail.com', 21382147, NULL, NULL),
(6, 'Prithul', 'password', 1, 'prithul@gmail.com', 138374312, 'jamai er bokol ghondho', NULL),
(7, 'Chadni', '123456', 1, 'chadni@gmail.com', 1263573264, 'Win_Shop', NULL),
(8, 'Shuvo', '1234', 2, 'shuvo@gmail.com', 1724327334, NULL, NULL),
(9, 'Noyon', '1234', 3, 'noyon@delivery.com', 1742042069, NULL, 456789876);

--
-- Indexes for dumped tables
--

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
-- AUTO_INCREMENT for table `products`
--
ALTER TABLE `products`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `ID` int(10) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `products`
--
ALTER TABLE `products`
  ADD CONSTRAINT `products_ibfk_1` FOREIGN KEY (`SELLER_ID`) REFERENCES `users` (`ID`) ON DELETE CASCADE ON UPDATE NO ACTION;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
