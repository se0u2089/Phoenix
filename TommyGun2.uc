

class TommyGun2 extends UTWeapon placeable ;

 Var bool bReloading, bInfiniteClips, bInfiniteClipSize;

var int ClipSize, NumClips;
var int ReserveAmmo, TotalAmmo;

var float ReloadTime;
var(Animations) name    ReloadAnim;
var(Animations) name    ArmsReloadAnim;
  var(Weapon) const Name MuzzleSocketName;
/** Sound to play when the weapon is Equipped */
var(Sounds) SoundCue    WeaponReloadSnd;

var class<UTDamageType> HeadShotDamageType;
var float HeadShotDamageMult;

/** headshot scale factor when moving slowly or stopped */
var float SlowHeadshotScale;

/** headshot scale factor when running or falling */
var float RunningHeadshotScale;

var UIRoot.TextureCoordinates CrossHairCoords;
var UIRoot.TextureCoordinates HUDIconCoords;

// chached instant hit, end-trace pos
var Vector InstantHitEnd;

var HUD DebugHud;
var MaterialInterface                  MatStealthed;
var bool bZoomed; // used for sniperrifles
var const editconst DynamicLightEnvironmentComponent LightEnvironment;

var int ShellCount, ShellCountOffset;
var int clips;
var SpotLightComponent Flashlight;

var SkeletalMeshComponent SKMesh;
var ParticleSystemComponent	FireEffectPSC;
var repnotify bool bIsFlashlightOn;
      var bool bIsReloading;
var bool bIsTurningonFlashlight;

var SoundCue FlashLightSound;

 var bool GoAim, GoUnAim;
/*********************************************************************************************
 Muzzle Flash
********************************************************************************************* */

/** Holds the name of the socket to attach a muzzle flash too */
var name					MuzzleFlashSocket;

/** Muzzle flash PSC and Templates*/
var UTParticleSystemComponent	MuzzleFlashPSC;

/** If true, always show the muzzle flash even when the weapon is hidden. */
var bool					bShowAltMuzzlePSCWhenWeaponHidden;

/** Normal Fire and Alt Fire Templates */
var ParticleSystem			MuzzleFlashPSCTemplate, MuzzleFlashAltPSCTemplate;

/** UTWeapon looks to set the color via a color parameter in the emitter */
var color					MuzzleFlashColor;

/** Set this to true if you want the flash to loop (for a rapid fire weapon like a minigun) */
var bool					bMuzzleFlashPSCLoops;

/** dynamic light */
var	UDKExplosionLight		MuzzleFlashLight;

/** dynamic light class */
var class<UDKExplosionLight> MuzzleFlashLightClass;

/** How long the Muzzle Flash should be there */
var() float					MuzzleFlashDuration;

/** Whether muzzleflash has been initialized */
var bool					bMuzzleFlashAttached;

/** Offset from view center */
var(FirstPerson) vector	PlayerViewOffset;

/** additional offset applied when using small weapons */
var(FirstPerson) vector SmallWeaponsOffset;

/** additional offset applied when using small weapons */
var(FirstPerson) float WideScreenOffsetScaling;

/** rotational offset only applied when in widescreen */
var rotator WidescreenRotationOffset;

/** special offset when using hidden weapons, as we need to still place the weapon for e.g. attached beams */
var vector HiddenWeaponsOffset;

var float ProjectileSpawnOffset;


   function SpawnFireEffect()
{
    //FireEffectPSC = WorldInfo.MyEmitterPool.SpawnEmitter(FireEffectPS, Location, , self, , , false);
}
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

simulated function StartZoom(UTPlayerController PC)
{
	local DemoPawn p;

	p = DemoPawn(instigator);

        Spread[0] = FMin(Spread[0]+0.01,0.02);
	MaxPitchLag=120;
	MaxYawLag=120;
	RotChgSpeed=3.0;
	ReturnChgSpeed=3.0;
        GoAim = true;
        GoUnAim = false;
        PlayerViewOffset = vect(5,1.5,3.5); // ïîëîæåíèå ñòâîëà ïðè ïðèöåëèâàíèè
        
        if (P != none)
        {
                p.GroundSpeed=+00250.000000; // ñêîðîñòü ïåðåäâèæåíèÿ èãðîêà ïðè ïðèöåëèâàíèè
        	p.JumpZ=+00020.000000; // âûñîòà ïðûæêà ïðè ïðèöåëèâàíèè
        }

        if (PC != none)
        {
               // pc.bNoCrosshair = false; // ïåðåêðåñòèå (False - ïðèñóòñòâóåò, True - îòñóòñòâóåò)
                PC.DesiredFOV -= 40; // ïðèáëèæåíèå(çóì)
        }
}

simulated function EndZoom(UTPlayerController PC)
{
	SetTimer(0.001,false,'LeaveZoom');
}

simulated function LeaveZoom()
{
	local AdvKitPlayerController PC;
	local DemoPawn p;

	p = DemoPawn(instigator);
	MaxPitchLag=600;
	MaxYawLag=500;
	RotChgSpeed=3.0;
	ReturnChgSpeed=3.0;
        Spread[0] = FMin(Spread[0]+0.07,0.10);
        GoAim = false;
        GoUnAim = true;
        PlayerViewOffset = vect(2,1,-2); // ñòàíäàðòíîå ïîëîæåíèå îðóæèÿ
	PC = AdvKitPlayerController(Instigator.Controller);

        if (P != none)
        {
                p.GroundSpeed = 440.0; // ñêîðîñòü ïåðåäâèæåíèÿ, ïîñëå îòêëþ÷åíèÿ ïðèöåëà
        	p.JumpZ = 322.0; // âûñîòà ïðûæêà, ïîñëå îòêëþ÷åíèÿ ïðèöåëà
        }

        if (PC != none)
	{
	//	pc.bNoCrosshair = true; // ïåðåêðåñòèå (False - ïðèñóòñòâóåò, True - îòñóòñòâóåò)
                PC.EndZoom();
	}
}

simulated function PostBeginPlay()
{
	SKMesh.AttachComponentToSocket(Flashlight, 'FlashlightSocket');
	FlashLight.SetEnabled(self.default.bIsFlashlightOn);

	super.PostBeginPlay();
}


 //FlashlightfnctionsEND
/**
 * Check on various replicated data and act accordingly.
 */
simulated event ReplicatedEvent(name VarName)
{
    `log(VarName @ "replicated");
    if (VarName == 'bIsFlashlightOn')
    {
    	FlashLightToggled();
    	`log("bIsFlashlightOn replicated");
    }
    else
    {
    	Super.ReplicatedEvent(VarName);
    }
}

function ToggleFlashLight()
{
  //PlayWeaponAnimation('WeaponToggleFlashLight',1.0);
  bIsTurningonFlashlight = true;
  setTimer(0.5,false, 'ToggleMainFlashLight');
}

simulated function ToggleMainFlashlight()
{
    bIsFlashlightOn = !bIsFlashlightOn;
    `log("ToggleFlashlight: " $ bIsFlashlightOn);
    PlaySound(FlashLightSound);
    FlashLightToggled();
    setTimer(0.4,false, 'OpenFire');

    // if we are a remote client, make sure the Server Set's toggles the flashlight
    `log("Role:" @ Role);
	if( Role < Role_Authority )
	{
		ServerToggleFlashlight();
	}
}

function OpenFire()
{
  bIsTurningonFlashlight = false;
}

reliable server function ServerToggleFlashlight()
{
    bIsFlashlightOn = !bIsFlashlightOn;
    `log("ServerToggleFlashlight: " $ bIsFlashlightOn);
    FlashLightToggled();
}

simulated function vector InstantFireStartTrace()
{
    if ((UTPlayerController(Instigator.Controller).PlayerCamera != none)
        && (UTPlayerController(Instigator.Controller).PlayerCamera.CameraStyle == 'ThirdPerson'))
    {
      return GetNewEffectLocation();
    }
   else
      return super.InstantFireStartTrace();
}


simulated function vector GetPhysicalFireStartLoc(optional vector AimDir)
{
	local vector outVector;

	//if the gun mesh is found it will return the muzzle of the gun
	if (SkeletalMeshComponent(Mesh) != none)
	{
		SkeletalMeshComponent(Mesh).GetSocketWorldLocationAndRotation(MuzzleFlashSocket, outVector);
		
		return outVector;
	}

	//something went wrong
	return Super.GetPhysicalFireStartLoc(AimDir);
}

simulated function FlashLightToggled()
{
    if(bIsFlashlightOn)
    {
        FlashLight.SetEnabled(true);
    }
    else
    {
        FlashLight.SetEnabled(false);
    }
}
//FlashlightfnctionsEND


simulated function StartFire(byte FireModeNum)
{
	local PlayerController PLR;
	PLR = PlayerController(Instigator.Controller);

	if(PLR == none || bIsTurningonFlashlight == true) //You can't shoot while reloading
		return;


        super.StartFire(FireModeNum);
}

simulated function CheckEmpty()
{
  if (clips == 0 && AmmoCount == 0)
  {
    //WeaponPlaySound(SoundCue'GearWeapons.Sound.WeaponEmptyClick_Cue');
  }
  //super.CheckEmpty();

}

simulated function bool DoOverrideNextWeapon()
{
      if(Clips == 0 && AmmoCount == 0)
      {
        super.DoOverrideNextWeapon();
      }
      return false;

}

simulated function WeaponEmpty()
{

        if(clips > 0 && !bIsReloading)
	{
		bIsReloading = true;
             //   PlayWeaponAnimation('WeaponReload',2.5);
                playcameraanim();
		SetTimer(2.5, false, 'Reload');
		
		if(bIsReloading == true)

            {
               DoEmpty();

            }
	}

        GotoState('Active');




}

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




 simulated function InstantFire()
{
	local vector StartTrace, EndTrace;
	local Array<ImpactInfo>	ImpactList;
	local ImpactInfo RealImpact, NearImpact;
	local int i, FinalImpactIndex;

	// define range to use for CalcWeaponFire()
	StartTrace = InstantFireStartTrace();
	EndTrace = InstantFireEndTrace(StartTrace);
	bUsingAimingHelp = false;
	// Perform shot
	RealImpact = CalcWeaponFire(StartTrace, EndTrace, ImpactList);
	FinalImpactIndex = ImpactList.length - 1;

	if (FinalImpactIndex >= 0 && (ImpactList[FinalImpactIndex].HitActor == None || !ImpactList[FinalImpactIndex].HitActor.bProjTarget))
	{
		// console aiming help
		NearImpact = InstantAimHelp(StartTrace, EndTrace, RealImpact);
		if ( NearImpact.HitActor != None )
		{
			bUsingAimingHelp = true;
			ImpactList[FinalImpactIndex] = NearImpact;
		}
	}

	for (i = 0; i < ImpactList.length; i++)
	{
		ProcessInstantHit(CurrentFireMode, ImpactList[i]);
	}

	if (Role == ROLE_Authority)
	{
		// Set flash location to trigger client side effects.
		// if HitActor == None, then HitLocation represents the end of the trace (maxrange)
		// Remote clients perform another trace to retrieve the remaining Hit Information (HitActor, HitNormal, HitInfo...)
		// Here, The final impact is replicated. More complex bullet physics (bounce, penetration...)
		// would probably have to run a full simulation on remote clients.
		if ( NearImpact.HitActor != None )
		{
			SetFlashLocation(NearImpact.HitLocation);
		}
		else
		{
			SetFlashLocation(RealImpact.HitLocation);
		}
	}
}
simulated function Projectile ProjectileFire()
{
	local vector		RealStartLoc;
	local Projectile	SpawnedProjectile;

	// tell remote clients that we fired, to trigger effects
	IncrementFlashCount();

	if( Role == ROLE_Authority )
	{
		// this is the location where the projectile is spawned.
		RealStartLoc = GetPhysicalFireStartLoc();

		// Spawn projectile
		SpawnedProjectile = Spawn(GetProjectileClass(),,, RealStartLoc);
		if( SpawnedProjectile != None && !SpawnedProjectile.bDeleteMe )
		{
			SpawnedProjectile.Init( Vector(GetAdjustedAim( RealStartLoc )) );
		}

		// Return it up the line
		return SpawnedProjectile;
	}

	return None;
}

 simulated function vector NewFireEnd()
{
    local Vector TempStart, TempEnd, NewLoc, HitNormal;
      local Actor Hit;

      // new trace
      TempStart = super.InstantFireStartTrace(); // old start
      TempEnd = TempStart + Vector(AddSpread(Instigator.GetBaseAimRotation())) * GetTraceRange(); // old end
      Hit = GetTraceOwner().Trace(NewLoc, HitNormal, TempEnd, TempStart, true); // new end

      if (Hit == none)
         NewLoc = TempEnd;

      //DebugHud.Draw3DLine(TempStart, TempEnd, class'UTHUD'.default.GreenColor);
      //DebugHud.Draw3DLine(InstantFireStartTrace(), NewLoc, class'UTHUD'.default.BlackColor);
      return NewLoc + Normal(Vector(Instigator.GetBaseAimRotation())) * 30; // small bugfix to shift forward, to really hit the aim
}


simulated function ProcessInstantHit( byte FiringMode, ImpactInfo Impact, optional int NumHits)
{

    local float Scaling;
    local int HeadDamage;

    if( (Role == Role_Authority) && !bUsingAimingHelp )
    {
        if (Instigator == None || VSize(Instigator.Velocity) < Instigator.GroundSpeed * Instigator.CrouchedPct)
        {
            Scaling = SlowHeadshotScale;
        }
        else
        {
            Scaling = RunningHeadshotScale;
        }

        HeadDamage = InstantHitDamage[FiringMode]* HeadShotDamageMult;
       // if ( (UTPawn(Impact.HitActor) != None && UTPawn(Impact.HitActor).TakeHeadShot(Impact, HeadShotDamageType, HeadDamage, Scaling, Instigator.Controller)) ||
       //     (UTVehicleBase(Impact.HitActor) != None && UTVehicleBase(Impact.HitActor).TakeHeadShot(Impact, HeadShotDamageType, HeadDamage, Scaling, Instigator.Controller)) )
       // {
      //      SetFlashLocation(Impact.HitLocation);
      //      return;
        //}
    }

    super.ProcessInstantHit( FiringMode, Impact );
}





simulated function vector InstantFireEndTrace(vector StartTrace)
{
   if ((UTPlayerController(Instigator.Controller).PlayerCamera != none)
        && (UTPlayerController(Instigator.Controller).PlayerCamera.CameraStyle == 'ThirdPerson'))
    {
        return NewFireEnd();
    }
   else
      return super.InstantFireEndTrace(StartTrace);
}



 simulated function vector GetNewEffectLocation()
{
    local vector SocketLocation;
   local UTPawn UTP;

   UTP = UTPawn(Instigator);
   if (UTP != none)
   {
      if (UTP.Mesh != none)
      {
         UTP.Mesh.GetSocketWorldLocationAndRotation('WeaponPoint', SocketLocation);
      }
      else
         SocketLocation = Location;
   }
   else
      SocketLocation = Location;

    return SocketLocation;
}

simulated function DoEmpty()
{

     local AdvKitPlayerController SPR;



     SPR = AdvKitPlayerController(Instigator.Controller);


     SPR.StopSprinting();
    // SPR.PlayCameraAnim(CameraAnim'ZombieWeapons.Camera.M4A1Reload');
   //  SPR.WeaponEmptyM();
     WorldInfo.Game.Broadcast(self, SPR); //BroadCast Target to make sure one is aquired

}

function PlayCameraAnim()
{
        local UTPlayerController PLR;
	PLR = UTPlayerController(Instigator.Controller);

//	PLR.PlayCameraAnim(CameraAnim'ZombieWeapons.Camera.M4A1Reload');
}

function Reload()
{
        bIsReloading = false;
	clips = clips - 1;
	AddAmmo(60);
	ClearTimer();

}

function byte BestMode()
{
	local byte Best;
	if ( IsFiring() )
		return CurrentFireMode;

	if ( FRand() < 1.0 )
		Best = 1;

	if ( Best < bZoomedFireMode.Length && bZoomedFireMode[Best] != 0 )
		return 0;
	else
		return Best;
}
//global variables






defaultproperties
{

        bIsReloading = false
	Clips = 2;
	ClipsMax = 4;
        bIsFlashlightOn=true
        bIsTurningonFlashlight=false

	AttachmentClass=class'Attachment_TommyGun2'
         FireEffectPSC=ParticleSystem'VH_Scorpion.Effects.PS_Scorpion_Gun_MuzzleFlash_Red'
        Begin Object class=SpotLightComponent name=SpotLightComponent0
		LightColor=(R=255,G=255,B=255)

        	CastShadows=true
        	bEnabled=true
        	Radius=1024.000000
        	FalloffExponent=3.000000
        	Brightness=1.900000
        	CastStaticShadows=False
        	CastDynamicShadows=True
        	bCastCompositeShadow=True
        	bAffectCompositeShadowDirection=True
	End Object
	Flashlight=SpotLightComponent0
        SKMesh=FirstPersonMesh
        
        
        Begin Object class=AnimNodeSequence Name=MeshSequenceA
		bCauseActorAnimEnd=true
	End Object


        Begin Object Class=DynamicLightEnvironmentComponent Name=MyLightEnvironment
		bEnabled=TRUE
		bSynthesizeSHLight=TRUE
		bIsCharacterLightEnvironment=TRUE
		bUseBooleanEnvironmentShadowing=TRUE
	End Object

        LightEnvironment=MyLightEnvironment
	Components.Add(MyLightEnvironment)

        Begin Object Name=FirstPersonMesh
			SkeletalMesh=SkeletalMesh'Characters.gun_low_poly_final'
		AnimSets(0)=none
		Animations=MeshSequenceA
		FOV=70.0
        End Object


	Begin Object Name=PickupMesh
	SkeletalMesh=SkeletalMesh'Characters.gun_low_poly_final'
	End Object

	WeaponFireTypes(0)=EWFT_InstantHit
	InstantHitDamage(0)=45
	InstantHitMomentum(0)=+10.0
	FireInterval(0)=+0.12
	InstantHitDamageTypes(0)=class'UTDmgType_Electrocuted'

	//
	//This is a very large value for debug purposes
	//A silly amount of spread ingame would show that the code isn't setting the spread values correctly
	//

        WeaponReloading(0)=WeaponReload
	WeaponFireSnd[0]=SoundCue'ZombieWeapons.Mesh.FireWep1_Cue'
	WeaponEquipSnd=none
	WeaponPutDownSnd=none
	PickupSound=none
	ReloadSound=none
	ReloadCameraAnim=none

	MaxDesireability=0.65
	AIRating=0.65
	CurrentRating=0.65
	bInstantHit=true
	bSplashJump=false
	bRecommendSplashDamage=false
	ShouldFireOnRelease(0)=1


	AmmoCount=30
	LockerAmmoCount=26
	MaxAmmoCount=30
//MuzzleSocketName=MuzzleFlashSocket
	MuzzleFlashSocket=MuzzleFlashSocket
	MuzzleFlashPSCTemplate=ParticleSystem'VH_Manta.Effects.PS_Manta_Gun_MuzzleFlash'
	MuzzleFlashDuration=0.33
	MuzzleFlashLightClass=class'Phoenix.Riflefirelight'

	IconCoordinates=(U=728,V=382,UL=162,VL=45)

	InventoryGroup=4
	GroupWeight=0.5

	IconX=400
	IconY=129
	IconWidth=5.5
	IconHeight=12
	EquipTime=+0.6
	PutDownTime=+0.33


	//CrossHairCoordinates=(U=256,V=0,UL=64,VL=64)
           CrossHairCoordinates=(U=406,V=320,UL=76,VL=77)
	//
	//These are the values carried over from the AimingWeaponClass that have been configured for this specific weapon
	//

	bSniping=true

	SpreadScoped=0.001
	SpreadNoScoped=0.003
	shellcount=2
        shellcountoffset=2

        
        WeaponName = "TommyGun2"
}