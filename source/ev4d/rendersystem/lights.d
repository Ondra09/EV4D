
module ev4d.rendersystem.lights;

import gl3n.linalg;

/**
	Holds lights data for usage in basic ligth equation L = emmisive + ambient + Ei diffuse_i + Ei specular_i


	http://in2gpu.com/2014/06/19/lighting-vertex-fragment-shader/
*/

/**
	Light has only one color for all parts of lighting equation.

	L = emmisive + ambient + att * Ei diffuse_i + att * Ei specular_i
*/
struct PointLight 
{
	mat4 *worldMatrix;

	vec3 color = vec3(1, 1, 1);
	/// point light attenuation constants (constant, linear, quadratic)
	/// att = 1/(kc + kl * d + kq * d^2)
	/// d = distance(light_position, world_pos);
	vec3 k_clq = vec3(1, 1, 1);
}

// if passsing this to functions often use class for this container
struct Lights
{
public:
	// global ambient light for all lights .. use one for all now
	vec4 ambientLight;

	void addPointLight(PointLight* pl)
	{
		pointLights ~= *pl;
	}

	PointLight* getNearestLight()
	{
		PointLight *pl = null;
		if (pointLights.length > 0)
			pl = &pointLights[0];

		return pl;
	}

	// TODO : implement here some spatial structure if needed
	// generalize for more lights (e.g.: 3)
/*	PointLight* getNearestLight(vec3 position)
	{
		PointLight* retVal;
		float dst = float.max;

		foreach (ref PointLight pl; pointLights)
		{
			float cdst = distance(*pl.position, position);

			if (dst > cdst)
			{
				dst = cdst;
				retVal = &pl;
			}
		}

		return retVal;
	}*/

private:
	PointLight[] pointLights;
}
