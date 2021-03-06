

class AimingDemoWeaponClass extends UTWeapon dependson(AdvKitPlayerController)
	abstract;
	
	
	

var int MaxAmmoCount;
  var(Weapon) const Name MuzzleSocketName;
/** Weapon animations for use while zoomed */
var(Animations)	array<name>	WeaponFireAnimZoom;
var(Animations) array<name> WeaponIdleAnimsZoom;
var CanvasIcon WeaponBGIcon;
/** Arm animations for use while zoomed */
var(Animations)	array<name>	ArmFireAnimZoom;
var(Animations) array<name> ArmIdleAnimsZoom;

//Camera Anims//
var Name PutDownCameraAnim;
var Name EquipCameraAnim;
var Name FireCamera;
var Name ReloadCameraAnim;

var() name					EjectorSocket;
var() Vector				BrassStartOffset;
var() Vector				BrassVelocity;
var() bool					bEjectBrassOnFire;
var() float					BrassForegroundTime;
var()  bool		            bEjectBrass;
var bool bHand;
var SoundCue ReloadSound;
/** headshot scale factor when moving slowly or stopped */
var float SlowHeadshotScale;

/** headshot scale factor when running or falling */
var float RunningHeadshotScale;

var class<UTDamageType> HeadShotDamageType;
var float HeadShotDamageMult;


/** New values for use while zoom aiming */
var float oldFOV; //Declaring variables as usual...
var float newFOV;


/** Spread value while zoom aiming */
var float SpreadScoped;

/** Spread value while not zoom aiming */
var float SpreadNoScoped;

/** Boolean for if the player is zoom aiming */
var bool AmIZoomed;

/** Boolean for if the crosshair should be displayed */
var bool bDisplayCrosshair;

/** Amount of FOV to subract from FOV when zoomed */
var float ZoomedFOVSub;

/** Zoom minimum time, from UT3 Sniper Rifle*/
var bool bAbortZoom;

/** Tracks number of zoom started calls, from UT3 Sniper Rifle */
var int ZoomCount;

var float RunStartInterval;
var float RunEndInterval;
var int RecoilAmount;

var int Clips;
var int ClipsMax;
var bool bIsReloading;
var(Animations)	array<name>	WeaponReloading;
var bool bUsingIronSights;
var(Animations) name	WeaponRunStartAnim;
var(Animations) name	WeaponRunIdleAnim;
var(Animations) name	WeaponRunEndAnim;
var bool bWeaponPuttingDown;
var bool IsitFiring;
//var(Weapon) const Name MuzzleSocketName;
// Particle system representing the muzzle flash
var(Weapon) const ParticleSystemComponent MuzzleFlash;
var(FirstPerson) vector	ISViewOffset;
var(FirstPerson) vector ISViewOffsetDefault;

var string WeaponName;

/** Tell the server that the client needs this information */
replication
{
  if ( Role == ROLE_Authority )
	AmIZoomed;
}

simulated event PostBeginPlay()
{
	local SkeletalMeshComponent SkeletalMeshComponent;

	Super.PostBeginPlay();

	if (MuzzleFlash != None)
	{
		SkeletalMeshComponent = SkeletalMeshComponent(Mesh);
		if (SkeletalMeshComponent != None && SkeletalMeshComponent.GetSocketByName(MuzzleSocketName) != None)
		{
			SkeletalMeshComponent.AttachComponentToSocket(MuzzleFlash, MuzzleSocketName);
		}
	}
}

/** This adds to the Activate function to force CheckMyZoom when the weapon is equipped so we get the proper values for not zoom aiming */
simulated function Activate()
{
	//CheckMyZoom();
	//GetSetFOV();
	super.Activate();
}

/** This stops autoswitching to a newly picked up weapon while zoom aiming, unedited from the UT3 Sniper Rifle */
simulated function bool DenyClientWeaponSet()
{
	// don't autoswitch while zoomed
	return (GetZoomedState() != ZST_NotZoomed);
}


reliable client function ClientGivenTo(Pawn NewOwner, bool bDoNotActivate)
{
	local DemoPawn DemoPawn;

	Super.ClientGivenTo(NewOwner, bDoNotActivate);

	// Check that we have a new owner and the new owner has a mesh
	if (NewOwner != None && NewOwner.Mesh != None)
	{
		// Cast the new owner into a DDPawn as we need the weapon socket name
		// If the cast succeeds, we check that the new owner's mesh has a socket by that name
		DemoPawn = DemoPawn(NewOwner);
		if (DemoPawn != None && NewOwner.Mesh.GetSocketByName(DemoPawn.WeaponSocketName) != None)
		{
			// Set the shadow parent of the weapon mesh to the new owner's skeletal mesh. This prevents doubling up
			// of shadows and also allows improves rendering performance
			Mesh.SetShadowParent(NewOwner.Mesh);
			// Set the light environment of the weapon mesh to the new owner's light environment. This improves
			// rendering performance
		//	Mesh.SetLightEnvironment(DemoPawn.MyLightEnvironment);
			// Attach the weapon mesh to the new owner's skeletal meshes socket
			NewOwner.Mesh.AttachComponentToSocket(Mesh, DemoPawn.WeaponSocketName);
		}
	}
}

/** Adds to UTweapon's Active state to decide whether we should be playing the normal idle animation or the zoom aiming idle animation */
simulated state Active
{


//        simulated event OnAnimEnd(optional AnimNodeSequence SeqNode, float PlayedTime, float ExcessTime)
//	{
//		local int IdleIndex;
 //
//		if ( WorldInfo.NetMode != NM_DedicatedServer && WeaponIdleAnims.Length > 0 )
//		{
//	if (AmIZoomed == true)
//	{
//			IdleIndex = Rand(WeaponIdleAnimsZoom.Length);
//			PlayWeaponAnimation(WeaponIdleAnimsZoom[IdleIndex], 0.0, true);
//			if(ArmIdleAnims.Length > IdleIndex && ArmsAnimSet != none)
//			{
//				PlayArmAnimation(ArmIdleAnimsZoom[IdleIndex], 0.0,, true);
//			}
//	}
//	else
//	{
//			IdleIndex = Rand(WeaponIdleAnims.Length);
//			PlayWeaponAnimation(WeaponIdleAnims[IdleIndex], 0.0, true);
//			if(ArmIdleAnims.Length > IdleIndex && ArmsAnimSet != none)
//			{
//				PlayArmAnimation(ArmIdleAnims[IdleIndex], 0.0,, true);
//			}
//	}
//		}
//	}
//




}


/*************************************************************************
 * Set HAND *
 *************************************************************************/




///RELAODING*********************************
//*********************************************


simulated function WeaponEmpty()
{


         if(clips > 0 && !bIsReloading)
            {

                LogInternal("COOOOL");
                bIsReloading = true;
	//	PlayWeaponAnimation('WeaponReload',2.5);
		SetTimer(2.5, false, 'Reload');
                DoEmpty();

	}
         GotoState('Active');

}

simulated function DoEmpty()
{

     local AdvKitPlayerController SPR;

     SPR = AdvKitPlayerController(Instigator.Controller);


     SPR.StopSprinting();
    // SPR.PlayCameraAnim(CameraAnim'ZombieWeapons.Camera.M4A1Reload');
    // SPR.WeaponEmptyM();
     WorldInfo.Game.Broadcast(self, SPR); //BroadCast Target to make sure one is aquired

}
simulated function CheckEmpty()
{
  if (clips == 0 && AmmoCount == 0)
  {
    WeaponPlaySound(SoundCue'GearWeapons.Sound.WeaponEmptyClick_Cue');
  }

}

function Reload()
{
	bIsReloading = false;
	clips = clips - 1;
	AddAmmo(6);
	ClearTimer();
}

simulated function StartFire(byte FireModeNum)
{

        local PlayerController PC;
	PC = PlayerController(Instigator.Controller);



	if(PC == none || bIsReloading) //You can't shoot while reloading
		return;
	if(AmIZoomed == true)
	{
       //      PlayWeaponAnimation( WeaponFireAnimZoom[FireModeNum], GetFireInterval(FireModeNum));
        }
        else
        {
       //      PlayWeaponAnimation(WeaponFireAnim[FireModeNum], GetFireInterval(FireModeNum));
        }

        IsitFiring = true;

        super.StartFire(FireModeNum);
}


simulated function AddClips (int AmountToAdd)
{
    if(Clips + AmountToAdd > ClipsMax)
    {
      //Store?
    }
    else
    {
     Clips += AmountToAdd;
    }

}

simulated function bool HasMaxedAmmo ()

{
  if(AmmoCount != MaxAmmoCount)
  return true;
  
  else
  return false;

}
simulated event MuzzleFlashTimer()
{
	if (MuzzleFlashPSC != none && (!bMuzzleFlashPSCLoops) )
	{
		MuzzleFlashPSC.DeactivateSystem();
	}
}

/**
 * Causes the muzzle flashlight to turn on
 */
simulated event CauseMuzzleFlashLight()
{
	// don't do muzzle flashes when running too slow, except on mobile, where we need it to show off dynamic lighting
	if ( WorldInfo.bDropDetail && !WorldInfo.IsConsoleBuild(CONSOLE_Mobile) )
	{
		return;
	}

	if ( MuzzleFlashLight != None )
	{
		MuzzleFlashLight.ResetLight();
	}
	else if ( MuzzleFlashLightClass != None )
	{
		MuzzleFlashLight = new(Outer) MuzzleFlashLightClass;
		SkeletalMeshComponent(Mesh).AttachComponentToSocket(MuzzleFlashLight,MuzzleFlashSocket);
	}
}

/**
 * Causes the muzzle flash to turn on and setup a time to
 * turn it back off again.
 */
simulated event CauseMuzzleFlash()
{
	local UTPawn P;
	local ParticleSystem MuzzleTemplate;

	if ( WorldInfo.NetMode != NM_Client )
	{
		P = UTPawn(Instigator);
		if ( (P == None) || !P.bUpdateEyeHeight )
		{
			return;
		}
	}

	CauseMuzzleFlashLight();

	if (GetHand() != HAND_Hidden || (bShowAltMuzzlePSCWhenWeaponHidden && Instigator != None && Instigator.FiringMode == 1 && MuzzleFlashAltPSCTemplate != None))
	{
		if ( !bMuzzleFlashAttached )
		{
			AttachMuzzleFlash();
		}
		if (MuzzleFlashPSC != None)
		{
			if (!bMuzzleFlashPSCLoops || (!MuzzleFlashPSC.bIsActive || MuzzleFlashPSC.bWasDeactivated))
			{
				if (Instigator != None && Instigator.FiringMode == 1 && MuzzleFlashAltPSCTemplate != None)
				{
					MuzzleTemplate = MuzzleFlashAltPSCTemplate;

					// Option to not hide alt muzzle
					MuzzleFlashPSC.SetIgnoreOwnerHidden(bShowAltMuzzlePSCWhenWeaponHidden);
				}
				else if (MuzzleFlashPSCTemplate != None)
				{
					MuzzleTemplate = MuzzleFlashPSCTemplate;
				}
				if (MuzzleTemplate != MuzzleFlashPSC.Template)
				{
					MuzzleFlashPSC.SetTemplate(MuzzleTemplate);
				}
				SetMuzzleFlashParams(MuzzleFlashPSC);
				MuzzleFlashPSC.ActivateSystem();
			}
		}

		// Set when to turn it off.
		SetTimer(MuzzleFlashDuration,false,'MuzzleFlashTimer');
	}
}

 simulated function AttachMuzzleFlash()
{
	local SkeletalMeshComponent SKMesh;

	// Attach the Muzzle Flash
	bMuzzleFlashAttached = true;
	SKMesh = SkeletalMeshComponent(Mesh);
	if (  SKMesh != none )
	{
		if ( (MuzzleFlashPSCTemplate != none) || (MuzzleFlashAltPSCTemplate != none) )
		{
			MuzzleFlashPSC = new(Outer) class'UTParticleSystemComponent';
			MuzzleFlashPSC.bAutoActivate = false;
			MuzzleFlashPSC.SetDepthPriorityGroup(SDPG_Foreground);
			MuzzleFlashPSC.SetFOV(UDKSkeletalMeshComponent(SKMesh).FOV);
			SKMesh.AttachComponentToSocket(MuzzleFlashPSC, MuzzleFlashSocket);
		}
	}
}



simulated event StopMuzzleFlash()
{
	ClearTimer('MuzzleFlashTimer');
	MuzzleFlashTimer();

	if ( MuzzleFlashPSC != none )
	{
		MuzzleFlashPSC.DeactivateSystem();
	}
}


simulated function PlayFireEffects( byte FireModeNum, optional vector HitLocation )
{
	// Play Weapon fire animation

	if ( FireModeNum < WeaponFireAnim.Length && WeaponFireAnim[FireModeNum] != '' )
		PlayWeaponAnimation( WeaponFireAnim[FireModeNum], GetFireInterval(FireModeNum) );
	if ( FireModeNum < ArmFireAnim.Length && ArmFireAnim[FireModeNum] != '' && ArmsAnimSet != none)
		PlayArmAnimation( ArmFireAnim[FireModeNum], GetFireInterval(FireModeNum) );

	// Start muzzle flash effect
	CauseMuzzleFlash();

	ShakeView();
}

simulated function StopFireEffects(byte FireModeNum)
{
	StopMuzzleFlash();
}

defaultproperties
{
	//
	//These values do not need to be present in your weapon class if you extend this class
	//
         bEjectBrass=True // eject ammo or bullets
	EjectorSocket="EjectorSocket" //socket to eject from
        IsitFiring=False
        
	//This is necessary so secondary fire doesn't actually fire
	InstantHitDamageTypes(1)=None
	FiringStatesArray(1)=Active
	FireInterval(1)=+0.00001

	//This defines the animations for the arms and the weapon while zoom aiming
	WeaponFireAnimZoom(0)=WeaponZoomFire
	WeaponIdleAnimsZoom(0)=WeaponZoomIdle
	ArmFireAnimZoom(0)=WeaponZoomFire
	ArmIdleAnimsZoom(0)=WeaponZoomIdle
	
	 WeaponRunStartAnim="WeaponRunStart" //
         WeaponRunIdleAnim="WeaponRunIdle" //
         WeaponRunEndAnim="WeaponRunEnd" // 


	//This sets which fire mode is zoom mode
	bZoomedFireMode(0)=0
	bZoomedFireMode(1)=1
	HeadShotDamageMult=2.0
	SlowHeadshotScale=1.75
	RunningHeadshotScale=0.8


	//This says to display the crosshair when the weapon is first equipped
	bDisplaycrosshair = true;

	//This vastly reduces the weapon bob effect when landing from a jump or fall in order to prevent model clipping while aiming
	JumpDamping=1.4

	//These reduce the weapon lagging behind the crosshair effect to ensure the sights are properly lined up when you enter zoom aiming mode
	MaxPitchLag=600
	MaxYawLag=800

	//Original UT3 movement values to use while not zoom aiming
	//This says the weapon isn't zoom aiming when the weapon is first equipped
	AmIZoomed=false
	bSniping=true


	//This sets how fast we want to zoom, a very high value gives an instant zoom rather than the UT3 Sniper Rifle's hold to zoom setup
	ZoomedRate=5.0

	//
	//This value does not need to be present in your weapon class but can be if you wish to have a different amount of zoom while zoom aiming
	//

	//This sets how much we want to zoom in, this is a value to be subtracted because smaller FOV values are greater levels of zoom
	ZoomedFOVSub=10.0

	//
	//These values should be present in your weapon class and be altered to suit your needs
	//

	//This is the spread value for use while zoom aiming, smaller number is more accurate
	SpreadScoped=0.0025

	//This is the spread value for use while not zoom aiming, larger number is less accurate
	SpreadNoScoped=0.065
        EquipCameraAnim = none
        PutDownCameraAnim = none
        FireCamera = none


	RotChgSpeed=4.0
	ReturnChgSpeed=4.0
	AimingHelpRadius[0]=80.0
	AimingHelpRadius[1]=80.0
	
	ISViewOffset=(X=0,Y=0,Z=-0.4)
	ISViewOffsetDefault=(X=0,Y=0,Z=0)
}