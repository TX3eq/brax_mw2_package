#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;

_init()
{
    /* Strings + Dvars */
	game["strings"]["change_class"] = undefined; //Removes Class Change Text
    level.pers["meters"] = 10; //Meters required to kill.
    level.pers["almost_hit_sens"] = 2; //Almost hit sensitivity.
    setDvarIfUninitialized("class_change", 1); //Enables/Disabled Mid-Game CC
    setDvarIfUninitialized("first_blood", 0); //Enables/Disabled First Blood
    level setClientDvar("g_teamcolor_myteam", "0.501961 0.8 1 1" ); 	
    level setClientDvar("g_teamTitleColor_myteam", "0.501961 0.8 1 1" );
    setDvar("g_teamcolor_myteam", "0.501961 0.8 1 1" ); 	
    setDvar("g_teamTitleColor_myteam", "0.501961 0.8 1 1" );
    setDvar("safeArea_adjusted_horizontal", 0.85);
    setDvar("safeArea_adjusted_vertical", 0.85);
    setDvar("safeArea_horizontal", 0.85);
    setDvar("safeArea_vertical", 0.85);
    setDvar("scr_sd_multibomb", "1");
    setDvar("ui_streamFriendly", true);
    setDvar("jump_slowdownEnable", 0); //Removes Jump Fatigue
    setDvar("bg_surfacePenetration", 9999); //Wallbang Everything
    setDvar("bg_bulletRange", 99999); //No Bullet Trail Limit

    setDvar("testClients_doMove", 0); //Bots do NOT Move

    setDvar("sv_allowAimAssist", 1); //Aim Assist Enable/Disable
    setDvar("bg_bounces", 2); //Allow Double Bouncing
    setDvar("bg_elevators", 2); //Allow EZ Elevators
    setDvar("bg_rocketJump", 1); //Allow Rocket Jumps
    setDvar("bg_bouncesAllAngles", 1); //Allow Multi Bouncing
    setDvar("bg_playerEjection", 0); //Removes Collision
    setDvar("bg_playerCollision", 0); //Removes Ejection
    
    setDvar("cg_newcolors", 0);
    setDvar("intro", 0);
    setDvar("cl_autorecord", 0);
    setDvar("snd_enable3D" , 1);
    setDvar("bg_fallDamageMaxHeight", 300);
    setDvar("bg_fallDamageMinHeight", 128);
    setDvar("scr_sd_timelimit", 2.5); //Stops unlimited time..
    level thread on_player_connect();
}

on_player_connect()
{
    self endon("disconnect");
    for(;;)
    {
        level waittill( "connected", player );

        if(!player IsTestClient())
        {
            if(!isDefined(player.pers["allow_fast_mantle"]))
                player.pers["allow_fast_mantle"] = true;
            if(!isDefined(player.pers["alt_swap"]))
                player.pers["alt_swap"] = false;
            if(!isDefined(player.pers["allow_soh"]))
                player.pers["allow_soh"] = true;
            if(!isDefined(player.pers["soft_land"]))
                player.pers["soft_land"] = false;
            if(!isDefined(player.pers["instashoots"]))
                player.pers["instashoots"] = false;
            if(!isDefined(player.pers["console_hud"]))
                player.pers["console_hud"] = true;
            if(!isDefined(player.pers["thermal_vision"]))
                player.pers["thermal_vision"] = false;
            if(!isDefined(player.pers["throwingknife_rhand_mp"]))
                player.pers["throwingknife_rhand_mp"] = false;
            if(!isDefined(player.pers["glow_stick"]))
                 player.pers["glow_stick"] = false;
            if(!isDefined(player.pers["almost_hits"]))
                 player.pers["almost_hits"] = false;
            if(!isDefined(player.pers["unstuck_origin"]))
                 player.pers["unstuck_origin"] = false;
            if(!isDefined(player.pers["ez_mala"]))
                 player.pers["ez_mala"] = false;
            if(!isDefined(player.pers["ez_prone"]))
                 player.pers["ez_prone"] = false;
            if(!isDefined(player.pers["smooth_action"]))
                 player.pers["smooth_action"] = false;

            player setClientDvar("clantag", getDvar("ui_clantag"));

            player_thread_calling(player);

            if(player isHost())
            {
                if(!isDefined(player.pers["bot_origin"]))
                    player.pers["bot_origin"] = 0;
                if(!isDefined(player.pers["bot_angles"]))
                    player.pers["bot_angles"] = 0;

                player thread tele_bots_cmd();
                player thread begin_auto_plant();
            }
        }
        player thread on_player_spawn();
    }
}

on_player_spawn()
{
	self endon("disconnect");
	for(;;)
	{
		self waittill("spawned_player");

        if(!self IsTestClient())
        {
            if(self.pers["instashoots"])
                self thread do_instashoots_action();
            else
                self notify("stop_insta_shoots");
            
            if(self.pers["thermal_vision"])
                self thread thermal_vision_scope();
            else
                self notify("stop_thermal");
        
            if(self.pers["ez_mala"])
                self thread test_new_ez_mala();
            else
                self notify("stop_ez_mala");

            if(self.pers["ez_prone"])
                self thread ez_prone_cmd();
            else
                self notify("stop_prone");

            if(self.pers["smooth_action"])
                self thread do_smooth_actions();
            else
                self notify("stop_smooth");

			/* DVARS */
			if(self.pers["console_hud"])
			{
				self setClientDvar( "cg_overheadiconsize" , 1);
				self setClientDvar( "cg_overheadnamesfont" , 3);
				self setClientDvar( "cg_overheadnamessize" , 0.6);
				self setClientDvar("g_teamcolor_myteam", "0.501961 0.8 1 1" ); 	
				self setClientDvar("g_teamTitleColor_myteam", "0.501961 0.8 1 1" );
			} else {
				self setClientDvar( "cg_overheadiconsize" , 0.7);
				self setClientDvar( "cg_overheadnamesfont" , 2);
				self setClientDvar( "cg_overheadnamessize" , 0.5);
				self setClientDvar("g_teamcolor_myteam", "0.501961 0.8 1 1" ); 	
				self setClientDvar("g_teamTitleColor_myteam", "0.501961 0.8 1 1" );
			}

            self setClientDvar("clantag", getDvar("ui_clantag"));
            
            self respawn_dvars();
            self VisionSetThermalForPlayer( game["nightvision"], 0 ); //Ensures Proper Reset
            self ThermalVisionOff(); //Ensures Proper Reset
            self.pers["unstuck_origin"] = self getOrigin();
        }

        force_load_bot_position();//Keep here...
        if(self IsTestClient())//Bot check...
        {
            self _clearPerks();
            self takeAllWeapons();
            if ( self.hasRiotShieldEquipped )
                self DetachShieldModel( "weapon_riot_shield_mp", "tag_weapon_left" );
            else
                self DetachShieldModel( "weapon_riot_shield_mp", "tag_shield_back" );
        }
        if(self isHost())//Host only functionality...
        {
            self freezeControls(false);
            self thread knife_x_prone_ads();
            gametype_verification();//Forces disconnect if gametype is not Search and Destroy!
            //Softland Commands
            if(self.pers["soft_land"])
                thread killcam_softland();
            else
                level notify("stop_softland");
            setDvar("snd_enable3D" , 1);
            setDvar("scr_sd_timelimit", 2.5);
            /* Referencing Joey's Bronx, but using native command. */
			if(getteamscore("allies") == 0 && getteamscore("axis") == 0)
			{
				exec("spawnbot 1");
			}
        }
    }
}

player_thread_calling(client)
{
    client thread welcome_message();
    client thread do_refill_all_cmd();
    client thread allow_mara_mantle_cmd();
    client thread kill_cmd();
    client thread alt_swap_cmd();
    client thread allow_soh_cmd();
    client thread instashoot_cmd();
    client thread console_hud_cmd();
    client thread thermal_vision_scope_cmd();
    client thread give_rhand_cmd();
    client thread give_lightstick_cmd();
    client thread do_streak_cmd();
    client thread toggle_almost_hits_cmd();
    client thread almost_hit_message();
    client thread do_unstuck_lol();
    client thread ez_mala_cmd();
    client thread ez_prone_cmd();
    client thread smooth_anim_toggle();
    if(client isHost())
        client thread softland_cmd();
    /* DVARS */
    client setClientDvar("safeArea_adjusted_horizontal", 0.85);
    client setClientDvar("safeArea_adjusted_vertical", 0.85);
    client setClientDvar("safeArea_horizontal", 0.85);
    client setClientDvar("safeArea_vertical", 0.85);
    client setClientDvar("ui_streamFriendly", true);
    client setClientDvar("cg_newcolors", 0);
    client setClientDvar("intro", 0);
    client setClientDvar("cl_autorecord", 0);
    client setClientDvar("snd_enable3D", 1);
    /* Force Spawning - Thanks Joey */
    if(client.pers["team"] != "axis")
    {
        client closeMenus();
        client maps\mp\gametypes\_menus::addToTeam("axis");
        client.pers["class"] = undefined;
        client.class = undefined;
        client maps\mp\gametypes\_menus::beginClassChoice();
    }
}

respawn_dvars()
{
    /* DVARS */
    if(self.pers["console_hud"])
    {
        self setClientDvar( "cg_overheadiconsize" , 1);
        self setClientDvar( "cg_overheadnamesfont" , 3);
        self setClientDvar( "cg_overheadnamessize" , 0.6);
        self setClientDvar("g_teamcolor_myteam", "0.501961 0.8 1 1" ); 	
        self setClientDvar("g_teamTitleColor_myteam", "0.501961 0.8 1 1" );
        setDvar( "cg_overheadiconsize" , 1);
        setDvar( "cg_overheadnamesfont" , 3);
        setDvar( "cg_overheadnamessize" , 0.6);
        setDvar("g_teamcolor_myteam", "0.501961 0.8 1 1" ); 	
        setDvar("g_teamTitleColor_myteam", "0.501961 0.8 1 1" );
    } else {
        self setClientDvar( "cg_overheadiconsize" , 0.7);
        self setClientDvar( "cg_overheadnamesfont" , 2);
        self setClientDvar( "cg_overheadnamessize" , 0.5);
        self setClientDvar("g_teamcolor_myteam", "0.501961 0.8 1 1" ); 	
        self setClientDvar("g_teamTitleColor_myteam", "0.501961 0.8 1 1" );
        setDvar( "cg_overheadiconsize" , 0.7);
        setDvar( "cg_overheadnamesfont" , 2);
        setDvar( "cg_overheadnamessize" , 0.5);
        setDvar("g_teamcolor_myteam", "0.501961 0.8 1 1" ); 	
        setDvar("g_teamTitleColor_myteam", "0.501961 0.8 1 1" );
    }
    self setClientDvar("safeArea_adjusted_horizontal", 0.85);
    self setClientDvar("safeArea_adjusted_vertical", 0.85);
    self setClientDvar("safeArea_horizontal", 0.85);
    self setClientDvar("safeArea_vertical", 0.85);
    self setClientDvar("ui_streamFriendly", true);
    self setClientDvar("cg_newcolors", 0);
    self setClientDvar("intro", 0);
    self setClientDvar("cl_autorecord", 0);
    self setClientDvar("snd_enable3D", 1);
    self setClientDvar("cg_nopredict", 0);
}

gametype_verification()
{
    if(level.gametype != "sd")
    {
        self iPrintLnBold("^1Invalid Gametype - Please utilize S&D!");
        wait 0.50;
        exec("disconnect");
    }
}

welcome_message()
{
    self waittill("spawned_player");
    self iprintln("Welcome ^1" + self.name + " ^7to ^1Brax PKG^7 by ^1@mp_rust^7!\nThis mod was inspired by ^1@plugwalker47^7\nUse [{+stance}] & [{+melee}] for a Ammo Refill!");
}

/* BOT LOGIC */
tele_bots_cmd()
{
	self endon("disconnect");
    for(;;)
    {
        self notifyOnPlayerCommand("tele", "+tele");
        self waittill("tele");
        self.pers["bot_origin"] = self getOrigin();
        self.pers["bot_angles"] = self getplayerangles();
        waitframe();
        for(i = 0; i < level.players.size; i++)
        {
            if(level.players[i].pers["team"] != self.pers["team"] && isSubStr( level.players[i].guid, "bot" ))
            {
                    level.players[i] setOrigin( self.pers["bot_origin"] );
                    level.players[i] setPlayerAngles( self.pers["bot_angles"] );
            }
        }
        self iPrintLnBold("Bots Position: ^2Saved");
    }
}

force_load_bot_position()
{
    for(i = 0; i < level.players.size; i++)
    {
        if(level.players[i].pers["team"] != self.pers["team"] && isSubStr( level.players[i].guid, "bot" ))
        {
                level.players[i] setOrigin( self.pers["bot_origin"] );
                level.players[i] setPlayerAngles( self.pers["bot_angles"] );
        }
    }
}

/* In-game Commands */
allow_mara_mantle_cmd()
{
    self endon("disconnect");
    for(;;)
    {
        self notifyOnPlayerCommand("afm", "+afm");
        self waittill("afm");
        if(!self.pers["allow_fast_mantle"])
        {
            self.pers["allow_fast_mantle"] = true;
            self maps\mp\perks\_perks::givePerk("specialty_fastmantle");
        } else {
            self.pers["allow_fast_mantle"] = false;
            self _unsetPerk("specialty_fastmantle");
        }
        self iPrintLn("Fast Mantle Perk: " + bool_to_text(self.pers["allow_fast_mantle"]));
    }
}

allow_soh_cmd()
{
    self endon("disconnect");
    for(;;)
    {
        self notifyOnPlayerCommand("soh", "+soh");
        self waittill("soh");
        if(!self.pers["allow_soh"])
        {
            self.pers["allow_soh"] = true;
            self maps\mp\perks\_perks::givePerk("specialty_fastreload");
        } else {
            self.pers["allow_soh"] = false;
            self _unsetPerk("specialty_fastreload");
        }
        self iPrintLn("Fast Reload Perk: " + bool_to_text(self.pers["allow_soh"]));
    }
}

kill_cmd()
{
    self endon("disconnect");
    for(;;)
    {
        self notifyOnPlayerCommand("die", "+die");
        self waittill("die");
        self suicide();
    }
}

do_refill_all_cmd()
{
    self endon("disconnect");
    for(;;)
    {
        self notifyOnPlayerCommand("melee", "+melee");
        self waittill("melee");
        if(self getStance() == "crouch")
        {
            weapon_list = self GetWeaponsListAll();
            foreach ( weapon in weapon_list )
            {
                self giveMaxAmmo(weapon);
            }
        }
    }
}

knife_x_prone_ads()
{
	self endon("disconnect");
	for(;;)
	{
        self notifyOnPlayerCommand("melee", "+melee");
        self waittill("melee");
        if(self getStance() == "prone" && self adsButtonPressed())
        {
            self giveWeapon("stinger_mp");
            self dropItem("stinger_mp");
        }
	}
}

alt_swap_cmd()
{
    self endon("disconnect");
    for(;;)
    {
        self notifyOnPlayerCommand("as", "+as");
        self waittill("as");
        if(!self.pers["alt_swap"])
        {
            self.pers["alt_swap"] = true;
            if(isSubStr(self.secondaryWeapon, "usp") || isSubStr(self.primaryWeapon, "usp"))
            {
                self giveWeapon("beretta_mp");
            } else {
                self giveWeapon("usp_mp");
            }
        } else {
            self.pers["alt_swap"] = false;
            if(isSubStr(self.secondaryWeapon, "usp") || isSubStr(self.primaryWeapon, "usp"))
            {
                self takeWeapon("beretta_mp");
            } else {
                self takeWeapon("usp_mp");
            }
        }
        self iPrintLn("Alt-Swaps: " + bool_to_text(self.pers["alt_swap"]));
    }
}

softland_cmd()
{
    self endon("disconnect");
    for(;;)
    {
        self notifyOnPlayerCommand("sl", "+sl");
        self waittill("sl");
        if(!self.pers["soft_land"])
        {
            self.pers["soft_land"] = true;
            thread killcam_softland();
        } else {
            self.pers["soft_land"] = false;
            level notify("stop_softland");
        }
        allClientsPrint("Host Has Enabled Softlands via Killcam: " + bool_to_text(self.pers["soft_land"]));
    }
}

killcam_softland()
{
    level endon("stop_softland");
    level waittill("round_end_finished");
    setDvar("bg_fallDamageMaxHeight", 1);
    setDvar("bg_fallDamageMinHeight", 1);
    wait 2;
    setDvar("snd_enable3D" , 0);
    self setClientDvar("snd_enable3D" , 0);
}

instashoot_cmd()
{
    self endon("disconnect");
    for(;;)
    {
        self notifyOnPlayerCommand("is", "+is");
        self waittill("is");
        if(!self.pers["instashoots"])
        {
            self.pers["instashoots"] = true;
            self thread do_instashoots_action();
        } else {
            self.pers["instashoots"] = false;
            self notify("stop_insta_shoots");
        }
        self iPrintLn("Instashoots: " + bool_to_text(self.pers["instashoots"]));
    }
}

do_instashoots_action()
{
    self endon("disconnect");
    self endon("stop_insta_shoots");
    for(;;)
    {
        self waittill("weapon_change", weapon);
        sniper_subStr = getweaponclass( weapon );
        if(sniper_subStr == "weapon_sniper")
        {
            self switchToWeaponImmediate(self getLastWeapon());
            waitframe();
            self switchToWeaponImmediate(weapon);
        }
    }
}

give_rhand_cmd()
{
    self endon("disconnect");
    for(;;)
    {
        self notifyOnPlayerCommand("rh", "+rh");
        self waittill("rh");
        if(self.pers["glow_stick"])
        {
            self iPrintLnBold("^1Warning: Please Disable Glowstick First!");
            continue;
        } 
        if(!self.pers["throwingknife_rhand_mp"])
        {
            self.pers["throwingknife_rhand_mp"] = true;
            self takeWeapon(self GetCurrentOffhand());
            self SetOffhandPrimaryClass("throwingknife");
            self giveWeapon("throwingknife_rhand_mp");
        } else {
            self.pers["throwingknife_rhand_mp"] = false;
            self takeWeapon("throwingknife_rhand_mp");
            self SetOffhandPrimaryClass("other");
            self maps\mp\perks\_perks::givePerk(maps\mp\gametypes\_class::cac_getPerk( self.class_num, 0 ));
        }
        self iPrintLn("Right Hand Throwing Knife: " + bool_to_text(self.pers["throwingknife_rhand_mp"]));
    }
}

give_lightstick_cmd()
{
    self endon("disconnect");
    for(;;)
    {
        self notifyOnPlayerCommand("glow", "+glow");
        self waittill("glow");
        if(self.pers["throwingknife_rhand_mp"])
        {
            self iPrintLnBold("^1Warning: Please Disable Right-Hand Throwing Knife First!");
            continue;
        } 
        if(!self.pers["glow_stick"])
        {
            self.pers["glow_stick"] = true;
            self takeWeapon(self GetCurrentOffhand());
            self SetOffhandPrimaryClass("other");
            self giveWeapon("lightstick_mp");
        } else {
            self.pers["glow_stick"] = false;
            self takeWeapon("lightstick_mp");
            self SetOffhandPrimaryClass("other");
            self maps\mp\perks\_perks::givePerk(maps\mp\gametypes\_class::cac_getPerk( self.class_num, 0 ));
        }
        self iPrintLn("Glowstick: " + bool_to_text(self.pers["glow_stick"]));
    }
}

thermal_vision_scope_cmd()
{
    self endon("disconnect");
    for(;;)
    {
        self notifyOnPlayerCommand("tv", "+tv");
        self waittill("tv");
        if(!self.pers["thermal_vision"])
        {
            self.pers["thermal_vision"] = true;
            self thread thermal_vision_scope();
        } else {
            self.pers["thermal_vision"] = false;
            self notify("stop_thermal");
        }
        self iPrintLn("Thermal Vision Scopes: " + bool_to_text(self.pers["thermal_vision"]));
    }
}

thermal_vision_scope()
{
    self endon("disconnect");
    self endon("stop_thermal");
    for(;;)
    {
        sniper_subStr = getweaponclass( self getCurrentWeapon() );
        if ( self adsButtonPressed() && sniper_subStr == "weapon_sniper" && self PlayerADS() > 0.90 )
        {
            self VisionSetThermalForPlayer( game["nightvision"], 1 );
            self ThermalVisionOn();
        } else {
            self VisionSetThermalForPlayer( game["nightvision"], 0 );
            self ThermalVisionOff();
        }
        waitframe();
    }
}

console_hud_cmd()
{
    self endon("disconnect");
    for(;;)
    {
        self notifyOnPlayerCommand("ch", "+ch");
        self waittill("ch");
        if(!self.pers["console_hud"])
        {
            self.pers["console_hud"] = true;
        } else {
            self.pers["console_hud"] = false;
        }
        self iPrintLn("Console Hud: " + bool_to_text(self.pers["console_hud"]));
    }
}

toggle_almost_hits_cmd()
{
    self endon("disconnect");
    for(;;)
    {
        self notifyOnPlayerCommand("ah", "+ah");
        self waittill("ah");
        if(!self.pers["almost_hits"])
        {
            self.pers["almost_hits"] = true;
        } else {
            self.pers["almost_hits"] = false;
        }
        self iPrintLn("Almost Hits: " + bool_to_text(self.pers["almost_hits"]));
    }
}

do_streak_cmd()
{
    self endon("disconnect");
    for(;;)
    {
        self notifyOnPlayerCommand("ks", "+ks");
        self waittill("ks");
        killstreak_array = strTok("airdrop,sentry,predator_missile", ",");
        self maps\mp\killstreaks\_killstreaks::giveKillstreak(killstreak_array[randomInt(2)], false);
    }
}

do_unstuck_lol()
{
    self endon("disconnect");
    for(;;)
    {
        self notifyOnPlayerCommand("us", "+us");
        self waittill("us");
        self setOrigin(self.pers["unstuck_origin"]);
    }
}

almost_hit_message()
{
	self endon("disconnect");
	level endon("game_ended"); 
	for(;;)
	{
		self waittill("weapon_fired");
		foreach(player in level.players)
		{
			if((player == self) || (level.teamBased && self.pers["team"] == player.pers["team"]) || !isAlive(player) || !self.pers["almost_hits"] || !brax_weapons(self getcurrentweapon()))
				continue;

            if(isDefined(player) && is_within_radius(self, player))
            {
                the_updated_distance = int(distance(player.origin, self.origin)*0.0254);
                self iPrintLnBold("You almost hit from: [^1" + the_updated_distance + "m's^7]!");
                print_all_not_self("[^1" + self.name + "^7] almost hit from: [^1"+ the_updated_distance + "m's^7] away!");
            }
        }
	}
}

begin_auto_plant()
{
	level endon("game_ended");
	level waittill("spawned_player");
	for(;;)
    {	
		if(maps\mp\gametypes\_gamelogic::getTimeRemaining() < 5010)
        {
			thread force_bomb_plant();
			return;
		}
		wait 1;//Loop Check for 1 second..
	}
}

force_bomb_plant()
{	
    if ( level.bombplanted )
        return;
    self thread maps\mp\gametypes\_hud_message::SplashNotify( "plant", maps\mp\gametypes\_rank::getScoreInfoValue( "plant" ) );
    level thread teamPlayerCardSplash( "callout_bombplanted", self, self.pers["team"] );
    self thread maps\mp\gametypes\_rank::giveRankXP( "plant" );
    self.bombPlantedTime = getTime();
    maps\mp\gametypes\_gamescore::givePlayerScore( "plant", self );	
    self playSound( "mp_bomb_plant" );
    leaderDialog( "bomb_planted" );
    if(cointoss())
    {
        level thread maps\mp\gametypes\sd::bombplanted(level.bombZones[0], undefined);
        level.bombZones[1] maps\mp\gametypes\_gameobjects::disableObject();
    } else {
        level thread maps\mp\gametypes\sd::bombplanted(level.bombZones[1], undefined);
        level.bombZones[0] maps\mp\gametypes\_gameobjects::disableObject();
    }
}

ez_mala_cmd()
{
    self endon("disconnect");
    for(;;)
    {
        self notifyOnPlayerCommand("ezm", "+ezm");
        self waittill("ezm");
        if(!self.pers["ez_mala"])
        {
            self.pers["ez_mala"] = true;
            self thread test_new_ez_mala();
        } else {
            self.pers["ez_mala"] = false;
            self notify("stop_ez_mala");
        }
        self iPrintLn("Ghetto Mala: " + bool_to_text(self.pers["ez_mala"]));
    }
}

test_new_ez_mala()
{
    self endon("disconnect");
    self endon("stop_ez_mala");
    for(;;)
    {
        self waittill("grenade_pullback");
        my_weapon = self getCurrentWeapon();
        waitframe();
        self switchToWeaponImmediate(my_weapon);
        self setSpawnWeapon(my_weapon);
    }
}

ez_prone_cmd()
{
    self endon("disconnect");
    for(;;)
    {
        self notifyOnPlayerCommand("ezp", "+ezp");
        self waittill("ezp");
        if(!self.pers["ez_prone"])
        {
            self.pers["ez_prone"] = true;
            self thread instant_prone_bind();
        } else {
            self.pers["ez_prone"] = false;
            self notify("stop_prone");
        }
        self iPrintLn("Instant Prone: " + bool_to_text(self.pers["ez_prone"]));
    }
}

instant_prone_bind()
{
    self endon("stop_prone");
    self endon("disconnect");
    for(;;)
    {
        self notifyOnPlayerCommand("prone", "+stance");
        self waittill("prone");
        self setStance("prone");
    }
}

smooth_anim_toggle()
{
    self endon("disconnect");
    for(;;)
    {
        self notifyOnPlayerCommand("sma", "+sma");
        self waittill("sma");
        if(!self.pers["smooth_action"])
        {
            self.pers["smooth_action"] = true;
            self thread do_smooth_actions();
        } else {
            self.pers["smooth_action"] = false;
            self notify("stop_smooth");
        }
        self iPrintLn("Smooth Animation Bind: " + bool_to_text(self.pers["smooth_action"]));
    }
}

do_smooth_actions()
{
    self endon("stop_smooth");
    for(;;)
    {
        self notifyOnPlayerCommand("smooth", "+actionslot 2");
        self waittill("smooth");
        all_weapons = self getWeaponsListPrimaries();
        if(self getCurrentWeapon() == all_weapons[0])
        {
            self setClientDvar("cg_nopredict", 1);
            waitframe();
            self switchToWeapon(all_weapons[1]);
            waitframe();
            self switchToWeapon(all_weapons[0]);
            waitframe();
            self setClientDvar("cg_nopredict", 0);
        }
        else if(self getCurrentWeapon() == all_weapons[1])
        {
            self setClientDvar("cg_nopredict", 1);
            waitframe();
            self switchToWeapon(all_weapons[0]);
            waitframe();
            self switchToWeapon(all_weapons[1]);
            waitframe();
            self setClientDvar("cg_nopredict", 0);
        }
        else
        {
            self setClientDvar("cg_nopredict", 1);
            waitframe();
            self switchToWeapon(all_weapons[1]);
            waitframe();
            self switchToWeapon(all_weapons[2]);
            waitframe();
            self setClientDvar("cg_nopredict", 0);
        }
    }
}

/* Utils */

bool_to_text(bool)
{
    if(bool)
        return "[^2On^7]";
    else
        return "[^1Off^7]";
}

notify_all_players(notification)
{
    foreach(player in level.players)
    {
        player notify(notification);
    }
}

vector_scale( vector, scale )
{
	return ( vector[0] * scale, vector[1] * scale, vector[2] * scale );
}

print_all_not_self( text )
{
    foreach(player in level.players)
    {
        if(player == self)
            return;

        if(!player.pers["almost_hits"])
            return;

        player iPrintLn( text ); 
    }
}

is_within_radius(player, target)
{
    radius_check = cos(level.pers["almost_hit_sens"]);
	current = vectorNormalize(target getOrigin() - player geteye());
	ending = anglesToForward(player getPlayerAngles());
	vector_dots = vectorDot( current, ending );
	return vector_dots >= radius_check;
}

/*
	Re-call the damage-hook.
*/

init_new_hooks()
{
	level.prevCallbackPlayerDamage = level.callbackPlayerDamage;
	level.callbackPlayerDamage = ::new_damage_hook;
}

new_damage_hook(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset)
{
	if( sMeansofDeath != "MOD_FALLING" && sMeansofDeath != "MOD_TRIGGER_HURT" && sMeansofDeath != "MOD_SUICIDE" ) 
    {
		if(!brax_weapons(sWeapon) && eAttacker.pers["team"] != self.pers["team"])//Fake Hitmarkers, but no damage = no risk of accidental killing!
        {
            eAttacker thread maps\mp\gametypes\_damagefeedback::updateDamageFeedback("damage_feedback");
            return;
        }
		if(brax_weapons(sWeapon) && eAttacker.pers["team"] != self.pers["team"] && int(distance(self.origin, eAttacker.origin)*0.0254) < level.pers["meters"])//Prevents Barrelstuff!
		{
			eAttacker iPrintLnBold("You Must Be Atleast Be [^2" + level.pers["meters"] + "m^7] Away!");
			return;
		}
		if(brax_weapons(sWeapon) && int(distance(self.origin, eAttacker.origin)*0.0254) >= level.pers["meters"])//Prevents Hitmarks + Confirms Meter Check!
			iDamage = 150;
	}
	self [[level.prevCallbackPlayerDamage]](eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset);
}

brax_weapons( weapons )
{
	if ( !isDefined ( weapons ) )
		return false;
    
	brax_classes = getweaponclass( weapons );

	if ( brax_classes == "weapon_sniper" || isSubStr(weapons, "fal_" ) || weapons == "throwingknife_mp" || weapons == "MOD_IMPACT" || weapons == "MOD_RIFLE_BULLET")
		return true;
    else
        return false;
}