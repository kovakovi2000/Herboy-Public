#include <amxmodx>
#include <cstrike>
#include <fakemeta>
#include <hamsandwich>
#include <engine>
#include <sqlx>
#include <manager>

new s_id = 0;

new Handle:sql_handler
new Handle:sql_handler_reg

public plugin_init()
{
  register_plugin("[sMod] ~ Server Manager", "v1.0", "shedi")
}
public plugin_cfg()
{
  new ServerIP[33]
  get_user_ip(0, ServerIP, 33, 0);
  console_print(0, ServerIP)
  
  if(equal(ServerIP, "37.221.212.11:27350") || equal(ServerIP, "37.221.209.130:27350"))
    s_id = 1;
  else if(equal(ServerIP, "37.221.212.11:27777") || equal(ServerIP, "37.221.212.11:27205"))
    s_id = 2;
  else if(equal(ServerIP, "37.221.212.11:27015") || equal(ServerIP, "37.221.212.11:27222")) 
    s_id = 3;
  else set_fail_state("[Server Manager] ~ Manager has got server switch problem, shutting down....");

  console_print(0, "************************************************ ")
  if(s_id == 1)
    sql_handler_reg = SQL_MakeDbTuple("37.221.212.11", "shedi", "aFpuRt3EQcfXBGW6hn8JMj", "s2_herboy");
  else
    sql_handler_reg = SQL_MakeDbTuple("127.0.0.1", "servers", "y5U87fYgnXDwsQe2TpJcMu", "s2_herboy");
  console_print(0, "[Server Manager] ~ RegSystem Handler created! (Tuple: %i)", int:sql_handler_reg);

  if(s_id == 1)
  {
    sql_handler = SQL_MakeDbTuple("37.221.212.11", "shedi", "aFpuRt3EQcfXBGW6hn8JMj", ServerMan[s_id][server_database]);
  }
  else
  {
    if(s_id == 3)
      sql_handler = SQL_MakeDbTuple("127.0.0.1", "servers", "y5U87fYgnXDwsQe2TpJcMu", ServerMan[s_id][server_database]);
    else
      sql_handler = SQL_MakeDbTuple("127.0.0.1", "servers", "y5U87fYgnXDwsQe2TpJcMu", ServerMan[s_id][server_database]);
  }


  console_print(0, "[Server Manager] ~ Main Handler created! (Tuple: %i)", int:sql_handler);
  
  console_print(0, "[Server Manager] ~ Server: %s inited as #%i", ServerMan[s_id][server_type], s_id);
  SQL_SetAffinity("mysql");
  SQL_SetCharset(sql_handler, "utf8");
  SQL_SetCharset(sql_handler_reg, "utf8");
  console_print(0, "************************************************")
}
public plugin_natives()
{
  register_native("m_get_server_id","native_manager_get_serverid", 1);
  register_native("m_get_sck_minport","native_manager_get_sck_minport", 1);
  register_native("m_get_sck_maxport","native_manager_get_sck_maxport", 1);
  register_native("m_get_reg_sql","native_manager_get_reg_sql", 1);
  register_native("m_get_sql","native_manager_get_sql", 1);
}
public native_manager_get_serverid()
{
	return s_id;
}
public native_manager_get_sck_minport()
{
	return ServerMan[s_id][sck_port_min];
}
public native_manager_get_sck_maxport()
{
	return ServerMan[s_id][sck_port_max];
}
public native_manager_get_reg_sql()
{
	return int:sql_handler_reg;
}
public native_manager_get_sql()
{
	return int:sql_handler;
}
public plugin_end()
{
  SQL_FreeHandle(sql_handler_reg);
  SQL_FreeHandle(sql_handler);
}