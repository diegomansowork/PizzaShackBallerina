import ballerina/persist as _;


public type Menu record {|
    readonly int id;
    string descripcion;
    string imagen;
    string nombre;
    string precio;

|};

public type Order record {|

readonly int id;
string direccion;
string numeroTarjetaCredito;
string nombreCliente;
string tipoDePizza;
int cantidad;
boolean delivered;


|};