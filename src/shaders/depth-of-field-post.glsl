#version 300 es
precision highp float;

in vec2 fs_UV;
out vec4 out_Col;

uniform sampler2D u_frame;
uniform float u_Time;

float normpdf(in float x, in float sigma)
{
	return 0.39894*exp(-0.5*x*x/(sigma*sigma))/sigma;
}

vec3 gaussianBlur() {
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
    return final_colour;
}

void main() {

	vec3 col = texture(u_frame, fs_UV).rgb;

    float z = texture(u_frame, fs_UV).a;

    vec3 final_colour;

    float dist = clamp(abs(z + 23.0) / 2.0, 0.0, 1.0);
    final_colour = 2.0 * gaussianBlur();
    vec3 colsum = dist * final_colour + (1.0 - dist) * col;
    out_Col = vec4(colsum, 1.0);

}