/**
 * Copyright 1998-2013 Epic Games, Inc. All Rights Reserved.
 */
class UTVehicleFactory_Walker extends UTVehicleFactory;

defaultproperties
{

	Begin Object Name=SVehicleMesh
		  	SkeletalMesh=SkeletalMesh'MECHBOT.mechframe19_Cylinder'
		Translation=(X=-400.0,Y=0.0,Z=-70.0) // -60 seems about perfect for exact alignment, -70 for some 'lee way'
	End Object

	Components.Remove(Sprite)

	Begin Object Name=CollisionCylinder
		CollisionHeight=+20.0
		CollisionRadius=+200.0
		Translation=(X=0.0,Y=0.0,Z=-40.0)
	End Object

	VehicleClassPath="Phoenix.UTVehicle_Walker_Content"
	DrawScale=1.3
}
