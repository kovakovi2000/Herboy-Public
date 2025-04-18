#include <amxmodx>

new g_File[32] = "addons/sm_ac/rec/resources.ini";
new g_Path[24] = "addons/sm_ac/rec/bases";
new g_PrecFile[32];
new Array:g_Files;

public plugin_precache()
{
	register_plugin("RC BaseChanger", "freesrv", "AMXX");
	
	new gfile[32], gfile_path[64], prec_buff[34], gfile_buff[34];
	new gdir = open_dir(g_Path, gfile, charsmax(gfile)), maxarr = 0;
	
	#if AMXX_VERSION_NUM < 183
	md5_file(g_File, prec_buff);
	#else
	hash_file(g_File, Hash_Md5, prec_buff, charsmax(prec_buff));
	#endif
	
	g_Files = ArrayCreate(32);
	
	do
	{
		if(strlen(gfile) > 3)
		{
			formatex(gfile_path, charsmax(gfile_path), "%s/%s", g_Path,gfile);
			
			#if AMXX_VERSION_NUM < 183
			md5_file(gfile_path, gfile_buff);
			#else
			hash_file(gfile_path, Hash_Md5, gfile_buff, charsmax(gfile_buff));
			#endif
			
			if(equal(prec_buff, gfile_buff))
				copy(g_PrecFile, charsmax(g_PrecFile), gfile);
			
			ArrayPushString(g_Files, gfile); maxarr += 1;
		}
	
	}
	
	while(next_file(gdir, gfile, charsmax(gfile)));
	close_dir(gdir);
	
	new listfile[128];
	format(listfile, charsmax(listfile), "addons/sm_ac/rec/baselist.txt");
	
	if(!file_exists(listfile))
	{
		write_file(listfile, g_PrecFile, 0);
		write_file(listfile, "0", 1);
	}
	
	new i, chk, lstfile[36], chkfile[36], arrfile[32], maxlst, len;

	for(i = 0 ; i < maxarr ; i++)
	{
		ArrayGetString(g_Files, i, arrfile, charsmax(arrfile));
		formatex(chkfile, charsmax(chkfile), "@%s", arrfile);
		chk = 0;
		
		new j; maxlst = file_size(listfile, 1);
		for(j = 2; j < maxlst - 1; j++)
		{
			read_file(listfile, j, lstfile, charsmax(lstfile), len);
			if (strfind(lstfile, chkfile) != -1)	chk += 1;
		}
		
		if(chk == 0)	
		{
			format(chkfile, charsmax(chkfile), "0%s", chkfile);
			write_file(listfile, chkfile, -1);
		}
	}
	
	new nextfile[32], setfile[32], pos;
	read_file(listfile, 0, nextfile, charsmax(nextfile), len);
	read_file(listfile, 1, setfile, charsmax(setfile), len);
	
	if(strlen(setfile) < 2)
	{
		if(maxlst > 3)
		{
			i = 0;
			for(i = 0; i < maxarr; i++)
			{
				ArrayGetString(g_Files, i, chkfile, charsmax(chkfile));
				if(strfind(nextfile, chkfile) != -1)
				{
					if (i == maxarr-1)	pos = 0;
					else				pos = i + 1;
				}
			}
			ArrayGetString(g_Files, pos, nextfile, charsmax(nextfile));
			log_amx("^tThe check is carried out on the database ^"%s^"", nextfile);
		}
		else	copy(nextfile, charsmax(nextfile), g_PrecFile);
		
		formatex(gfile_path, charsmax(gfile_path), "%s/%s", g_Path,nextfile);
		write_file(listfile, nextfile, 0);
	}
	else	formatex(gfile_path, charsmax(gfile_path), "%s/%s", g_Path,setfile);
	
	ArrayDestroy(g_Files);
	file_copy(gfile_path, g_File);
	//pause("ad");
}

stock bool:file_copy(SOURCE[], TARGET[]) 
{
	new source = fopen(SOURCE, "rb");
	new target = fopen(TARGET, "wb");
	
	for(new buffer, eof = feof(source); !eof; !eof && fputc(target, buffer))
	{
		buffer = fgetc(source);
		eof = feof(source);
	}
	
	fclose(source);
	fclose(target);
	
	return true;
}