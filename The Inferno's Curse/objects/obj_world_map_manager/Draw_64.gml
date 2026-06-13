// Draw the map background first!
if (sprite_exists(spr_world_map)) {
    draw_sprite(spr_world_map, 0, 0, 0);
}

// Draw Paths
draw_set_color(c_dkgray);
var _k = ds_map_find_first(global.map_nodes);
while (!is_undefined(_k)) {
    var _node = global.map_nodes[? _k];
    
    for (var i = 0; i < array_length(_node.connections); i++) {
        var _conn = global.map_nodes[? _node.connections[i]];
        
        var _dist = point_distance(_node.x, _node.y, _conn.x, _conn.y);
        var _dir = point_direction(_node.x, _node.y, _conn.x, _conn.y);
        
        for (var j = 0; j < _dist; j += 16) {
            var _px = _node.x + lengthdir_x(j, _dir);
            var _py = _node.y + lengthdir_y(j, _dir);
            draw_circle(_px, _py, 2, false);
        }
    }
    _k = ds_map_find_next(global.map_nodes, _k);
}

// Draw Nodes
_k = ds_map_find_first(global.map_nodes);
while (!is_undefined(_k)) {
    var _node = global.map_nodes[? _k];
    
    if (_node.unlocked) draw_set_color(c_aqua);
    else draw_set_color(c_maroon);
    
    draw_circle(_node.x, _node.y, 8, false);
    draw_set_color(c_white);
    draw_circle(_node.x, _node.y, 8, true);
    
    _k = ds_map_find_next(global.map_nodes, _k);
}

// Draw Cursor
var _cur = global.map_nodes[? current_node_id];
var _tar = global.map_nodes[? target_node_id];
var _cx = lerp(_cur.x, _tar.x, move_progress);
var _cy = lerp(_cur.y, _tar.y, move_progress);

draw_set_color(c_yellow);
var _radius = 12 + sin(cursor_pulse) * 4;
draw_circle(_cx, _cy, _radius, true);
draw_circle(_cx, _cy, _radius + 1, true);
draw_set_color(c_white);

// Draw Location Banner
var _sw = display_get_gui_width();
draw_set_font(FONT_TITLE);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);

draw_set_color(c_black);
draw_set_alpha(0.8);
draw_rectangle(_sw / 2 - 200, 20, _sw / 2 + 200, 80, false);
draw_set_alpha(1.0);

draw_set_color(c_white);
draw_rectangle(_sw / 2 - 200, 20, _sw / 2 + 200, 80, true);

if (_cur.unlocked) {
    draw_text(_sw / 2, 50, _cur.name);
} else {
    draw_set_color(c_gray);
    draw_text(_sw / 2, 50, "???");
    draw_set_color(c_white);
}

draw_set_halign(fa_left);
draw_set_valign(fa_top);
