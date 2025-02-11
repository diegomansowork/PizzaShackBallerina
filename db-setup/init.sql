CREATE DATABASE `PizzaShack` /*!40100 DEFAULT CHARACTER SET utf16 COLLATE utf16_spanish_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;

-- PizzaShack.Menu definition

CREATE TABLE PizzaShack.`MENU` (
  MENU_ID SMALLINT UNSIGNED auto_increment NOT NULL,
  NAME varchar(100) NOT NULL UNIQUE,
  DESCRIPTION varchar(500) DEFAULT NULL,
  PRICE DECIMAL(15,2) NULL,
  ICON varchar(400) DEFAULT NULL,
  CONSTRAINT MENU_PK PRIMARY KEY (MENU_ID)
) ENGINE=InnoDB DEFAULT CHARSET=utf16 COLLATE=utf16_spanish_ci;

INSERT INTO PizzaShack.Menu (NAME,DESCRIPTION,PRICE,ICON) VALUES
	 ('Menu 1','Menu pizza Carbonara',30.12,'https://d28f3w0x9i80nq.cloudfront.net/restaurantImages/188a8488-1a98-41f1-85f1-7b75f6ddcf5c/Asset%202@2x.png'),
	 ('Menu 2','Menu pizza barbacoa',25.56,'https://d28f3w0x9i80nq.cloudfront.net/restaurantImages/188a8488-1a98-41f1-85f1-7b75f6ddcf5c/Asset%202@2x.png'),
	 ('Menu 3','Menu pizza pepperoni',26.54,'https://d28f3w0x9i80nq.cloudfront.net/restaurantImages/188a8488-1a98-41f1-85f1-7b75f6ddcf5c/Asset%202@2x.png');


-- PizzaShack.`Order` definition

CREATE TABLE PizzaShack.`ORDERS` (
	ORDER_ID SMALLINT UNSIGNED auto_increment NOT NULL,
	CLIENT_NAME varchar(250) NOT NULL,
	MENU_NAME varchar(100) NOT NULL,
	DELIVERED BOOL DEFAULT 0 NOT NULL,
	CREDIT_CARD_NUMBER varchar(100) NULL,
	QUANTITY DECIMAL(15,2) NULL,
	ADDRESS varchar(300) NOT NULL,
	CONSTRAINT ORDER_PK PRIMARY KEY (ORDER_ID)
)
ENGINE=InnoDB
DEFAULT CHARSET=utf16
COLLATE=utf16_spanish_ci;
