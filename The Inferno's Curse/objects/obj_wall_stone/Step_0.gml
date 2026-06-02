// =============================================================================
// obj_wall_stone — Step Event
// =============================================================================
// Track Limbo corruption (circle index 0) and advance the breathing phase.

wall_corruption = global.circle_corruption[0];
breathe_offset += breathe_speed;
