//
// shd_floor_relief — fragment. Normal-mapped point-light RELIEF for tiled
// floors, GLOBAL system (any room). Albedo comes through gm_BaseTexture
// (the tile being drawn); the normal map sprite is bound on stage 1.
// Because both sprites live on texture atlases, BOTH uv rects are passed
// in and the local 0-1 tile uv is remapped from the albedo rect into the
// normal rect.
//
// DIVISION OF LABOUR (the fix vs the dropped shd_ponte_floor POC, which
// fought the global light map): this shader NEVER darkens the room.
// u_ambient stays near-white; lights only ADD normal-mapped relief on top.
// scr_lightmap (the global multiply light map) owns room darkness and the
// coloured glow pools — its pools and these relief pools share the same
// light sources, so the bright spots line up.
//
// Lights: up to MAX_LIGHTS point lights, one shared colour computed
// per-frame in GML (time-of-day x corruption, scr_relief_begin).
//
#define MAX_LIGHTS 8

varying vec2 v_vTexcoord;
varying vec4 v_vColour;
varying vec2 v_vWorldPos;

uniform sampler2D u_normal_tex;       // derived normal map (stage 1)
uniform vec4  u_albedo_uvs;           // xy = atlas top-left, zw = extent
uniform vec4  u_normal_uvs;           // same for the normal sprite
uniform float u_light_count;          // active lights (<= MAX_LIGHTS)
uniform vec3  u_lights[MAX_LIGHTS];   // x, y (room px), z = radius px
uniform vec3  u_light_color;          // shared: time-of-day x corruption
uniform vec3  u_ambient;              // near-white relief floor

void main()
{
    vec4 albedo = texture2D(gm_BaseTexture, v_vTexcoord);

    // remap this tile's albedo uv into the normal sprite's atlas rect
    vec2 local = (v_vTexcoord - u_albedo_uvs.xy) / u_albedo_uvs.zw;
    vec2 nuv   = u_normal_uvs.xy + clamp(local, 0.001, 0.999) * u_normal_uvs.zw;

    // decode OpenGL tangent-space normal; room y grows DOWN so green flips
    vec3 n = texture2D(u_normal_tex, nuv).rgb * 2.0 - 1.0;
    n = normalize(vec3(n.x, -n.y, max(n.z, 0.2)));

    vec3 light = u_ambient;
    for (int i = 0; i < MAX_LIGHTS; i++)
    {
        if (float(i) >= u_light_count) break;
        vec2  d      = u_lights[i].xy - v_vWorldPos;
        float radius = max(u_lights[i].z, 1.0);
        float atten  = clamp(1.0 - length(d) / radius, 0.0, 1.0);
        atten *= atten;                                   // soft quadratic falloff
        // light hovers ~48px above the floor; -d.y converts to OpenGL up
        vec3  L    = normalize(vec3(d.x, -d.y, 48.0));
        float diff = max(dot(n, L), 0.0);
        // relief only — modest gain, the light map paints the actual pool
        light += u_light_color * (atten * (0.10 + 0.55 * diff));
    }

    gl_FragColor = vec4(albedo.rgb * v_vColour.rgb * min(light, vec3(1.25)), albedo.a * v_vColour.a);
}
