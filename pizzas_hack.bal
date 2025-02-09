import ballerina/http;
import ballerina/io;
import ballerina/sql;
import ballerinax/mysql;
import ballerinax/mysql.driver as _;

public function main() {
    io:println("Pizzas Hack inicializado con exito!");
}

type DatabaseConfig record{|
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
        //self.db = check new ("localhost", "pizzashackuser", "manage1234", "PizzaShack", 3306);
        self.db = check new(...databaseConfig);
    }

    resource function get menustest() returns MenuEntry[] {
        return menuTable.toArray();
    }

    resource function get menus() returns MenuEntry[]|error {
        
        stream<MenuEntry, sql:Error?> menuStream = self.db->query(`SELECT * FROM Menu`);

        return from MenuEntry menu in menuStream
            select menu;
    }

    resource function get menu/[string menuName]() returns MenuEntry|http:NotFound|error {
        // Execute simple query to fetch record with requested id.
        MenuEntry|sql:Error result = self.db->queryRow(`SELECT * FROM menu WHERE name = ${menuName}`);

        // Check if record is available or not
        if result is sql:NoRowsError {
            return http:NOT_FOUND;
        } else {
            return result;
        }
    }

      resource function post menu(@http:Payload MenuEntry menu) returns MenuEntry|ConflictingMenuError|error {
        
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

    resource function delete menu/[string menuName]() returns http:NoContent|error {
        // Execute simple query to fetch record with requested id.

        _ = check self.db->execute(`DELETE FROM menu WHERE name = ${menuName}`);
        return http:NO_CONTENT;
    }
    resource function post menutest(@http:Payload MenuEntry menu) returns MenuEntry|ConflictingMenuError {
        if menuTable.hasKey(menu.name) {
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



    resource function get delivery() returns json {

    }

    resource function put delivery/[string deliveryId]() {

    }
}

public type ConflictingMenuError record {|
    *http:Conflict;
    ErrorMsg body;
|};

public type ErrorMsg record {|
    string errmsg;
|};

public type MenuEntry record {
	readonly string name;
	string description;
	string price;
	string icon;	
};

public final table<MenuEntry> key(name) menuTable = table [

    {name: "Menu 1", description: "Menu pizza carbonara", price: "30.13", icon: "xxxx"},
    {name: "Menu 2", description: "Menu pizza barbacoa", price: "25.54", icon: "xxxx"},
    {name: "Menu 3", description: "Menu pizza pepperoni", price: "28.43", icon: "xxxx"}

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
     string pizzaType;
     string clientName;
     int quantity;
     string creditCardNumber;
     boolean delivered;
     readonly string orderId;
};

public final table<OrderEntry> key(orderId) oderTable = table [

    {address: "Paseo de la castellana 43, planta 2", pizzaType: "carbonara", clientName: "Diego Manso", quantity: 2, creditCardNumber: "i234i32u43", delivered: false, orderId: "1" },
    {address: "Paseo de la castellana 43, planta 2", pizzaType: "barbacoa", clientName: "Juan", quantity: 5, creditCardNumber: "83475983475", delivered: false, orderId: "2" }

];