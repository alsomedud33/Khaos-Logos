RSRC                     VisualShader            ’’’’’’’’                                            J      resource_local_to_scene    resource_name    output_port_for_preview    default_input_values    expanded_output_ports    script    parameter_name 
   qualifier    texture_type    color_default    texture_filter    texture_repeat    texture_source    source    texture    interpolation_mode    offsets    colors 	   gradient    width    use_hdr    code    graph_offset    mode    modes/blend    modes/depth_draw    modes/cull    modes/diffuse    modes/specular    flags/depth_prepass_alpha    flags/depth_test_disabled    flags/sss_mode_skin    flags/unshaded    flags/wireframe    flags/skip_vertex_transform    flags/world_vertex_coords    flags/ensure_correct_normals    flags/shadows_disabled    flags/ambient_light_disabled    flags/shadow_to_opacity    flags/vertex_lighting    flags/particle_trails    flags/alpha_to_coverage     flags/alpha_to_coverage_and_one    nodes/vertex/0/position    nodes/vertex/connections    nodes/fragment/0/position    nodes/fragment/2/node    nodes/fragment/2/position    nodes/fragment/3/node    nodes/fragment/3/position    nodes/fragment/4/node    nodes/fragment/4/position    nodes/fragment/5/node    nodes/fragment/5/position    nodes/fragment/6/node    nodes/fragment/6/position    nodes/fragment/connections    nodes/light/0/position    nodes/light/connections    nodes/start/0/position    nodes/start/connections    nodes/process/0/position    nodes/process/connections    nodes/collide/0/position    nodes/collide/connections    nodes/start_custom/0/position    nodes/start_custom/connections     nodes/process_custom/0/position !   nodes/process_custom/connections    nodes/sky/0/position    nodes/sky/connections    nodes/fog/0/position    nodes/fog/connections        &   local://VisualShaderNodeFresnel_n8vtn å      1   local://VisualShaderNodeTexture2DParameter_txngw 9	      &   local://VisualShaderNodeTexture_yqs5g 	         local://Gradient_sehtu ×	          local://GradientTexture1D_0fevj X
      &   local://VisualShaderNodeTexture_3pckx 
      &   local://VisualShaderNodeFresnel_54rdr Ī
         local://VisualShader_4soc6 &         VisualShaderNodeFresnel                                     @@      #   VisualShaderNodeTexture2DParameter             Texture2DParameter                   VisualShaderNodeTexture                             	   Gradient       !          },>.pA?[²R?   $                    ?  ?  ?  ?  ?  ?  ?  ?  ?              ?         GradientTexture1D                         VisualShaderNodeTexture                                   VisualShaderNodeFresnel                                )   ¹?         VisualShader          H  shader_type spatial;
uniform sampler2D Texture2DParameter : repeat_disable;
uniform sampler2D tex_frg_5;



void fragment() {
// Fresnel:2
	float n_in2p3 = 3.00000;
	float n_out2p0 = pow(1.0 - clamp(dot(NORMAL, VIEW), 0.0, 1.0), n_in2p3);


	vec4 n_out4p0;
// Texture2D:4
	n_out4p0 = texture(Texture2DParameter, vec2(n_out2p0));


// Fresnel:6
	float n_in6p3 = 0.10000;
	float n_out6p0 = pow(1.0 - clamp(dot(NORMAL, VIEW), 0.0, 1.0), n_in6p3);


// Texture2D:5
	vec4 n_out5p0 = texture(tex_frg_5, vec2(n_out6p0));


// Output:0
	ALBEDO = vec3(n_out4p0.xyz);
	ALPHA = n_out5p0.x;


}
    
   ūĆÅ„B.   
     CD  C/             0   
      Ć  ęC1            2   
     šĆ  4C3            4   
     pĀ  C5            6   
     ¾C  pC7            8   
     C  śC9                                                                                      RSRC