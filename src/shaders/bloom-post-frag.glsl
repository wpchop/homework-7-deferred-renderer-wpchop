#version 300 es
precision highp float;

in vec2 fs_UV;
out vec4 out_Col;

uniform sampler2D u_frame;
uniform float u_Time;

// // Interpolation between color and greyscale over time on left half of screen
// void main() {
// 	vec3 color = texture(u_frame, fs_UV).xyz;
// 	// vec3 color2 = vec3(dot(color, vec3(0.2126, 0.7152, 0.0722)));
// 	// float t = sin(3.14 * u_Time) * 0.5 + 0.5;
// 	// t *= 1.0 - step(0.5, fs_UV.x);
// 	// color = mix(color, color2, smoothstep(0.0, 1.0, t));
// 	out_Col = vec4(color, 1.0);
// }


float normpdf(in float x, in float sigma)
{
	return 0.39894*exp(-0.5*x*x/(sigma*sigma))/sigma;
}

void main() {

	vec3 col = texture(u_frame, fs_UV).rgb;

    float brightness = dot(col, vec3(0.2126, 0.7152, 0.0722));

	float tex_offsetX = float(textureSize(u_frame, 0).x);
	float tex_offsetY = float(textureSize(u_frame, 0).y);
	vec2 offset = vec2(1.0 / tex_offsetX, 1.0 / tex_offsetY);

		//declare stuff
		const int mSize = 11;
		const int kSize = (mSize-1)/2;
		float kernel[mSize];
		vec3 final_colour = vec3(0.0);
		
		//create the 1-D kernel
		float sigma = 7.0;
		float Z = 0.0;
		for (int j = 0; j <= kSize; ++j)
		{
			kernel[kSize+j] = kernel[kSize-j] = normpdf(float(j), sigma);
		}
		
		//get the normalization factor (as the gaussian has been clamped)
		for (int j = 0; j < mSize; ++j)
		{
			Z += kernel[j];
		}
		
		//read out the texels
		for (int i=-kSize; i <= kSize; ++i)
		{
			for (int j=-kSize; j <= kSize; ++j)
			{
				// final_colour += kernel[kSize+j]*kernel[kSize+i] * texture(u_gb2, fs_UV + vec2(float(i),float(j))).rgb;
				vec2 blurSample = fs_UV + vec2(float(i),float(j)) * offset;
				final_colour += kernel[kSize+j]*kernel[kSize+i] * texture(u_frame, blurSample).rgb;
			}
		}

    if(brightness > 0.1) {
        out_Col = vec4(col, 1.0) + 2.0 * vec4(final_colour/(Z*Z), 0.0);;
    } else {
        out_Col = vec4(col, 1.0); 
    }

	// out_Col = vec4(col, 1.0);
		// out_Col = vec4(final_colour/(Z*Z), 1.0);
}