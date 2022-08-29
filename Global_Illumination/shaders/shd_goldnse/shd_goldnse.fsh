/*
// Gold Noise ©2015 dcerisano@standard3d.com
// - based on the Golden Ratio
// - uniform normalized distribution
// - fastest static noise generator function (also runs at low precision)

float PHI = 1.61803398874989484820459;  // Φ = Golden Ratio 

float gold_noise(in vec2 xy, in float seed){
       return fract(tan(distance(xy*PHI, xy)*seed)*xy.x);
}
*/
varying vec2 in_Coord;
uniform float in_Timer;
uniform vec2 in_Resol;
#define PHI 1.61803398874989484820459  // Golden Ratio 

float V2_F16(vec2 v) { return v.x + (v.y / 255.0); }

void main() {
	vec2 coordinate = in_Coord * in_Resol;
    float gold_noise = fract(tan(distance(coordinate*vec2(PHI), coordinate)*in_Timer)*coordinate.x);
    gl_FragColor = vec4(vec3(gold_noise), 1.0);
}