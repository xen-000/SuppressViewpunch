#include <sourcemod>
#include <sdktools>
#include <dhooks>

#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
	name 			= "SuppressViewpunch",
	author 			= "xen",
	description 	= "Suppresses viewpunch when a player slams into the ground.",
	version 		= "1.0",
	url 			= ""
};

Handle g_hPlayerRoughLandingEffects;

ConVar g_cvarSuppressViewpunch = null;

public void OnPluginStart()
{
	Handle hGameData = LoadGameConfigFile("SuppressViewpunch.games");
	if(!hGameData)
		SetFailState("Failed to load SuppressViewpunch gamedata.");

	// void CGameMovement::PlayerRoughLandingEffects( float fvol )
	g_hPlayerRoughLandingEffects = DHookCreateFromConf(hGameData, "CGameMovement__PlayerRoughLandingEffects");
	if(!g_hPlayerRoughLandingEffects)
	{
		delete hGameData;
		SetFailState("Failed to setup detour for CGameMovement__PlayerRoughLandingEffects");
	}

	if(!DHookEnableDetour(g_hPlayerRoughLandingEffects, false, Detour_PlayerRoughLandingEffects))
	{
		delete hGameData;
		SetFailState("Failed to detour CGameMovement__PlayerRoughLandingEffects.");
	}

	delete hGameData;

	g_cvarSuppressViewpunch = CreateConVar("sm_suppress_viewpunch", "1", "Whether to suppress viewpunch when a player slams into the ground");
}

public MRESReturn Detour_PlayerRoughLandingEffects(Handle hParams)
{
	if (g_cvarSuppressViewpunch.BoolValue)
		return MRES_Supercede;

	return MRES_Ignored;
}
