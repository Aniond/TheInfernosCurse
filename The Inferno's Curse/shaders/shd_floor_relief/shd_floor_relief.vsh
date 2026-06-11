//
// shd_floor_relief — vertex. Standard GM passthrough + room-space position
// varying so the fragment stage can attenuate point lights in pixels.
// GLOBAL floor relief system (2026-06-11) — grown from the shd_ponte_floor
// POC; usable on any tiled floor in any room via scr_relief_begin/end.
//
attribute vec3 in_Position;                  // (x,y,z)
attribute vec4 in_Colour;                    // (r,g,b,a)
attribute vec2 in_TextureCoord;              // (u,v)

varying vec2 v_vTexcoord;
varying vec4 v_vColour;
varying vec2 v_vWorldPos;

void main()
{
    vec4 object_space_pos = vec4(in_Position.x, in_Position.y, in_Position.z, 1.0);
    gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * object_space_pos;

    v_vColour   = in_Colour;
    v_vTexcoord = in_TextureCoord;
    v_vWorldPos = (gm_Matrices[MATRIX_WORLD] * object_space_pos).xy;
}
