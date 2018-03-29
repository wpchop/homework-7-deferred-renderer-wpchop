#version 300 es
precision highp float;

#define EPS 0.0001
#define PI 3.1415962

in vec2 fs_UV;
out vec4 out_Col;

uniform sampler2D u_gb0;
uniform sampler2D u_gb1;
uniform sampler2D u_gb2;

uniform float u_Time;
uniform float u_Fovy;
uniform float u_Aspect;

uniform mat4 u_View;
uniform vec4 u_CamPos;   

float normpdf(in float x, in float sigma)
{
	return 0.39894*exp(-0.5*x*x/(sigma*sigma))/sigma;
}

vec4 gaussianBlur() {
	float tex_offsetX = float(textureSize(u_gb2, 0).x);
	float tex_offsetY = float(textureSize(u_gb2, 0).y);
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
				final_colour += kernel[kSize+j]*kernel[kSize+i] * texture(u_gb2, blurSample).rgb;
			}
		}
		return vec4(final_colour/(Z*Z), 1.0);
}

void main() {
	// read from GBuffers

	vec4 gb0 = texture(u_gb0, fs_UV);
	vec4 gb1 = texture(u_gb1, fs_UV);
	vec4 gb2 = texture(u_gb2, fs_UV);

	vec3 col = gb2.xyz;
	vec3 brightCol = gb1.xyz;
	col+= brightCol;

	// Material base color (before shading)
	vec4 diffuseColor = vec4(col, 1.0);

	vec3 nor = gb0.xyz;

	vec4 lightPos = vec4(0.0,10.0,-10.0,1.0);

	float sx = fs_UV.x * 2.0 - 1.0;
	float sy = 1.0 - fs_UV.y * 2.0;
	vec3 eye = u_CamPos.xyz;
	float t = gb0.w; // depth
	vec3 ref = eye + t * vec3(0,0,1);
	float len = length(ref - eye);
	
	float alpha = u_Fovy / 2.0;
	float aspect = u_Aspect;
	vec3 V = vec3(0.0,1.0,0.0) * len * tan(alpha);
	vec3 H = vec3(1.0,0.0,0.0) * len * aspect * tan(alpha);

	vec3 pos_cam = ref + sx * H + sy * V;
	
	vec4 localLightPos = u_View * lightPos;
	vec3 lightDir = localLightPos.xyz - pos_cam;

	// Calculate the diffuse term for Lambert shading
	float diffuseTerm = dot(normalize(nor), normalize(lightDir));

	float ambientTerm = 0.2;

	float lightIntensity = diffuseTerm + ambientTerm;

	// Compute final shaded color
	out_Col = vec4(diffuseColor.rgb * lightIntensity, diffuseColor.a);

	if (t > 0.0) {
		out_Col = vec4(pow(vec3(0.0,187.0/255.0,1.0), vec3(2.2)),1.0);
		if (sy > 0.25 * sin(sx * 10.0) + 0.25) {
			out_Col = vec4(pow(vec3(39.0/255.0, 112.0/255.0, 68.0/255.0), vec3(2.2)), 1.0);			
		}
	}

	// out_Col = gaussianBlur();
}