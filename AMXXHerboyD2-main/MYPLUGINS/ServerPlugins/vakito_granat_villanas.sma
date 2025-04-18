
 #include <amxmodx>
 #include <fakemeta>

 new enabled_cvar;
 new radius_cvar;
 new color_cvar;

 public plugin_init()
 {
	register_plugin("Flashbang Dynamic Light","0.10","Avalanche");
	register_forward(FM_EmitSound,"fw_emitsound");

	enabled_cvar = register_cvar("fbl_enabled","1");
	radius_cvar = register_cvar("fbl_radius","50");
	color_cvar = register_cvar("fbl_color","255 255 255");
 }

 public fw_emitsound(entity,channel,const sample[],Float:volume,Float:attenuation,fFlags,pitch)
 {
	// plugin disabled
	if(!get_pcvar_num(enabled_cvar))
		return FMRES_IGNORED;

	// not a flashbang exploding
	if(!equali(sample,"weapons/flashbang-1.wav") && !equali(sample,"weapons/flashbang-2.wav"))
		return FMRES_IGNORED;

	// light effect
	flashbang_explode(entity);

	return FMRES_IGNORED;
 }


 public flashbang_explode(greindex)
 {
	// invalid entity
	if(!pev_valid(greindex)) return;

	// get origin of explosion
	new Float:origin[3];
	pev(greindex,pev_origin,origin);

	// get color from cvar
	new color[16];
	get_pcvar_string(color_cvar,color,15);

	// split it into red, green, blue
	new redamt[5], greenamt[5], blueamt[5];
	parse(color,redamt,4,greenamt,4,blueamt,4);

	// send the light flash
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY);
	write_byte(27); // TE_DLIGHT
	write_coord(floatround(origin[0])); // x
	write_coord(floatround(origin[1])); // y
	write_coord(floatround(origin[2])); // z
	write_byte(get_pcvar_num(radius_cvar)); // radius
	write_byte(random(255));	// r
	write_byte(random(255)); // g
	write_byte(random(255)); // b
	write_byte(8); // life
	write_byte(60); // decay rate
	message_end();
 }
