//	This file implements NQ, QW, and N64-style huds in csqc. Its meant to be complete, while not otherwise being that different.
//	The hud layout+items used are specific to vanilla Quake. For the mission packs, you should use the appropriate alternative huds.
//	
//	The entry points are at the bottom of the file.
//	You can just add this file (and fteextensions.qc or qsextensions.qc) into any mod and then just adapt it as desired.
//
//	Note that it doesn't understand viewsizes all that well, but no worse than eg scr_sbaralpha<1 in QS (its default). (this keeps the api spec simpler.)
//	the 'simple csqc' api means that this file (and api defs) is all you need for a hud, and can be directly embedded into a regular nq progs.dat, if needed.
//
//	I have made attempts to avoid copying the engine code, however I will not be held liable if there's any GPL contagion.
//	There is otherwise no license for the code in this file.
 
// items. FIXME: you should share these with your ssqc...
float	IT_SHOTGUN				= 1<<0;
float	IT_SUPER_SHOTGUN		= 1<<1;
float	IT_NAILGUN				= 1<<2;
float	IT_SUPER_NAILGUN		= 1<<3;
float	IT_GRENADE_LAUNCHER		= 1<<4;
float	IT_ROCKET_LAUNCHER		= 1<<5;
float	IT_LIGHTNING			= 1<<6;

//float	IT_EXTRA_WEAPON			= 1<<7;

// =================================================

// my client vars (33-63) -whipowill
const float IT_GRENADES = 33;

// my global vars (128-255) -whipowill
const float GAME_SCARLET = 128;
const float GAME_TEAMPLAY = 129;
const float GAME_GRENADES = 130;
const float SCORE_DEATHS = 131; // 32 slots

// =================================================

float	IT_SHELLS				= 1<<8;
float	IT_NAILS				= 1<<9;
float	IT_ROCKETS				= 1<<10;
float	IT_CELLS				= 1<<11;
float	IT_AXE					= 1<<12;

float	IT_ARMOR1				= 1<<13;
float	IT_ARMOR2				= 1<<14;
float	IT_ARMOR3				= 1<<15;
//float	IT_SUPERHEALTH			= 1<<16;

float	IT_KEY1					= 1<<17;
float	IT_KEY2					= 1<<18;
float	IT_INVISIBILITY			= 1<<19;
float	IT_INVULNERABILITY		= 1<<20;
float	IT_SUIT					= 1<<21;
float	IT_QUAD					= 1<<22;

float 	IT2_RUNE1				= 1<<5;
float 	IT2_RUNE2				= 1<<6;
float 	IT2_RUNE3				= 1<<7;
float 	IT2_RUNE4				= 1<<8;

// wad image names in array form, for easier access.
static string number[10] = {
	"gfx/num_0",
	"gfx/num_1",
	"gfx/num_2",
	"gfx/num_3",
	"gfx/num_4",
	"gfx/num_5",
	"gfx/num_6",
	"gfx/num_7",
	"gfx/num_8",
	"gfx/num_9"
};
static string anumber[10] = {
	"gfx/anum_0",
	"gfx/anum_1",
	"gfx/anum_2",
	"gfx/anum_3",
	"gfx/anum_4",
	"gfx/anum_5",
	"gfx/anum_6",
	"gfx/anum_7",
	"gfx/anum_8",
	"gfx/anum_9"
};
static string weaponnames[] = {
	"shotgun",
	"sshotgun",
	"nailgun",
	"snailgun",
	"rlaunch",
	"srlaunch",
	"lightng",
#define WEAPONICONS 7
#define LIGHTNING_WIDTH 48
};
static string facetab[] = {
	"gfx/face5", "gfx/face4", "gfx/face3", "gfx/face2", "gfx/face1",
	"gfx/face_p5", "gfx/face_p4", "gfx/face_p3", "gfx/face_p2", "gfx/face_p1",
	"gfx/face_inv2", "gfx/face_quad", "gfx/face_invis", "gfx/face_invul2"
};

// copies of stats, for easier access
static float sitems;		//copy of .items
static float sitems2;		//copy of .items2 (or serverflags)
static float sweapon;		//copy of .weapon
static float shealth;		//copy of .health

static float flashtime[WEAPONICONS]; //tracks the time that various items were obtained, so we can flash stuff accordingly.
static float painfinishtime; //tracks when we took damage, for flinching.

// registers the various pics so they're ready as needed.
static void() Hud_Init
{
	float i;
	precache_pic("gfx/sbar", TRUE);
	precache_pic("gfx/ibar", TRUE);
	for (i = 0; i < 10; i++)
	{
		precache_pic(number[i], TRUE);
		precache_pic(anumber[i], TRUE);
	}

	precache_pic("gfx/sb_armor1", TRUE);
	precache_pic("gfx/sb_armor2", TRUE);
	precache_pic("gfx/sb_armor3", TRUE);
	precache_pic("gfx/disc", TRUE);

	precache_pic("gfx/sb_shells", TRUE);
	precache_pic("gfx/sb_nails", TRUE);
	precache_pic("gfx/sb_rocket", TRUE);
	precache_pic("gfx/sb_cells", TRUE);

	precache_pic("gfx/sb_key1", TRUE);
	precache_pic("gfx/sb_key2", TRUE);
	precache_pic("gfx/sb_invis", TRUE);
	precache_pic("gfx/sb_invuln", TRUE);
	precache_pic("gfx/sb_suit", TRUE);
	precache_pic("gfx/sb_quad", TRUE);
	
	precache_pic("gfx/sb_sigil1", TRUE);
	precache_pic("gfx/sb_sigil2", TRUE);
	precache_pic("gfx/sb_sigil3", TRUE);
	precache_pic("gfx/sb_sigil4", TRUE);

	precache_pic("gfx/num_colon", TRUE);//R00k needed for matchtime
	
	for (i = 0; i < weaponnames.length; i++)
	{
		precache_pic(strcat("gfx/inv_", weaponnames[i]), TRUE);
		precache_pic(strcat("gfx/inv2_", weaponnames[i]), TRUE);
		precache_pic(strcat("gfx/inva1_", weaponnames[i]), TRUE);
		precache_pic(strcat("gfx/inva2_", weaponnames[i]), TRUE);
		precache_pic(strcat("gfx/inva3_", weaponnames[i]), TRUE);
		precache_pic(strcat("gfx/inva4_", weaponnames[i]), TRUE);
		precache_pic(strcat("gfx/inva5_", weaponnames[i]), TRUE);
	}
	for (i = 0; i < facetab.length; i++)
		precache_pic(facetab[i], TRUE);
};

static void(vector pos, float value, float threshhold, string justify, float size) Hud_DrawLargeValue =
{
	float c;
	float len;
	string s;
	if (value < 0)
		value = 0;
	if (value>999)
		value = 999;

	s = ftos(floor(value));
	len = strlen(s);

	if (justify == "right")
		pos_x -= size*len;

	local vector dimensions;
	if (size >= 24)
	{
		size = 24;
		dimensions = '24 24 0';
	}
	else
	{
		size = 16;
		dimensions = '16 16 0';
	}

	if (value <= 3) // used to use "threshhold"
	{
		//use alternate (red) numbers
		while(len>0)
		{
			len--;
			c = str2chr(s, len);
			drawpic(pos+[len*size,0], anumber[c-'0'], dimensions, '1 1 1', 1, 0);
		}
	}
	else
	{
		//use normal numbers
		while(len>0)
		{
			len--;
			c = str2chr(s, len);
			drawpic(pos+[len*size,0], number[c-'0'], dimensions, '1 1 1', 1, 0);
		}
	}
};

static void(float type, vector pos) Hud_DrawAmmoCount =
{
	string s;
	float value;
	float len;
	float c;
	string pic;

	if (type == 4) // I added this to the game! -whipowill
	{
		local float is_grenades = getstatf(GAME_GRENADES);
		local float is_grenades_manual = autocvar(cl_grenades, 0);
		if (!is_grenades && !is_grenades_manual) return;

		value = getstatf(IT_GRENADES);

		if (!value) return;
	}
	else
	{
		value = getstatf(STAT_SHELLS+type);
		if (value < 0)
			value = 0;
		if (value>999)
			value = 999;
	}

	if (type == 0) pic = "gfx/sb_shells";
	else if (type == 1) pic = "gfx/sb_nails";
	else if (type == 2) pic = "gfx/sb_rocket";
	else if (type == 3) pic = "gfx/sb_cells";
	else if (type == 4) pic = "gfx/disc"; // I added this to the game! -whipowill

	drawpic(pos, pic, '16 16 0', '1 1 1', 1, 0);

	s = ftos(floor(value));
	len = strlen(s);

	pos += [-6,4];

	pos_x -= 8*len; // right justify the numbers
	while(len>0)
	{
		len--;
		c = str2chr(s, len);

		// https://quakewiki.org/w/images/1/1b/Quakefont.gif

		if (value > 0)
			drawcharacter(pos+len*[8,0,0], (18-'0') + c, [8,8,0], [1,1,1], .7, 0);
		else
			drawcharacter(pos+len*[8,0,0], 142, [8,8,0], [1,1,1], .7, 0);
	}
};

static void(float num, vector pos) Hud_DrawWeapon =
{
	string prefix;
	float flash = (time - flashtime[num])*10;
	if (flash >= 10)
	{
		if (sweapon == (1<<num))
			prefix = "gfx/inv2_";
		else
			prefix = "gfx/inv_";
	}
	else
	{
		static string tab[] = {"gfx/inva1_","gfx/inva2_","gfx/inva3_","gfx/inva4_","gfx/inva5_"};
		if (flash >= 5)
			flash -= 5;
		prefix = tab[flash];
	}

	drawpic(pos, strcat(prefix, weaponnames[num]), '24 16 0', '1 1 1', 1, 0);
};

static void(float num, float lflashtime, float iscurrent, vector pos, float drawwidth, float imgwidth) Hud_DrawWeaponEx =
{
	string prefix;
	float flash = (time - lflashtime)*10;
	if (flash >= 10)
	{
		if (iscurrent)
			prefix = "gfx/inv2_";
		else
			prefix = "gfx/inv_";
	}
	else
	{
		static string tab[] = {"gfx/inva1_","gfx/inva2_","gfx/inva3_","gfx/inva4_","gfx/inva5_"};
		if (flash >= 5)
			flash -= 5;
		prefix = tab[flash];
	}
	drawsubpic(pos, [drawwidth, 16], strcat(prefix, weaponnames[num]), '0 0 0', [drawwidth/imgwidth, 1], '1 1 1', 1, 0);
};

static string(float f, float chars, string lead) FormatFloat
{
	string s = ftos(f);
	if (f < 10 && chars >= 3)
		s = strcat(lead, lead, s);
	else if (f < 10 && chars == 2)
		s = strcat(lead, s);
	else if (f < 100 && chars >= 3)
		s = strcat(lead, s);
	return s;
};

static void(vector pos) Hud_CoopScores_SBar =
{
	string s;
	float nsecs;
	float nmins;
	vector sbar = pos;
	drawpic(sbar, "gfx/scorebar", '320 24 0', '1 1 1', autocvar(scr_sbaralpha, 0.75), 0);

	s = strcat("Monsters:", FormatFloat(getstatf(STAT_KILLEDMONSTERS), 3, " "), "/", FormatFloat(getstatf(STAT_TOTALMONSTERS), 3, " "));
	drawstring(sbar + '8 4', s, '8 8 0', '1 1 1', 1, 0);
	s = strcat("Secrets :", FormatFloat(getstatf(STAT_FOUNDSECRETS), 3, " "), "/", FormatFloat(getstatf(STAT_TOTALSECRETS), 3, " "));
	drawstring(sbar + '8 12', s, '8 8 0', '1 1 1', 1, 0);

	nmins = floor(time/60);
	nsecs = floor(time - nmins*60);
	s = strcat("Time :", FormatFloat(nmins, 3, " "), ":", FormatFloat(nsecs, 2, "0"));
	drawstring(sbar + '184 4', s, '8 8 0', '1 1 1', 1, 0);

	drawstring(sbar + '232 12' - strlen(world.message)*'4 0', world.message, '8 8 0', '1 1 1', 1, 0);
};

static void Hud_PicOrModel(vector topleft, string pic, string showmodel, float showskin, float speed)
{
	drawpic(topleft, pic, '24 24 0', '1 1 1', 1, 0);
};

static void Hud_DrawFace(vector pos)
{
	string face;
	if (sitems & IT_INVISIBILITY)
	{	//invis can go first, because its the most obvious image difference.
		if (sitems & IT_INVULNERABILITY)
			face = facetab[10];	//special double-powerup image!
		else
			face = facetab[12];
	}
	else if (sitems & IT_QUAD)
		face = facetab[11];
	else if (sitems & IT_INVULNERABILITY)
		face = facetab[13];
	else
	{
		float frame = shealth/20;
		if (frame < 0)
			frame = 0;
		else if (frame > 4)
			frame = 4;
		if (painfinishtime > time)
			frame += 5;	//pain.
		face = facetab[frame];
	}
	
	if (shealth > 100)
		Hud_PicOrModel(pos, face, "maps/b_bh100.bsp", 0, -90);
	else if (shealth > 50)
		Hud_PicOrModel(pos, face, "maps/b_bh25.bsp", 0, -90);
	else
		Hud_PicOrModel(pos, face, "maps/b_bh10.bsp", 0, -90);
};

static void Hud_DrawSBar(vector virtsize)
{
	// edited from the above function to mimic the 2021 rerelease. -whipowill

	float test = autocvar(cl_hudtest, 0);

	// for math
	float picsize = 24;
	float iconsize = 16;
	float buffersize = 2;
	float activebuttons;
	vector pos;

	// draw face
	pos = [picsize, virtsize_y-(picsize*1.5)];
	Hud_DrawFace(pos);

	// draw health numbers
	Hud_DrawLargeValue(pos+[picsize*1.5,0], shealth, 25, "left", 24);

	if (sitems & (IT_INVULNERABILITY|IT_ARMOR1|IT_ARMOR2|IT_ARMOR3))
	{
		// draw armor picture
		pos -= [0,picsize+(buffersize*2)];
		if (sitems & IT_INVULNERABILITY)
			Hud_PicOrModel(pos, "gfx/disc", "progs/invulner.mdl", 0, 70);
		else if (sitems & IT_ARMOR3)
			Hud_PicOrModel(pos, "gfx/sb_armor3", "progs/armor.mdl", 2, 70);
		else if (sitems & IT_ARMOR2)
			Hud_PicOrModel(pos, "gfx/sb_armor2", "progs/armor.mdl", 1, 70);
		else if (sitems & IT_ARMOR1)
			Hud_PicOrModel(pos, "gfx/sb_armor1", "progs/armor.mdl", 0, 70);

		// draw armor numbers
		if (sitems & IT_INVULNERABILITY)
			Hud_DrawLargeValue(pos+[picsize*1.5,0], 999, 25, "left", 24);
		else
			Hud_DrawLargeValue(pos+[picsize*1.5,0], getstatf(STAT_ARMOR), 25, "left", 24);
	}

	// draw ammo picture
	pos = [virtsize_x-(picsize*2), virtsize_y-(picsize*1.5)];
	if (sitems & IT_SHELLS)
		Hud_PicOrModel(pos, "gfx/sb_shells", "maps/b_shell1.bsp", 0, 80);
	else if (sitems & IT_NAILS)
		Hud_PicOrModel(pos, "gfx/sb_nails", "maps/b_nail1.bsp", 0, 80);
	else if (sitems & IT_ROCKETS)
		Hud_PicOrModel(pos, "gfx/sb_rocket", "maps/b_rock1.bsp", 0, 80);
	else if (sitems & IT_CELLS)
		Hud_PicOrModel(pos, "gfx/sb_cells", "maps/b_batt1.bsp", 0, 80);

	// draw ammo numbers
	Hud_DrawLargeValue(pos-[(picsize*0.5),0], getstatf(STAT_AMMO), 10, "right", 24);

	// display rune keys
	activebuttons = 0;
	pos = [virtsize_x-(picsize*2)+picsize, virtsize_y-(picsize*1.5)-(buffersize*2)-iconsize];
	if ((sitems2 & IT2_RUNE4) || test)
	{
		activebuttons++;
		drawpic(pos-[8*activebuttons,0], "gfx/sb_sigil4", '8 16 0', '1 1 1', 1, 0);
	}
	if ((sitems2 & IT2_RUNE3) || test)
	{
		activebuttons++;
		drawpic(pos-[8*activebuttons,0], "gfx/sb_sigil3", '8 16 0', '1 1 1', 1, 0);
	}
	if ((sitems2 & IT2_RUNE2) || test)
	{
		activebuttons++;
		drawpic(pos-[8*activebuttons,0], "gfx/sb_sigil2", '8 16 0', '1 1 1', 1, 0);
	}
	if ((sitems2 & IT2_RUNE1) || test)
	{
		activebuttons++;
		drawpic(pos-[8*activebuttons,0], "gfx/sb_sigil1", '8 16 0', '1 1 1', 1, 0);
	}

	local float hasrunes = (activebuttons > 0) ? 1 : 0;

	// display powerups
	activebuttons = hasrunes ? 1 : 0;
	pos = [virtsize_x-(picsize*2)+picsize-iconsize, virtsize_y-(picsize*1.5)-(buffersize*4)];
	if ((sitems & IT_KEY1) || test)
	{
		activebuttons++;
		drawpic(pos-[0,((iconsize+buffersize)*activebuttons)-buffersize], "gfx/sb_key1", '16 16 0', '1 1 1', 1, 0);
	}
	if ((sitems & IT_KEY2) || test)
	{
		activebuttons++;
		drawpic(pos-[0,((iconsize+buffersize)*activebuttons)-buffersize], "gfx/sb_key2", '16 16 0', '1 1 1', 1, 0);
	}
	if ((sitems & IT_INVISIBILITY) || test)
	{
		activebuttons++;
		drawpic(pos-[0,((iconsize+buffersize)*activebuttons)-buffersize], "gfx/sb_invis", '16 16 0', '1 1 1', 1, 0);
	}
	if ((sitems & IT_INVULNERABILITY) || test)
	{
		activebuttons++;
		drawpic(pos-[0,((iconsize+buffersize)*activebuttons)-buffersize], "gfx/sb_invuln", '16 16 0', '1 1 1', 1, 0);
	}
	if ((sitems & IT_SUIT) || test)
	{
		activebuttons++;
		drawpic(pos-[0,((iconsize+buffersize)*activebuttons)-buffersize], "gfx/sb_suit", '16 16 0', '1 1 1', 1, 0);
	}
	if ((sitems & IT_QUAD) || test)
	{
		activebuttons++;
		drawpic(pos-[0,((iconsize+buffersize)*activebuttons)-buffersize], "gfx/sb_quad", '16 16 0', '1 1 1', 1, 0);
	}

	/*
	// draw grenades
	local float is_grenades = getstatf(GAME_GRENADES);
	if (!is_grenades) return;
	{
		pos = [virtsize_x-picsize, picsize/2];
		Hud_DrawLargeValue(pos, getstatf(IT_GRENADES), 0, "right", 16);
	}
	*/
};

static void Hud_DrawIBar(vector virtsize)
{
	// for math
	float picsize = 24;
	float iconsize = 16;
	float buffersize = 2;
	float activebuttons;
	vector pos;

	pos = [virtsize_x-picsize, picsize/2];

	// make room for grenades space
	//pos += [0, (buffersize*2)];

	// draw ammo
	pos -= [iconsize, 0];
	Hud_DrawAmmoCount(0, pos+[0, (iconsize+buffersize)*0]);
	Hud_DrawAmmoCount(1, pos+[0, (iconsize+buffersize)*1]);
	Hud_DrawAmmoCount(2, pos+[0, (iconsize+buffersize)*2]);
	Hud_DrawAmmoCount(3, pos+[0, (iconsize+buffersize)*3]);
	Hud_DrawAmmoCount(4, pos+[0, (iconsize+buffersize)*4]); // hand grenades

	if (autocvar(cl_weapons, 0))
	{
		// draw weapons
		pos = [virtsize_x-(picsize*2), 0+(picsize*.5)+((iconsize+buffersize)*6)];
		if (sitems & IT_SHOTGUN)
		{
			Hud_DrawWeapon(0, pos+[0,(activebuttons*16)+buffersize]);
			activebuttons++;
		}
		if (sitems & IT_SUPER_SHOTGUN)
		{
			Hud_DrawWeapon(1, pos+[0,(activebuttons*16)+buffersize]);
			activebuttons++;
		}
		if (sitems & IT_NAILGUN)
		{
			Hud_DrawWeapon(2, pos+[0,(activebuttons*16)+buffersize]);
			activebuttons++;
		}
		if (sitems & IT_SUPER_NAILGUN)
		{
			Hud_DrawWeapon(3, pos+[0,(activebuttons*16)+buffersize]);
			activebuttons++;
		}
		if (sitems & IT_GRENADE_LAUNCHER)
		{
			Hud_DrawWeapon(4, pos+[0,(activebuttons*16)+buffersize]);
			activebuttons++;
		}
		if (sitems & IT_ROCKET_LAUNCHER)
		{
			Hud_DrawWeapon(5, pos+[0,(activebuttons*16)+buffersize]);
			activebuttons++;
		}
		if (sitems & IT_LIGHTNING)
		{
			Hud_DrawWeaponEx(6, flashtime[6], sweapon==IT_LIGHTNING, pos+[0,(activebuttons*16)+buffersize], 24, LIGHTNING_WIDTH);
			activebuttons++;
		}
	}
};

float numclientseats;
static void Hud_Draw(vector virtsize, float scoreboard)
{
	vector pos;
	float oitems = sitems;
	float oitems2 = sitems2;
	float ohealth = shealth;

	pos_x = (virtsize_x-320)/2;
	pos_y = virtsize_y;

	sitems 	= getstatbits(STAT_ITEMS, 0, 23);	//note that we could use getstati to read the items stat, but it'd degrade when then cast to a float, and QSS+DP don't support ints, so we have to use two floats. 
	sitems2 = getstatbits(STAT_ITEMS, 23, 9);
	sweapon = getstatf(STAT_ACTIVEWEAPON);
	shealth = getstatf(STAT_HEALTH);

	//note that ssqc can provide custom stats, eg: clientstat(STAT_USER+n, EV_FLOAT, items3); can then be read by us with float items3 = getstatf(STAT_USER+n);
	
	if (shealth <= 0)
		scoreboard = TRUE;

	if (numclientseats <= 1)
	{
		//note that we only track one player's stats. with splitscreen we need to stop looking for changes otherwise we'd see them all the time.
		if (ohealth && sitems != oitems)
		{
			for (float f = 0; f < 7; f++)
			{
				if ((sitems & (1<<f)) && !(oitems & (1<<f)))
					flashtime[f] = time;
			}
		}
	}

	if (autocvar(viewsize, 100) < 120)
	{
		if (scoreboard)
		{
			Hud_CoopScores_SBar(pos - '0 24 0');
		}
		else
		{
			Hud_DrawSBar(virtsize);
			if (autocvar(viewsize, 100) < 110)
				Hud_DrawIBar(virtsize);
		}
	}
};

void () CSQC_Parse_Event =
{
	local float ev;

	ev = readbyte();

	switch (ev)
	{
		//case PQC_MATCH_TIME:
			//matchtime_minutes = readbyte();
			//matchtime_seconds = readbyte();
			//break;
	}
}

//lame entry point, just so that we know when damage was taken
float(float save, float take, vector dir) CSQC_Parse_Damage =
{
	if (numclientseats <= 1)
		painfinishtime = time + 0.2;
	return FALSE;	//let the engine handle any red tints etc
};

//Hud entry point!
//showscores is set if +scores is held (check health yourself).
void(vector virtsize, float showscores) CSQC_DrawHud =
{
	Hud_Draw(virtsize, showscores);
};

void(float apilevel, string enginename, float engineversion) CSQC_Init =
{
	Hud_Init();
};