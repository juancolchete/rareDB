SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;


DELIMITER $$
CREATE DEFINER=`root`@`%` FUNCTION `get_user_balance` (`p_wallet_address` VARCHAR(100), `p_asset_id` INT) RETURNS DECIMAL(30,18) READS SQL DATA BEGIN
  DECLARE wallet_balance DECIMAL(30,18);
  SET @wallet_id = (SELECT id FROM wallet WHERE address = p_wallet_address  LIMIT 1);
  SELECT (SELECT SUM(value) FROM entry e 
          WHERE to_wallet_id = @wallet_id 
          AND asset_id = p_asset_id) - 
          (SELECT SUM(value+fee) FROM `entry` 
           WHERE from_wallet_id = @wallet_id 
           AND asset_id = p_asset_id) INTO wallet_balance;
   RETURN wallet_balance;
END$$

DELIMITER ;

CREATE TABLE `asset` (
  `id` int UNSIGNED NOT NULL,
  `name` varchar(200) NOT NULL,
  `description` varchar(500) NOT NULL,
  `blockchain_id` int UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `blockchain` (
  `id` int UNSIGNED NOT NULL,
  `name` varchar(45) NOT NULL,
  `description` varchar(200) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `entry` (
  `id` int UNSIGNED NOT NULL,
  `value` decimal(30,18) NOT NULL,
  `description` varchar(500) NOT NULL,
  `observation` varchar(500) NOT NULL,
  `txn_date` datetime NOT NULL,
  `txn_id` varchar(200) NOT NULL,
  `fee` decimal(30,18) NOT NULL,
  `from_wallet_id` int UNSIGNED NOT NULL,
  `to_wallet_id` int UNSIGNED NOT NULL,
  `asset_id` int UNSIGNED NOT NULL,
  `type_id` int UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `type` (
  `id` int UNSIGNED NOT NULL,
  `name` varchar(200) NOT NULL,
  `description` varchar(500) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `user` (
  `id` int UNSIGNED NOT NULL,
  `nickname` varchar(100) NOT NULL,
  `profile_photo` varchar(200) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `wallet` (
  `id` int UNSIGNED NOT NULL,
  `address` varchar(100) NOT NULL,
  `name` varchar(100) NOT NULL,
  `description` varchar(500) NOT NULL,
  `user_id` int UNSIGNED NOT NULL,
  `blockchain_id` int UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


ALTER TABLE `asset`
  ADD PRIMARY KEY (`id`),
  ADD KEY `blockchain_id` (`blockchain_id`);

ALTER TABLE `blockchain`
  ADD PRIMARY KEY (`id`);

ALTER TABLE `entry`
  ADD PRIMARY KEY (`id`),
  ADD KEY `from_wallet_id` (`from_wallet_id`),
  ADD KEY `to_wallet_id` (`to_wallet_id`),
  ADD KEY `type_id` (`type_id`),
  ADD KEY `asset_id` (`asset_id`);

ALTER TABLE `type`
  ADD PRIMARY KEY (`id`);

ALTER TABLE `user`
  ADD PRIMARY KEY (`id`);

ALTER TABLE `wallet`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `blockchain_id` (`blockchain_id`);


ALTER TABLE `asset`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT;

ALTER TABLE `blockchain`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT;

ALTER TABLE `entry`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT;

ALTER TABLE `type`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT;

ALTER TABLE `user`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT;

ALTER TABLE `wallet`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT;


ALTER TABLE `asset`
  ADD CONSTRAINT `fk_asset_blockchain` FOREIGN KEY (`blockchain_id`) REFERENCES `blockchain` (`id`);

ALTER TABLE `entry`
  ADD CONSTRAINT `entry_asset_id` FOREIGN KEY (`asset_id`) REFERENCES `asset` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  ADD CONSTRAINT `entry_type_id` FOREIGN KEY (`type_id`) REFERENCES `type` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  ADD CONSTRAINT `entry_wallet_from` FOREIGN KEY (`from_wallet_id`) REFERENCES `wallet` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  ADD CONSTRAINT `entry_wallet_to` FOREIGN KEY (`to_wallet_id`) REFERENCES `wallet` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE `wallet`
  ADD CONSTRAINT `wallet_blockchain_id` FOREIGN KEY (`blockchain_id`) REFERENCES `blockchain` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  ADD CONSTRAINT `wallet_user_id` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
