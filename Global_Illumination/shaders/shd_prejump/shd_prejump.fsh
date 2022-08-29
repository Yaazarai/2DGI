varying vec2 in_Coord;
varying vec4 in_Color;

vec2 F16_V2(float f) { return vec2(floor(f * 255.0) / 255.0, fract(f * 255.0)); }

void main() {
    vec4 scene = texture2D(gm_BaseTexture, in_Coord);
    gl_FragColor = vec4(F16_V2(in_Coord.x * scene.a), F16_V2(in_Coord.y * scene.a));
}