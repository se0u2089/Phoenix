class GameHUD extends UTHUDBase;

var ZomHUD HudMovie;
var bool bTargeted;   


//var ZOMPauseMenu PauseMenu;
var GFxProjectedItemUI      ItemUI;
var GFxProjectedItemUI FloatingUIs;
var float ItemLocation;
var Vector VectorLocation;

var LinearColor Defaults;

enum EActorBracketStyle
{
	EABS_3DActorBrackets
};

// INDICATOR INFOS
struct SRadarInfo
{
	var DemoPawns DemoPawns;
	var MaterialInstanceConstant MaterialInstanceConstant;
	var bool DeleteMe;
	var Vector2D Offset;
	var float Opacity;
};

struct SObjectiveInfo
{
	var ObjectiveActor ObjectiveActor;
	var MaterialInstanceConstant MaterialInstanceConstant;
	var bool DeleteMe;
	var Vector2D Offset;
	var float Opacity;
};
var array<SRadarInfo> RadarInfo;
var array<SObjectiveInfo> ObjectiveInfo;

var EActorBracketStyle ActorBracketStyle;

simulated function PostBeginPlay()
{
	super.PostBeginPlay();
	CreateHUD();

}

function AddPostRenderedActor(Actor A)
{
	// Remove post render call for UTPawns as we don't want the name bubbles showing
	if (DemoPawns(A) != None)
	{
		return;
	}

	Super.AddPostRenderedActor(A);
}

function CreateHUD()
{
     HudMovie = new class'ZomHUD';
                           // HudMovie = new class'UTGFxTeamHUD';
	HudMovie.SetTimingMode(TM_Real);
	HudMovie.Init(class'Engine'.static.GetEngine().GamePlayers[HudMovie.LocalPlayerOwnerIndex]);
	HudMovie.SetViewScaleMode(SM_ExactFit);
        HudMovie.SetAlignment(Align_TopLeft);
}


 function ResolutionChanged()
{
   super.ResolutionChanged();


     if ( HUDMovie != None )
	{
		HUDMovie.Close(false);
		HUDMovie = None;
		ItemUI.Close(false);
		ItemUI = None;
	        CreateHUD();
	}

   
}

exec function ToggleInventory()
{
        if(ItemUI == None)
        {
         ItemUI = new class'GFxProjectedItemUI';
         ItemUI.LocalPlayerOwnerIndex = class'Engine'.static.GetEngine().GamePlayers.Find(LocalPlayer(PlayerOwner.Player));
         ItemUI.SetTimingMode(TM_Real);
         ItemUI.Start();
        }
        else
        {
        }
}


event PostRender()
{
	local Actor HitActor;
	local Vector HitLocation, HitNormal, EyeLocation;
	local Rotator EyeRotation;
	//local MyHUDInterface HUDInterface;
	local string traceName;
	local string traceEnergy;
	local int traceHealth;
	local int traceHealthMax;

        local int i, Index;
	local Vector WorldHUDLocation, ScreenHUDLocation, ActualPointerLocation, CameraViewDirection, PawnDirection, ObjectiveDirection, CameraLocation;
	local Rotator CameraRotation;
	local DemoPawns DemoPawns;
	local ObjectiveActor ObjectiveActor;
	local float PointerSize;




        RenderDelta = WorldInfo.TimeSeconds - LastHUDRenderTime;
        //******************** For Pawns
        //******************************
        for (i = 0; i < RadarInfo.Length; ++i)
	{
		RadarInfo[i].DeleteMe = true;
	}
	
        //******************** For objective Actors
        //*****************************************
	for (i = 0; i < ObjectiveInfo.Length; ++i)
	{
		ObjectiveInfo[i].DeleteMe = true;
	}


	// Update the radar infos and see if we need to add or remove any
	ForEach DynamicActors(class'DemoPawns', DemoPawns)
	{
	  if(DemoPawns.bIsObjective == false)
	  {
           //return;
	  }
	  else
	  {
        	if (DemoPawns != PlayerOwner.Pawn)
		{
			Index = RadarInfo.Find('DemoPawns', DemoPawns);
			// This pawn was not found in our radar infos, so add it
			if (Index == INDEX_NONE && DemoPawns.Health > 0)
			{
				i = RadarInfo.Length;
				RadarInfo.Length = RadarInfo.Length + 1;
				RadarInfo[i].DemoPawns = DemoPawns;
				RadarInfo[i].MaterialInstanceConstant = new () class'MaterialInstanceConstant';

				if (RadarInfo[i].MaterialInstanceConstant != None)
				{
					RadarInfo[i].MaterialInstanceConstant.SetParent(Material'ZombiesGFX.Objectives.OBJPointerMat');


				}

				RadarInfo[i].DeleteMe = false;
			}
			else if (DemoPawns.Health > 0)
			{
				RadarInfo[Index].DeleteMe = false;
			}
		}
	   }
	}

        // Handle rendering of all of the radar infos
	PointerSize = Canvas.ClipX * 0.083f;
	PlayerOwner.GetPlayerViewPoint(CameraLocation, CameraRotation);
	CameraViewDirection = Vector(CameraRotation);


        for (i = 0; i < RadarInfo.Length; ++i)
	{
		if (!RadarInfo[i].DeleteMe)
		{
			if (RadarInfo[i].DemoPawns != None && RadarInfo[i].MaterialInstanceConstant != None)
			{
				// Handle the opacity of the pointer. If the player cannot see this pawn,
				// then fade it out half way, otherwise if he can, fade it in
				if (WorldInfo.TimeSeconds - RadarInfo[i].DemoPawns.LastRenderTime > 0.1f)
				{
					// Player has not seen this pawn in the last 0.1 seconds
					RadarInfo[i].Opacity = Lerp(RadarInfo[i].Opacity, 0.4f, RenderDelta * 4.f);
				}
				else
				{
					// Player has seen this pawn in the last 0.1 seconds
					RadarInfo[i].Opacity = Lerp(RadarInfo[i].Opacity, 1.f, RenderDelta * 4.f);
				}
				// Apply the opacity
				RadarInfo[i].MaterialInstanceConstant.SetScalarParameterValue('Opacity', RadarInfo[i].Opacity);

				// Get the direction from the player's pawn to the pawn
				PawnDirection = Normal(RadarInfo[i].DemoPawns.Location - PlayerOwner.Pawn.Location);

				// Check if the pawn is in front of me
				if (PawnDirection dot CameraViewDirection >= 0.f)
				{
					// Get the world HUD location, which is just above the pawn's head
					WorldHUDLocation = RadarInfo[i].DemoPawns.Location + (RadarInfo[i].DemoPawns.GetCollisionHeight() * Vect(0.f, 0.f, 1.f));
					// Project the world HUD location into screen HUD location
					ScreenHUDLocation = Canvas.Project(WorldHUDLocation);

					// If the screen HUD location is more to the right, then swing it to the left
					if (ScreenHUDLocation.X > (Canvas.ClipX * 0.5f))
					{
						RadarInfo[i].Offset.X -= PointerSize * RenderDelta * 4.f;
					}
					else
					{
						// If the screen HUD location is more to the left, then swing it to the right
						RadarInfo[i].Offset.X += PointerSize * RenderDelta * 4.f;
					}
					RadarInfo[i].Offset.X = FClamp(RadarInfo[i].Offset.X, PointerSize * -0.5f, PointerSize * 0.5f);
				
					// Set the rotation of the material icon
					ActualPointerLocation.X = Clamp(ScreenHUDLocation.X, 8, Canvas.ClipX - 8) + RadarInfo[i].Offset.X;
					ActualPointerLocation.Y = Clamp(ScreenHUDLocation.Y - PointerSize + RadarInfo[i].Offset.Y, 8, Canvas.ClipY - 8 - PointerSize) + (PointerSize * 0.5f);
					RadarInfo[i].MaterialInstanceConstant.SetScalarParameterValue('Rotation', GetAngle(ActualPointerLocation, ScreenHUDLocation));

					// Draw the material pointer
					Canvas.SetPos(ActualPointerLocation.X - (PointerSize * 0.5f), ActualPointerLocation.Y - (PointerSize * 0.5f));
					Canvas.DrawMaterialTile(RadarInfo[i].MaterialInstanceConstant, PointerSize, PointerSize, 0.f, 0.f, 1.f, 1.f);
				}
				else
				{
					// Handle rendering the on screen indicator when the actor is behind the camera
					// Project the pawn's location
					ScreenHUDLocation = Canvas.Project(RadarInfo[i].DemoPawns.Location);

					// Inverse the Screen HUD location
					ScreenHUDLocation.X = Canvas.ClipX - ScreenHUDLocation.X;

					// If the screen HUD location is on the right edge, then swing it to the left
					if (ScreenHUDLocation.X > (Canvas.ClipX - 8))
					{
						RadarInfo[i].Offset.X -= PointerSize * RenderDelta * 4.f;
						RadarInfo[i].Offset.X = FClamp(RadarInfo[i].Offset.X, PointerSize * -0.5f, PointerSize * 0.5f);
					}
					else if (ScreenHUDLocation.X < 8)
					{
						// If the screen HUD location is on the left edge, then swing it to the right
						RadarInfo[i].Offset.X += PointerSize * RenderDelta * 4.f;
						RadarInfo[i].Offset.X = FClamp(RadarInfo[i].Offset.X, PointerSize * -0.5f, PointerSize * 0.5f);
					}
					else
					{
						// If the screen HUD location is somewhere in the middle, then straighten it up
						RadarInfo[i].Offset.X = Lerp(RadarInfo[i].Offset.X, 0.f, 4.f * RenderDelta);
					}

					// Set the screen HUD location
					ScreenHUDLocation.X = Clamp(ScreenHUDLocation.X, 8, Canvas.ClipX - 8);
					ScreenHUDLocation.Y = Canvas.ClipY - 8;

					// Set the actual pointer location
					ActualPointerLocation.X = ScreenHUDLocation.X + RadarInfo[i].Offset.X;
					ActualPointerLocation.Y = ScreenHUDLocation.Y - (PointerSize * 0.5f);

					// Set the rotation of the material icon
					RadarInfo[i].MaterialInstanceConstant.SetScalarParameterValue('Rotation', GetAngle(ActualPointerLocation, ScreenHUDLocation));

					// Draw the material pointer
					Canvas.SetPos(ActualPointerLocation.X - (PointerSize * 0.5f), ActualPointerLocation.Y - (PointerSize * 0.5f));
					Canvas.DrawMaterialTile(RadarInfo[i].MaterialInstanceConstant, PointerSize, PointerSize, 0.f, 0.f, 1.f, 1.f);
				}
			}
		}
		else
		{
			// Null the variables previous stored so garbage collection can occur
			RadarInfo[i].DemoPawns = None;
			RadarInfo[i].MaterialInstanceConstant = None;
			// Remove from the radar info array
			RadarInfo.Remove(i, 1);
			// Back step one, to maintain the for loop
			--i;
		}
	}


        // Update the radar infos and see if we need to add or remove any
	ForEach DynamicActors(class'ObjectiveActor', ObjectiveActor)
	{
	  if( ObjectiveActor.bIsObjective == false)
	  {
           //return;
	  }
	  else
	  {
        	if ( ObjectiveActor != None)
		{
			Index = ObjectiveInfo.Find('ObjectiveActor',  ObjectiveActor);
			// This pawn was not found in our radar infos, so add it
			if (Index == INDEX_NONE &&  ObjectiveActor.bActive == true)
			{
				i = ObjectiveInfo.Length;
				ObjectiveInfo.Length = RadarInfo.Length + 1;
				ObjectiveInfo[i].ObjectiveActor = ObjectiveActor;
				ObjectiveInfo[i].MaterialInstanceConstant = new () class'MaterialInstanceConstant';

				if (ObjectiveInfo[i].MaterialInstanceConstant != None)
				{
					ObjectiveInfo[i].MaterialInstanceConstant.SetParent(Material'ZombiesGFX.Objectives.OBJPointerMat');


				}

				ObjectiveInfo[i].DeleteMe = false;
			}
			else if (ObjectiveActor.bActive == true)
			{
				ObjectiveInfo[Index].DeleteMe = false;
			}
		}
	   }
	}

        // Handle rendering of all of the radar infos
	PointerSize = Canvas.ClipX * 0.083f;
	PlayerOwner.GetPlayerViewPoint(CameraLocation, CameraRotation);
	CameraViewDirection = Vector(CameraRotation);


        for (i = 0; i < ObjectiveInfo.Length; ++i)
	{
		if (!ObjectiveInfo[i].DeleteMe)
		{
			if (ObjectiveInfo[i].ObjectiveActor != None && ObjectiveInfo[i].MaterialInstanceConstant != None)
			{
				// Handle the opacity of the pointer. If the player cannot see this pawn,
				// then fade it out half way, otherwise if he can, fade it in
				if (WorldInfo.TimeSeconds - ObjectiveInfo[i].ObjectiveActor.LastRenderTime > 0.1f)
				{
					// Player has not seen this pawn in the last 0.1 seconds
					ObjectiveInfo[i].Opacity = Lerp(ObjectiveInfo[i].Opacity, 0.4f, RenderDelta * 4.f);
				}
				else
				{
					// Player has seen this pawn in the last 0.1 seconds
					ObjectiveInfo[i].Opacity = Lerp(ObjectiveInfo[i].Opacity, 1.f, RenderDelta * 4.f);
				}
				// Apply the opacity
				ObjectiveInfo[i].MaterialInstanceConstant.SetScalarParameterValue('Opacity', ObjectiveInfo[i].Opacity);

				// Get the direction from the player's pawn to the pawn
				ObjectiveDirection = Normal(ObjectiveInfo[i].ObjectiveActor.Location - PlayerOwner.Pawn.Location);

				// Check if the pawn is in front of me
				if (ObjectiveDirection dot CameraViewDirection >= 0.f)
				{
					// Get the world HUD location, which is just above the pawn's head
					WorldHUDLocation = ObjectiveInfo[i].ObjectiveActor.Location + (ObjectiveInfo[i].ObjectiveActor.Height * Vect(0.f, 0.f, 1.f));
					// Project the world HUD location into screen HUD location
					ScreenHUDLocation = Canvas.Project(WorldHUDLocation);

					// If the screen HUD location is more to the right, then swing it to the left
					if (ScreenHUDLocation.X > (Canvas.ClipX * 0.5f))
					{
						ObjectiveInfo[i].Offset.X -= PointerSize * RenderDelta * 4.f;
					}
					else
					{
						// If the screen HUD location is more to the left, then swing it to the right
						ObjectiveInfo[i].Offset.X += PointerSize * RenderDelta * 4.f;
					}
					ObjectiveInfo[i].Offset.X = FClamp(ObjectiveInfo[i].Offset.X, PointerSize * -0.5f, PointerSize * 0.5f);
				
					// Set the rotation of the material icon
					ActualPointerLocation.X = Clamp(ScreenHUDLocation.X, 8, Canvas.ClipX - 8) + RadarInfo[i].Offset.X;
					ActualPointerLocation.Y = Clamp(ScreenHUDLocation.Y - PointerSize + RadarInfo[i].Offset.Y, 8, Canvas.ClipY - 8 - PointerSize) + (PointerSize * 0.5f);
					ObjectiveInfo[i].MaterialInstanceConstant.SetScalarParameterValue('Rotation', GetAngle(ActualPointerLocation, ScreenHUDLocation));

					// Draw the material pointer
					Canvas.SetPos(ActualPointerLocation.X - (PointerSize * 0.5f), ActualPointerLocation.Y - (PointerSize * 0.5f));
					Canvas.DrawMaterialTile(ObjectiveInfo[i].MaterialInstanceConstant, PointerSize, PointerSize, 0.f, 0.f, 1.f, 1.f);
				}
				else
				{
					// Handle rendering the on screen indicator when the actor is behind the camera
					// Project the pawn's location
					ScreenHUDLocation = Canvas.Project(ObjectiveInfo[i].ObjectiveActor.Location);

					// Inverse the Screen HUD location
					ScreenHUDLocation.X = Canvas.ClipX - ScreenHUDLocation.X;

					// If the screen HUD location is on the right edge, then swing it to the left
					if (ScreenHUDLocation.X > (Canvas.ClipX - 8))
					{
						ObjectiveInfo[i].Offset.X -= PointerSize * RenderDelta * 4.f;
						ObjectiveInfo[i].Offset.X = FClamp(ObjectiveInfo[i].Offset.X, PointerSize * -0.5f, PointerSize * 0.5f);
					}
					else if (ScreenHUDLocation.X < 8)
					{
						// If the screen HUD location is on the left edge, then swing it to the right
						ObjectiveInfo[i].Offset.X += PointerSize * RenderDelta * 4.f;
						ObjectiveInfo[i].Offset.X = FClamp(ObjectiveInfo[i].Offset.X, PointerSize * -0.5f, PointerSize * 0.5f);
					}
					else
					{
						// If the screen HUD location is somewhere in the middle, then straighten it up
						ObjectiveInfo[i].Offset.X = Lerp(ObjectiveInfo[i].Offset.X, 0.f, 4.f * RenderDelta);
					}

					// Set the screen HUD location
					ScreenHUDLocation.X = Clamp(ScreenHUDLocation.X, 8, Canvas.ClipX - 8);
					ScreenHUDLocation.Y = Canvas.ClipY - 8;

					// Set the actual pointer location
					ActualPointerLocation.X = ScreenHUDLocation.X + ObjectiveInfo[i].Offset.X;
					ActualPointerLocation.Y = ScreenHUDLocation.Y - (PointerSize * 0.5f);

					// Set the rotation of the material icon
					ObjectiveInfo[i].MaterialInstanceConstant.SetScalarParameterValue('Rotation', GetAngle(ActualPointerLocation, ScreenHUDLocation));

					// Draw the material pointer
					Canvas.SetPos(ActualPointerLocation.X - (PointerSize * 0.5f), ActualPointerLocation.Y - (PointerSize * 0.5f));
					Canvas.DrawMaterialTile(ObjectiveInfo[i].MaterialInstanceConstant, PointerSize, PointerSize, 0.f, 0.f, 1.f, 1.f);
				}
			}
		}
		else
		{
			// Null the variables previous stored so garbage collection can occur
			ObjectiveInfo[i].ObjectiveActor = None;
			ObjectiveInfo[i].MaterialInstanceConstant = None;
			// Remove from the radar info array
			ObjectiveInfo.Remove(i, 1);
			// Back step one, to maintain the for loop
			--i;
		}
	}
	// Setup the render delta




        if (PlayerOwner != None)
	{
		PlayerOwner.GetPlayerViewPoint(EyeLocation, EyeRotation);

		ForEach TraceActors(class'Actor', HitActor, HitLocation, HitNormal, EyeLocation + Vector(EyeRotation) * PlayerOwner.InteractDistance * 3 , EyeLocation, Vect(1.f, 1.f, 1.f),, TRACEFLAG_Bullet)
		{
			if (HitActor == PlayerOwner || HitActor == PlayerOwner.Pawn || !FastTrace(HitActor.Location, EyeLocation))
			{
				continue;
			}

	//		HUDInterface = MyHUDInterface(HitActor);

			if ( HitActor.IsA('Pawn') || HitActor.IsA('DemoAIBasePawn') || HitActor.IsA('ZomExplodingBarrel') || HitActor.IsA('VaultActor') )
			{
				


			}

                        else
                        {

                                bTargeted=false;

                                HudMovie.showTrace(bTargeted, traceName, traceHealth, traceHealthMax,traceEnergy);

                        }

		}
	}



         HudMovie.TickHUD();
         LastHUDRenderTime = WorldInfo.TimeSeconds;
         Super.PostRender();

}


function float GetAngle(Vector PointB, Vector PointC)
{
	// Check if angle can easily be determined if it is up or down
	if (PointB.X == PointC.X)
	{
		return (PointB.Y < PointC.Y) ? Pi : 0.f;
	}

	// Check if angle can easily be determined if it is left or right
	if (PointB.Y == PointC.Y)
	{
		return (PointB.X < PointC.X) ? (Pi * 1.5f) : (Pi * 0.5f);
	}

	return (2.f * Pi) - atan2(PointB.X - PointC.X, PointB.Y - PointC.Y);
}




singular event Destroyed()
{
	if (HudMovie != none)
	{
		HudMovie.Close(true);
		HudMovie = none;
	}

}

exec function ShowMenu()
{
	// if using GFx HUD, use GFx pause menu
	TogglePauseMenu();
}


function TogglePauseMenu()
{

}

function CompletePauseMenuClose()
{

}

function CloseOtherMenus();

function ExtraUnpause()
{

}

Defaultproperties()
{
        ActorBracketStyle=EABS_3DActorBrackets
        Defaults = (R=64,G=95,B=155,A=155)
}