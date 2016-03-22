
class DemoPlayerController extends UTPlayerController dependson(DemoPawn) ;


var config int OldHealths;
var rotator r;
var bool bWantsHints;

//Zombie stuff
var() SoundCue StompSound;
var DemoAIBasePawn Z;
var bool CanDoStomp;

//****EndCredit*****
//Objectives
var int CurrentObjective;

// Score Kill Points
var int Credits;
var int Lives;

var int KillStreak;
var int LastKillStreak;
var int ItemsCollected;

var int TommyGunAmmoCount;
var int TommyGunMaxAmmoCount;
var int TommyGunClipCount;
var int TommyGunClipCountMax;
//M34A
var int M34AAmmoCount;
var int M34AMaxAmmoCount;
var int M34AClipCount;
var int M34AClipCountMax;


var bool M34AEquipped;
var bool TommyGunEquipped;

var bool bNewGame;

/** Holds the dimensions of the viewport */
var vector2D ViewportSize;
  var MobileInputZone SliderZone;
  var MobileInputZone StickMoveZone;
var MobileInputZone StickLookZone;
var MobileInputZone FreeLookZone;

   var bool bLookAtDestination;
   var CloudSaveData SaveData;

var int Slot1DocIndex;
var int Slot2DocIndex;
 var MobilePlayerInput MPI;
var DemoPawn P;


//AnimSets per weapon animsets
var array<AnimSet> defaultAnimSet;

//Variable for opening active elements.
var gfxmovieplayer Movie;




var bool IsTommyGunWeapon;
var bool IsM34AWeapon;

//******Itemsbools*******
var bool IsZOMAmmoSmall;
var bool IsSmallHealth;

//******ExternalBools*****
var bool Used;
var bool Redo;
var bool HasZOM;

var bool HasM34A;
var bool HasTommyGun;

var bool MadeNoise;
var float DistanceToPlayer;
var int ClimbHeight;
var Vector MoveLocation;
var SoundCue ReloadSound; // Only used in traditional FPS games.
var bool bVaulted;
var bool bDoingSlam;
var name VaultStartSocketName;
var name VaultEndSocketName;
//****** Generic Weapon Animations ********
//**when running no need to specify an animation for a specific weapon as its already called.
var(Animations) name	WeaponRunStartAnim;
var(Animations) name	WeaponRunIdleAnim;
var(Animations) name	WeaponRunEndAnim;

//****** Sprinting Variables *******
var float		Stamina;
var float		SprintTimer;
var float		SprintRecoverTimer;
var float		Empty;
var bool		bSprinting;
var bool                bCurrentlyReloading;// Dont want to forget that your reloading.
var bool                bZoomedIn;
//Special Case for specific weapons
var CameraAnim          ReloadCameraAnim; //Everytime you reload a nice camera animation will play



var float PreDist;//Camera currently depreciated in this FPS game.

var Vector MyLocation;
var Vector ItemLoc;
var Vector VectorLocation;



//Level Event Vars
var int LastEventNumber;
//Damage Taken Show//
//TEMP



//Display Damage Info
//TEMP
var PostProcessSettings UTPostProcess_Console;

var bool bShowNightVision;
var bool bMICSetUP;

var MaterialEffect NightVision;
var transient MaterialInstanceConstant NightVisionInstance;

 var bool bBehindView;

    var float LastCameraTimeStamp;
  var bool bFreeCamera;
      var int CameraZoom;
   var vector ThirdPersonCamOffset;
var float CamTurnSpeed;
//var CustomCamBase CameraBase;

var float zOffset;
var float pitchOffset;
var float horizontalOffset;


   event NotifyOnAnimEnd(AnimNodeSequence _SeqNode, float _fPlayedTime, float _fExcessTime);



simulated event GetPlayerViewPoint( out vector POVLocation, out Rotator POVRotation )
{
	local float DeltaTime;
	local DemoPawn P;

	P = IsLocalPlayerController() ? DemoPawn(CalcViewActor) : None;

	if (PlayerCamera == None
		&& LastCameraTimeStamp == WorldInfo.TimeSeconds
		&& CalcViewActor == ViewTarget
		&& CalcViewActor != None
		&& CalcViewActor.Location == CalcViewActorLocation
		&& CalcViewActor.Rotation == CalcViewActorRotation
		)
	{
		if ( (P == None) || ((P.EyeHeight == CalcEyeHeight) && (P.WalkBob == CalcWalkBob)) )
		{
			// use cached result
			POVLocation = CalcViewLocation;
			POVRotation = CalcViewRotation;
			return;
		}
	}

	DeltaTime = WorldInfo.TimeSeconds - LastCameraTimeStamp;
	LastCameraTimeStamp = WorldInfo.TimeSeconds;

	// support for using CameraActor views
	if ( CameraActor(ViewTarget) != None )
	{
		if ( PlayerCamera == None )
		{
			super.ResetCameraMode();
			SpawnCamera();
		}
		super.GetPlayerViewPoint( POVLocation, POVRotation );
	}
	else
	{
		/*
		if ( PlayerCamera != None )
		{
		//	PlayerCamera.Destroy();
		//	PlayerCamera = None;
		}
		*/
		if ( ViewTarget != None )
		{
			POVRotation = Rotation;
			if ( (PlayerReplicationInfo != None) && PlayerReplicationInfo.bOnlySpectator && (UTVehicle(ViewTarget) != None) )
			{
				UTVehicle(ViewTarget).bSpectatedView = true;
				ViewTarget.CalcCamera( DeltaTime, POVLocation, POVRotation, FOVAngle );
				UTVehicle(ViewTarget).bSpectatedView = false;
			}
			else
			{
			ViewTarget.CalcCamera( DeltaTime, POVLocation, POVRotation, FOVAngle );
			}
			if ( bFreeCamera )
			{
				POVRotation = Rotation;
			}
		}
		else
		{
			CalcCamera( DeltaTime, POVLocation, POVRotation, FOVAngle );
			return;
		}
	}

	// apply view shake
	POVRotation = Normalize(POVRotation + ShakeRot);
	POVLocation += ShakeOffset >> Rotation;

	if( CameraEffect != none )
	{
		CameraEffect.UpdateLocation(POVLocation, POVRotation, GetFOVAngle());
	}


	// cache result
	CalcViewActor = ViewTarget;
	CalcViewActorLocation = ViewTarget.Location;
	CalcViewActorRotation = ViewTarget.Rotation;
	CalcViewLocation = POVLocation;
	CalcViewRotation = POVRotation;

	if ( P != None )
	{
		CalcEyeHeight = P.EyeHeight;
		CalcWalkBob = P.WalkBob;
	}
}


simulated function name GetDefaultCameraMode(PlayerController RequestedBy)
{
    return 'ThirdPerson';   
}



  function UpdateRotation( float DeltaTime )
{
   local Rotator   DeltaRot, ViewRotation;
  
   ViewRotation = Rotation;

   if (Pawn!=none) 
   {

	Pawn.SetDesiredRotation(ViewRotation);
   }
  
   //=================================

   
   // Calculate Delta to be applied on ViewRotation
   DeltaRot.Yaw   = PlayerInput.aTurn * CamTurnSpeed;
   DeltaRot.Pitch   = PlayerInput.aLookUp;


	//retrieves new rotation data from playerinput values
	ProcessViewRotation( DeltaTime, ViewRotation, DeltaRot );
   

	SetRotation(ViewRotation);

	//Makes sure to apply any view shake, yaaay
	ViewShake( deltaTime );
	
    

	r = ViewRotation;
	r.Roll = Rotation.Roll;

   
	if (Pawn!=none)
	{
		
	  Pawn.FaceRotation(r, deltatime);
	}

}






reliable client function ClientSetBehindView(bool bNewBehindView)
{
	if (LocalPlayer(Player) != None)
	{
		SetBehindView(bNewBehindView);
	}
	// make sure we recalculate camera position for this frame
	LastCameraTimeStamp = WorldInfo.TimeSeconds - 1.0;
}



function SetBehindView(bool bNewBehindView)
{
	bBehindView = bNewBehindView;
	if ( !bBehindView )
	{
		bFreeCamera = false;
	}

	if (LocalPlayer(Player) == None)
	{
		ClientSetBehindView(bNewBehindView);
	}

	// make sure we recalculate camera position for this frame
	LastCameraTimeStamp = WorldInfo.TimeSeconds - 1.0;
}



//exec function DebugHUD(string text)
//{
//	if(myHUD != none)
//		GameHUD(myHUD).HudMovie.Debug(text);
//}











Public function CalculateHealth()
{
        if(Pawn.Health <=0)
	{
           ConsoleCommand("Suicide");
        }
}

function PawnDied(Pawn Pn)
{


  SetTimer(1.0,true,'CheckDead');

}
function CheckDead()
{
  Lives--;
  if(Lives == 0)
  {
    ConsoleCommand("restartlevel");
  }
}



/***********************Stop Shooting in certain situations******************/

exec function StartFire(optional byte FireModeNum)
{

	if(bSprinting == true) //You can't shoot while running // or reloading really
		return;


        super.StartFire(FireModeNum);
}

exec function StartSprint()

{
         local DemoPawn MP;
         local UTWeapon PD;
         P = DemoPawn(Pawn);
         PD = UTWeapon(Pawn.Weapon);
         PlayerCamera.CameraStyle = 'SprintCam';
         if((Vsize(Pawn.Velocity) == 0) || bCurrentlyReloading == true || bZoomedIn == true)
         {

         }
         else if((Vsize(Pawn.Velocity) > 0))
         {
             Pawn.GroundSpeed = 700;
          //   Pawn.Weapon.PlayWeaponAnimation(WeaponRunStartAnim,0.5); // for trADITIONAL fps GAMES.
             PD.BobDamping=0.75000;
             bSprinting = true;

                if(Pawn.Groundspeed >= 490)
                {
                  setTimer(SprintTimer, false, 'EmptySprint');
                }
         }

    foreach VisibleCollidingActors(class'DemoPawn', MP, 45, Pawn.Location)
   {
      MP.StepInterval = 9.0; //
   }



}


simulated function EmptySprint()
{


          Stamina = Empty;
          Pawn.Groundspeed = 120;
          bSprinting = false;
          setTimer(SprintRecoverTimer, false, 'ReplenishStamina');


}

simulated function ReplenishStamina()
{

       Stamina = 3.0;
       bSprinting = false;

}

exec function StopSprinting()
{
  local UTWeapon PD;
  local DemoPawn MP;
  P = DemoPawn(Pawn);
  PD = UTWeapon(Pawn.Weapon);
  PlayerCamera.CameraStyle = 'ReturnCam';
  if((Vsize(Pawn.Velocity) == 0))
         {

         }
    else
    {

    //  Pawn.Weapon.PlayWeaponAnimation(WeaponRunEndAnim,0.5);
      Pawn.GroundSpeed = 120;
      bSprinting = false;
      PD.BobDamping=0.15000;

    }
      foreach VisibleCollidingActors(class'DemoPawn', MP, 45, Pawn.Location)
   {
      MP.StepInterval = 7.0;
   }
}



 ////**********Request RELOAD*********************************************************
exec function RequestReload()
{
	local AimingDemoWeaponClass MYWP;
	local int clips;   //Clips will be added back through the playercontroller when the ammo is picked up
	local DemoPawn MP;
	local Attachment_TommyGun2 AF;


        MYWP = AimingDemoWeaponClass(Pawn.Weapon);

        if(bSprinting == true)
        {
          //do nothing
        }

        else if(MYWP != none)
	{
		clips = MYWP.clips;

		if(clips > 0 && !MYWP.bIsReloading && MYWP.AmmoCount != MYWP.MaxAmmoCount)
		{


                	bCurrentlyReloading = true;
                        SetTimer(2.5,false,'EndReload');
                        MYWP.bIsReloading = true;
                        MYWP.SetTimer(2.5, false, 'Reload');
		        MYWP.PlayWeaponAnimation('WeaponReload',2.5);
		        MYWP.WeaponPlaySound(ReloadSound);
		        SetTimer(2.5, false, 'EndReload');
		        PlayCameraAnim(CameraAnim'ZombieWeapons.Camera.M4A1Reload');


                              foreach VisibleCollidingActors(class'DemoPawn', MP, 45, Pawn.Location)
                              {
                                        MP.TopHalfAnimSlot.PlayCustomAnim('UlariSwordtoRifleSwapFBX01', 1.0, 0.2, 0.2, FALSE, TRUE);
                              }


		}
	}


}

//Play empty reload animation called from AimingWeaponClass.
simulated function WeaponEmptyM()
{
    local DemoPawn MP;

    local Attachment_TommyGun2 TG;

    MP = DemoPawn(Pawn);
    MP.EmptyWeapon = true;
    MP.PlayEmpty();


    bCurrentlyReloading = true;


    foreach AllActors(class'Attachment_TommyGun2', TG)
    {
         TG.ReloadANIMS();
         MP.EmptyWeapon = false;
    }
    SetTimer(2.5, false, 'EndReload');
}

function EndReload() // Make sure to set reloading to false when its done.
{
 bCurrentlyReloading = false;
}

function LosingHealth()
{
  P = DemoPawn(Pawn);
  if(P.Health <= 0)
  {
    ConsoleCommand("Suicide"); //Make sure you are really dead!
    WorldInfo.Game.Broadcast(self,"Im dead");
  }
}


function AddHealthSmall()
{

}

/******************************Handles the third person AIMING.***************
*/

exec function StartAltFire( optional byte FireModeNum )

{
   local DemoPawn MP;

   if(bCurrentlyReloading == true || bSprinting == true)
   {

   }
   else if(bCurrentlyReloading == false || bSprinting == false)
   {
        foreach VisibleCollidingActors(class'DemoPawn', MP, 45, Pawn.Location)
          {
             MP.AIMP();
             ConsoleCommand("FOV 45");
          }
          bZoomedIn = true;
   }

   	//ServerViewSelf();
}




exec function StopAltFire( optional byte FireModeNum )

{
   local DemoPawn MP;
    
    if(bCurrentlyReloading == true || bSprinting == true)
   {

   }

    else if(bCurrentlyReloading == false || bSprinting == false)
    {
          foreach VisibleCollidingActors(class'DemoPawn', MP, 45, Pawn.Location)
            {
                MP.AIMPRelease();
                ConsoleCommand("FOV 90");
            }
    }
    bZoomedIn = false;

}



//Query all remote events in level.
function TriggerRemoteKismetEvent( name EventName )
{
    local array<SequenceObject> AllSeqEvents;
    local Sequence GameSeq;
    local int i;

    GameSeq = WorldInfo.GetGameSequence();
    if (GameSeq != None)
    {
        // find any Level Reset events that exist
        GameSeq.FindSeqObjectsByClass(class'SeqEvent_RemoteEvent', true, AllSeqEvents);

        // activate them
        for (i = 0; i < AllSeqEvents.Length; i++)
        {
	    if(SeqEvent_RemoteEvent(AllSeqEvents[i]).EventName == EventName)
	    SeqEvent_RemoteEvent(AllSeqEvents[i]).CheckActivate(WorldInfo, None);
	}
    }
}





defaultproperties
{

        SprintTimer=3.0
	SprintRecoverTimer=4
	Stamina=3.0
        Empty=1.0
        //OldHealth = 100;
        VehicleCheckRadiusScaling=1.0
         WeaponRunStartAnim="WeaponRunStart" //
         WeaponRunIdleAnim="WeaponRunIdle" //
         WeaponRunEndAnim="WeaponRunEnd" //
        Name="Default__mainPlayerController"
	bSprinting = false
        bCurrentlyReloading = false

        IsZOMWeapon = false

        IsM34AWeapon = false

        IsTommyGunWeapon = false

        IsZOMAmmoSmall =false
        IsSmallHealth = false
        Redo = false
        Used = true
        HasZOM = false

        HasM34A = false

        Credits = 0
        KillStreak = 0
        LastKillStreak = 0
        ItemsCollected = 0
        MadeNoise = false
        CanDoStomp = false
        bRotateMiniMap=true



        //TommyGun
        TommyGunAmmoCount = 0
        TommyGunMaxAmmoCount = 0
        TommyGunClipCount = 0
        TommyGunClipCountMax = 0
        //M34A
        M34AAmmoCount = 0
        M34AMaxAmmoCount = 0
        M34AClipCount = 0
        M34AClipCountMax = 0
       CameraClass=class'Phoenix.AdvKitCamera'
       // CameraClass=class'Phoenix.CustomCamera2'
             //CameraClass=class'Phoenix.CustomCamera'
        //CameraClass=class'Phoenix.CustomCamBase'

pitchOffset =30
horizontalOffset =300
       bBehindView=True
             CamTurnSpeed = 1.4
              zOffset=10
}
