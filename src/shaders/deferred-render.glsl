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


void main() { 
	// read from GBuffers

	vec4 gb0 = texture(u_gb0, fs_UV);
	vec4 gb2 = texture(u_gb2, fs_UV);

	vec3 col = gb2.xyz;

	// Material base color (before shading)
	vec4 diffuseColor = vec4(col, 1.0);

	vec3 nor = gb0.xyz;

	vec4 lightPos = vec4(10.0,10.0,10.0,1.0);

	float sx = fs_UV.x * 2.0 - 1.0;
	float sy = 1.0 - fs_UV.y * 2.0;
	vec3 eye = u_CamPos.xyz;
	float t = gb0.w;
	vec3 ref = eye + t * vec3(0,0,1);
	float len = length(ref - eye);
	
	float alpha = u_Fovy / 2.0;
	float aspect = u_Aspect;
	vec3 V = vec3(0.0,1.0,0.0) * len * tan(alpha);
	vec3 H = vec3(1.0,0.0,0.0) * len * aspect * tan(alpha);

	vec3 pos_cam = ref + sx * H + sy * V;
	
	vec4 localLightPos = u_View * lightPos;
	vec3 light = localLightPos.xyz - pos_cam;

	// Calculate the diffuse term for Lambert shading
	float diffuseTerm = dot(normalize(nor), normalize(light));

	float ambientTerm = 0.2;

	float lightIntensity = diffuseTerm + ambientTerm;

	// Compute final shaded color
	out_Col = vec4(diffuseColor.rgb * lightIntensity, diffuseColor.a);
}