-- phpMyAdmin SQL Dump
-- version 4.8.3
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: Dec 09, 2018 at 11:55 PM
-- Server version: 5.6.39-cll-lve
-- PHP Version: 7.2.7

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `upmhworl_estudihambres`
--
CREATE DATABASE IF NOT EXISTS `upmhworl_estudihambres` DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;
USE `upmhworl_estudihambres`;

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`upmhworl`@`localhost` PROCEDURE `borrarProducto` (IN `productoID` INT)  BEGIN

UPDATE Producto
SET Producto.Activo=0 WHERE Producto.idProducto=productoID; 

END$$

CREATE DEFINER=`upmhworl`@`localhost` PROCEDURE `busquedaProducto` (IN `aguja` VARCHAR(255))  NO SQL
select Producto.idProducto as idPro, Producto.Foto as fotoPro, Producto.Nombre as nombrePro, Producto.Precio as precioPro FROM Producto 
WHERE Producto.Activo=1 AND
( nombre LIKE CONCAT('%',aguja,'%') 
OR descripcion LIKE CONCAT('%',aguja,'%') )$$

CREATE DEFINER=`upmhworl`@`localhost` PROCEDURE `editarProducto` (IN `productoID` INT, IN `productoPrice` INT, IN `productoName` VARCHAR(45), IN `productoCantidad` INT)  BEGIN
DECLARE ANTERIOR INT DEFAULT 0;
UPDATE Producto
SET Producto.Nombre = productoName, Producto.Precio = productoPrice WHERE Producto.idProducto=productoID; 



select SUM(Cantidad) INTO ANTERIOR FROM Movimiento WHERE idProducto=productoID GROUP BY idProducto;



INSERT INTO Movimiento (Movimiento.Cantidad, Movimiento.idProducto, Movimiento.IsDesechado, Movimiento.Momento) VALUES (productoCantidad-ANTERIOR, productoID, False, now());

END$$

CREATE DEFINER=`upmhworl`@`localhost` PROCEDURE `editarUser` (IN `usuarioID` INT, IN `nombre` VARCHAR(90), IN `appaterno` VARCHAR(90), IN `apmaterno` VARCHAR(90), IN `alias` VARCHAR(45), IN `cel` VARCHAR(15))  BEGIN

UPDATE Usuario
SET Alias=alias, ApellidoM=apmaterno, ApellidoP=appaterno, Celular = cel, Nombre = nombre WHERE idUsuario=usuarioID; 

END$$

CREATE DEFINER=`upmhworl`@`localhost` PROCEDURE `spRegistrarUsuario` (IN `name` VARCHAR(90), IN `lastP` VARCHAR(90), IN `lastM` VARCHAR(90), IN `seudo` VARCHAR(45), IN `phone` VARCHAR(15), IN `contra` VARCHAR(255))  BEGIN

insert into Usuario(Nombre, ApellidoP, ApellidoM, Alias, Celular, Password, idCampus) VALUES(name, lastP, lastM, seudo, phone, contra, 1);

select LAST_insert_id() ID;

END$$

CREATE DEFINER=`upmhworl`@`localhost` PROCEDURE `spValidarAcceso` (IN `phone` VARCHAR(15), IN `contra` VARCHAR(255))  BEGIN
 IF EXISTS(SELECT * FROM Usuario 
    WHERE Usuario.Celular=phone AND Usuario.Password=contra) THEN 
           
      SELECT A.idUsuario ID,
      CONCAT(A.Nombre,' ',A.ApellidoP,' ',A.ApellidoM) NOMBRE 
      FROM Usuario A
      WHERE A.Celular=phone
      AND A.Password=contra;
      ELSE
      SELECT '0' ID;
  END IF;
      END$$

CREATE DEFINER=`upmhworl`@`localhost` PROCEDURE `verCantidadProducto` (IN `productoID` INT)  BEGIN

SELECT SUM(Movimiento.Cantidad) FROM Movimiento where Movimiento.idProducto = productoID;


END$$

CREATE DEFINER=`upmhworl`@`localhost` PROCEDURE `verMisProductos` (IN `id` INT)  BEGIN

select Producto.idProducto as idPro, Producto.Foto as fotoPro, Producto.Nombre as nombrePro, SUM(Movimiento.Cantidad) as cantidadPro, Producto.Precio as precio FROM Producto LEFT JOIN Movimiento ON Movimiento.idProducto = Producto.idProducto WHERE Producto.idUsuario=id and Producto.Activo=1 GROUP BY idPro;

END$$

CREATE DEFINER=`upmhworl`@`localhost` PROCEDURE `verTodosProductos` ()  BEGIN

select Producto.idProducto as idPro, Producto.Foto as fotoPro, Producto.Nombre as nombrePro, Producto.Precio as precioPro, SUM(Movimiento.Cantidad) as cantidadPro FROM Producto LEFT JOIN Movimiento ON Movimiento.idProducto = Producto.idProducto WHERE Producto.Activo=1 GROUP BY idPro ;


END$$

CREATE DEFINER=`upmhworl`@`localhost` PROCEDURE `verunproducto` (IN `id` INT)  BEGIN

select Producto.idProducto as idPro, Producto.Foto as fotoPro, Producto.Nombre as nombrePro, SUM(Movimiento.Cantidad) as cantidadPro, Producto.Precio as precio, Producto.Descripcion as descripcion, CONCAT(Usuario.Nombre, " ", Usuario.ApellidoP, " ", Usuario.ApellidoM) as username, Usuario.Alias as alias, Usuario.Foto as userfoto, Usuario.UltimaUbicacion as ultima, Usuario.Celular as celular FROM Producto LEFT JOIN Movimiento ON Movimiento.idProducto = Producto.idProducto INNER JOIN Usuario ON (Usuario.idUsuario = Producto.idUsuario) WHERE Producto.idProducto=id;

END$$

CREATE DEFINER=`upmhworl`@`localhost` PROCEDURE `verUser` (IN `usuarioID` INT)  BEGIN

SELECT Usuario.Nombre, Usuario.ApellidoP, Usuario.ApellidoM, Usuario.Alias, Usuario.Celular FROM Usuario WHERE Usuario.idUsuario = usuarioID;

END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `Aula`
--

CREATE TABLE `Aula` (
  `idAula` int(11) NOT NULL,
  `Numero` varchar(45) NOT NULL,
  `idEdificio` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `Campus`
--

CREATE TABLE `Campus` (
  `idCampus` int(11) NOT NULL,
  `Nombre` varchar(90) NOT NULL,
  `Estado` varchar(45) DEFAULT NULL,
  `Municipio` varchar(90) DEFAULT NULL,
  `Coordenadas` varchar(255) DEFAULT NULL,
  `idOrganizacion` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `Campus`
--

INSERT INTO `Campus` (`idCampus`, `Nombre`, `Estado`, `Municipio`, `Coordenadas`, `idOrganizacion`) VALUES
(1, 'UPMH', 'Hidalgo', 'Tolcayuca', '-2,-5', 1);

-- --------------------------------------------------------

--
-- Table structure for table `Edificio`
--

CREATE TABLE `Edificio` (
  `idEdificio` int(11) NOT NULL,
  `Nombre` varchar(45) DEFAULT NULL,
  `idCampus` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `Etiqueta`
--

CREATE TABLE `Etiqueta` (
  `idEtiqueta` int(11) NOT NULL,
  `Nombre` varchar(45) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `Movimiento`
--

CREATE TABLE `Movimiento` (
  `idMovimiento` int(11) NOT NULL,
  `Cantidad` int(11) NOT NULL,
  `Momento` datetime NOT NULL,
  `idProducto` int(11) NOT NULL,
  `IsDesechado` tinyint(4) NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `Organizacion`
--

CREATE TABLE `Organizacion` (
  `idOrganizacion` int(11) NOT NULL,
  `Nombre` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `Organizacion`
--

INSERT INTO `Organizacion` (`idOrganizacion`, `Nombre`) VALUES
(1, 'UPMH');

-- --------------------------------------------------------

--
-- Table structure for table `Producto`
--

CREATE TABLE `Producto` (
  `idProducto` int(11) NOT NULL,
  `Nombre` varchar(45) NOT NULL,
  `Descripcion` varchar(255) DEFAULT NULL,
  `Precio` int(11) NOT NULL,
  `idUsuario` int(11) NOT NULL,
  `Activo` tinyint(4) NOT NULL,
  `Foto` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `Producto_has_Etiqueta`
--

CREATE TABLE `Producto_has_Etiqueta` (
  `idProducto` int(11) NOT NULL,
  `idEtiqueta` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `Usuario`
--

CREATE TABLE `Usuario` (
  `idUsuario` int(11) NOT NULL,
  `Nombre` varchar(90) DEFAULT NULL,
  `ApellidoP` varchar(90) DEFAULT NULL,
  `ApellidoM` varchar(90) DEFAULT NULL,
  `Alias` varchar(45) DEFAULT NULL,
  `Celular` varchar(15) DEFAULT NULL,
  `Password` varchar(255) DEFAULT NULL,
  `Foto` varchar(70) DEFAULT NULL,
  `UltimaUbicacion` varchar(255) DEFAULT NULL,
  `TimeUbicacion` datetime DEFAULT NULL,
  `idCampus` int(11) NOT NULL,
  `fb_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `UsuarioAccesaProducto`
--

CREATE TABLE `UsuarioAccesaProducto` (
  `idProducto` int(11) NOT NULL,
  `idUsuario` int(11) NOT NULL,
  `Momento` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `UsuarioContactaProducto`
--

CREATE TABLE `UsuarioContactaProducto` (
  `idProducto` int(11) NOT NULL,
  `idUsuario` int(11) NOT NULL,
  `Momento` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `Aula`
--
ALTER TABLE `Aula`
  ADD PRIMARY KEY (`idAula`),
  ADD KEY `fk_Aula_Edificio_idx` (`idEdificio`);

--
-- Indexes for table `Campus`
--
ALTER TABLE `Campus`
  ADD PRIMARY KEY (`idCampus`),
  ADD KEY `fk_Campus_Organizacion1_idx` (`idOrganizacion`);

--
-- Indexes for table `Edificio`
--
ALTER TABLE `Edificio`
  ADD PRIMARY KEY (`idEdificio`),
  ADD KEY `fk_Edificio_Campus1_idx` (`idCampus`);

--
-- Indexes for table `Etiqueta`
--
ALTER TABLE `Etiqueta`
  ADD PRIMARY KEY (`idEtiqueta`);

--
-- Indexes for table `Movimiento`
--
ALTER TABLE `Movimiento`
  ADD PRIMARY KEY (`idMovimiento`),
  ADD KEY `fk_Movimiento_Producto1_idx` (`idProducto`);

--
-- Indexes for table `Organizacion`
--
ALTER TABLE `Organizacion`
  ADD PRIMARY KEY (`idOrganizacion`);

--
-- Indexes for table `Producto`
--
ALTER TABLE `Producto`
  ADD PRIMARY KEY (`idProducto`),
  ADD KEY `fk_Producto_Usuario1_idx` (`idUsuario`);

--
-- Indexes for table `Producto_has_Etiqueta`
--
ALTER TABLE `Producto_has_Etiqueta`
  ADD PRIMARY KEY (`idProducto`,`idEtiqueta`),
  ADD KEY `fk_Producto_has_Etiqueta_Etiqueta1_idx` (`idEtiqueta`),
  ADD KEY `fk_Producto_has_Etiqueta_Producto1_idx` (`idProducto`);

--
-- Indexes for table `Usuario`
--
ALTER TABLE `Usuario`
  ADD PRIMARY KEY (`idUsuario`),
  ADD UNIQUE KEY `fb_id_unico` (`fb_id`),
  ADD KEY `fk_Usuario_Campus1_idx` (`idCampus`);

--
-- Indexes for table `UsuarioAccesaProducto`
--
ALTER TABLE `UsuarioAccesaProducto`
  ADD PRIMARY KEY (`idProducto`,`idUsuario`),
  ADD KEY `fk_Producto_has_Usuario_Usuario1_idx` (`idUsuario`),
  ADD KEY `fk_Producto_has_Usuario_Producto1_idx` (`idProducto`);

--
-- Indexes for table `UsuarioContactaProducto`
--
ALTER TABLE `UsuarioContactaProducto`
  ADD PRIMARY KEY (`idProducto`,`idUsuario`),
  ADD KEY `fk_Producto_has_Usuario_Usuario2_idx` (`idUsuario`),
  ADD KEY `fk_Producto_has_Usuario_Producto2_idx` (`idProducto`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `Aula`
--
ALTER TABLE `Aula`
  MODIFY `idAula` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `Campus`
--
ALTER TABLE `Campus`
  MODIFY `idCampus` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `Edificio`
--
ALTER TABLE `Edificio`
  MODIFY `idEdificio` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `Etiqueta`
--
ALTER TABLE `Etiqueta`
  MODIFY `idEtiqueta` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `Movimiento`
--
ALTER TABLE `Movimiento`
  MODIFY `idMovimiento` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=73;

--
-- AUTO_INCREMENT for table `Organizacion`
--
ALTER TABLE `Organizacion`
  MODIFY `idOrganizacion` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `Producto`
--
ALTER TABLE `Producto`
  MODIFY `idProducto` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=49;

--
-- AUTO_INCREMENT for table `Usuario`
--
ALTER TABLE `Usuario`
  MODIFY `idUsuario` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=55;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `Aula`
--
ALTER TABLE `Aula`
  ADD CONSTRAINT `fk_Aula_Edificio` FOREIGN KEY (`idEdificio`) REFERENCES `Edificio` (`idEdificio`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Constraints for table `Campus`
--
ALTER TABLE `Campus`
  ADD CONSTRAINT `fk_Campus_Organizacion1` FOREIGN KEY (`idOrganizacion`) REFERENCES `Organizacion` (`idOrganizacion`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Constraints for table `Edificio`
--
ALTER TABLE `Edificio`
  ADD CONSTRAINT `fk_Edificio_Campus1` FOREIGN KEY (`idCampus`) REFERENCES `Campus` (`idCampus`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Constraints for table `Movimiento`
--
ALTER TABLE `Movimiento`
  ADD CONSTRAINT `fk_Movimiento_Producto1` FOREIGN KEY (`idProducto`) REFERENCES `Producto` (`idProducto`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Constraints for table `Producto`
--
ALTER TABLE `Producto`
  ADD CONSTRAINT `fk_Producto_Usuario1` FOREIGN KEY (`idUsuario`) REFERENCES `Usuario` (`idUsuario`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Constraints for table `Producto_has_Etiqueta`
--
ALTER TABLE `Producto_has_Etiqueta`
  ADD CONSTRAINT `fk_Producto_has_Etiqueta_Etiqueta1` FOREIGN KEY (`idEtiqueta`) REFERENCES `Etiqueta` (`idEtiqueta`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_Producto_has_Etiqueta_Producto1` FOREIGN KEY (`idProducto`) REFERENCES `Producto` (`idProducto`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Constraints for table `Usuario`
--
ALTER TABLE `Usuario`
  ADD CONSTRAINT `fk_Usuario_Campus1` FOREIGN KEY (`idCampus`) REFERENCES `Campus` (`idCampus`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Constraints for table `UsuarioAccesaProducto`
--
ALTER TABLE `UsuarioAccesaProducto`
  ADD CONSTRAINT `fk_Producto_has_Usuario_Producto1` FOREIGN KEY (`idProducto`) REFERENCES `Producto` (`idProducto`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_Producto_has_Usuario_Usuario1` FOREIGN KEY (`idUsuario`) REFERENCES `Usuario` (`idUsuario`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Constraints for table `UsuarioContactaProducto`
--
ALTER TABLE `UsuarioContactaProducto`
  ADD CONSTRAINT `fk_Producto_has_Usuario_Producto2` FOREIGN KEY (`idProducto`) REFERENCES `Producto` (`idProducto`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_Producto_has_Usuario_Usuario2` FOREIGN KEY (`idUsuario`) REFERENCES `Usuario` (`idUsuario`) ON DELETE NO ACTION ON UPDATE NO ACTION;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
