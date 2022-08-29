varying vec2 in_Coord;
uniform float in_Jdist;
uniform vec2  in_Resol;

float V2_F16(vec2 v) { return v.x + (v.y / 255.0); }

void main() {
	vec2 offsets[9];
	offsets[0] = vec2(-1.0, -1.0);
	offsets[1] = vec2(-1.0, 0.0);
	offsets[2] = vec2(-1.0, 1.0);
	offsets[3] = vec2(0.0, -1.0);
	offsets[4] = vec2(0.0, 0.0);
	offsets[5] = vec2(0.0, 1.0);
	offsets[6] = vec2(1.0, -1.0);
	offsets[7] = vec2(1.0, 0.0);
    offsets[8] = vec2(1.0, 1.0);
    
    float closest_dist = 9999999.9;
    vec2 closest_pos = vec2(0.0);
    vec4 closest_data = vec4(0.0);
    
    for(int i = 0; i < 9; i++) {
        vec2 jump = in_Coord + (offsets[i] * (in_Jdist / in_Resol));
        vec4 seed = texture2D(gm_BaseTexture, jump);
        vec2 seedpos = vec2(V2_F16(seed.xy), V2_F16(seed.zw));
        float dist = distance(seedpos, in_Coord);
        
        if (seedpos != vec2(0.0) && dist <= closest_dist) {
            closest_dist = dist;
            closest_data = seed;
        }
    }
    
    gl_FragColor = closest_data;
}