varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec3 u_burn_colour;
uniform float u_burn_strength;

void main()
{
    vec4 base_sample = v_vColour
        * texture2D(gm_BaseTexture, v_vTexcoord);

    // Photoshop-style Colour Burn:
    // 1 - ((1 - base) / blend). Guard zero-valued blend channels so the
    // shader remains stable, then mix with the untouched frame by strength.
    vec3 safe_burn_colour = max(u_burn_colour, vec3(0.001));
    vec3 burned_colour = 1.0 - min(
        vec3(1.0),
        (vec3(1.0) - base_sample.rgb) / safe_burn_colour
    );
    vec3 final_colour = mix(
        base_sample.rgb,
        burned_colour,
        clamp(u_burn_strength, 0.0, 1.0)
    );

    gl_FragColor = vec4(final_colour, base_sample.a);
}
