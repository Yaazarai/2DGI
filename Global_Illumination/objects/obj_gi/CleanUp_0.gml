for(var i = 0; i < gistage_numb; i++) 
    if (surface_exists(gistage_surf[i])) surface_free(gistage_surf[i]);

for(var i = 0; i < gistage_tmpk; i++) 
    if (surface_exists(gistage_temp[i])) surface_free(gistage_temp[i]);