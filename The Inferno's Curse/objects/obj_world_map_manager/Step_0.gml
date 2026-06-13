// Input and Nav
if (is_moving) {
    move_progress += 0.05;
    if (move_progress >= 1.0) {
        move_progress = 0;
        is_moving = false;
        current_node_id = target_node_id;
    }
    return;
}

cursor_pulse += 0.1;
var _node = global.map_nodes[? current_node_id];

var _dx = 0;
var _dy = 0;

if (keyboard_check_pressed(vk_right)) _dx = 1;
if (keyboard_check_pressed(vk_left)) _dx = -1;
if (keyboard_check_pressed(vk_down)) _dy = 1;
if (keyboard_check_pressed(vk_up)) _dy = -1;

if (_dx != 0 || _dy != 0) {
    var _best_dist = 999999;
    var _best_node_id = "";
    
    for (var i = 0; i < array_length(_node.connections); i++) {
        var _conn_id = _node.connections[i];
        var _conn_node = global.map_nodes[? _conn_id];
        var _ang = point_direction(_node.x, _node.y, _conn_node.x, _conn_node.y);
        
        var _valid = false;
        if (_dx == 1 && (_ang > 315 || _ang < 45)) _valid = true;
        else if (_dx == -1 && (_ang > 135 && _ang < 225)) _valid = true;
        else if (_dy == -1 && (_ang >= 45 && _ang <= 135)) _valid = true;
        else if (_dy == 1 && (_ang >= 225 && _ang <= 315)) _valid = true;
        
        if (_valid) {
            var _dist = point_distance(_node.x, _node.y, _conn_node.x, _conn_node.y);
            if (_dist < _best_dist) {
                _best_dist = _dist;
                _best_node_id = _conn_id;
            }
        }
    }
    
    if (_best_node_id != "") {
        target_node_id = _best_node_id;
        is_moving = true;
    }
}

if (keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space)) {
    var _target = global.map_nodes[? current_node_id];
    if (_target.unlocked && _target.target_room != -1) {
        room_goto(_target.target_room);
    }
}
