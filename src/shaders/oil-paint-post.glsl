#version 300 es
precision highp float;

in vec2 fs_UV;
out vec4 out_Col;

uniform sampler2D u_frame;
uniform float u_Time;

// references 
// https://stackoverflow.com/questions/5830139/how-can-i-do-these-image-processing-tasks-using-opengl-es-2-0-shaders
// https://www.shadertoy.com/view/lls3WM

vec3 kuwahara() {

    float textSizeX = float(textureSize(u_frame, 0).x);
    float textSizeY = float(textureSize(u_frame, 0).y);
    vec2 texSize = vec2(textSizeX, textSizeY);
    vec2 uv = fs_UV;
    const int radius = 4;
    float n = float((radius + 1) * (radius + 1));

    vec3 outCol = vec3(0.0);

    vec3 m[4];
    vec3 s[4];
    for (int k = 0; k < 4; ++k) {
        m[k] = vec3(0.0);
        s[k] = vec3(0.0);
    }

    for (int j = -radius; j <= 0; ++j)  {
        for (int i = -radius; i <= 0; ++i)  {
            vec3 c = texture(u_frame, uv + vec2(i,j) / texSize).rgb;
            m[0] += c;
            s[0] += c * c;
        }
    }

    for (int j = -radius; j <= 0; ++j)  {
        for (int i = 0; i <= radius; ++i)  {
            vec3 c = texture(u_frame, uv + vec2(i,j) / texSize).rgb;
            m[1] += c;
            s[1] += c * c;
        }
    }

    for (int j = 0; j <= radius; ++j)  {
        for (int i = 0; i <= radius; ++i)  {
            vec3 c = texture(u_frame, uv + vec2(i,j) / texSize).rgb;
            m[2] += c;
            s[2] += c * c;
        }
    }

    for (int j = 0; j <= radius; ++j)  {
        for (int i = -radius; i <= 0; ++i)  {
            vec3 c = texture(u_frame, uv + vec2(i,j) / texSize).rgb;
            m[3] += c;
            s[3] += c * c;
        }
    }


    float min_sigma2 = 1e+2;
    for (int k = 0; k < 4; ++k) {
        m[k] /= n;
        s[k] = abs(s[k] / n - m[k] * m[k]);

        float sigma2 = s[k].r + s[k].g + s[k].b;
        if (sigma2 < min_sigma2) {
            min_sigma2 = sigma2;
            outCol = vec3(m[k]);
        }
    }
    return outCol;
}

void main() {

	vec3 col = texture(u_frame, fs_UV).rgb;

    float z = texture(u_frame, fs_UV).a;

    vec3 final_color = kuwahara();

    out_Col = vec4(final_color, 1.0);

}