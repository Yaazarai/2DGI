varying vec2 in_Coord;
uniform vec2  in_Resol;

void main() {
    vec2 offsets[9];
	offsets[0] = vec2(-1.0, -1.0);
	offsets[1] = vec2(-1.0, 0.0);
	offsets[2] = vec2(-1.0, 1.0);
	offsets[3] = vec2(0.0, -1.0);
	offsets[4] = vec2(0.0, 1.0);
	offsets[5] = vec2(1.0, -1.0);
	offsets[6] = vec2(1.0, 0.0);
    offsets[7] = vec2(1.0, 1.0);
    
    vec3 noisepx = texture2D(gm_BaseTexture, in_Coord).rgb;
    float nval = max(noisepx.r, max(noisepx.g, noisepx.b));
    
    vec3 colors = vec3(0.0);
    float valinc = 0.0, dsgn = sign(nval);
    for(int i = 0; i < 8; i++) {
        vec3 denoise = texture2D(gm_BaseTexture, in_Coord + (offsets[i] * (1.0/in_Resol))).rgb;
        float dval = max(denoise.r, max(denoise.g, denoise.b));
        valinc += dval;
        colors += denoise;
        dsgn += sign(dval);
    }
    
    valinc /= dsgn;
    noisepx *= valinc/nval;
    colors += noisepx;
    colors /= dsgn;
    gl_FragColor = vec4(colors, 1.0);
}