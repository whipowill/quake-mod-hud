
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

	if (autocvar(cg_woot, 0))	//I added this mostly just to demonstrate that you're actually using the csqc version...
		pos_x = (virtsize_x-320)/2 * (1+sin(time));
	else
		pos_x += (virtsize_x-320)/2;

	pos_x += 80;

	//negative numbers are players sorted by frags.
	for (float i = -1; ; i--, pos_y += 10)
	{
		string name = getplayerkeyvalue(i, "name");
		if not (name)
			break;
		float isspec = stof(getplayerkeyvalue(i, "*spectator"));
		float frags = stof(getplayerkeyvalue(i, "frags"));
		string ping = getplayerkeyvalue(i, "ping");
		vector top = stov(getplayerkeyvalue(i, "topcolor_rgb"));
		vector bot = stov(getplayerkeyvalue(i, "bottomcolor_rgb"));
		//name = strconv(0,2,2, name);
		ping = strconv(0,2,2, ping);
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

		drawstring(pos-[8*5	,0], strpad(-4, ping), [8,8], [1,1,1],1,0);
		if (isspec)
			drawstring(pos+[4,0], "spec", [8,8], [1,1,1],1,0);
		else
		{
			drawfill(pos+[0,0], [40,4], top, 0.75, 0);
			drawfill(pos+[0,4], [40,4], bot, 0.75, 0);
			drawstring(pos+[8,0], strpad(-3, ftos(frags)), [8,8], [1,1,1],1,0);
			if (player_localentnum == stof(getplayerkeyvalue(i, "viewentity")))
			{
				drawcharacter(pos-[8,0], 0xe00d, [8,8], [1,1,1],1, 0);
				drawcharacter(pos+[ 0,0], 0xe010, [8,8], [1,1,1],1, 0);
				drawcharacter(pos+[32,0], 0xe011, [8,8], [1,1,1],1, 0);
			}
		}
		drawstring(pos+[64,0], name, [8,8], [1,1,1],1,0);
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

void() Hud_UpdateTeamScores =
{
	float fraglimit = cvar("fraglimit");

	// reset all team scores to zero
	for (float t = 0 ; t < 14 ; t++)
	{
		cl_teamscores[t].is_team = 0;
		cl_teamscores[t].bottomcolor = "";
		cl_teamscores[t].frags = 0;
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
}

void(vector virtsize) Hud_DrawTeamScores =
{
	Hud_UpdateTeamScores();

	local vector pos1, pos2;
	local float i, n = 0;

	float pos_x = virtsize_x / 2;

	pos1_y = 0;
	pos1_x = pos_x - 30;

	pos2_y = 0;
	pos2_x = pos_x;

	//todo add more teams here...

	for (i = 0 ; i < 14 ; i++)
	{
		if (cl_teamscores[i].is_team > 0)
		{
			n += 1;

			if (n == 1)
			{
				drawfill(pos1+([0,0]), ([28,9]), stov(cl_teamscores[i].bottomcolor), 0.75, 0);
				drawstring(pos1+([2,0]), strpad(-3, ftos(cl_teamscores[i].frags)), ([8,8]), ([1,1,1]),1,0);
			}
			else
			{
				drawfill(pos2+([0,0]), ([28,9]), stov(cl_teamscores[i].bottomcolor), 0.75, 0);
				drawstring(pos2+([2,0]), strpad(-3, ftos(cl_teamscores[i].frags)), ([8,8]), ([1,1,1]),1,0);
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
			Hud_DeathmatchScoreboard('0 0 0', virtsize);
			if (autocvar(cl_teamscores, 0))
				Hud_DrawTeamScores(virtsize);
		}
	}

	if (intermission)
		if (!deathmatch)
			Hud_Intermission('0 0 0', virtsize);
};