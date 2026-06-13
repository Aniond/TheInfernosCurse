// Map Initialization
global.map_nodes = ds_map_create();

// Node struct
function MapNode(_x, _y, _name, _unlocked, _target_room) constructor {
    x = _x;
    y = _y;
    name = _name;
    unlocked = _unlocked;
    target_room = _target_room;
    connections = [];
}

// Map dimensions are roughly 1376x768
var _florence = new MapNode(688, 384, "Florence", true, asset_get_index("Room_florence_v2"));
var _siena = new MapNode(720, 480, "Siena", false, -1);
var _venice = new MapNode(850, 200, "Venice", false, -1);
var _rome = new MapNode(800, 600, "Rome", false, -1);

ds_map_add(global.map_nodes, "florence", _florence);
ds_map_add(global.map_nodes, "siena", _siena);
ds_map_add(global.map_nodes, "venice", _venice);
ds_map_add(global.map_nodes, "rome", _rome);

_florence.connections = ["siena", "venice", "rome"];
_siena.connections = ["florence", "rome"];
_venice.connections = ["florence"];
_rome.connections = ["florence", "siena"];

current_node_id = "florence";
target_node_id = "florence";
is_moving = false;
move_progress = 0;
cursor_pulse = 0;
