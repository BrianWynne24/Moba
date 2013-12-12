GM.Name		 = "MOBA";
GM.Author 	 = "Annoyed Tree";
GM.Website	 = "";
GM.Folder	 = "moba"; //Do not edit this...

AddCSLuaFile( GM.Folder .. "/load.lua" ); //"heist/load.lua"
include( GM.Folder .. "/load.lua" );