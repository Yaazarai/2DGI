// Recreate any surfaces that were cleared from VRAM (for whatever reason).

//for(var i = 0; i < gistage_numb; i++)
var i = 0; repeat(gistage_numb) {
    if (!surface_exists(gistage_surf[i])) gistage_surf[i] = surface_create(gistage_resw, gistage_resh);
    i++;
}

//for(var i = 0; i < gistage_tmpk; i++)
var i = 0; repeat(gistage_tmpk) {
    if (!surface_exists(gistage_temp[i])) gistage_temp[i] = surface_create(gistage_resw, gistage_resh);
    i++;
}