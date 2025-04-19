shader_type canvas_item;

// — Color de agua y olas
uniform vec4   water_color     : source_color = vec4(0.0, 0.8, 0.9, 1.0);
uniform float  time_speed      = 1.0;
uniform float  wave_speed      = 1.0;
uniform float  wave_scale      = 20.0;

// — Parámetros de caústics “telaraña”
uniform float  caustic_freq    = 15.0;
uniform float  caustic_strength= 1.0;
uniform float  caustic_width   = 0.02;

// — Ruido para deformación de UV
uniform float  noise_scale     = 5.0;
uniform float  noise_speed     = 0.2;
uniform float  noise_amp       = 0.02;

// — Ruido escalar para Voronoi y deformación
float rand1(vec2 p) {
    return fract(sin(dot(p, vec2(127.1,311.7))) * 43758.5453);
}
float fadef(float t) {
    return t*t*t*(t*(t*6.0 - 15.0) + 10.0);
}
float valueNoise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    vec2 u = vec2(fadef(f.x), fadef(f.y));
    float a = rand1(i + vec2(0.0,0.0));
    float b = rand1(i + vec2(1.0,0.0));
    float c = rand1(i + vec2(0.0,1.0));
    float d = rand1(i + vec2(1.0,1.0));
    return mix(mix(a,b,u.x), mix(c,d,u.x), u.y);
}

// — Voronoi F1/F2 para “telaraña”
void voronoiF12(vec2 uv, out float f1, out float f2) {
    vec2 i = floor(uv), f = fract(uv);
    f1 = 1e10; f2 = 1e10;
    for(int y=-1; y<=1; y++){
        for(int x=-1; x<=1; x++){
            vec2 o = vec2(float(x),float(y));
            vec2 r = vec2(
                valueNoise(i + o),
                valueNoise(i + o + vec2(5.2,1.3))
            );
            float d2 = dot(o + r - f, o + r - f);
            if(d2 < f1) {
                f2 = f1;
                f1 = d2;
            } else if(d2 < f2) {
                f2 = d2;
            }
        }
    }
}

// — Altura de ola para tintar el agua
float waveHeight(vec2 uv, float t) {
    float h = sin(uv.x*5.0  + t*wave_speed)
            + sin(uv.y*3.0  + t*wave_speed*1.3)
            + sin((uv.x+uv.y)*4.0 + t*wave_speed*0.8);
    return h * 0.1667 + 0.5;
}

void fragment() {
    vec2 uv = UV;
    float t  = TIME * time_speed;

    // 1) Agua base + tint de olas
    float wh = waveHeight(uv * wave_scale, t);
    vec3 col = water_color.rgb + vec3((wh - 0.5) * 0.04);

    // 2) Deformación global de UV con noise
    vec2 np = uv * noise_scale + vec2(t * noise_speed);
    vec2 deform = (vec2(
        valueNoise(np),
        valueNoise(np + vec2(12.7,24.9))
    ) - 0.5) * noise_amp;

    // 3) Caústics “telaraña” global
    float f1, f2;
    voronoiF12((uv + deform) * caustic_freq, f1, f2);
    float diff = sqrt(f2) - sqrt(f1);
    float line = smoothstep(caustic_width, caustic_width + 0.005, diff);

    // 4) Mezcla final: oscurece las crestas
    col = mix(col, col * (1.0 - line * caustic_strength), line);

    COLOR = vec4(col, 1.0);
}