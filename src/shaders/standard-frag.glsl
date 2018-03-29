#version 300 es
precision highp float;

in vec4 fs_Pos;
in vec4 fs_Nor;
in vec4 fs_Col;
in vec2 fs_UV;

out vec4 fragColor[3]; // The data in the ith index of this array of outputs
                       // is passed to the ith index of OpenGLRenderer's
                       // gbTargets array, which is an array of textures.
                       // This lets us output different types of data,
                       // such as albedo, normal, and position, as
                       // separate images from a single render pass.

uniform sampler2D tex_Color;

uniform float u_Bloom;


void main() {
    // TODO: pass proper data into gbuffers
    // Presently, the provided shader passes "nothing" to the first
    // two gbuffers and basic color to the third.

    // Camera-space depth of the fragment (you'll see why in the next section)
    // World-space surface normal of the fragment
    // Albedo (base color) of the fragment. This is already done in the base code.

    vec3 col = texture(tex_Color, fs_UV).rgb;

    float brightness = dot(col, vec3(0.2126, 0.7152, 0.0722));

    vec4 brightColor;
    if(brightness > u_Bloom) {
        brightColor = vec4(col, 1.0);
    } else {
        brightColor = vec4(0.0, 0.0, 0.0, 1.0); 
    }

    float sx = fs_Pos.x * 2.0 - 1.0;
	float sy = 1.0 - fs_Pos.y * 2.0;

    if (fs_Pos.z > 0.0) {
		col = vec3(0.0,187.0/255.0,1.0);
		if (sy > 0.25 * sin(sx * 10.0) + 0.25) {
			col = vec3(39.0/255.0, 112.0/255.0, 68.0/255.0);
		}
	}

    // if using textures, inverse gamma correct
    col = pow(col, vec3(2.2));

    fragColor[0] = vec4(fs_Nor.xyz, fs_Pos.z); // world space normal & camera-space depth of the fragment
    fragColor[1] = vec4(brightColor);
    fragColor[2] = vec4(col, 1.0);
}
