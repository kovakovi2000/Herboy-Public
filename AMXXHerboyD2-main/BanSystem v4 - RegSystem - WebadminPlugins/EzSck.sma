#include <amxmodx>
#include <amxmisc>
#include <sockets_async>
#include <ezsck>
#include <manager>

#define PLUGIN    "EzSck" 
#define AUTHOR    "Kova" 
#define VERSION    "2.2.53b"
//EZEKET NE VÁLTOZTASD HA NEM ÉRTESZ HOZZÁ!
#define MAX_VARIBLE 20
#define VARIBLE_LENGTH 64
#define MAX_PACKET_SIZE 1024

#define SALT "_SALTYHerBoY_53GKAKRjQhTyFpdwWsCDV8rQ3q39kXPN"

new g_port;
new SOCKET:g_socket;
new SOCKET:g_sendport;
//new bool:g_Sockets[256];

public plugin_init()
{
    register_plugin(PLUGIN, VERSION, AUTHOR);
    set_task(1.0, "create_sokets");
}

public LoadUtils() {}

public create_sokets()
{
    console_print(0, "************************************************ ")
    console_print(0, "%s %s is running! (by %s)", PLUGIN, VERSION, AUTHOR);
    console_print(0, "************************************************")
    //new port = ServerID[server][sck_port];
    g_sendport = socket_create(SOCK_TYPE_TCP, SOCK_DOWNLOAD)

    if(m_get_server_id() == 1)
        socket_connect(g_sendport, "37.221.212.11", 80);//194.180.16.153
    else
        socket_connect(g_sendport, "127.0.0.1", 80);//194.180.16.153
}

new SOCKET:g_AccountEmail;
public send_register_email(accountid)
{
    g_AccountEmail = socket_create(SOCK_TYPE_TCP, accountid)
    if(m_get_server_id() == 1)
        socket_connect(g_AccountEmail, "37.221.212.11", 80);//194.180.16.153
    else
        socket_connect(g_AccountEmail, "127.0.0.1", 80);//194.180.16.153
}

public fw_sockConnected(SOCKET:socket, customID)
{
    if(socket == g_sendport)
    {
        g_port = random_num(m_get_sck_minport(), m_get_sck_maxport());

        new data[256];
        if(m_get_server_id() == 1)
            formatex(data, charsmax(data),"GET /ban_api/portupdate.php?&n=%i&s=%i HTTP/1.1^r^nHost: 37.221.212.11^r^nConnection: close^r^n^r^n", g_port, m_get_server_id());
        else formatex(data, charsmax(data),"GET /ban_api/portupdate.php?&n=%i&s=%i HTTP/1.1^r^nHost: 127.0.0.1^r^nConnection: close^r^n^r^n", g_port, m_get_server_id());
        socket_send(socket, data);
        console_print(0, data)
        }
    else if(socket == g_AccountEmail)
    {
        if(customID == 0)
            return;
        
        new data[256];
        if(m_get_server_id() == 1)
            formatex(data, charsmax(data),"GET /index.php?pagelink=regmail&id=%i HTTP/1.1^r^nHost: 37.221.212.11^r^nConnection: close^r^n^r^n", customID);
        else
            formatex(data, charsmax(data),"GET /index.php?pagelink=regmail&id=%i HTTP/1.1^r^nHost: 127.0.0.1^r^nConnection: close^r^n^r^n", customID);
        socket_send(socket, data);
    }
}


public plugin_end()
{
    cls_sck(g_socket);
    kill_sockets();
}
public kill_sockets()
{
    //g_Sockets[int:g_socket] = false;
    
    // for(new socket = 0; socket < sizeof(g_Sockets); socket++)
    // {
    //     if(g_Sockets[socket] == true)
    //         socket_close(SOCKET:socket);
    // }

    
}

public log(const message_fmt1[], const message_fmt[], any:...)
{
	static filename[96];
	static LogName[96];
	static LogMessage[3068];
	vformat(LogName, sizeof(LogName) - 1, message_fmt1, 2);
	vformat(LogMessage, sizeof(LogMessage) - 1, message_fmt, 2);

	format_time(filename, sizeof(filename) - 1, "%Y-%m-%d");
	format(filename, sizeof(filename) - 1, "%s__%s.log", LogName, filename);

	log_to_file(filename, "%s", LogMessage);
}


sck_answer_command(SOCKET:socket, tocommand, answer)
{
    new a[] = { 0x00, 0xa1, 0x00, EOS };
    a[0] = tocommand;
    a[2] = answer;
    socket_send(socket, a);
}

public exfunc_callback(SOCKET:socket, answer)
{
    sck_answer_command(socket, cmd_CallExFunc, answer);
}

CallExFunc(SOCKET:socket, data[], len)
{
    new lastpost[2], varcount = 0, vars[MAX_VARIBLE][VARIBLE_LENGTH], curvarpos = 0;
    for(new i = 1;i < len; i++)
    {
        if(varcount == MAX_VARIBLE)
        {
            log("EzSck", "[ERROR] Varible overflow in socket! ");
            sck_answer_command(socket, cmd_CallExFunc, an_Overflow);
            cls_sck(SOCKET:socket);
            return false;
        }
        if(data[i] == ';')
        {
            vars[varcount][curvarpos] = EOS;
            varcount++;
            curvarpos = 0;

            lastpost[0] = lastpost[1];
            lastpost[1] = i+1;
            continue;
        }
        else
            vars[varcount][curvarpos++] = data[i];
    }

    new pluginname[64];
    get_plugin(-1, pluginname, charsmax(pluginname));

    if( callfunc_begin(vars[0],vars[1]) == 1 ) 
    {
        callfunc_push_int(cb_ExFunc);
        callfunc_push_int(int:socket);
        for(new i = 2; i < varcount - 1; i+=2)
        {
            switch(vars[i][0])
            {
                case 'i': { callfunc_push_int(str_to_num(vars[i+1])); }
                case 'f': { callfunc_push_float(str_to_float(vars[i+1])); }
                case 's': { callfunc_push_str(vars[i+1]); }
                default: { log("EzSck", "[ERROR] Can't identify this varible type"); }
            }
        }
        callfunc_end();
        cls_sck(SOCKET:socket);
        return true;
    }
    else
    {
        sck_answer_command(socket, cmd_CallExFunc, an_funcError);
    }

    cls_sck(SOCKET:socket);
    return false;
}

public fw_sockReadable(SOCKET:socket, customID)
{
    if(socket == g_sendport)
    {
        cls_sck(socket);


        g_socket = socket_create(SOCK_TYPE_TCP, SOCK_LISTEN_TCP);
        if(!socket_bind(g_socket, "", g_port))
        {
            log_amx("*ERROR: Failed to bind to TCP port %i.. retry in 2 seconds!", g_port);
            set_task(0.5, "create_sokets");
            return;
        }

        console_print(0, "SOCKET CREATED on TCP port %i!", g_port);
        return; 
    }
    else if(socket == g_AccountEmail && customID > 7)
    {
        console_print(0, "Email sent for account: %i!", customID);
        cls_sck(socket);
        return;
    }

    //g_Sockets[int:socket] = true;
    new data[MAX_PACKET_SIZE], len;
    do {
        len = socket_recv(socket, data, charsmax(data));

        if(len <= 0)
            break;
    } while(len == charsmax(data))
    
    if(data[0] != cmd_CallExFunc)
        return;

    new semmicolum = 0, last_scloc = -1, char_since = 0;
    for(new i = 1; i < len; i++)
    {
        char_since++;
        if(data[i] == ';')
        {
            semmicolum++;
            last_scloc = i;
            char_since = 0;
        }
    }
    if(semmicolum < 4)
        return;

    new datahasher[MAX_PACKET_SIZE];
    new read_hash[33];
    new gen_hash[33];
    copy(datahasher, last_scloc, data);
    formatex(datahasher, MAX_PACKET_SIZE, "%s;%s", datahasher[1], SALT);
    hash_string(datahasher, Hash_Md5, gen_hash, charsmax(gen_hash));
    copy(read_hash, 32, data[last_scloc+1]);

    if(!equal(gen_hash, read_hash))
    {
        log("EzSck", fmt("[ERROR] HASH DIFER ^n^"%s^" != ^"%s^"", gen_hash, read_hash));
        return;
    }

    CallExFunc(socket, data, len);
}

public fw_sockClosed(SOCKET:socket, customID, error)
{
    //g_Sockets[int:socket] = false;
}

public fw_sockAccepted(SOCKET:socket, customID, SOCKET:cl_sock, const cl_ip[], cl_port)
{
    //g_Sockets[int:socket] = true;
}

stock cls_sck(SOCKET:socket)
{
    //g_Sockets[int:socket] = false;
    socket_close(SOCKET:socket);
}
