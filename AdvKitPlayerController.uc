
class AdvKitPlayerController extends CastlePC
dependson(DemoPawn)
	dependson(UTPlayerReplicationInfo)
	config(Game);

  var bool bInAim;
 var transient float FOVNonlinearZoomInterpSpeed;
var transient bool bNonlinearZoomInterpolation;
/** Used to scale changes in rotation when the FOV is zoomed */
var float ZoomRotationModifier;
      var int CameraZoom;
var config bool bSimpleCrosshair;
 var float FOVLinearZoomRate;
var config bool bCenteredWeaponFire;
/** set when the last camera anim we played was caused by damage - we only let damage shakes override other damage shakes */
var bool bCurrentCamAnimIsDamageShake;
/** set if camera anim modifies FOV - don't do any FOV interpolation while camera anim is playing */
var bool bCurrentCamAnimAffectsFOV;
/** Vibration  */
var ForceFeedbackWaveform CameraShakeShortWaveForm, CameraShakeLongWaveForm;
	var int clips;
         var DemoPawns                           Companions[3];
var config int OldHealths;
var rotator r;

/** camera anim played when hit (blend strength depends on damage taken) */
var CameraAnim DamageCameraAnim;

var globalconfig	bool	bLandingShake;

var float LastCameraTimeStamp; /** Used during matinee sequences */
var class<Camera> MatineeCameraClass;
var CameraAnimInst CameraAnimPlayer;

/**hold a AdvKitPawn reference to prevent alot of unecessary casting (set in Posses)*/
var DemoPawns advPawn;
var bool bBehindView;
//NOTE: since FOV is set in the PlayerController, I figured I'd place
//the camera distance variables here as well
/**minimum distance of the camera to the pawn*/
var float fMinCameraDistance;
/**maximum distance of the camera to the pawn*/
var float fMaxCameraDistance;

//****** Sprinting Variables *******
var float		Stamina;
var float		SprintTimer;
var float		SprintRecoverTimer;
var float		Empty;
var bool		bSprinting;
var bool                bCurrentlyReloading;// Dont want to forget that your reloading.
var bool                bZoomedIn;
var float   PreDist;
var PostProcessSettings CamOverridePostProcess;

/** additional post processing settings modifier that can be applied
 * @note: defaultproperties for this are hardcoded to zeroes in C++
 */
var PostProcessSettings PostProcessModifier;

var config bool bNoCrosshair;

  //Special Case for specific weapons
var CameraAnim          ReloadCameraAnim; //Everytime you reload a nice camera animation will play

  // var CloudSaveData SaveData;

//var int Slot1DocIndex;
//var int Slot2DocIndex;


enum EWeaponHand
{
	HAND_Right,
	HAND_Left,
	HAND_Centered,
	HAND_Hidden,
};
var globalconfig EWeaponHand WeaponHandPreference;
var EWeaponHand	WeaponHand;





 var bool bFreeCamera;
 var Actor CalcViewActor;
var vector CalcViewActorLocation;
var rotator CalcViewActorRotation;
var vector CalcViewLocation;
var rotator CalcViewRotation;
var float CalcEyeHeight;
var vector CalcWalkBob;



var Vector MyLocation;
var Vector ItemLoc;
var Vector VectorLocation;
var ZomHUD ZHUD;


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




// Score Kill Points
var int Credits;
var int Lives;

var int KillStreak;
var int LastKillStreak;
var int ItemsCollected;
//Fammes
var int FammesAmmoCount;
var int FammesMaxAmmoCount;
var int FammesClipCount;
var int FammesClipCountMax;
//Magnum
var int MagnumAmmoCount;
var int MagnumMaxAmmoCount;
var int MagnumClipCount;
var int MagnumClipCountMax;
//TommyGun
var int TommyGunAmmoCount;
var int TommyGunMaxAmmoCount;
var int TommyGunClipCount;
var int TommyGunClipCountMax;
//M34A
var int M34AAmmoCount;
var int M34AMaxAmmoCount;
var int M34AClipCount;
var int M34AClipCountMax;

var bool FammesEquipped;
var bool M34AEquipped;
var bool TommyGunEquipped;
var bool ShotGunEquipped;
var bool MagnumEquipped;
var bool PistolEquipped;
var bool RocketEquipped;
var bool C2AREquipped;
var bool CrowbarEquipped;
var bool KnifeEquipped;
var bool PipeEquipped;
var bool bNewGame;
     var bool      bWantsHints;
/** Holds the dimensions of the viewport */
var vector2D ViewportSize;
  var MobileInputZone SliderZone;
  var MobileInputZone StickMoveZone;
var MobileInputZone StickLookZone;
var MobileInputZone FreeLookZone;
 var int CurrentObjective;
   var bool bLookAtDestination;
   var CloudSaveData SaveData;

var int Slot1DocIndex;
var int Slot2DocIndex;


//AnimSets per weapon animsets
var array<AnimSet> defaultAnimSet;

//Variable for opening active elements.
var gfxmovieplayer Movie;

//******Weaponbools*****
var bool IsZOMWeapon;
var bool IsPistolWeapon;
var bool IsFammesWeapon;
var bool IsTommyGunWeapon;
var bool IsM34AWeapon;
var bool IsMagnumWeapon;
var bool IsCrowbarWeapon;

//******Itemsbools*******
var bool IsZOMAmmoSmall;
var bool IsSmallHealth;

//******ExternalBools*****
var bool Used;
var bool Redo;
var bool HasZOM;
var bool HasMagnum;
var bool HasFammes;
var bool HasM34A;
var bool HasTommyGun;
var bool HasCrowbar;
var bool MadeNoise;
var float DistanceToPlayer;
var int ClimbHeight;
var Vector MoveLocation;
var SoundCue ReloadSound; // Only used in traditional FPS games.
var bool bVaulted;
var bool bDoingSlam;
var name VaultStartSocketName;
var name VaultEndSocketName;
var string DisconnectCommand;

/** whether or not pre-disconnect cleanup is in progress */
var bool bCleanupInProgress;
var DemoPawns P;
/** whether or not cleanup has finished; if false, 'NotifyDisconnect' blocks disconnection */
var bool bCleanupComplete;

 var DemoPawn Ulari;
  var DemoPawn2 DemoPawn2;
 var Human Human;


          var TestMechPawn TestMechPawn ;
 var bool bControlingUlari;



var rotator PCCameraRot;     //keeps track of the player controller camera rotation
var vector PCCameraLoc;      //keeps track of the player controller camera Location
var float PCCameraOrbit;     //this is only the camera orbit that the player wants. Not the actual yaw or location of the camera.

var Vector MouseHitWorldLocation;      //Hold where the ray casted from the mouse in 3d coordinate intersect with world geometry.
var Vector2D         resolution;       //the screen resolution
var bool bCamRotating;



exec function SwitchPawns()

{

                  if(bControlingUlari == true)
                                   {
                                       //  Self.Possess(Ulari, false);
                                    UnPossess();
                                       GoToState('ControllingUlariPawn');
                                    }

else
                                    {
                                           UnPossess();
                                       // GoToState('ControllingHumanPawn');
                                           GoToState('ControllingUlariPawn');
                                      }
}


exec function SwitchPawns2()

{

                  if(bControlingUlari == true)
                                   {
                                       //  Self.Possess(Ulari, false);
                                    UnPossess();
                                       GoToState('ControllingUlariPawn');
                                    }

else
                                    {
                                           UnPossess();
                                       GoToState('ControllingHumanPawn');
                                        //   GoToState('ControllingUlariPawn');
                                      }
}

 exec function SwitchPawns3()

{

                  if(bControlingUlari == true)
                                   {
                                       //  Self.Possess(Ulari, false);
                                    UnPossess();
                                       GoToState('ControllingUlariPawn');
                                    }

else
                                    {
                                           UnPossess();
                                       GoToState('ControllingKazalitePawn');
                                        //   GoToState('ControllingUlariPawn');
                                      }
}


state ControllingKazalitePawn

{


      simulated event BeginState( Name PreviousStateName )

      {
         bControlingUlari = false;
      foreach WorldInfo.AllPawns(class'Human', Human)

      {
         Self.Possess(Human, false);
             bControlingUlari = false;

      if(Human != Pawn)

             {
    bControlingUlari = false;
   Worldinfo.Game.Broadcast(self, "Human");
  // `log("CONTROLLING Human");
   Self.Possess(Human, false);

   break;

                     }

                      }

                         }

}



state ControllingUlariPawn

{


      simulated event BeginState( Name PreviousStateName )

      {
         bControlingUlari = true;
      foreach WorldInfo.AllPawns(class'DemoPawn', Ulari)

      {
         Self.Possess(Ulari, false);
             bControlingUlari = false;

      if(Ulari != Pawn)

             {
    bControlingUlari = true;
   Worldinfo.Game.Broadcast(self, "Ulari");
  // `log("CONTROLLING Human");
   Self.Possess(Ulari, false);

   break;

                     }

                      }

                         }

}





state ControllingHumanPawn

{

    //	Controller = Spawn(inAction.ControllerClass);
//		Controller.Possess( Self, false );
      simulated event BeginState( Name PreviousStateName )

      {
         bControlingUlari = false;
      foreach WorldInfo.AllPawns(class'DemoPawn2', DemoPawn2)

      {
         Self.Possess(DemoPawn2, false);
             bControlingUlari = false;

      if(TestMechPawn != Pawn)

             {
    bControlingUlari = false;
   Worldinfo.Game.Broadcast(self, "DemoPawn2");
  // `log("CONTROLLING TestMechPawn");
   Self.Possess(DemoPawn2, false);

   break;

                     }

                      }

                         }

}




//*********************************************************
//Save/ Load Char --   DONE / 45%
//*********************************************************
 function QuitToMainMenu()
{
	bCleanupInProgress = true;
//	bQuittingToMainMenu = true;





}


event InitInputSystem()
{
	Super.InitInputSystem();


}


function ShowCredits(int ECredits)
{
  GameHUD(myHUD).HudMovie.DisplayCreditsEarned(ECredits);
}

/** Called after onlinesubsystem game cleanup has completed. */
function FinishQuitToMainMenu()
{
	// stop any movies currently playing before we quit out
	class'Engine'.static.StopMovie(true);

	bCleanupComplete = true;

	// Call disconnect to force us back to the menu level
	if (DisconnectCommand != "")
	{
		ConsoleCommand(DisconnectCommand);
		DisconnectCommand = "";
	}
	else
	{
		ConsoleCommand("Disconnect");
	}

	`Log("------ QUIT TO MAIN MENU --------");
}


exec function SavePCVariables()
{

}

function HackSave()
{

}

exec function LoadPCVariables()
{


}

//**** From Kismet *************************
simulated function SetLevelNumber (int LevelNumber)
{

             local LoadState bState; //Our gameState variable

             //Temporarily load a copy of the GameState Class so we can load our variables...
             bState = new class'LoadState';

             bState.LevelNumber = LevelNumber;
             class'Engine'.static.BasicSaveObject(bState, "LoadState.bin", true, 0);

}


function LoadALL()
{
    local LoadState bState;

          //Temporarily load a copy of the GameState Class so we can load our variables...

     bState = new class'LoadState';

     if(class'Engine'.static.BasicLoadObject(bState, "LoadState.bin", true, 0)) //Load only if the file actually exists
       {
          if(bState.bNewGame == false)
          {
            loadPCVariables();
          }
          else
          {
            `log("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! CANT LOAD !!!!!!!!!!!!!!!!!!!!!!!!!!!!");
          }
       }
}




/*----------------------------------------------------------------------------------------*\
|*------------------"Hotfix" Utility Functions for easy testing---------------------------*|
\*----------------------------------------------------------------------------------------*/

//These functions are easy wrappers to make the AdvKit work out of the box. You should
//replace these with your own implementations

//This is just to make pressing ESC quit the game for easier testing
exec function ShowMenu()
{
	ConsoleCommand("quit");
}


function CheckBulletWhip(soundcue BulletWhip, vector FireLocation, vector FireDir, vector HitLocation)
{
	local vector PlayerDir;
	local float Dist, PawnDist;

	if ( ViewTarget != None  )
	{
		// if bullet passed by close enough, play sound
		// first check if bullet passed by at all
		PlayerDir = ViewTarget.Location - FireLocation;
		Dist = PlayerDir Dot FireDir;
		if ( (Dist > 0) && ((FireDir Dot (HitLocation - ViewTarget.Location)) > 0) )
		{
			// check distance from bullet to vector
			PawnDist = VSize(PlayerDir);
			if ( Square(PawnDist) - Square(Dist) < 40000 )
			{
				// check line of sight
				if ( FastTrace(ViewTarget.Location + class'DemoPawn'.default.BaseEyeheight*vect(0,0,1), FireLocation + Dist*FireDir) )
				{
					PlaySound(BulletWhip, true,,, HitLocation);
				}
			}
		}
	}
}


Public function CalculateHealth()
{
        if(Pawn.Health <=0)
	{
           ConsoleCommand("Suicide");
        }
}

exec function StartSprint()

{
         local DemoPawns MP;
         local UTWeapon PD;
         P = DemoPawns(Pawn);
         PD = UTWeapon(Pawn.Weapon);

       // PreDist = PlayerCamera.FreeCamDistance;
      SKPlayerCamera(PlayerCamera).CameraStyle = 'SprintCam';
         if((Vsize(Pawn.Velocity) == 0) || bCurrentlyReloading == true || bZoomedIn == true)
         {

         }
         else if((Vsize(Pawn.Velocity) > 0))
         {
             Pawn.GroundSpeed = 1300;
          //   Pawn.Weapon.PlayWeaponAnimation(WeaponRunStartAnim,0.5); // for trADITIONAL fps GAMES.
             PD.BobDamping=0.75000;
             bSprinting = true;

                if(Pawn.Groundspeed >= 490)
                {
                  setTimer(SprintTimer, false, 'EmptySprint');
                }
         }

    foreach VisibleCollidingActors(class'DemoPawns', MP, 45, Pawn.Location)
   {
      MP.StepInterval = 9.0; //
   }


 // EmptySprint();
}

simulated function StartZoomNonlinear(float NewDesiredFOV, float NewZoomInterpSpeed)
{
	DesiredFOV = NewDesiredFOV;
	FOVNonlinearZoomInterpSpeed = NewZoomInterpSpeed;

	// clear out any linear zoom info
	bNonlinearZoomInterpolation = TRUE;
	FOVLinearZoomRate = 0.f;
}

/**
 * This function will stop the zooming process keeping the current FOV Angle
 */
simulated function StopZoom()
{
	DesiredFOV = FOVAngle;
	FOVLinearZoomRate = 0.0f;
}


 function PlayCameraAnim( CameraAnim AnimToPlay, optional float Scale=1.f, optional float Rate=1.f,
			optional float BlendInTime, optional float BlendOutTime, optional bool bLoop, optional bool bIsDamageShake )
{
	local Camera MatineeAnimatedCam;

	bCurrentCamAnimAffectsFOV = false;

	// if we have a real camera, e.g we're watching through a matinee camera,
	// send the CameraAnim to be played there
	MatineeAnimatedCam = PlayerCamera;
	if (MatineeAnimatedCam != None)
	{
		MatineeAnimatedCam.PlayCameraAnim(AnimToPlay, Rate, Scale, BlendInTime, BlendOutTime, bLoop, FALSE);
	}
	else if (CameraAnimPlayer != None)
	{
		// play through normal UT camera
		CamOverridePostProcess = class'CameraActor'.default.CamOverridePostProcess;
		CameraAnimPlayer.Play(AnimToPlay, self, Rate, Scale, BlendInTime, BlendOutTime, bLoop, false);
	}

	// Play controller vibration - don't do this if damage, as that has its own handling
	if( !bIsDamageShake && !bLoop && WorldInfo.NetMode != NM_DedicatedServer )
	{
		if( AnimToPlay.AnimLength <= 1 )
		{
			ClientPlayForceFeedbackWaveform(CameraShakeShortWaveForm);
		}
		else
		{
			ClientPlayForceFeedbackWaveform(CameraShakeLongWaveForm);
		}
	}

	bCurrentCamAnimIsDamageShake = bIsDamageShake;
}
/** Stops the currently playing camera animation. */
function StopCameraAnim(optional bool bImmediate)
{
	if (CameraAnimPlayer != None)
	{
		CameraAnimPlayer.Stop(bImmediate);
	}
}




simulated function EmptySprint()
{

        //     AdvKitCamera(PlayerCamera).CameraStyle = 'ThirdPerson';
          Stamina = Empty;
          Pawn.Groundspeed = 120;
          bSprinting = false;
          setTimer(SprintRecoverTimer, false, 'ReplenishStamina');
           StopSprinting();

}

simulated function ReplenishStamina()
{

       Stamina = 3.0;
       bSprinting = false;

}

exec function StopSprinting()
{
  local UTWeapon PD;
  local DemoPawns MP;
  P = DemoPawns(Pawn);
  PD = UTWeapon(Pawn.Weapon);
 //  AdvKitCamera(PlayerCamera).CameraStyle = 'ThirdPerson';
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
      foreach VisibleCollidingActors(class'DemoPawns', MP, 45, Pawn.Location)
   {
      MP.StepInterval = 7.0;
   }
}




/*----------------------------------------------------------------------------------------*\
|*-------------------------------------Input handling-------------------------------------*|
\*----------------------------------------------------------------------------------------*/

/**This calculates a relative movement input vector with the axes being within -1 and 1
 * (Movement input is keys or left analog stick)
 * 
 * @param   _fDeltaTime the current delta time to use for scaling
 * @return              the relative vector
 */
final function Vector GetRelativeInputMovement(float _fDeltaTime)
{
	local Vector vInputVector;

	vInputVector.X = PlayerInput.aForward/PlayerInput.MoveForwardSpeed;
	vInputVector.Y = PlayerInput.aStrafe/PlayerInput.MoveStrafeSpeed;
	vInputVector.Z = PlayerInput.aUp/PlayerInput.MoveStrafeSpeed;

	if(_fDeltaTime!=0)
	{
		vInputVector /= 100.f*_fDeltaTime;
	}

	//NOTE: For some reason the Z Axis scaling differs from XY, so it needs to be clamped
	vInputVector.Z = FClamp(vInputVector.Z,-1,1);

	return vInputVector;
}

/**This calculates a relative look input vector with the axes being within -1 and 1
 * (Look input is mouse or right analog stick)
 * 
 * @param   _fDeltaTime	the current delta time to use for scaling
 * @return              the relative vector
 */
final function Vector GetRelativeInputLook(float _fDeltaTime)
{
	local Vector vInputVector;

	vInputVector.X = PlayerInput.aTurn/PlayerInput.LookRightScale;
	vInputVector.Y = PlayerInput.aLookUp/PlayerInput.LookUpScale;
	vInputVector.Z = 0; //Nothing

	if(_fDeltaTime!=0)
	{
		vInputVector /= 100.f*_fDeltaTime;
	}

	return vInputVector;
}

/**Transforms relative movement input into camera aligned axes
 * For walking this means the XY-Plane
 * 
 * @param   _fDeltaTime	the current delta time to use for scaling
 * @return              the transformed vector
 */
function Vector GetDirectionalizedInputMovement(float _fDeltaTime)
{
	local Vector	X,Y,Z, vInputVector;

	vInputVector = GetRelativeInputMovement(_fDeltaTime);
	vInputVector.Z = 0;

	//Prevent speed hack (e.g. Forward is slower than Foward + Right movement)
	if(VSize(vInputVector)>1)
		vInputVector = Normal(vInputVector);

	//Align acceleration to view angle
	GetAxes(PlayerCamera.Rotation,X,Y,Z);

	X.Z = 0;
	Y.Z = 0;

	vInputVector = Normal(vInputVector.X*X + vInputVector.Y*Y);

	return vInputVector;
}







  simulated function EndZoom()
{
	DesiredFOV = DefaultFOV;
	FOVAngle = DefaultFOV;
	FOVLinearZoomRate = 0.0f;
	FOVNonlinearZoomInterpSpeed = 0.f;
}






/*----------------------------------------------------------------------------------------*\
|*-----------------------------------------Misc Functions---------------------------------*|
\*----------------------------------------------------------------------------------------*/

/**The controller posesses a Pawn
 *
 * @param   _inPawn                 the Pawn that is getting possesed
 * @param   _bVehicleTransition     is it a vehicle transition (not that important)
 */
event Possess(Pawn _inPawn, bool _bVehicleTransition)
{
	//cast the pawn into AdvKitPawn
	advPawn = DemoPawns(_inPawn);

	super.Possess(_inPawn, _bVehicleTransition);
}


  function UpdateRotation( float _fDeltaTime )
{
	local Rotator	rDeltaRot, rViewRotation;

	//Manage and rotate the camera
	rViewRotation = Rotation;

	// Calculate Delta to be applied on ViewRotation
	rDeltaRot.Yaw	= PlayerInput.aTurn;
	rDeltaRot.Pitch	= PlayerInput.aLookUp;

	ProcessViewRotation( _fDeltaTime, rViewRotation, rDeltaRot );
	SetRotation(rViewRotation);

	ViewShake( _fDeltaTime );


	if(advPawn==none)
		return;

	//only rotate the pawn when it is not in RootMotion
	if(!advPawn.bInRootRotation)
	{
		UpdatePawnRotation(_fDeltaTime);
	}
}


/**Default behaviour (for walking) to rotate the pawn. This is called from
 * UpdateRotation when the advPawn is not in RootMotion.
 * 
 * @param   _fDeltaTime     the delta time
 */
function UpdatePawnRotation(float _fDeltaTime)
{
	local Vector vDirection;

if(bInAim == false)
{
        //rotate the pawn only if it is not in the air
	if(Pawn.Physics != PHYS_Falling)
	{
		//only rotate around the Z axis
		vDirection = Pawn.Acceleration;
		vDirection.Z = 0;

		//only rotate if the Pawn is actually being accelerated,
		//otherwise Rotator(vDirection) will be rot(0,0,0)
		if(VSize(vDirection)>0)
		{
			Pawn.SetRotation(RLerp(Pawn.Rotation,Rotator(vDirection),FMin(_fDeltaTime*advPawn.fRotationLerpSpeed,1),true));
		}
	}
}
}



function UpdateRotationAiming( float DeltaTime )  //sets the rotation of the PlayerController and the pawn it is controlling
{
  local rotator pcrotation;   //these variables are explained in part 2 of this function
  local float pitchmultoffset;
  local Rotator	DeltaRot, ViewRotation, TargetRotation, offsetrotation;

     local DemoPawn P;
   local Rotator  newRotation;




//----part1---------------------------------------------------------------------------
  //in part1 of this function, you tell it what rotation you want the camera to have, the target, and the distance, and it finds the right location.
  //this script is here instead of in GetPlayerViewPoint because we don't want to interpolate the camera every time something tries to get the player view point.
  //CamRotation.Pitch = the desired pitch of the camera. What vertical angle you want to view your target.
  //Distance = how far you want to be from your target.
  //CamRotation.Yaw = What direction the camera will be facing. 0 is north (12 o'clock). 180 is south (six o'clock).
  //CamAimLoc = location the camera is looking at. This is usually an offset from the pawn.

  local float           distance, curdistance;  //curdistance will hold the camera's current distance from the target
  local vector		CamAimLoc,FinalPos;      //FinalPos will be the final calculated camera position
  local rotator		CamRotation;
  CamRotation.yaw = 0;
    P = DemoPawn(Pawn);

       ViewRotation = Rotation;
      Pawn.SetDesiredRotation(ViewRotation);
   DeltaRot.Pitch = PlayerInput.aLookUp;
   ProcessViewRotation( DeltaTime, ViewRotation, DeltaRot );
   SetRotation(ViewRotation);
   NewRotation = ViewRotation;
    Pawn.FaceRotation(NewRotation, deltatime);
    

  //the camera always switches to 1st person on player respawn. this fixes that. You'll get rid of this when your own game dictates respawn conditions.
  if (CameraZoom != 1 && !bBehindView)   //if camerazoom is not in first person mode and bbehindview is false.
     Camera('3rd');                       //set camera to 3rd person.   bbehindview becomes true.

  if (CameraZoom > 2) //if camerazoom is in a 3rd person free aim mode
  {
     CamRotation.roll = 0;
      CamRotation.yaw = 0;
     if(bCamRotating) //if the player has the middle mouse button down to rotate the camera
     {
       PCCameraOrbit +=  PlayerInput.aMouseX;       //adjust PCCameraOrbit according to mouse input
       if(PCCameraOrbit > 360)  PCCameraOrbit -=  360.0f; //fix the value if exceeded 360
       if(PCCameraOrbit< 0)  PCCameraOrbit +=  360.0f;
     } //if(bCamRotating)


     switch(CameraZoom )      //see descriptions for the variables at the top of the function
                       {

                             case 3:
                                               CamRotation.pitch =  0;
                                               CamRotation.yaw = 0;
                                               distance = 70;

                                               CamAimLoc.X =  0; //set the offsets from the pawn
                                               CamAimLoc.Y =  0;
                                               CamAimLoc.Z =  0;

                                               break;

                             case 4:
                                               CamRotation.pitch = 0;
                                               CamRotation.yaw =  0;
                                               distance =300;

                                               CamAimLoc.X =  0;
                                               CamAimLoc.Y =  0;
                                               CamAimLoc.Z =  0;

                                               break;

                             case 5:           
                                               CamRotation.pitch =  0;
                                               CamRotation.yaw =  0;
                                               distance =500;

                                               CamAimLoc.X =  0;
                                               CamAimLoc.Y =  0; // I like pie
                                               CamAimLoc.Z =  0;

                                               break;
                                        
                             case 6:
                                               CamRotation.pitch =  0;
                                               CamRotation.yaw =  0;
                                               distance =800;

                                               CamAimLoc.X =  0;
                                               CamAimLoc.Y =  0;
                                               CamAimLoc.Z =  0;

                                               break;

                       }             //switch( PC.CameraZoom )


     CamRotation.Pitch = (CamRotation.Pitch *DegToRad) * RadToUnrRot;   //convert from degrees to Unreal rotation
     CamRotation.Roll =  (CamRotation.Roll *DegToRad) * RadToUnrRot;
     CamRotation.Yaw =   (CamRotation.Yaw *DegToRad) * RadToUnrRot;



     CamAimLoc.X += Pawn.Location.X;  //add the pawn location to your offsets
     CamAimLoc.Y += Pawn.Location.Y;
     CamAimLoc.Z += Pawn.Location.Z;

     curdistance = VSize( PCCameraLoc -  CamAimLoc);  //find the distance from the camera to where the camera is aiming

     if(curdistance != distance && !bCamRotating)           //('erp's) interpolate for smooth transition
                    distance = lerp(curdistance, distance, 0.2);
     if(PCCameraRot != CamRotation && !bCamRotating)
                    CamRotation = Rlerp (PCCameraRot, CamRotation, 0.05, true);

     FinalPos = CamAimLoc - Vector(CamRotation) * Distance; //found the final location for the camera

     setrotation(CamRotation);      //set the playercontroller
     setLocation(FinalPos);
     PCCameraRot =  CamRotation;    //set the pccamera information
     PCCameraLoc =  FinalPos;

 //--------------end part1-----start part2----------------------------------------
        //Part 2 of this function aims the pawn at your target. also, it will temporarily aim the playercontroller's
        //pitch at the target because UT script uses this to adjust the pawn's aimnode. (aim weapon and arm pitch, but not the pawn's pitch)

     TargetRotation  = rotator(MouseHitWorldLocation - Pawn.Location);  //find the rotation to aim the pawn at the target
     pitchmultoffset = 3.0;    //adjust the weapon's aim to look more accurate. only a visual effect so you can adjust however you want.
     offsetrotation.pitch = -1750; //adjust the weapon's aim to look more accurate. only a visual effect so you can adjust however you want.
     offsetrotation.yaw = 0;    //adjust the weapon's aim to look more accurate. only a visual effect so you can adjust however you want.
     TargetRotation += offsetrotation;    //add the offset to your target rotation
     TargetRotation.pitch *= pitchmultoffset;   //applies the multiplier offset to the pitch
     ViewRotation = DemoPawn(pawn).getbaseaimrotation() ;  //gets the pawn's current rotations.

     DeltaRot.Pitch	= TargetRotation.pitch - ViewRotation.pitch;  //find the difference between current and desired rotations.
     DeltaRot.Yaw	= TargetRotation.Yaw - ViewRotation.Yaw;

     if (Pawn!=none)
     {
        Pawn.SetDesiredRotation(TargetRotation);  //self explanitory
     }

     ProcessViewRotation( DeltaTime, ViewRotation, DeltaRot );//this will take deltatime and add deltarot to ViewRotation
	
     pcrotation = ViewRotation;    //we don't want to change the playercontroller's yaw, so use a temporary variable...
     pcrotation.yaw = Rotation.yaw; //and set the yaw to the playercontroller's current yaw.

     SetRotation(pcrotation); // temporarily rotate the playercontroller to this rotation to change the pawn's aim pitch. (not the PAWN'S pitch)

     //ViewShake( deltaTime );   //enable this if you like the camera shake effect

     ViewRotation.Roll = pawn.Rotation.Roll;  //dont change the roll.

     if ( Pawn != None )
        Pawn.FaceRotation(ViewRotation, deltatime);   //aim the pawn at the target. (in our case this will only affect the yaw)

   }//if (CameraZoom > 2)

   if (CameraZoom < 3)
      super.UpdateRotation(DeltaTime );    //if in locked aim mode, run regular UT script.

}








/**Zoom the camera (modify distance of the camera to the Pawn)
 * 
 * @param   _fZoom          the distance amount to zoom
 * @param   _fDeltaTime     the delta time
 */
final exec function Zoom(float _fZoom, optional float _fDeltaTime)
{
	local float fNewZoom;
	local float fScale;

	//set scale to 1 in case delta time is zero
	fScale = _fDeltaTime == 0 ? 1.0f : _fDeltaTime;

	//calculate the zoom
	fNewZoom = PlayerCamera.FreeCamDistance += fScale * _fZoom;
	fNewZoom = FClamp(fNewZoom,fMinCameraDistance,fMaxCameraDistance);

	//set the zoom
	PlayerCamera.FreeCamDistance = fNewZoom;
}

/**Called from Pawn.OnAnimEnd when the pawn finished playing an animation
 * 
 * Look at Actor.OnAnimEnd for Documentation
 */
event NotifyOnAnimEnd(AnimNodeSequence _SeqNode, float _fPlayedTime, float _fExcessTime);

exec function StartFire(optional byte FireModeNum)
{
  // StartFire( 1 );
 if(bSprinting == true) //You can't shoot while running // or reloading really
		return;


        super.StartFire(1);
}

 exec function StopFire( optional byte FireModeNum )
{
	if ( Pawn != None )
	{
		Pawn.StopFire( 1 );
	}
}

function Rotator GetAdjustedAimFor(Weapon W, Vector StartFireLoc)
{
    local Rotator Rot;
    local Vector Vec;
    local Vector HitLocation, HitNormal, TraceEnd, TraceStart;
    local vector WorldPos, WorldDir;
    
    	local Actor HitActor;


       TraceStart = Instigator.GetWeaponStartTraceLocation();
    HitActor = Trace(HitLocation, HitNormal, TraceEnd, self.Location, true,,,
				TRACEFLAG_Bullet | TRACEFLAG_PhysicsVolumes |
				TRACEFLAG_SkipMovers | TRACEFLAG_Blocking);

     if ( HitActor != None)
             {

               TraceEnd =   HitLocation ;
             }


    if ( Pawn != None)
    {
   TraceStart = WorldPos;



      HitActor = Trace(HitLocation, HitNormal, TraceEnd, self.Location, true,,,
				TRACEFLAG_Bullet | TRACEFLAG_PhysicsVolumes |
				TRACEFLAG_SkipMovers | TRACEFLAG_Blocking);
				

    TraceEnd = PlayerCamera.ViewTarget.POV.Location + Normal(vector(PlayerCamera.ViewTarget.POV.Rotation))*32768;
//TraceEnd = TraceStart + StartFireLoc * 32768;
       // Trace(HitLocation, HitNormal, TraceEnd, PlayerCamera.ViewTarget.POV.Location, false);
           Trace(HitLocation, HitNormal, TraceEnd, PlayerCamera.ViewTarget.POV.Location, true,,,
				TRACEFLAG_Bullet | TRACEFLAG_PhysicsVolumes |
				TRACEFLAG_SkipMovers | TRACEFLAG_Blocking);
        if (HitLocation == vect(0,0,0))
            return Rotation;

        Vec = HitLocation - StartFireLoc;

        //Cast our Vector to a Rotator
        Rot = Rotator(Vec);
        
        //Return our adjusted aim Rotator
        return Rot;
    }
    //Got from top of this thread but it doesn't seem to change anything
       if ((HitLocation - StartFireLoc) dot Normal(Vector(Rotation)) < 0.0)
        {
            return Rotation;
        }
}

/*----------------------------------------------------------------------------------------*\
|*----------------------------------------Player States-----------------------------------*|
\*----------------------------------------------------------------------------------------*/

state PlayerWalking
{
	event BeginState(name PreviousStateName)
	{
		super.BeginState(PreviousStateName);
		
		Pawn.SetHardAttach(false);
		Pawn.SetCollision(true,true,false);

		if(advPawn==none)
		{
			return;
		}

		advPawn.adventureState = EAS_Default;
	}

	event EndState(name NextStateName)
	{
		super.EndState(NextStateName);

		//make sure to undo any modification
		Pawn.MovementSpeedModifier = 1;
	}

	event NotifyOnAnimEnd(AnimNodeSequence _SeqNode, float _fPlayedTime, float _fExcessTime)
	{

	}

	function PlayerMove(float _fDeltaTime)
	{
		local Vector    vNormalInput;
		local Vector	vNewAccel;
		local float     fInputStrength;
	//	local AdvKitSplineActor tmpLedge;
		local float fNewDistance;

		if (advPawn == none)
		{
			GotoState('Dead');
		}
		else
		{
			// Update rotation.
			UpdateRotation( _fDeltaTime );

			//only update if the pawn is not in root motion
			if(!advPawn.bInRootMotion)
			{

				vNormalInput = GetRelativeInputMovement(_fDeltaTime);
				vNormalInput.Z = 0;
				fInputStrength = FClamp(VSize(vNormalInput),0,1);

				vNewAccel = GetDirectionalizedInputMovement(_fDeltaTime) * Pawn.AccelRate;

				//each of these two lines guarantee analog movement speed, I do not really like both
				//solutions but I did not find any others
				//Pawn.GroundSpeed = Pawn.default.GroundSpeed*fInputStrength;
				Pawn.MovementSpeedModifier = fInputStrength;
				Pawn.Acceleration = vNewAccel;				
				
				if(bPressedJump)
				{
					if(Pawn.Physics == PHYS_Walking)
					{
						Pawn.DoJump(bUpdating);
					}
					bPressedJump = false;
				}



			}

			//ignore jumps in case the pawn is in root motion
			bPressedJump = false;
		}
	}
}

 exec function StartAltFire( optional byte FireModeNum )

{
   local DemoPawns MP;
 //StartFire( 0 );

   UpdateRotationAiming(1);
     bInAim=true;
       PlayerMove(1);
     //  bEdgeForward=true;
   if(bCurrentlyReloading == true || bSprinting == true)
   {

   }
   else if(bCurrentlyReloading == false || bSprinting == false)
   {
        foreach VisibleCollidingActors(class'DemoPawns', MP, 45, Pawn.Location)
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
   local DemoPawns MP;
    //UpdateRotation(1);
   // StopFire( 0 );
    bInAim=false;
   // bEdgeForward=false;
    if(bCurrentlyReloading == true || bSprinting == true)
   {

   }

    else if(bCurrentlyReloading == false || bSprinting == false)
    {
          foreach VisibleCollidingActors(class'DemoPawns', MP, 45, Pawn.Location)
            {
                MP.AIMPRelease();
                ConsoleCommand("FOV 90");
            }
    }
    bZoomedIn = false;

}

function PlayerSpawned(NavigationPoint StartLocation)
{
  Companions[0] = Spawn(Class'Kazalite',,, StartLocation.Location + vect(45,0,0), StartLocation.Rotation);
   Companions[1] = Spawn(Class'KazalitePawn',,, StartLocation.Location + vect(25,12,0), StartLocation.Rotation);
  // Companions[2] = Spawn(Class'HumanPawn',,, StartLocation.Location - vect(45,0,0), StartLocation.Rotation);
}


simulated function SpawnCompanions(NavigationPoint StartLocation)
{
 Companions[0] = Spawn(Class'Kazalite',,, StartLocation.Location + vect(1,0,0), StartLocation.Rotation);
    // Companions[1] = Spawn(Class'TestMechPawn',,, StartLocation.Location + vect(1,1,0), StartLocation.Rotation);
  // Companions[2] = Spawn(Class'HumanPawn',,, StartLocation.Location - vect(45,0,0), StartLocation.Rotation);
}



simulated function StartZoom(float NewDesiredFOV, float NewZoomRate)
{
	FOVLinearZoomRate = NewZoomRate;
	DesiredFOV = NewDesiredFOV;

	// clear out any nonlinear zoom info
	bNonlinearZoomInterpolation = FALSE;
	FOVNonlinearZoomInterpSpeed = 0.f;
}

exec function ToggleCam()
{
	if(GamePlayerCamera(PlayerCamera).CameraStyle == 'FreeCam_Default')
	{
		GamePlayerCamera(PlayerCamera).CameraStyle = 'FirstPerson';
	//	HideMesh(true);
	}
	else
	{
		GamePlayerCamera(PlayerCamera).CameraStyle = 'FreeCam_Default';
	//	HideMesh(false);
	}

}


DefaultProperties
{
     CameraClass=class'Phoenix.SKPlayerCamera'
	//CameraClass = class 'Phoenix.AdvKitCamera'
	MinHitWall = 0.8
	fMinCameraDistance = 34
	fMaxCameraDistance = 177312
         SprintTimer=3
	Begin Object Class=ForceFeedbackWaveform Name=ForceFeedbackWaveform7
		Samples(0)=(LeftAmplitude=60,RightAmplitude=50,LeftFunction=WF_LinearDecreasing,RightFunction=WF_LinearDecreasing,Duration=0.200)
	End Object
	CameraShakeShortWaveForm=ForceFeedbackWaveform7

	Begin Object Class=ForceFeedbackWaveform Name=ForceFeedbackWaveform8
		Samples(0)=(LeftAmplitude=60,RightAmplitude=50,LeftFunction=WF_LinearDecreasing,RightFunction=WF_LinearDecreasing,Duration=0.400)
	End Object
	CameraShakeLongWaveForm=ForceFeedbackWaveform8

     // CheatClass=class'ZOMCheatManager'
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
        IsPistolWeapon = false
        IsFammesWeapon = false
        IsM34AWeapon = false
        IsMagnumWeapon = false
        IsTommyGunWeapon = false
        IsCrowbarWeapon = false

        IsZOMAmmoSmall =false
        IsSmallHealth = false
        Redo = false
        Used = true
        HasZOM = false
        HasFammes = false
        HasTommyGun = false
        HasM34A = false
        HasMagnum = false
        HasCrowbar = false
        Credits = 0
        KillStreak = 0
        LastKillStreak = 0
        ItemsCollected = 0
        MadeNoise = false
        CanDoStomp = false
        bRotateMiniMap=true
        StompSound = SoundCue'ZombiesSounds.ATTACK.StompCue'


        //Fammes
        FammesAmmoCount = 0
        FammesMaxAmmoCount = 0
        FammesClipCount = 0
        FammesClipCountMax =0
        //Magnum
        MagnumAmmoCount = 0
        MagnumMaxAmmoCount = 0
        MagnumClipCount = 0
        MagnumClipCountMax =0
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

        //Savestatevars
        FammesEquipped = false
        M34AEquipped = false
        TommyGunEquipped = false
        ShotGunEquipped = false
        MagnumEquipped = false
        PistolEquipped = false
        RocketEquipped = false
        C2AREquipped = false
        CrowbarEquipped = false
        KnifeEquipped = false
        PipeEquipped = false
        Lives = 1
        bNewGame = true
        bVaulted = false
        bDoingSlam = false
        ClimbHeight = 0

        VaultStartSocketName = VaultStart
        VaultEndSocketName =   VaultEnd
        CurrentObjective = 0
        LastEventNumber = 0
        bShowNightVision = false
        bMICSetUP = false
        bWantsHints = false

        ControlingUlari=true
}
