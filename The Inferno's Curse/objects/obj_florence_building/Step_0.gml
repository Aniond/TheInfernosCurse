// Keep the collision footprint matching the (possibly rescaled) sprite. The room
// builder sets image_xscale/yscale AFTER Create, so refresh wall_w/wall_h here.
wall_w = sprite_width;
wall_h = sprite_height;
