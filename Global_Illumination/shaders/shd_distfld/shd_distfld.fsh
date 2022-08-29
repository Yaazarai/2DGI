varying vec2 in_Coord;

float V2_F16(vec2 v) { return v.x + (v.y / 255.0); }
vec2 F16_V2(float f) { return vec2(floor(f * 255.0) / 255.0, fract(f * 255.0)); }

void main() {
    vec4 jfuv = texture2D(gm_BaseTexture, in_Coord);
    vec2 jumpflood = vec2(V2_F16(jfuv.rg),V2_F16(jfuv.ba));
    gl_FragColor = vec4(F16_V2(distance(in_Coord, jumpflood)), 0.0, 1.0);
}