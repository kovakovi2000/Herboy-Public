#if defined _manager_included
  #endinput
#endif

#define _manager_included
#include <sqlx>

enum _:ServerProperties
{
	server_id,
	server_port,
  sck_port_min,
	sck_port_max,
	server_type[15],
	server_database[15],
}

new const ServerMan[][ServerProperties] =
{
	{0, 00000, 30000, 30999, "", ""},
	{1, 27350, 31000, 31999, "FUN", "avatar"},
	{2, 27205, 32000, 32999, "Developer", "dev"},
	{3, 27295, 33000, 33999, "OnlyDust2", "s2_herboy"},
}

native m_get_server_id();
native m_get_sck_minport();
native m_get_sck_maxport();
native Handle:m_get_reg_sql();
native Handle:m_get_sql();

