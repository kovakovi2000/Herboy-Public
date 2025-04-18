#include <amxmodx>  
#include <cstrike> 
#include <csx>  

new const PLUGIN[] = "C4 Hangok"  
new const VERSION[] = "1.2"  
new const AUTHOR[] = "Xvil"  

new c4_ido

public plugin_init() {  
    register_plugin(PLUGIN, VERSION, AUTHOR)  
    c4_ido = get_cvar_pointer("mp_c4timer")
    register_logevent("RoundEnd",2,"1=Round_End")    
    register_logevent("logevent_round_start", 2, "1=Round_Start")    
}

public plugin_precache() { 
	precache_sound("hb2024/tiz.wav")   
	precache_sound("hb2024/kilenc.wav")  
	precache_sound("hb2024/nyolc.wav")  
	precache_sound("hb2024/het.wav")  
	precache_sound("hb2024/hat.wav")  
	precache_sound("hb2024/ot.wav")  
	precache_sound("hb2024/negy.wav")  
	precache_sound("hb2024/harom.wav")  
	precache_sound("hb2024/ketto.wav")  
	precache_sound("hb2024/egy.wav")  
	precache_sound("hb2024/bomba.wav")
} 
 
public bomb_planted(planter) {  
    //client_cmd(0, "spk hb2024/bomba.wav" )  
	
    new time = get_pcvar_num(c4_ido)
    
    float(time)
    
    set_task( (time - 10.0) , "tiz", 0)	
    set_task( (time - 9.0) , "kilenc", 0)  
    set_task( (time - 8.0) , "nyolc", 0)  
    set_task( (time - 7.0) , "het", 0)  
    set_task( (time - 6.0) , "hat", 0)  
    set_task( (time - 5.0) , "ot", 0)  
    set_task( (time - 4.0) , "negy", 0)
    set_task( (time - 3.0) , "harom", 0)  
    set_task( (time - 2.0) , "ketto", 0)  
    set_task( (time - 1.0) , "egy", 0)  
    return PLUGIN_CONTINUE  
}  

public tiz()  
{  
    set_hudmessage(random(255), random(255), random(255), -1.0, 0.1, 0, 6.0, 1.0)
    show_hudmessage(0, "Robbanás 10 másodperc múlva...")  
    client_cmd(0, "spk hb2024/tiz.wav" )  
    return PLUGIN_CONTINUE  
}  

public kilenc()  
{  
    set_hudmessage(random(255), random(255), random(255), -1.0, 0.1, 0, 6.0, 1.0)
    show_hudmessage(0, "Robbanás 9 másodperc múlva...")  
    client_cmd(0, "spk hb2024/kilenc.wav" )  
    return PLUGIN_CONTINUE  
}  
public nyolc()  
{  
    set_hudmessage(random(255), random(255), random(255), -1.0, 0.1, 0, 6.0, 1.0)
    show_hudmessage(0, "Robbanás 8 másodperc múlva...")  
    client_cmd(0, "spk hb2024/nyolc.wav")  
    return PLUGIN_CONTINUE  
}  
public het()  
{  
    set_hudmessage(random(255), random(255), random(255), -1.0, 0.1, 0, 6.0, 1.0)
    show_hudmessage(0, "Robbanás 7 másodperc múlva...")  
    client_cmd(0, "spk hb2024/het.wav")  
    return PLUGIN_CONTINUE  
}  
public hat()  
{  
    set_hudmessage(random(255), random(255), random(255), -1.0, 0.1, 0, 6.0, 1.0)
    show_hudmessage(0, "Robbanás 6 másodperc múlva...")  
    client_cmd(0, "spk hb2024/hat.wav"  )  
    return PLUGIN_CONTINUE  
}  
public ot()  
{  
    set_hudmessage(random(255), random(255), random(255), -1.0, 0.1, 0, 6.0, 1.0)
    show_hudmessage(0, "Robbanás 5 másodperc múlva...")  
    client_cmd(0, "spk hb2024/ot.wav" )  
    return PLUGIN_CONTINUE  
}  
public negy()  
{  
    set_hudmessage(random(255), random(255), random(255), -1.0, 0.1, 0, 6.0, 1.0)
    show_hudmessage(0, "Robbanás 4 másodperc múlva...")  
    client_cmd(0, "spk hb2024/negy.wav" )  
    return PLUGIN_CONTINUE  
}  
public harom()  
{  
    set_hudmessage(random(255), random(255), random(255), -1.0, 0.1, 0, 6.0, 1.0)
    show_hudmessage(0, "Robbanás 3 másodperc múlva...")  
    client_cmd(0, "spk hb2024/harom.wav")  
    return PLUGIN_CONTINUE  
}  
public ketto()  
{  
    set_hudmessage(random(255), random(255), random(255), -1.0, 0.1, 0, 6.0, 1.0)
    show_hudmessage(0, "Robbanás 2 másodperc múlva..")  
    client_cmd(0, "spk hb2024/ketto.wav"  )  
    return PLUGIN_CONTINUE  
}  
public egy()  
{  
    set_hudmessage(random(255), random(255), random(255), -1.0, 0.1, 0, 6.0, 1.0)
    show_hudmessage(0, "Robbanás 1 másodperc múlva.")  
    client_cmd(0, "spk hb2024/egy.wav")  
    return PLUGIN_CONTINUE  
}  


public RoundEnd()  
{  
    remove_task(0,0)  
}  


public logevent_round_start()  
{  
    remove_task(0,0)  
}  
