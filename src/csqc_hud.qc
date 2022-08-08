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

/*autocvars:
	cl_sbar: alternative layouts (sorry for this complication, but mneh).
		0: QuakeWorld style hud
		1: Vanilla style hud
		2: N64 / 2021 Rerelease style hud
	cl_hudswap: QW/n64 ammo+weapons are on the
		0: right
		1: left
	scr_sbaralpha: opacity of backgroundy elements
*/
 
// items. FIXME: you should share these with your ssqc...
float	IT_SHOTGUN				= 1<<0;
float	IT_SUPER_SHOTGUN		= 1<<1;
float	IT_NAILGUN				= 1<<2;
float	IT_SUPER_NAILGUN		= 1<<3;
float	IT_GRENADE_LAUNCHER		= 1<<4;
float	IT_ROCKET_LAUNCHER		= 1<<5;
float	IT_LIGHTNING			= 1<<6;

//float	IT_EXTRA_WEAPON			= 1<<7;

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

//ProQuake commands
float	PQC_NOP		    =	1;
float 	PQC_NEW_TEAM	=	2;
float	PQC_ERASE_TEAM	=	3;
float 	PQC_TEAM_FRAGS	=	4;
float	PQC_MATCH_TIME	=	5;
float 	PQC_MATCH_RESET	=	6;
float 	PQC_PING_TIMES	=	7;

float matchtime_minutes;
float matchtime_seconds;

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

static void(vector pos, float value, float threshhold, string justify) Hud_DrawLargeValue =
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
		pos_x -= 24*len;

	if (value <= threshhold)
	{
		//use alternate (red) numbers
		while(len>0)
		{
			len--;
			c = str2chr(s, len);
			drawpic(pos+[len*24,0], anumber[c-'0'], '24 24 0', '1 1 1', 1, 0);
		}
	}
	else
	{
		//use normal numbers
		while(len>0)
		{
			len--;
			c = str2chr(s, len);
			drawpic(pos+[len*24,0], number[c-'0'], '24 24 0', '1 1 1', 1, 0);
		}
	}
};

static void(float type, vector pos, float drawback, float weapnum = -1) Hud_DrawAmmoCount =
{
	// detect if this is weapon being used
	float is_active = 0;
	if (sweapon == (1<<weapnum)) is_active = 1;

	string s;
	float value;
	float len;
	float c;
	value = getstatf(STAT_SHELLS+type);
	if (value < 0)
		value = 0;	//hrm
	if (value>999)
		value = 999;
		
	if (drawback)
	{
		drawsubpic(pos, '42 11', "gfx/ibar", [(3.0/320)+type*(48.0/320), 0], [42.0/320, 11.0/24], '1 1 1', autocvar(scr_sbaralpha, 0.75), 0);
		pos_x += 8;
	}

	s = ftos(floor(value));
	len = strlen(s);

	pos_x += 8 * (3-len);
	while(len>0)
	{
		len--;
		c = str2chr(s, len);
		if (is_active)
			drawcharacter(pos+len*[8,0,0], (18-'0') + c, [8,8,0], [1,1,1], 1, 0);
		else
			drawcharacter(pos+len*[8,0,0], (18-'0') + c, [8,8,0], [1,1,1], .6, 0);
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

static void Hud_DrawSBar(vector pos, vector virtsize)
{
	if (autocvar(cl_sbar, 3))
		drawpic(pos, "gfx/sbar", '320 24 0', '1 1 1', autocvar(scr_sbaralpha, 0.75), 0);

	if (sitems & IT_INVULNERABILITY)
	{
		drawpic(pos, "gfx/disc", '24 24 0', '1 1 1', 1, 0);
		Hud_DrawLargeValue(pos+'24 0 0', 999, 25, "left");
	}
	else
	{
		Hud_DrawLargeValue(pos+'24 0 0', getstatf(STAT_ARMOR), 25, "left");
		if (sitems & IT_ARMOR3)
			drawpic(pos, "gfx/sb_armor3", '24 24 0', '1 1 1', 1, 0);
		else if (sitems & IT_ARMOR2)
			drawpic(pos, "gfx/sb_armor2", '24 24 0', '1 1 1', 1, 0);
		else if (sitems & IT_ARMOR1)
			drawpic(pos, "gfx/sb_armor1", '24 24 0', '1 1 1', 1, 0);
	}

	Hud_DrawFace(pos+'112 0 0');
	Hud_DrawLargeValue(pos+'136 0 0', shealth, 25, "left");

	if (sitems & IT_SHELLS)
		drawpic(pos+'224 0 0', "gfx/sb_shells", '24 24 0', '1 1 1', 1, 0);
	else if (sitems & IT_NAILS)
		drawpic(pos+'224 0 0', "gfx/sb_nails", '24 24 0', '1 1 1', 1, 0);
	else if (sitems & IT_ROCKETS)
		drawpic(pos+'224 0 0', "gfx/sb_rocket", '24 24 0', '1 1 1', 1, 0);
	else if (sitems & IT_CELLS)
		drawpic(pos+'224 0 0', "gfx/sb_cells", '24 24 0', '1 1 1', 1, 0);
	Hud_DrawLargeValue(pos+'248 0 0', getstatf(STAT_AMMO), 10, "left");
};

static void Hud_DrawSBar2021(vector virtsize)
{
	// edited from the above function to mimic the 2021 rerelease. -whipowill

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
	Hud_DrawLargeValue(pos+[picsize*1.5,0], shealth, 25, "left");

	if (sitems & (IT_INVULNERABILITY|IT_ARMOR1|IT_ARMOR2|IT_ARMOR3))
	{
		// draw armor picture
		pos -= [0,picsize+buffersize];
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
			Hud_DrawLargeValue(pos+[picsize*1.5,0], 999, 25, "left");
		else
			Hud_DrawLargeValue(pos+[picsize*1.5,0], getstatf(STAT_ARMOR), 25, "left");
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
	Hud_DrawLargeValue(pos-[(picsize*0.5),0], getstatf(STAT_AMMO), 10, "right");

	// display rune keys
	activebuttons = 0;
	pos = [virtsize_x-(picsize*2)+picsize, virtsize_y-(picsize*1.5)-(buffersize*2)-iconsize];

	if (sitems2 & IT2_RUNE4)
	{
		activebuttons++;
		drawpic(pos-[8*activebuttons,0], "gfx/sb_sigil4", '8 16 0', '1 1 1', 1, 0);
	}
	if (sitems2 & IT2_RUNE3)
	{
		activebuttons++;
		drawpic(pos-[8*activebuttons,0], "gfx/sb_sigil3", '8 16 0', '1 1 1', 1, 0);
	}
	if (sitems2 & IT2_RUNE2)
	{
		activebuttons++;
		drawpic(pos-[8*activebuttons,0], "gfx/sb_sigil2", '8 16 0', '1 1 1', 1, 0);
	}
	if (sitems2 & IT2_RUNE1)
	{
		activebuttons++;
		drawpic(pos-[8*activebuttons,0], "gfx/sb_sigil1", '8 16 0', '1 1 1', 1, 0);
	}

	// display icons
	activebuttons = 0;
	pos = [virtsize_x-(picsize*2)+picsize-iconsize, virtsize_y-(picsize*1.5)-(buffersize*2)];
	if (sitems2 & (IT2_RUNE1 || IT2_RUNE2 || IT2_RUNE3 || IT2_RUNE4))
	{
		activebuttons++;
		pos -= [0,buffersize];
	}

	if ((sitems & IT_KEY1))
	{
		activebuttons++;
		drawpic(pos-[0,((iconsize+buffersize)*activebuttons)-buffersize], "gfx/sb_key1", '16 16 0', '1 1 1', 1, 0);
	}
	if ((sitems & IT_KEY2))
	{
		activebuttons++;
		drawpic(pos-[0,((iconsize+buffersize)*activebuttons)-buffersize], "gfx/sb_key2", '16 16 0', '1 1 1', 1, 0);
	}
	if ((sitems & IT_INVISIBILITY))
	{
		activebuttons++;
		drawpic(pos-[0,((iconsize+buffersize)*activebuttons)-buffersize], "gfx/sb_invis", '16 16 0', '1 1 1', 1, 0);
	}
	if ((sitems & IT_INVULNERABILITY))
	{
		activebuttons++;
		drawpic(pos-[0,((iconsize+buffersize)*activebuttons)-buffersize], "gfx/sb_invuln", '16 16 0', '1 1 1', 1, 0);
	}
	if ((sitems & IT_SUIT))
	{
		activebuttons++;
		drawpic(pos-[0,((iconsize+buffersize)*activebuttons)-buffersize], "gfx/sb_suit", '16 16 0', '1 1 1', 1, 0);
	}
	if ((sitems & IT_QUAD))
	{
		activebuttons++;
		drawpic(pos-[0,((iconsize+buffersize)*activebuttons)-buffersize], "gfx/sb_quad", '16 16 0', '1 1 1', 1, 0);
	}
};

static void Hud_DrawIBar(vector pos, vector br)
{
	if (!autocvar(cl_sbar, 3))
	{
		//qw puts its ammo+weapons on the side. mimic that.
		vector pos2, pos3;
		const float hheight = (WEAPONICONS*16)+(11*4);
		pos2 = [0, br_y-48, 0];
		if (pos2_y < hheight)
			pos2_y = hheight;
		if (autocvar(cl_hudswap, 0))
			pos3 = pos2 + [0,-44];	//hudswap puts it on the left
		else
		{	//otherwise align to the right edge
			pos2_x += br_x-42;
			pos3 = pos2 + [42-24,-44];
		}
		pos3_y -= WEAPONICONS*16;
		Hud_DrawAmmoCount(0, pos2 + '0 -44', TRUE);
		Hud_DrawAmmoCount(1, pos2 + '0 -33', TRUE);
		Hud_DrawAmmoCount(2, pos2 + '0 -22', TRUE);
		Hud_DrawAmmoCount(3, pos2 + '0 -11', TRUE);
		if (sitems & IT_SHOTGUN)			Hud_DrawWeapon(0, pos3+[0,16*0]);
		if (sitems & IT_SUPER_SHOTGUN)		Hud_DrawWeapon(1, pos3+[0,16*1]);
		if (sitems & IT_NAILGUN)			Hud_DrawWeapon(2, pos3+[0,16*2]);
		if (sitems & IT_SUPER_NAILGUN)		Hud_DrawWeapon(3, pos3+[0,16*3]);
		if (sitems & IT_GRENADE_LAUNCHER)	Hud_DrawWeapon(4, pos3+[0,16*4]);
		if (sitems & IT_ROCKET_LAUNCHER)	Hud_DrawWeapon(5, pos3+[0,16*5]);
		if (sitems & IT_LIGHTNING)			Hud_DrawWeaponEx(6, flashtime[6], sweapon==IT_LIGHTNING, pos3+([0,16*6]), 24, LIGHTNING_WIDTH);
	}
	else
	{
		drawpic(pos, "gfx/ibar", '320 24 0', '1 1 1', autocvar(scr_sbaralpha, 0.75), 0);

		if (sitems & IT_SHOTGUN)			Hud_DrawWeapon(0, pos+[24*0,8]);
		if (sitems & IT_SUPER_SHOTGUN)		Hud_DrawWeapon(1, pos+[24*1,8]);
		if (sitems & IT_NAILGUN)			Hud_DrawWeapon(2, pos+[24*2,8]);
		if (sitems & IT_SUPER_NAILGUN)		Hud_DrawWeapon(3, pos+[24*3,8]);
		 if (sitems & IT_GRENADE_LAUNCHER)	Hud_DrawWeapon(4, pos+[24*4,8]);
		if (sitems & IT_ROCKET_LAUNCHER)	Hud_DrawWeapon(5, pos+[24*5,8]);
		if (sitems & IT_LIGHTNING)			Hud_DrawWeaponEx(6, flashtime[6], sweapon==IT_LIGHTNING, pos+([24*6,8]), LIGHTNING_WIDTH, LIGHTNING_WIDTH);

		Hud_DrawAmmoCount(0, pos + '10 0 0', FALSE);
		Hud_DrawAmmoCount(1, pos + '58 0 0', FALSE);
		Hud_DrawAmmoCount(2, pos + '106 0 0', FALSE);
		Hud_DrawAmmoCount(3, pos + '154 0 0', FALSE);
	}

	if (sitems & IT_KEY1)
		drawpic(pos+'192 8 0', "gfx/sb_key1", '16 16 0', '1 1 1', 1, 0);
	if (sitems & IT_KEY2)
		drawpic(pos+'208 8 0', "gfx/sb_key2", '16 16 0', '1 1 1', 1, 0);
	if (sitems & IT_INVISIBILITY)
		drawpic(pos+'224 8 0', "gfx/sb_invis", '16 16 0', '1 1 1', 1, 0);
	if (sitems & IT_INVULNERABILITY)
		drawpic(pos+'240 8 0', "gfx/sb_invuln", '16 16 0', '1 1 1', 1, 0);
	if (sitems & IT_SUIT)
		drawpic(pos+'256 8 0', "gfx/sb_suit", '16 16 0', '1 1 1', 1, 0);
	if (sitems & IT_QUAD)
		drawpic(pos+'272 8 0', "gfx/sb_quad", '16 16 0', '1 1 1', 1, 0);

	if (sitems2 & IT2_RUNE1)
		drawpic(pos+'288 8 0', "gfx/sb_sigil1", '8 16 0', '1 1 1', 1, 0);
	if (sitems2 & IT2_RUNE2)
		drawpic(pos+'296 8 0', "gfx/sb_sigil2", '8 16 0', '1 1 1', 1, 0);
	if (sitems2 & IT2_RUNE3)
		drawpic(pos+'304 8 0', "gfx/sb_sigil3", '8 16 0', '1 1 1', 1, 0);
	if (sitems2 & IT2_RUNE4)
		drawpic(pos+'312 8 0', "gfx/sb_sigil4", '8 16 0', '1 1 1', 1, 0);

	/*
	// this was a terrible feature and should never have been in the game at all. -whipowill
	if (deathmatch)
	{
		//should probably show team scores, but this mimics vanilla
		pos_x += 194;
		for (float i = -1; i >= -4; i--)
		{
			string frags = getplayerkeyvalue(i, "frags");
			if not (frags)
				break;
			vector top = stov(getplayerkeyvalue(i, "topcolor_rgb"));
			vector bot = stov(getplayerkeyvalue(i, "bottomcolor_rgb"));
			drawfill(pos+[0,1], [28,3], top, 0.75, 0);
			drawfill(pos+[0,4], [28,4], bot, 0.75, 0);
			drawstring(pos+[2,0], strpad(-3, frags), [8,8], [1,1,1],1,0);
			if (player_localentnum == stof(getplayerkeyvalue(i, "viewentity")))
			{
				drawcharacter(pos+[-4,0], 0xe010, [8,8], [1,1,1], 1, 0);
				drawcharacter(pos+[24,0], 0xe011, [8,8], [1,1,1], 1, 0);
			}
			pos_x += 8*4;
		}
	}
	*/
};

static void Hud_DrawIBar2021(vector virtsize)
{
	// for math
	float picsize = 24;
	float iconsize = 16;
	float buffersize = 2;
	float activebuttons;
	vector pos;

	// draw weapons
	pos = [virtsize_x-(picsize*2), 0+(picsize*1.5)];
	if (sitems & IT_SHOTGUN)
	{
		Hud_DrawAmmoCount(0, pos-[28,0]+[0,(activebuttons*16)+(buffersize*3)], FALSE, 0);
		Hud_DrawWeapon(0, pos+[0,(activebuttons*16)+buffersize]);
		activebuttons++;
	}
	if (sitems & IT_SUPER_SHOTGUN)
	{
		Hud_DrawAmmoCount(0, pos-[28,0]+[0,(activebuttons*16)+(buffersize*3)], FALSE, 1);
		Hud_DrawWeapon(1, pos+[0,(activebuttons*16)+buffersize]);
		activebuttons++;
	}
	if (sitems & IT_NAILGUN)
	{
		Hud_DrawAmmoCount(1, pos-[28,0]+[0,(activebuttons*16)+(buffersize*3)], FALSE, 2);
		Hud_DrawWeapon(2, pos+[0,(activebuttons*16)+buffersize]);
		activebuttons++;
	}
	if (sitems & IT_SUPER_NAILGUN)
	{
		Hud_DrawAmmoCount(1, pos-[28,0]+[0,(activebuttons*16)+(buffersize*3)], FALSE, 3);
		Hud_DrawWeapon(3, pos+[0,(activebuttons*16)+buffersize]);
		activebuttons++;
	}
	if (sitems & IT_GRENADE_LAUNCHER)
	{
		Hud_DrawAmmoCount(2, pos-[28,0]+[0,(activebuttons*16)+(buffersize*3)], FALSE, 4);
		Hud_DrawWeapon(4, pos+[0,(activebuttons*16)+buffersize]);
		activebuttons++;
	}
	if (sitems & IT_ROCKET_LAUNCHER)
	{
		Hud_DrawAmmoCount(2, pos-[28,0]+[0,(activebuttons*16)+(buffersize*3)], FALSE, 5);
		Hud_DrawWeapon(5, pos+[0,(activebuttons*16)+buffersize]);
		activebuttons++;
	}
	if (sitems & IT_LIGHTNING)
	{
		Hud_DrawAmmoCount(3, pos-[28,0]+[0,(activebuttons*16)+(buffersize*3)], FALSE, 6);
		Hud_DrawWeaponEx(6, flashtime[6], sweapon==IT_LIGHTNING, pos+[0,(activebuttons*16)+buffersize], 24, LIGHTNING_WIDTH);
		activebuttons++;
	}
};

static void(vector pos, string num) Hud_DrawMatchNumbers =
{
	float i;
	float c;
	local float a;

	a = autocvar(hud_matchtime_alpha, 1);

	for(i = 0; ; i++, pos_x += 24)
	{
		c = str2chr(num, i);
		if (!c)
			break;
		if (c == ' ')
			continue;
		if (c == '/')
			drawpic(pos, "gfx/num_slash", ([24,24]),([1,0,0]),a,0);
		else if (c == ':' || c == '.')
			drawpic(pos, "gfx/num_colon", ([24,24]),([1,0,0]),a,0);
		else if (c == '-')
			drawpic(pos, "gfx/anum_minus", ([24,24]),([1,1,1]),a,0);
		else if (c >= '0' && c <= '9')
			drawpic(pos, anumber[c-'0'], ([24,24]),([1,1,1]),a,0);
	}
};

void() Hud_DrawMatchTime =
{
	vector pos;

	pos_x = autocvar(hud_matchtime_x, 10);
	pos_y = autocvar(hud_matchtime_y, 10);

	Hud_DrawMatchNumbers(pos+([0, 0]), sprintf("%2.0f:%02.0f", matchtime_minutes, matchtime_seconds));
}

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
			Hud_CoopScores_SBar(pos - '0 24 0');
		else
		{
			// if cl_sbar=0-1
			if (autocvar(cl_sbar, 3) <= 1)
				Hud_DrawSBar(pos - '0 24 0', virtsize);
			else
				Hud_DrawSBar2021(virtsize);
		}

		if (autocvar(viewsize, 100) < 110)
			if (autocvar(cl_sbar, 3) <= 1)
				Hud_DrawIBar(pos - '0 48 0', virtsize);
			else
				Hud_DrawIBar2021(virtsize);
	}

	//if (autocvar(hud_matchtimer, 1))
		//Hud_DrawMatchTime(virtsize);//todo add virtsize here too
};

void () CSQC_Parse_Event =
{
	local float ev;

	ev = readbyte();

	switch (ev)
	{
		/*
		case PQC_MATCH_TIME:
			matchtime_minutes = readbyte();
			matchtime_seconds = readbyte();
			break;

		case PQC_NEW_TEAM:
			team = readbyte();
			if (team < 0 || team > 15) return;
			cl_teamscores[team].bottomcolor = teamcolor[team];		//save out the rgb values for team number
			cl_teamscores[team].frags = 0;
			break;

		case PQC_ERASE_TEAM:
			team = readbyte();
			if (team < 0 || team > 15) return;
			cl_teamscores[team].bottomcolor = "0 0 0";
			cl_teamscores[team].frags = 0;
			break;

		case PQC_TEAM_OVERLAY:
			local float teammate;
			teammate = readbyte();
			if ((teamate <= 0)||(teammate > 8)) return;//FIXME: SV_MAXPLAYERS
			cl_teamoverlay[teammate].health = readshort();
			cl_teamoverlay[teammate].armor = readshort();
			cl_teamoverlay[teammate].weapon = readshort();
			cl_teamoverlay[teammate].ammo = readshort();
			cl_teamoverlay[teammate].powerup = readshort();
			break;			

		case PQC_TEAM_FRAGS:
			local float frags;
			team = readbyte();
			if (team < 0 || team > 15) return;
			frags = readshort();
			cl_teamscores[team].frags = frags;
			break;			
			
		case PQC_MATCH_RESET:
			local float i;
			for (i = 0 ; i < 14 ; i++)
			{				
				cl_teamscores[i].bottomcolor = "0 0 0";
				cl_teamscores[i].frags = 0;
			}
			break;
		*/
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