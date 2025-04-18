// Plugin információk
#include <amxmodx>
#include < grip >
#include < sk_utils >
new const WEBHOOK[] = "https://discord.com/api/webhooks/1262535786562195548/7jfKjHa6E04DqGYfzYVxvSi6z-ZIn63xnjDgn9F9uxwB_Eui_wZWUvoHrju7vrf1PN0f";//assault

// Változók a legutóbbi FPS kiszámítás idejének tárolásához
new Float:lastCheckTime = 0.0;
new frames = 0;
new Float:fps = 0.0;
new Float:avgFps = 0.0;
new Float:minFps = 99999.0;
new Float:maxFps = 0.0;
new readings = 0;
new Float:startDelay = 10.0;
new Float:minResetTime = 0.0;
new bool:hasStarted = false;
new ch1eck
new under500 = 0;
new under250 = 0;
new under150 = 0;

// Plugin inicializáció
public plugin_init() {
    register_plugin("FPS Checker", "1.0", "YourName");
    register_clcmd("checking", "checkon")
    lastCheckTime = get_gametime(); // Indítási idő mentése
    minResetTime = get_gametime(); // Minimális FPS reset időzítés kezdete
}
public checkon(id)
{
 ch1eck = id;
}
public mensure_ending()
{
  //send_report(3)
}
// Server frame callback
public server_frame() {
    // Aktuális idő lekérése
    new Float:currentTime = get_gametime();

    // Ellenőrizzük, hogy eltelt-e 10 másodperc az indítás előtt
    if (!hasStarted) {
        if (currentTime - lastCheckTime >= startDelay) {
            hasStarted = true;
            //send_report(1);
            lastCheckTime = currentTime; // Frissítjük az időzítést a működés indításához
        }
        return;
    }

    // Növeljük a frame-számlálót
    frametimes[frames] = get_gametime();
    frames++;

    // Ellenőrizzük, hogy eltelt-e 0.2 másodperc
    if (currentTime - lastCheckTime >= 0.1) {
        // FPS kiszámítása
        fps = float(frames) / (currentTime - lastCheckTime);

        // Minimális és maximális FPS frissítése
        if (fps < minFps) {
            minFps = fps;
        }
        if (fps > maxFps) {
            maxFps = fps;
        }
        if(fps < 150.00)
          {
            under150++;
          }
        if(fps < 250.00)
        {
          under250++;
        }
        if(fps < 500.00)
        {
          //send_report(2)
          under500++;
        }
          

          prevTime = frametimes[i];
        }
        
        avg /= frames;

        avg *= 1000.0;
        min *= 1000.0;
        max *= 1000.0;

        client_print(0, print_chat, "FPS: %.2f | Min: %.2f | Max: %.2f | Avg: %.2f", frames, min, max, avg);
        // Frame-számláló nullázása és idő frissítése
        frames = 0;
        lastCheckTime = currentTime;
        client_print(ch1eck, print_console, "FPS: %.2f | Min: %3.2f | Max: %3.2f", fps, minFps, maxFps);
    }
}

public send_report(MensureTyp)
{
  new String[128], len, sTime[33];
  new MapName[33];
  get_mapname(MapName, charsmax(MapName));
  formatCurrentDateAndTime(sTime, charsmax(sTime));
  new nowplayers = get_playersnum();

  if(MensureTyp == 1)
    len += formatex(String[len], charsmax(String) - len, "`[DEV] ~ Mensure Started ~^n^nMap: %s^nDateTime: %s^nPlayers: %i/32^n^nAll server drops writed here:`", MapName, sTime, nowplayers);
  else if(MensureTyp == 2)
    len += formatex(String[len], charsmax(String) - len, "`[DEV] Detected FPS Drop: [%3.2f] | On: %s | Date: %s | Players: %i/32`", fps, MapName, sTime, nowplayers);
  else if(MensureTyp == 3)
    len += formatex(String[len], charsmax(String) - len, "`~[DEV] Ended ~^n^nS-Stat:^nTC: %i^nUn500FPS: %i^nUn250FPS: %i^nUn150FPS: %i^n^nFPSStat:^nMaFPS: %.2f^nMiFPS: %.2f^nAvFPS: %.2f^n`", readings, under500, under250, under150, maxFps, minFps, avgFps);

  GoRequest(WEBHOOK, "Handler_SendReason", GripRequestTypePost, fmt("content=%s", String));
}

public Handler_SendReason()
{
  if(!HandlerGetErr()){
      return;
  }
  
}

public GoRequest(const site[], const handler[], const GripRequestType:type, data[]){
    new GripRequestOptions:options = grip_create_default_options();
    grip_options_add_header(options, "Content-Type", "application/x-www-form-urlencoded");
    
    new GripBody: body = grip_body_from_string(data);
    grip_request(site, body, type, handler, options, 0);
    
    grip_destroy_body(body);
    grip_destroy_options(options);
}

public bool: HandlerGetErr(){
    if(grip_get_response_state() == GripResponseStateError){
        sk_chat(0, "ResponseState is Error");
        return false;
    }
    
    new GripHTTPStatus:err;
    if((err = grip_get_response_status_code()) != GripHTTPStatusNoContent){
        sk_chat(0, "ResponseStatusCode is %d", err);
        return false;
    }
    
    return true;
}
