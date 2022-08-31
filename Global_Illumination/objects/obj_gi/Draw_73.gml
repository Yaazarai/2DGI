/*
    STAGE 1: [INITIAL] Render the scene that GI will be rendered from.
*/
// Enable GPU blending to create the initialization surface and blend that with the first GI pass.
gpu_set_blendenable(true);

surface_set_target(gistage_surf[GISTAGES.INITIAL]);
draw_clear_alpha(c_black, 0);
draw_sprite(Spr_SceneGI,0,0,0);
draw_set_color($FF94FD);
draw_circle(mouse_x*(gistage_resw/gistage_rndw), mouse_y*(gistage_resh/gistage_rndh), 8, false);
draw_set_color(c_white);
surface_reset_target();

surface_set_target(gistage_temp[gistage_iter mod gistage_tmpk]);
draw_surface(gistage_surf[GISTAGES.INITIAL],0,0);
surface_reset_target();

// Disable GPU blending for future stages to eliminate alpha component artifacts.
gpu_set_blendenable(false);

/*
    STAGE 2: [PREJUMP] Setup for Jump Flooding
*/
surface_set_target(gistage_surf[GISTAGES.PREJUMP]);
draw_clear_alpha(c_black, 0);
shader_set(GISHADER.PREJUMP);
draw_surface(gistage_surf[GISTAGES.INITIAL],0,0);
shader_reset();
surface_reset_target();

surface_set_target(gistage_surf[GISTAGES.JMPFLDA]);
draw_clear_alpha(c_black, 0);
surface_reset_target();

surface_set_target(gistage_surf[GISTAGES.JMPFLDB]);
draw_clear_alpha(c_black, 0);
draw_surface(gistage_surf[GISTAGES.PREJUMP],0,0);
surface_reset_target();

/*
    STAGE 3: [JUMPFLD] Jump Flooding
*/
var passes = ceil(log2(max(gistage_resw, gistage_resh)) / log2(2.0));

shader_set(GISHADER.JUMPFLD);
shader_set_uniform_f(JUMPFLD_inResol, gistage_resw, gistage_resh);
var i = 0; repeat(passes) {
    var offset = power(2, passes - i - 1);
    shader_set_uniform_f(JUMPFLD_inJdist, offset);
    
    surface_set_target(gistage_surf[GISTAGES.JMPFLDA]);
    draw_surface(gistage_surf[GISTAGES.JMPFLDB],0,0);
    surface_reset_target();
    
    surface_set_target(gistage_surf[GISTAGES.JMPFLDB]);
    draw_surface(gistage_surf[GISTAGES.JMPFLDA],0,0);
    surface_reset_target();
    i++;
}
shader_reset();

/*
    STAGE 4: [DISTFLD] Distance Field from Jump Flood
*/
surface_set_target(gistage_surf[GISTAGES.DISTFLD]);
draw_clear_alpha(c_black, 0);
    shader_set(GISHADER.DISTFLD);
    draw_surface(gistage_surf[GISTAGES.JMPFLDB],0,0);
    shader_reset();
surface_reset_target();

/*
    STAGE 5: [FASTNSE] Generate noise using a basic random function.
*/
surface_set_target(gistage_surf[GISTAGES.FASTNSE]);
    shader_set(GISHADER.FASTNSE);
    shader_set_uniform_f(FASTNSE_inTimer, gistage_time);
    draw_surface(gistage_surf[GISTAGES.INITIAL],0,0);
    shader_reset();
surface_reset_target();

/*
    STAGE 6: [GILIGHT] Ray March the light scene.
*/

surface_set_target(gistage_temp[(gistage_iter+1) mod gistage_tmpk]);
    shader_set(GISHADER.GILIGHT);
    shader_set_uniform_f(GILIGHT_inResol, gistage_resw, gistage_resh);
    texture_set_stage(GILIGHT_inDistfld, surface_get_texture(gistage_surf[GISTAGES.DISTFLD]));
    texture_set_stage(GILIGHT_inFastnse, surface_get_texture(gistage_surf[GISTAGES.FASTNSE]));
    draw_surface(gistage_temp[gistage_iter mod gistage_tmpk],0,0);
    shader_reset();
surface_reset_target();
gistage_iter++;

/*
    STAGE 7: [POSTPRC] additive blending for bloom.
*/
// Re-Enable color blending for bloom.
gpu_set_blendenable(true);

surface_set_target(gistage_surf[GISTAGES.POSTPRC]);
    draw_clear(c_black);
    gpu_set_blendmode(bm_add);
    repeat(2) { draw_surface(gistage_temp[gistage_iter mod gistage_tmpk],0,0); }
    gpu_set_blendmode(bm_normal);
surface_reset_target();

/*
    STAGE 8: [DENOISE] Remove noise from final scene.
*/
repeat(gistage_dnse) {
    surface_set_target(gistage_surf[GISTAGES.DENOISE]);
        shader_set(GISHADER.DENOISE);
        shader_set_uniform_f(DENOISE_inResol, gistage_resw, gistage_resh);
        draw_surface(gistage_surf[GISTAGES.POSTPRC],0,0);
        shader_reset();
        draw_surface(gistage_surf[GISTAGES.INITIAL],0,0);
    surface_reset_target();

    surface_set_target(gistage_surf[GISTAGES.POSTPRC]);
        shader_set(GISHADER.DENOISE);
        shader_set_uniform_f(DENOISE_inResol, gistage_resw, gistage_resh);
        draw_surface(gistage_surf[GISTAGES.DENOISE],0,0);
        shader_reset();
        draw_surface(gistage_surf[GISTAGES.INITIAL],0,0);
    surface_reset_target();
}

if (gistage_curr == 0)
/*STAGE 1*/draw_surface_ext(gistage_surf[GISTAGES.INITIAL],0,0,gistage_rndw/gistage_resw,gistage_rndh/gistage_resh,0,c_white,1);

if (gistage_curr == 1)
/*STAGE 2*/draw_surface_ext(gistage_surf[GISTAGES.PREJUMP],0,0,gistage_rndw/gistage_resw,gistage_rndh/gistage_resh,0,c_white,1);

if (gistage_curr == 2)
/*STAGE 3*/draw_surface_ext(gistage_surf[GISTAGES.JMPFLDB],0,0,gistage_rndw/gistage_resw,gistage_rndh/gistage_resh,0,c_white,1);

if (gistage_curr == 3)
/*STAGE 4*/draw_surface_ext(gistage_surf[GISTAGES.DISTFLD],0,0,gistage_rndw/gistage_resw,gistage_rndh/gistage_resh,0,c_white,1);

if (gistage_curr == 4)
/*STAGE 5*/draw_surface_ext(gistage_surf[GISTAGES.FASTNSE],0,0,gistage_rndw/gistage_resw,gistage_rndh/gistage_resh,0,c_white,1);

if (gistage_curr == 5)
/*STAGE 6*/draw_surface_ext(gistage_temp[gistage_iter mod gistage_tmpk],0,0,gistage_rndw/gistage_resw,gistage_rndh/gistage_resh,0,c_white,1);

if (gistage_curr == 6)
/*STAGE 7*/draw_surface_ext(gistage_surf[GISTAGES.POSTPRC],0,0,gistage_rndw/gistage_resw,gistage_rndh/gistage_resh,0,c_white,1);

//*STAGE 8*/draw_surface_ext(gistage_surf[GISTAGES.DENOISE],0,0,gistage_rndw/gistage_resw,gistage_rndh/gistage_resh,0,c_white,1);

draw_set_color(c_black);
draw_rectangle(0,0,88,135,false);
draw_set_color(c_yellow);
draw_text(5, 5, "FPS: " + string(fps));
draw_text(5, 25, "DNS: " + string(gistage_dnse));
draw_text(5, 45, "RSW: " + string(gistage_resw));
draw_text(5, 65, "RSH: " + string(gistage_resh));
draw_text(5, 85, "STG: " + string(gistage_curr));
draw_set_color(c_white);