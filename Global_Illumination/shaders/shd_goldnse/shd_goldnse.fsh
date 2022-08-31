varying vec2 in_Coord;
uniform float in_Timer;

void main() {
    /*
        Source: https://stackoverflow.com/questions/4200224/random-noise-functions-for-glsl
        TAN instead of SIN for fun.
    */
    gl_FragColor = vec4(vec3(fract(tan(dot(in_Coord * in_Timer, vec2(12.9898, 78.233))) * 43758.5453)), 1.0);
}
