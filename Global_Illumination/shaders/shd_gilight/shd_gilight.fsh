varying vec2 in_Coord;
varying vec4 in_Color;
uniform vec2      in_Resol;
uniform sampler2D in_Distfld;
uniform sampler2D in_Fastnse;

#define TAU 6.2831853071795864769252867665590
#define MAX_STEPS       32.0  // higher = accuracy, lower = efficiency
#define RAYS_PER_PIXEL  32.0  // higher = accuracy, lower = efficiency
#define EPSILON         0.001 // floating point precision check
#define dot(f) dot(f,f)       // shorthand dot of a single float

float V2_F16(vec2 v) { return v.x + (v.y / 255.0); }
bool RANGE(float v, float lo, float hi) { return (v - hi) * (v - lo) > 0.0; }
bool surfacemarch(vec2 pix, vec2 dir, float noise, out vec2 hitpos, out vec3 hitcol) {
    float aspect = in_Resol.x / in_Resol.y;
    vec2 pixel = vec2(pix.x * aspect, pix.y);
    
    for(float ray = 0.0, dst = 0.0, i = 0.0; i < MAX_STEPS; i += 1.0) {
        vec2 raypos = pixel + (dir * ray);
        raypos.x /= aspect;
        ray += (dst = V2_F16(texture2D(in_Distfld, raypos).rg));
        
        if (RANGE(raypos.x, 0.0, 1.0) || RANGE(raypos.y, 0.0, 1.0)) return false;
        if (dst <= EPSILON) {
            // Random sample either surface emitters or previous frame emission pixel.
            raypos *= aspect;
            raypos -= (ray * EPSILON * noise);
            raypos /= aspect;
            
            hitcol = texture2D(gm_BaseTexture, raypos).rgb;
            hitpos = raypos;
            return true;
        }
    }
    return false;
}

vec3 tonemap(vec3 color, float dist) {
    // INVERSE SQR LAW FOR LIGHT: (not my preferred, visually)
    //return color * (1.0 / (1.0 + dot(dist / min(in_Resol.x, in_Resol.y))));
    
    // LINEAR DROP OFF:
    return color * (1.0 - (dist / min(in_Resol.x, in_Resol.y)));
}

void main() {
    vec2 pixelPos = in_Coord * in_Resol;
    vec3  colors = vec3(0.0);
    float emissv = 0.0,
        gnoise = texture2D(in_Fastnse, in_Coord).r,
        gangle = gnoise * TAU;
    
    const float RAY_DELTA = TAU * (1.0/RAYS_PER_PIXEL);
    for(float i = 0.0; i < TAU; i += RAY_DELTA) {
        vec2 hitpos = in_Coord; vec3 hitcol = vec3(0.0);
        surfacemarch(in_Coord, vec2(cos(gangle + i), -sin(gangle + i)), gnoise, hitpos, hitcol);
        hitcol = tonemap(hitcol, distance(in_Coord * in_Resol, hitpos * in_Resol));
        emissv += max(hitcol.r, max(hitcol.g, hitcol.b));
        colors += hitcol;
    }
    
    vec3 color = (colors / emissv) * (emissv / RAYS_PER_PIXEL);
    gl_FragColor = vec4(color, 1.0);
}