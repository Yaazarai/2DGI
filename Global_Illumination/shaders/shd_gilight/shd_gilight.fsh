varying vec2 in_Coord;
varying vec4 in_Color;
uniform vec2      in_Resol;
uniform sampler2D in_Distfld;
uniform sampler2D in_Goldnse;

#define TAU 6.2831853071795864769252867665590
#define MAX_STEPS       64.0  // higher = accuracy, lower = efficiency
#define RAYS_PER_PIXEL  32.0  // higher = accuracy, lower = efficiency
#define EPSILON         0.001 // floating point precision check

float V2_F16(vec2 v) { return v.x + (v.y / 255.0); }
bool RANGE(float v, float lo, float hi) { return (v - hi) * (v - lo) > 0.0; }

vec3 surfacemarch(vec2 hit, vec2 dir, float noise, out vec2 hitpos) {
    float aspect = in_Resol.x / in_Resol.y;
    
    for(float j = 0.0, d = 0.0, i = 0.0; i < MAX_STEPS; i += 1.0) {
        vec2 emsvpos = vec2(hit.x*aspect, hit.y) + (dir * j);
        emsvpos.x /= aspect;
        
        j += (d = V2_F16(texture2D(in_Distfld, emsvpos).rg));
        
        if (RANGE(emsvpos.x, 0.0, 1.0) || RANGE(emsvpos.y, 0.0, 1.0)) return vec3(0.0);
        if (d <= EPSILON) {
            vec2 noispos = vec2(hit.x*aspect, hit.y) + (dir * j * noise);
            noispos.x /= aspect;
            
            vec3 emsvcol = texture2D(gm_BaseTexture, emsvpos).rgb;
            vec3 noiscol = texture2D(gm_BaseTexture, noispos).rgb;
            vec3 pixlcol = max(emsvcol, noiscol);
            hitpos = emsvpos;
            return pixlcol;
        }
    }
    return vec3(0.0);
}

vec3 tonemap(vec3 color, float dist) {
    return color * (1.0 - dist / min(in_Resol.x, in_Resol.y));
}

void main() {
    vec3  colors = vec3(0.0);
    float emissv = 0.0,
        gnoise = texture2D(in_Goldnse, in_Coord).r,
        gangle = gnoise * TAU;
    
    const float RAY_DELTA = TAU * (1.0/RAYS_PER_PIXEL);
    for(float i = 0.0; i < TAU; i += RAY_DELTA) {
        vec2 hitpos = in_Coord;
        vec3 hitcol = surfacemarch(hitpos, vec2(cos(gangle + i), -sin(gangle + i)), gnoise, hitpos);
        vec3 mapped = tonemap(hitcol, distance(in_Coord * in_Resol, hitpos.xy * in_Resol));
        emissv += max(mapped.r, max(mapped.g, mapped.b));
        colors += mapped.rgb;
    }
    
    vec3 color = (colors / emissv) * (emissv / RAYS_PER_PIXEL);
    gl_FragColor = vec4(color, 1.0);
}