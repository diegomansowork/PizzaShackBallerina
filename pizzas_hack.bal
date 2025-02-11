import ballerina/http;
import ballerina/io;
import ballerina/sql;
import ballerinax/mysql;
import ballerinax/mysql.driver as _;

public function main() {
    io:println("Pizzas Hack inicializado con exito!");
}

type DatabaseConfig record {|
    string host;
    string user;
    string password;
    string database;
    int port;
|};

configurable DatabaseConfig databaseConfig = ?;

service /pizza on new http:Listener(9095) {

    private final mysql:Client db;

    function init() returns error? {
        // Initiate the mysql client at the start of the service. This will be used
        // throughout the lifetime of the service.
        self.db = check new (...databaseConfig);
    }

    resource function get menustest() returns MenuEntryTest[] {
        return menuTable.toArray();
    }

    resource function get menu() returns MenuEntry[]|error {

        stream<MenuEntry, sql:Error?> menuStream = self.db->query(`SELECT * FROM Menu`);

        return from MenuEntry menu in menuStream
            select menu;
    }

    resource function get menu/[string menuId]() returns MenuEntry|http:NotFound|error {
        // Execute simple query to fetch record with requested id.
        MenuEntry|sql:Error result = self.db->queryRow(`SELECT * FROM menu WHERE menu_id = ${menuId}`);

        // Check if record is available or not
        if result is sql:NoRowsError {
            return http:NOT_FOUND;
        } else {
            return result;
        }
    }

    resource function post menu(@http:Payload MenuEntry menu) returns MenuEntry|ConflictingError|error {

        MenuEntry|sql:Error result = self.db->queryRow(`SELECT * FROM menu WHERE name = ${menu.name}`);

        // Check if record is available or not
        if result is sql:NoRowsError {
            _ = check self.db->execute(`
            INSERT INTO Menu (name, description, price, icon)
            VALUES (${menu.name}, ${menu.description}, ${menu.price}, ${menu.icon});`);
            return menu;
            //return http:CREATED;
        } else {
            return {
                body: {
                    errmsg: string:'join(" ", "Conflicting Menu name:", menu.name)
                }
            };
        }

    }

    resource function delete menu/[string menuId]() returns http:NoContent|error {
        // Execute simple query to fetch record with requested id.

        _ = check self.db->execute(`DELETE FROM menu WHERE menu_id = ${menuId}`);
        return http:NO_CONTENT;
    }

    resource function post menutest(@http:Payload MenuEntryTest menu) returns MenuEntry|ConflictingError {
        if menuTable.hasKey(menu.menuId) {
            return {
                body: {
                    errmsg: string:'join(" ", "Conflicting Menu name:", menu.name)
                }
            };
        } else {
            menuTable.add(menu);
            return menu;
        }
    }

    resource function get 'order(boolean delivered = false) returns OrderEntry[]|error {

        stream<OrderEntry, sql:Error?> orderStream = self.db->query(`SELECT * FROM ORDERS WHERE delivered = ${delivered}`);

        return from OrderEntry 'order in orderStream
            select 'order;
    }

    resource function get 'order/[string orderId]() returns OrderEntry|http:NotFound|error {
        // Execute simple query to fetch record with requested id.
        OrderEntry|sql:Error result = self.db->queryRow(`SELECT * FROM ORDERS WHERE name = ${orderId}`);

        // Check if record is available or not
        if result is sql:NoRowsError {
            return http:NOT_FOUND;
        } else {
            return result;
        }
    }

    // resource function post menu(@http:Payload MenuEntry menu) returns MenuEntry|ConflictingMenuError|error {
    resource function post 'order(@http:Payload OrderEntry 'order) returns OrderEntry|error {
        _ = check self.db->execute(`
        INSERT INTO ORDERS (ADDRESS,MENU_NAME,CLIENT_NAME,QUANTITY,CREDIT_CARD_NUMBER)
        VALUES (${'order.address}, ${'order.menuName}, ${'order.clientName}, ${'order.quantity}, ${'order.creditCardNumber});`);
        return 'order;
    }

    resource function post deliver_order/[string orderId]() returns http:NotFound|OutputMessage {
        OrderEntry|sql:Error result = self.db->queryRow(`SELECT * FROM ORDERS WHERE name = ${orderId}`);

        // Check if record is available or not
        if result is sql:NoRowsError {
            return http:NOT_FOUND;
        } else {
            return {
                body: {
                    errmsg: string:'join(" ", "Delivered! ID: ", orderId)
                }
            };
        }
    }

} // main

public type ConflictingError record {|
    *http:Conflict;
    ErrorMsg body;
|};

public type OutputMessage record {|
    *http:Accepted;
    string body;
|};

public type ErrorMsg record {|
    string errmsg;
|};

public type MenuEntry record {
    @sql:Column {
        name: "MENU_ID"
    }
    int menuId?;
    string name;
    string description;
    string price;
    string icon;
};

public type MenuEntryTest record {
    readonly int menuId;
    string name;
    string description;
    string price;
    string icon;
};

public final table<MenuEntryTest> key(menuId) menuTable = table [

    {menuId: 1, name: "Menu 1", description: "Menu pizza carbonara", price: "30.13", icon: "xxxx"},
    {menuId: 2, name: "Menu 2", description: "Menu pizza barbacoa", price: "25.54", icon: "xxxx"},
    {menuId: 3, name: "Menu 3", description: "Menu pizza pepperoni", price: "28.43", icon: "xxxx"}

];

public type PizzaEntry record {
    readonly string name;
    string description;
    string imageUrl;
    decimal price;
};

public final table<PizzaEntry> key(name) pizzaTable = table [

    {name: "Pizza carbonara", description: "Ingredienes: bacon, salsa carbonara, champis, cebolla", price: 30.13, imageUrl: "https://as.com"},
    {name: "Pizza barbacoa", description: "Ingredientes: bacon, carne picada, chorizo, salsa barbacoa", price: 234.43, imageUrl: "https://marca.com"},
    {name: "Pizza Matanza", description: "Ingredientes: morcilla, carne picada, chorizo", price: 234.43, imageUrl: "https://pizzeriavenecia.com/matanza"}

];

public type OrderEntry record {
    string address;
    @sql:Column {
        name: "MENU_NAME"
    }
    string menuName;
    @sql:Column {
        name: "client_name"
    }
    string clientName;
    decimal quantity;
    @sql:Column {
        name: "credit_card_number"
    }
    string creditCardNumber;
    boolean delivered?;
    @sql:Column {
        name: "order_id"
    }
    readonly string orderId?;
};

// public final table<OrderEntry> key(orderId) oderTable = table [

//     {address: "Paseo de la castellana 43, planta 2", pizzaType: "carbonara", clientName: "Diego Manso", quantity: 2, creditCardNumber: "i234i32u43", delivered: false, orderId: "1"},
//     {address: "Paseo de la castellana 43, planta 2", pizzaType: "barbacoa", clientName: "Juan", quantity: 5, creditCardNumber: "83475983475", delivered: false, orderId: "2"}

// ];
