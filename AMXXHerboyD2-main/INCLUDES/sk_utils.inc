#include <manager>
new const Admin_Permissions[][][] = {
	//Rang név | Jogok | Hozzáadhat-e admint? (0-Nem | 1-Igen)| Hozzáadhat-e VIP-t? (0-Nem | 1-Igen) | Bannolhat accot? 0 nem 1 igen
	{"Játékos", "z", "0", "0"}, //Játékos - 0
	{"Fejlesztő", "abcvnmlpoikujzhtgrfedwsac", "1", "1"}, //Tulajdonos - 4
	{"Tulajdonos", "abcvnmlpoikujzhtgrfedwsac", "1", "1"}, //Tulajdonos - 4
	{"FőAdmin", "abmjcfscdtiue", "1", "1"}, //FőAdmin - 3
	{"Admin", "bmjcfscdtiue", "0", "0"}, //Admin - 2
	{"Szerver NagyApja", "z", "0", "0"}, //Admin - 2
};

public sk_chat(iId, const sText[], any:...)
{
	new sFormatedText[256];
	
	vformat(sFormatedText, charsmax(sFormatedText), sText, 3);
	if(m_get_server_id() == 1)
		client_print_color(iId, 0, "^4[AVATAR] ^3»^1 %s", sFormatedText);
	else 
		client_print_color(iId, 0, "^4[^1~^3|^4HerBoy^3|^1~^4] ^3»^1 %s", sFormatedText);
}
public sDebug(dId, is_console, const CalledFunc[], const dsText[], any:...)
{
	new sdFormatedText[256], sCalledFunc[256];
	vformat(sCalledFunc, charsmax(sCalledFunc), CalledFunc, 3);
	vformat(sdFormatedText, charsmax(sdFormatedText), dsText, 3);
	if(is_console)
		client_print(dId, print_console, "[DEBUG ~ %s] %s", sCalledFunc, sdFormatedText);
	else
		client_print_color(dId, print_team_default, "^4[DEBUG ~ %s]^1 ~ %s", sCalledFunc, sdFormatedText);
}
public sk_chat_lang(const sText[], const lang_string[], any:...)
{
	for(new i = 0; i < 33; i++)
	{
		if(!is_user_connected(i))
			continue;

		new sFormatedText[256];
		new sLangText[256];
		new sPrintText[256];
		
		if(m_get_server_id() == 1)
			format(sFormatedText, charsmax(sFormatedText), "^4[AVATAR] ^3»^1 %s", sText);
		else 
			format(sFormatedText, charsmax(sFormatedText), "^4[^1~^3|^4HerBoy^3|^1~^4] ^3»^1 %s", sText);
		LookupLangKey(sLangText, charsmax(sLangText), lang_string, i);
		replace_string(sFormatedText, charsmax(sFormatedText), "%L", sLangText);
		vformat(sPrintText, charsmax(sPrintText), sFormatedText, 3);
		client_print_color(i, 0, sPrintText);
	}
}
stock formatCurrentDateAndTime(sTime[], iLen) {
	format_time(sTime, iLen, "%Y-%m-%d %H:%M:%S", get_systime());
}
stock formatTime(sTime[], iLen, iTime) {
	format_time(sTime, iLen, "%Y-%m-%d %H:%M:%S", iTime);
}
//37 char
stock gen_uuid(uuid[], length)
{
	format(uuid, length, "%08x-%04x-h%03x-%04x-%04x%04x%04x", get_systime() | random(0x7fffffff), random(0xffff), random(0xfff), (random(0x3fff) | 0x8000), random(0xffff), random(0xffff), random(0xffff));
}

public sk_log(const LogFile[], const LogMess[], any:...)
{
	static file[100], file_handle, timeformatted[33], filename[64]
	static callerplugin[32];
	get_plugin(-1, callerplugin, charsmax(callerplugin));
	format_time(timeformatted, sizeof(timeformatted) - 1, "%Y-%m-%d");
	format(filename, sizeof(filename) - 1, "%s.slog",  LogFile);
	copy(file, 100, fmt("addons/amxmodx/SMOD_LOGS/%s", timeformatted))
	
	if(!dir_exists(fmt("addons/amxmodx/SMOD_LOGS"))) 
		mkdir(fmt("addons/amxmodx/SMOD_LOGS"))

	if(!dir_exists(fmt("addons/amxmodx/SMOD_LOGS/%s", timeformatted)))
		mkdir(fmt("addons/amxmodx/SMOD_LOGS/%s", timeformatted))

	format(file, charsmax(file), "%s/%s", file, filename)

	if(file_exists(file))
		file_handle = fopen(file, "at")
	else
		file_handle = fopen(file, "wt")

	new sTime[64];
	formatCurrentDateAndTime(sTime, charsmax(sTime));

	if(file_handle) {
		new formatstring[2000]
		format(formatstring, charsmax(formatstring), "^n[ TIME : %s ] %s - %s", sTime, callerplugin, LogMess)
		fputs(file_handle, formatstring)
	}

	fclose(file_handle)
}
public sk_logw(const LogFile[], const LogMess[], any:...)
{
	static file[100], file_handle, timeformatted[33], filename[64]
	static callerplugin[32];
	get_plugin(-1, callerplugin, charsmax(callerplugin));
	format_time(timeformatted, sizeof(timeformatted) - 1, "%Y-%m-%d");
	format(filename, sizeof(filename) - 1, "%s.slog",  LogFile);
	copy(file, 100, fmt("addons/amxmodx/SMOD_LOGS/%s", timeformatted))
	
	if(!dir_exists(fmt("addons/amxmodx/SMOD_LOGS"))) 
		mkdir(fmt("addons/amxmodx/SMOD_LOGS"))

	if(!dir_exists(fmt("addons/amxmodx/SMOD_LOGS/%s", timeformatted)))
		mkdir(fmt("addons/amxmodx/SMOD_LOGS/%s", timeformatted))

	format(file, charsmax(file), "%s/%s", file, filename)

	if(file_exists(file))
		file_handle = fopen(file, "at")
	else
		file_handle = fopen(file, "wt")
	new sTime[64];
	formatCurrentDateAndTime(sTime, charsmax(sTime));

	if(file_handle) {
		new formatstring[2000]
		format(formatstring, charsmax(formatstring), "^n%s",LogMess)
		fputs(file_handle, formatstring)
	}
			
	fclose(file_handle)
}

public get_page_num(key, start_key, elements_per_page) {
    return (key - start_key) / elements_per_page;
}