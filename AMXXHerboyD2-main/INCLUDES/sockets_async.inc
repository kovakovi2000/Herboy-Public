#if defined _sockets_async_included
	#endinput
#endif
#define _sockets_async_included
 /*==================|
| Sockets Async 1.1b |
|==================*/
#pragma reqlib sockets_async
#pragma loadlib sockets_async


enum SOCKET: {}


enum {
    SOCK_TYPE_UDP=0,
    SOCK_TYPE_TCP,
    SOCK_TYPE_CHILD // Son los nuevos sockets que se crean al aceptar una conexion TCP
}

enum {
    SOCKET:SOCK_SEND_UDP,
    SOCKET:SOCK_LISTEN_UDP,
    SOCKET:SOCK_LISTEN_TCP,
    SOCKET:SOCK_UPLOAD,
    SOCKET:SOCK_DOWNLOAD,
    SOCK_CLIENT
}


native SOCKET:socket_create(type, customID)

native socket_lasterror()
native socket_getip(const hostname[], ip[], len)

native socket_close(SOCKET:socket)
native socket_bind(SOCKET:socket, const local_ip[]="", local_port)

native socket_get_custom(SOCKET:socket)
native socket_set_custom(SOCKET:socket, customID)

// TCP
native socket_connect(SOCKET:socket, const hostname[], port)
native socket_send(SOCKET:socket, const data[], sendsize=0)
native socket_recv(SOCKET:socket, data[], maxlen)

// UDP
native socket_sendto(SOCKET:socket, const ip[], port, const data[], sendsize=0)
native socket_recvfrom(SOCKET:socket, data[], maxlen, ip[], len, &port)

forward fw_sockConnected(SOCKET:socket, customID)
forward fw_sockClosed(SOCKET:socket, customID, error)
forward fw_sockAccepted(SOCKET:socket, customID, SOCKET:cl_sock, const cl_ip[], cl_port)
forward fw_sockReadable(SOCKET:socket, customID, type)
forward fw_sockWritable(SOCKET:socket, customID, type)