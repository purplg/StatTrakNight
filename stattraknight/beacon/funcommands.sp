/**
 * vim: set ts=4 :
 * =============================================================================
 * SourceMod Basic Fun Commands Plugin
 * Implements basic punishment commands.
 *
 * SourceMod (C)2004-2008 AlliedModders LLC.  All rights reserved.
 * =============================================================================
 *
 * This program is free software; you can redistribute it and/or modify it under
 * the terms of the GNU General Public License, version 3.0, as published by the
 * Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
 * details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * As a special exception, AlliedModders LLC gives you permission to link the
 * code of this program (as well as its derivative works) to "Half-Life 2," the
 * "Source Engine," the "SourcePawn JIT," and any Game MODs that run on software
 * by the Valve Corporation.  You must obey the GNU General Public License in
 * all respects for all other code used.  Additionally, AlliedModders LLC grants
 * this exception to all derivative works.  AlliedModders LLC defines further
 * exceptions, found in LICENSE.txt (as of this writing, version JULY-31-2007),
 * or <http://www.sourcemod.net/license.php>.
 *
 * Version: $Id$
 */

#pragma semicolon 1

#include <sdktools>
#undef REQUIRE_PLUGIN

public Plugin:myinfo =
{
	name = "Fun Commands",
	author = "AlliedModders LLC",
	description = "Fun Commands",
	version = SOURCEMOD_VERSION,
	url = "http://www.sourcemod.net/"
};

// Sounds
new String:g_BlipSound[PLATFORM_MAX_PATH];
new String:g_BeepSound[PLATFORM_MAX_PATH];
new String:g_FinalSound[PLATFORM_MAX_PATH];
new String:g_BoomSound[PLATFORM_MAX_PATH];
new String:g_FreezeSound[PLATFORM_MAX_PATH];

// Following are model indexes for temp entities
new g_BeamSprite        = -1;
new g_HaloSprite        = -1;

// Basic color arrays for temp entities
new redColor[4]		= {255, 75, 75, 255};
new greenColor[4]	= {75, 255, 75, 255};
new blueColor[4]	= {75, 75, 255, 255};
new greyColor[4]	= {128, 128, 128, 255};

// Serial Generator for Timer Safety
new g_Serial_Gen = 0;

// Flags used in various timers
#define DEFAULT_TIMER_FLAGS TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE

// Include various commands and supporting functions
#include "stattraknight/beacon/beacon.sp"

Funcommands_OnPluginStart()
{
	if (FindPluginByFile("basefuncommands.smx") != null)
	{
		ThrowError("This plugin replaces basefuncommands.  You cannot run both at once.");
	}

	LoadTranslations("common.phrases");
	LoadTranslations("funcommands.phrases");

	RegisterCvars( );
	HookEvents( );
}

RegisterCvars( )
{
	// beacon
	g_Cvar_BeaconRadius = CreateConVar("sm_beacon_radius", "375", "Sets the radius for beacon's light rings.", 0, true, 50.0, true, 1500.0);

	AutoExecConfig(true, "funcommands");
}

HookEvents( )
{
	decl String:folder[64];
	GetGameFolderName(folder, sizeof(folder));

	if (strcmp(folder, "tf") == 0)
	{
		HookEvent("teamplay_win_panel", Event_RoundEnd, EventHookMode_PostNoCopy);
		HookEvent("teamplay_restart_round", Event_RoundEnd, EventHookMode_PostNoCopy);
		HookEvent("arena_win_panel", Event_RoundEnd, EventHookMode_PostNoCopy);
	}
	else if (strcmp(folder, "nucleardawn") == 0)
	{
		HookEvent("round_win", Event_RoundEnd, EventHookMode_PostNoCopy);
	}
	else
	{
		HookEvent("round_end", Event_RoundEnd, EventHookMode_PostNoCopy);
	}
}

public OnMapStart()
{
	new Handle:gameConfig = LoadGameConfigFile("funcommands.games");
	if (gameConfig == null)
	{
		SetFailState("Unable to load game config funcommands.games");
		return;
	}

	if (GameConfGetKeyValue(gameConfig, "SoundBlip", g_BlipSound, sizeof(g_BlipSound)) && g_BlipSound[0])
	{
		PrecacheSound(g_BlipSound, true);
	}

	if (GameConfGetKeyValue(gameConfig, "SoundBeep", g_BeepSound, sizeof(g_BeepSound)) && g_BeepSound[0])
	{
		PrecacheSound(g_BeepSound, true);
	}

	if (GameConfGetKeyValue(gameConfig, "SoundFinal", g_FinalSound, sizeof(g_FinalSound)) && g_FinalSound[0])
	{
		PrecacheSound(g_FinalSound, true);
	}

	if (GameConfGetKeyValue(gameConfig, "SoundBoom", g_BoomSound, sizeof(g_BoomSound)) && g_BoomSound[0])
	{
		PrecacheSound(g_BoomSound, true);
	}

	if (GameConfGetKeyValue(gameConfig, "SoundFreeze", g_FreezeSound, sizeof(g_FreezeSound)) && g_FreezeSound[0])
	{
		PrecacheSound(g_FreezeSound, true);
	}

	new String:buffer[PLATFORM_MAX_PATH];
	if (GameConfGetKeyValue(gameConfig, "SpriteBeam", buffer, sizeof(buffer)) && buffer[0])
	{
		g_BeamSprite = PrecacheModel(buffer);
	}

	if (GameConfGetKeyValue(gameConfig, "SpriteHalo", buffer, sizeof(buffer)) && buffer[0])
	{
		g_HaloSprite = PrecacheModel(buffer);
	}

	delete gameConfig;
}

Funcommands_OnMapEnd()
{
	KillAllBeacons( );
}

public Action:Event_RoundEnd(Handle:event,const String:name[],bool:dontBroadcast)
{
	KillAllBeacons( );
}
