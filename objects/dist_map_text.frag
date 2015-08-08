// Eastern Wolf @ 2014
// 

uniform sampler2D u_texture;
uniform vec4 u_color;
uniform float u_buffer;
uniform float u_gamma;

//varying vec2 v_texcoord;

void main() 
{
    float dist = texture2D(u_texture, gl_TexCoord[0].st).r;
    float alpha = smoothstep(u_buffer - u_gamma, u_buffer + u_gamma, dist);
	vec4 f_color = u_color;

	// black halo
	f_color.rgb = u_color.rgb * step(u_buffer+0.01 , dist);
	
    gl_FragColor = vec4(f_color.rgb, alpha * u_color.a);
}