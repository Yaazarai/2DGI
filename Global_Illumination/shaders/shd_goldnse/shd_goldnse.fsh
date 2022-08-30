/*
// Gold Noise ©2015 dcerisano@standard3d.com
// - based on the Golden Ratio
// - uniform normalized distribution
// - fastest static noise generator function (also runs at low precision)
*/
varying vec2 in_Coord;
uniform float in_Timer;
uniform vec2 in_Resol;
#define PHI 1.61803398874989484820459  // Golden Ratio 

void main() {
    vec2 coordinate = in_Coord * in_Resol;
    float gold_noise = fract(tan(distance(coordinate*vec2(PHI*in_Timer), coordinate*-vec2(PHI*in_Timer))));
    gl_FragColor = vec4(vec3(gold_noise), 1.0);
}
