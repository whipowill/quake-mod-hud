typedef struct
{
	float is_team;
	string bottomcolor;
	float frags;
	string teamname;
} teamscores_t;
teamscores_t cl_teamscores[14];
teamscores_t cl_teamscores_ranked[4];

static string teamcolor[14] =
{
	"0.48 0.48 0.48",	// 0 Newspaper
	"0.33 0.23 0.11",  	// 1 Brown
	"0.31 0.31 0.45",	// 2 Light Blue
	"0.22 0.22 0.03",	// 3 Green
	"0.27 0.00 0.00",	// 4 Red
	"0.37 0.28 0.04",	// 5 Mustard
	"0.56 0.26 0.20",	// 6 Clay
	"0.50 0.33 0.23",	// 7 Flesh
	"0.34 0.21 0.26",	// 8 Lavendar
	"0.37 0.20 0.23",	// 9 Grape
	"0.42 0.34 0.28",	// 10 Biege
	"0.18 0.26 0.22",	// 11 Aqua
	"0.49 0.39 0.03",	// 12 Lemon
	"0.18 0.18 0.49"	// 13 Blue
};
/*
static string teamname[14] =
{
	"White",
	"Brown",
	"Sky Blue",
	"Green",
	"Red",
	"Mustard",
	"Orange",
	"Salmon",
	"Purple",
	"Pink",
	"Vanilla",
	"Aqua",
	"Yellow",
	"Blue"
};
*/

// happy little color names
static string teamname[14] =
{
	"Titanium White",
	"Van Dyke Brown",
	"Mountain Mixture",
	"Sap Green",
	"Alizarin Crimson",
	"Yellow Ochre",
	"Cadmium Orange",
	"Flower Pink",
	"Magenta Mauve",
	"Dusty Rose",
	"Dark Sienna",
	"Phthalo Green",
	"Indian Yellow",
	"Prussian Blue",
};

vector(string picname, float height) Hud_AspectSize =
{
	vector sz = drawgetimagesize(picname);
	return [sz_x * height/sz_y, height];
};

void(string picname, float screenwidth, vector pos, float height) Hud_CentrePic =
{
	vector sz = Hud_AspectSize(picname, height);
	pos_x += (screenwidth-sz_x)/2;
	drawpic(pos, picname, sz, [1,1,1],1,0);
};

void(vector virtmin, vector virtsize) Hud_DeathmatchScoreboard =
{
	vector pos = virtmin;
	if not (getplayerkeyvalue(-16, "name"))
		pos_y += (virtsize_y-200)/2;

	if not (getplayerkeyvalue(-24, "name"))
	{
		//and only draw the header when its not a really big game
		pos_y += 8;
		Hud_CentrePic("gfx/ranking.lmp", virtsize_x, pos, 24);	pos_y += 24;
		pos_y += 10;
	}

	if (autocvar(cg_woot, 0)) // mostly just to demonstrate that you're actually using the csqc version...
		pos_x = (virtsize_x-320)/2 * (1+sin(time));
	else
		pos_x += (virtsize_x-320)/2;

	pos_x += 80;

	float test = autocvar(cl_hudtest, 0);
	float is_scarlet = getstatf(GAME_SCARLET);
	if (test == 2) is_scarlet = 0;
	if (is_scarlet)
		pos -= [20,0];

	// for counting players
	local float players;

	// for printing team scores
	local float is_teamplay = getstatf(GAME_TEAMPLAY);
	if (autocvar(cl_teams, 0) || is_teamplay)
	{
		for (float t = 0 ; t < 4 ; t++)
		{
			if (cl_teamscores_ranked[t].is_team > 0)
			{
				players++;

				local string name = cl_teamscores_ranked[t].teamname;
				//name = strcat(teamname, " Team");

				drawfill(pos+[0,0]+[0,10*players], ([40,8]), stov(cl_teamscores_ranked[t].bottomcolor), .75, 0);
				//drawfill(pos1+([0,0]), ([28,9]), stov(cl_teamscores_ranked[i].bottomcolor), 0.75, 0);
				drawstring(pos+[8,0]+[0,10*players], strpad(-3, ftos(cl_teamscores_ranked[t].frags)), [8,8], [1,1,1], 1, 0);
				drawstring(pos+[64,0]+[0,10*players], strconv(0,2,2, name), [8,8], [1,1,1], 1, 0);
			}
		}
		players++;
	}

	// alphabetize the list of players (so we can ID players from score stats from server)
	if (is_scarlet)
	{
		string score_player_alpha[8];

        // reset player order
        score_player_alpha[7] = "ZZZZZZZ";
        score_player_alpha[6] = "ZZZZZZZ";
        score_player_alpha[5] = "ZZZZZZZ";
        score_player_alpha[4] = "ZZZZZZZ";
        score_player_alpha[3] = "ZZZZZZZ";
        score_player_alpha[2] = "ZZZZZZZ";
        score_player_alpha[1] = "ZZZZZZZ";
        score_player_alpha[0] = "ZZZZZZZ";

		for (float i=-1; ; i--)
		{
			string name = getplayerkeyvalue(i, "name");
			if not (name) break;

			if (strcasecmp(name, score_player_alpha[0]) < 0)
            {
                    score_player_alpha[7] = score_player_alpha[6];
                    score_player_alpha[6] = score_player_alpha[5];
                    score_player_alpha[5] = score_player_alpha[4];
                    score_player_alpha[4] = score_player_alpha[3];
                    score_player_alpha[3] = score_player_alpha[2];
                    score_player_alpha[2] = score_player_alpha[1];
                    score_player_alpha[1] = score_player_alpha[0];
                    score_player_alpha[0] = name;
            }
            else if (strcasecmp(name, score_player_alpha[1]) < 0)
            {
                    score_player_alpha[7] = score_player_alpha[6];
                    score_player_alpha[6] = score_player_alpha[5];
                    score_player_alpha[5] = score_player_alpha[4];
                    score_player_alpha[4] = score_player_alpha[3];
                    score_player_alpha[3] = score_player_alpha[2];
                    score_player_alpha[2] = score_player_alpha[1];
                    score_player_alpha[1] = name;
            }
            else if (strcasecmp(name, score_player_alpha[2]) < 0)
            {
                    score_player_alpha[7] = score_player_alpha[6];
                    score_player_alpha[6] = score_player_alpha[5];
                    score_player_alpha[5] = score_player_alpha[4];
                    score_player_alpha[4] = score_player_alpha[3];
                    score_player_alpha[3] = score_player_alpha[2];
                    score_player_alpha[2] = name;
            }
            else if (strcasecmp(name, score_player_alpha[3]) < 0)
            {
                    score_player_alpha[7] = score_player_alpha[6];
                    score_player_alpha[6] = score_player_alpha[5];
                    score_player_alpha[5] = score_player_alpha[4];
                    score_player_alpha[4] = score_player_alpha[3];
                    score_player_alpha[3] = name;
            }
            else if (strcasecmp(name, score_player_alpha[4]) < 0)
            {
                    score_player_alpha[7] = score_player_alpha[6];
                    score_player_alpha[6] = score_player_alpha[5];
                    score_player_alpha[5] = score_player_alpha[4];
                    score_player_alpha[4] = name;
            }
            else if (strcasecmp(name, score_player_alpha[5]) < 0)
            {
                    score_player_alpha[7] = score_player_alpha[6];
                    score_player_alpha[6] = score_player_alpha[5];
                    score_player_alpha[5] = name;
            }
            else if (strcasecmp(name, score_player_alpha[6]) < 0)
            {
                    score_player_alpha[7] = score_player_alpha[6];
                    score_player_alpha[6] = name;
            }
            else if (strcasecmp(name, score_player_alpha[7]) < 0)
            {
                    score_player_alpha[7] = name;
            }
		}

		// print sorted players to screen for testing
		/*
		float rows;
		for (float j=0; j<8; j++)
		{
			drawstring([0,(10*rows)+60], strcat(score_player_alpha[j], " - ", ftos(getstatf(SCORE_DEATHS+j))), [8,8], [1,1,1], 1, 0);
			rows++;
		}
		*/

		// draw key
		//drawfill([(virtsize_x/2)-148,pos_y], [296,virtsize_y/2], [0,0,0], 0.5, 0);
		players++;
		players++;
		drawstring(pos+[5,10*players], strconv(0,2,2, "Frags"), [6,6], [1,1,1], 1, 0);
		drawstring(pos+[64,0]+[0,10*players], strconv(0,2,2, "Name"), [6,6], [1,1,1], 1, 0);
		drawstring(pos+[158,0]+[0,10*players], strconv(0,2,2, "Deaths"), [6,6], [1,1,1], 1, 0);
		//drawstring(pos+[220,0]+[0,10*players], strconv(0,2,2, "K/D"), [6,6], [1,1,1], 1, 0);
		players++;
	}

	// negative numbers are players sorted by frags
	for (float i=-1; ; i--)
	{
		string name = getplayerkeyvalue(i, "name");
		if not (name) break;

		players++;

		float isspec = stof(getplayerkeyvalue(i, "*spectator"));
		float frags = stof(getplayerkeyvalue(i, "frags"));
		string ping = getplayerkeyvalue(i, "ping");
		vector top = stov(getplayerkeyvalue(i, "topcolor_rgb"));
		vector bot = stov(getplayerkeyvalue(i, "bottomcolor_rgb"));

		//FIXME: string team = getplayerkeyvalue(i, "team");	//QW team names do NOT match player colours.
		/*Other interesting fields
			pl 			- for packetloss
			activetime	- how long the player has been on the server.
			chat 		- to check if someone is at the console/tabbed out
			userid		- for easy banning etc, assuming you're the server.
			ignored		- text from this player will be dropped clientside.
			vignored	- voicechat from this player will be dropped (clientside and hopefully serverside too).
			voipspeaking- whether they're speaking or not
			voiploudness- the player's average voip volume.
			also any other networked userinfo
		*/

		// ------------------------------------------

		float deaths, kd;
		if (is_scarlet)
		{
			for (float j=0; j<8; j++)
			{
				if (name == score_player_alpha[j])
				{
					deaths = getstatf(SCORE_DEATHS+j);

					// this stupid process is bc CSQC doesn't have a round() function
					kd = floor((frags / deaths * 100) + 0.5);
					if (deaths == 0) kd = (frags > 0) ? 1000 : 0;
					if (frags < 0) kd = 0;

					break;
				}
			}
		}

		// ------------------------------------------

		if (player_localentnum == stof(getplayerkeyvalue(i, "viewentity")))
		{
			//drawcharacter(pos-[8,0]+[0,10*players], 0xe00d, [8,8], [1,1,1], 1, 0);
			//drawcharacter(pos+[0,0]+[0,10*players], 0xe010, [8,8], [1,1,1], 1, 0);
			//drawcharacter(pos+[32,0]+[0,10*players], 0xe011, [8,8], [1,1,1], 1, 0);
			drawfill([(virtsize_x/2)-140,pos_y-2]+[0,10*players], [280,12], [0,0,0], 0.5, 0);
			drawfill([(virtsize_x/2)-140,pos_y-2]+[0,10*players], [280,12], bot, 0.25, 0);
		}
		if (ping != "0" || test)
			drawstring(pos-[8*5,0]+[6,2]+[0,10*players], strpad(-4, strconv(0,2,2, ping)), [6,6], [1,1,1], 1, 0);
		drawfill(pos+[0,0]+[0,10*players], [40,4], top, 0.75, 0);
		drawfill(pos+[0,4]+[0,10*players], [40,4], bot, 0.75, 0);
		drawstring(pos+[8,0]+[0,10*players], strpad(-3, ftos(frags)), [8,8], [1,1,1], 1, 0);
		drawstring(pos+[64,0]+[0,10*players], name, [8,8], [1,1,1], 1, 0);
		if (is_scarlet)
		{
			drawstring(pos+[170,0]+[0,10*players], strpad(-3, ftos(deaths)), [8,8], [1,1,1], 1, 0);
			drawstring(pos+[200,2]+[0,10*players], strconv(0,2,2, ftos(kd)), [6,6], [1,1,1], 1, 0);
		}
	}
};

static void(vector pos, string num) Hud_DrawIntermissionNumber =
{
	float i;
	float c;
	for(i = 0; ; i++, pos_x += 24)
	{
		c = str2chr(num, i);
		if (!c)
			break;
		if (c == ' ')
			continue;
		if (c == '/')
			drawpic(pos, "gfx/num_slash", [24,24],[1,1,1],1,0);
		else if (c == ':' || c == '.')
			drawpic(pos, "gfx/num_colon", [24,24],[1,1,1],1,0);
		else if (c == '-')
			drawpic(pos, "gfx/num_minus", [24,24],[1,1,1],1,0);
		else if (c >= '0' && c <= '9')
			drawpic(pos, sprintf("gfx/num_%c", c), [24,24],[1,1,1],1,0);
	}
};

void(vector virtmin, vector virtsize) Hud_Intermission =
{
	vector pos = virtmin + (virtsize-[320,200])/2;

	Hud_CentrePic("gfx/complete.lmp", 320, pos+'0 24', 24);
	drawpic(pos+[0,56], "gfx/inter.lmp", [160,144],[1,1,1],1,0);
	
	Hud_DrawIntermissionNumber(pos+[144, 64], sprintf("%3.0f:%02.0f", intermission_time/60, intermission_time%60));
	Hud_DrawIntermissionNumber(pos+[144, 104], sprintf("%3.0f/%.0f", getstatf(STAT_FOUNDSECRETS), getstatf(STAT_TOTALSECRETS)));
	Hud_DrawIntermissionNumber(pos+[144, 144], sprintf("%3.0f/%.0f", getstatf(STAT_KILLEDMONSTERS), getstatf(STAT_TOTALMONSTERS)));
};

float(string pants1, string pants2) ComparePants =
{
	local vector v1, v2;

	v1 = stov(pants1);
	v2 = stov(pants2);

	local float dist, is_match;
	dist = vlen(v1 - v2);

	is_match = 0;

	if (dist < .03) is_match = 1;

	return is_match;
};

void() Hud_UpdateTeamScores =
{
	float fraglimit = cvar("fraglimit");

	// reset all team scores to zero
	for (float t = 0 ; t < 14 ; t++)
	{
		cl_teamscores[t].is_team = 0;
		cl_teamscores[t].bottomcolor = "";
		cl_teamscores[t].frags = 0;
		cl_teamscores[t].teamname = "";
	}

	// foreach player (negative numbers are players sorted by frags)
	float i = -1;
	while (1)
	{
		string name = getplayerkeyvalue(i, "name");

		if not (name) break; // end the loop, no more players

		float frags = stof(getplayerkeyvalue(i, "frags"));
		string bottomcolor = getplayerkeyvalue(i, "bottomcolor_rgb");

		// loop thru cl_teamscores looking for bottom color match
		float teamnum = 0;
		float nextnum = 0;
		for (float t = 0 ; t < 14 ; t++)
		{
			if (cl_teamscores[t].bottomcolor == bottomcolor)
				teamnum = t;

			if (cl_teamscores[t].bottomcolor == "")
				nextnum = t;
		}

		// if no teamnum was found
		if (!teamnum)
		{
			teamnum = nextnum;
		}

		cl_teamscores[teamnum].is_team = 1;
		cl_teamscores[teamnum].bottomcolor = bottomcolor;
		cl_teamscores[teamnum].frags += frags;

		// next player
		i--;
	}

	// reset all ranked team scores to zero
	for (float t = 0 ; t < 4 ; t++)
	{
		cl_teamscores_ranked[t].is_team = 0;
		cl_teamscores_ranked[t].bottomcolor = "";
		cl_teamscores_ranked[t].frags = 0;
		cl_teamscores_ranked[t].teamname = "";
	}
	for (float t = 0 ; t < 14 ; t++)
	{
		// order ranks
		if (cl_teamscores[t].is_team > 0)
		{
			// determine teamname
			for (float u = 0 ; u < 14 ; u++)
			{
				if (ComparePants(cl_teamscores[t].bottomcolor, teamcolor[0])) cl_teamscores[t].teamname = teamname[0];
				if (ComparePants(cl_teamscores[t].bottomcolor, teamcolor[1])) cl_teamscores[t].teamname = teamname[1];
				if (ComparePants(cl_teamscores[t].bottomcolor, teamcolor[2])) cl_teamscores[t].teamname = teamname[2];
				if (ComparePants(cl_teamscores[t].bottomcolor, teamcolor[3])) cl_teamscores[t].teamname = teamname[3];
				if (ComparePants(cl_teamscores[t].bottomcolor, teamcolor[4])) cl_teamscores[t].teamname = teamname[4];
				if (ComparePants(cl_teamscores[t].bottomcolor, teamcolor[5])) cl_teamscores[t].teamname = teamname[5];
				if (ComparePants(cl_teamscores[t].bottomcolor, teamcolor[6])) cl_teamscores[t].teamname = teamname[6];
				if (ComparePants(cl_teamscores[t].bottomcolor, teamcolor[7])) cl_teamscores[t].teamname = teamname[7];
				if (ComparePants(cl_teamscores[t].bottomcolor, teamcolor[8])) cl_teamscores[t].teamname = teamname[8];
				if (ComparePants(cl_teamscores[t].bottomcolor, teamcolor[9])) cl_teamscores[t].teamname = teamname[9];
				if (ComparePants(cl_teamscores[t].bottomcolor, teamcolor[10])) cl_teamscores[t].teamname = teamname[10];
				if (ComparePants(cl_teamscores[t].bottomcolor, teamcolor[11])) cl_teamscores[t].teamname = teamname[11];
				if (ComparePants(cl_teamscores[t].bottomcolor, teamcolor[12])) cl_teamscores[t].teamname = teamname[12];
				if (ComparePants(cl_teamscores[t].bottomcolor, teamcolor[13])) cl_teamscores[t].teamname = teamname[13];
			}

			if (cl_teamscores[t].frags >= cl_teamscores_ranked[0].frags)
			{
				cl_teamscores_ranked[3] = cl_teamscores_ranked[2];
				cl_teamscores_ranked[2] = cl_teamscores_ranked[1];
				cl_teamscores_ranked[1] = cl_teamscores_ranked[0];
				cl_teamscores_ranked[0] = cl_teamscores[t];
			}
			else if (cl_teamscores[t].frags >= cl_teamscores_ranked[1].frags)
			{
				cl_teamscores_ranked[3] = cl_teamscores_ranked[2];
				cl_teamscores_ranked[2] = cl_teamscores_ranked[1];
				cl_teamscores_ranked[1] = cl_teamscores[t];
			}
			else if (cl_teamscores[t].frags >= cl_teamscores_ranked[2].frags)
			{
				cl_teamscores_ranked[3] = cl_teamscores_ranked[2];
				cl_teamscores_ranked[2] = cl_teamscores[t];
			}
			else if (cl_teamscores[t].frags >= cl_teamscores_ranked[3].frags)
			{
				cl_teamscores_ranked[3] = cl_teamscores[t];
			}
		}
	}
}

void(vector virtsize) Hud_DrawTeamScores =
{
	local vector pos1, pos2;
	local float i, n = 0;

	float pos_x = virtsize_x / 2;

	pos1_y = 0;
	pos1_x = pos_x - 30;

	pos2_y = 0;
	pos2_x = pos_x;

	for (i = 0 ; i < 4 ; i++)
	{
		if (cl_teamscores_ranked[i].is_team > 0)
		{
			n += 1;

			if (n == 1)
			{
				drawfill(pos1+([0,0]), ([28,9]), stov(cl_teamscores_ranked[i].bottomcolor), 0.75, 0);
				drawstring(pos1+([2,0]), strpad(-3, ftos(cl_teamscores_ranked[i].frags)), ([8,8]), ([1,1,1]),1,0);
			}
			else
			{
				drawfill(pos2+([0,0]), ([28,9]), stov(cl_teamscores_ranked[i].bottomcolor), 0.75, 0);
				drawstring(pos2+([2,0]), strpad(-3, ftos(cl_teamscores_ranked[i].frags)), ([8,8]), ([1,1,1]),1,0);
				break;
			}
		}
	}
};

// called unless there's a menu/finale visible. also called during intermissions.
void(vector virtsize, float showscores) CSQC_DrawScores =
{
	if (intermission || showscores || getstatf(STAT_HEALTH) <= 0)
	{
		if (deathmatch)
		{
			Hud_UpdateTeamScores();
			Hud_DeathmatchScoreboard('0 0 0', virtsize);
		}
	}

	/*
	else
	{
		if (deathmatch)
			if (autocvar(cl_teams, 0))
				Hud_DrawTeamScores(virtsize);
	}
	*/

	if (intermission)
		if (!deathmatch)
			Hud_Intermission('0 0 0', virtsize);
};