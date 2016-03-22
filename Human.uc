
class Human extends DemoPawns Placeable;


 var repnotify	class<DemoAttachmentClass>	CurrentWeaponAttachmentClass;
 var				DemoAttachmentClass			CurrentWeaponAttachment;
 var bool bDualWielding;
var(DemoGame2) const Name WeaponSocketName;

 var DemoPawn ZPawn;
/*hold a AdvKitPlayerController reference to prevent alot of unecessary casting (set in PossessedBy)*/

// var		bool	bSpawnIn;
var		bool	bShieldAbsorb;			// set true when shield absorbs damage
var		bool	bDodging;				// true while in air after dodging
var		bool	bStopOnDoubleLanding;
var		bool	bIsInvulnerable;
var		bool	bJustDroppedOrb;
var	LinearColor SpawnProtectionColor;
var protected repnotify bool bPuttingDownWeapon;

/*trace length for CheckFloor function in the Controller*/
var float fFloorTraceLength;
 var bool bIsZoomedReady;
/*lerp speed used to smoothly rotate pawn*/
var float fRotationLerpSpeed;

 var	bool		bUpdateEyeheight;
 //  var FlashWeap myGun;
 var bool bWeaponAttachmentVisible;
  var		bool	bSpawnDone;

   var					vector	WalkBob;
  var bool cSpawnDone;
   var name WeaponSocket, WeaponSocket2;


// ****************Mesh Attributes****************** //
var SkeletalMesh defaultMesh;
var MaterialInterface defaultMaterial0;
var AnimTree defaultAnimTree;
var array<AnimSet> defaultAnimSet;
var AnimNodeSequence defaultAnimSeq;
var PhysicsAsset defaultPhysicsAsset;
var array<AnimSet> transformedAnimSet;
var config float CastlePawnSpeed;
var config float CastlePawnAccel;
var bool MadeNoise;

var name EyeSocket;
var name WeaponPoint;

// Camera Vars //
var float Dist;
var float TargetFOV;
var float TargetZ;
var float Z;
var float TargetOffset;
var float Offset;
var float pival;

var float		Stamina;
var float		SprintTimer;
var float		SprintRecoverTimer;
var float		Empty;
var bool		bSprinting;
var bool bIsProned;
   var float fWaterSurfaceZ;
//Walking ints......
var int m,n;
var float smooth, MaxEyeHeight, OldEyeHeight, Speed2D, OldBobTime;
var float StepInterval;


var ZomHUD ZomHUD;
var bool EmptyWeapon;
var float AngleHit;
var bool downPlayed;
var AdvKitPlayerController MP;
var SoundCue TakeDamageSound;
// Post begin play

// Slam Variables ******
var float BaseDamage;
var float DamageRadius;
var EmitterSpawnable GroundSlamEffect;
var bool bPressingKeyPad;

/** Controller currently possessing this Pawn */
var editinline repnotify Controller Controller;
var Color LightColor;
var float LightScale;
var PointLightComponent LightAttachment;
  var SkelControl_CCD_IK RightArmIK;
var	AnimNodeAimOffset AimNode;

// Reference to the gun recoil skel controller node
var GameSkelCtrl_Recoil GunRecoilNode;

     var float CamOffsetDistance; //distance to offset the camera from the player in unreal units
var float CamMinDistance, CamMaxDistance;
var float CamZoomTick; //how far to zoom in/out per command
     var float CamHeight; //how high cam is relative to pawn pelvis
        var int CameraZoom;
          var int      camerazoomsensitivity;
            var int       CameraMinDistance ;
            var int       CameraMaxDistance   ;


enum EAdventureState
{
	EAS_Default,

};
var EAdventureState adventureState;


    simulated singular function Rotator GetBaseAimRotation()
{
    local vector    POVLoc;
    local rotator   POVRot;
    local AdvKitPlayerController PC;

    local vector TargetLocation;
    local vector HitLocation, HitNormal;
    local int TraceScalar;

    // If we have a controller, by default we aim at the player's 'eyes' direction
    // that is by default Controller.Rotation for AI, and camera (crosshair) rotation for human players.
    if( Controller != None && !InFreeCam() )
    {
        Controller.GetPlayerViewPoint(POVLoc, POVRot);
        PC = AdvKitPlayerController( Controller );




        if ( !PC.bBehindView )
        {


            return POVRot;
        }


        /** INFO (neoaez) 20080610: changed ActionCam code in the following line from this:
         * TargetLocation = POVLoc + (vector(POVRot)*100000);
         * to remove arbitray scalar used in trace to that of the weapon equipped.  This follows the
         * example set out by the function GetWeaponAim in UTVehicle  Fixes an accuracy issue when
         * in third-person.
         * */
         if (Weapon.bMeleeWeapon) { TraceScalar = 100000; }
         else { TraceScalar = Weapon.GetTraceRange(); }
         TargetLocation = POVLoc + ( vector( POVRot ) * TraceScalar );
         if( Trace( HitLocation, HitNormal, TargetLocation, POVLoc, false,,,TRACEFLAG_Bullet ) == None )
         {
             HitLocation = TargetLocation;
         }
         POVRot = rotator( HitLocation - GetWeaponStartTraceLocation() );

        return POVRot;
    }

    // If we have no controller, we simply use our rotation
    POVRot = Rotation;

    // If our Pitch is 0, then use RemoveViewPitch
    if( POVRot.Pitch == 0 )
    {
        POVRot.Pitch = RemoteViewPitch << 8;
    }

    return POVRot;
}




     function Tick( float DeltaTime )
{
		local Actor HitActor;
                local vector HitLocation, HitNormal, TraceStart, TraceEnd;




      if( Physics == PHYS_Ladder || bPressingKeyPad == true )
      {
        //Dont Do this
      }
      else
      {

                   // Trace from my weapons location and see if it hit my pickup actors
                TraceStart = GetWeaponStartTraceLocation();
                TraceEnd = TraceStart + vector(Rotation) * 40;
                HitActor = Trace(HitLocation, HitNormal, TraceEnd, self.Location, true,,,
				TRACEFLAG_Bullet | TRACEFLAG_PhysicsVolumes |
				TRACEFLAG_SkipMovers | TRACEFLAG_Blocking);

                if (HitActor == None && downplayed == true)
                {
                  return;
                }

                 // If we hit a wall, play up anim!
                 else if (HitActor.IsA('WorldInfo') || HitActor.IsA('bWorldGeometry'))
		{
               //    TopHalfAnimSlot.PlayCustomAnim('WeaponUpIdle', 1.0, 0.2, 0.2, TRUE, TRUE);
                   downPlayed = false;
		}
		else if(HitActor == None && downPlayed == false  )
		{
             //      TopHalfAnimSlot.PlayCustomAnim('WeaponDown', 1.0, 0.2, 0.2, FALSE, TRUE);
                   downPlayed = true;
                }
                else if(downPlayed == true)
                {

                }

      }
}
 function Vector GetAimAtLocation()
{
//	return MyTargetLocation;
}
 exec function CamZoomIn()
{
	`Log("Zoom in");
	if(CamOffsetDistance > CamMinDistance)
		CamOffsetDistance-=CamZoomTick;
}
  simulated function SetWeaponAttachmentVisibility(bool bAttachmentVisible)
{
	bWeaponAttachmentVisible = bAttachmentVisible;
	if (CurrentWeaponAttachment != None )
	{
		CurrentWeaponAttachment.ChangeVisibility(bAttachmentVisible);
	}
}
exec function CamZoomOut()
{
	`Log("Zoom out");
	if(CamOffsetDistance < CamMaxDistance)
		CamOffsetDistance+=CamZoomTick;
}





function ZoomHold()
            {
  //            TopHalfAnimSlot.PlayCustomAnim('WeaponAIMFull', 1.0, 0.2, 0.2, TRUE, TRUE);
            }

function AIMPRelease()

{
  bIsZoomedReady = false;
 // TopHalfAnimSlot.PlayCustomAnim('WeaponAIMOut', 1.0, 0.2, 0.2, FALSE, TRUE);
  GroundSpeed=180;

     ZomHUD.ToggleCrosshair(false);
}



 function AssignController(SeqAct_AssignController inAction)
{

	if ( inAction.ControllerClass != None )
	{
		if ( Controller != None )
		{
			DetachFromController( true );
		}

		Controller = Spawn(inAction.ControllerClass);
		Controller.Possess( Self, false );

		// Set class as the default one if pawn is restarted.
		if ( Controller.IsA('AIController') )
		{
			ControllerClass = class<AIController>(Controller.Class);
		}
	}
	else
	{
		`warn("Assign controller w/o a class specified!");
	}
}














simulated function PostBeginPlay()
{

        super.PostBeginPlay();
}



event Landed(vector HitNormal, actor FloorActor)
{
	local vector Impulse;

	Super.Landed(HitNormal, FloorActor);

	MP =AdvKitPlayerController(Controller);



        // adds impulses to vehicles and dynamicSMActors (e.g. KActors)
	Impulse.Z = Velocity.Z * 4.0f; // 4.0f works well for landing on a Scorpion
	if (UTVehicle(FloorActor) != None)
	{
		UTVehicle(FloorActor).Mesh.AddImpulse(Impulse, Location);
	}
	else if (DynamicSMActor(FloorActor) != None)
	{
		DynamicSMActor(FloorActor).StaticMeshComponent.AddImpulse(Impulse, Location);
	}

	if ( Velocity.Z < -200 )
	{
		OldZ = Location.Z;
		bJustLanded = bUpdateEyeHeight && (Controller != None) && Controller.LandingShake();
	}

	if (UTInventoryManager(InvManager) != None)
	{
		UTInventoryManager(InvManager).OwnerEvent('Landed');
	}
	if ((MultiJumpRemaining < MaxMultiJump && bStopOnDoubleLanding) || bDodging || Velocity.Z < -2 * JumpZ)
	{
		// slow player down if double jump landing
		Velocity.X *= 0.1;
		Velocity.Y *= 0.1;
	}

	AirControl = DefaultAirControl;
	MultiJumpRemaining = MaxMultiJump;
	bDodging = false;
	bReadyToDoubleJump = false;
	if (UTBot(Controller) != None)
	{
		UTBot(Controller).ImpactVelocity = vect(0,0,0);
	}

	if(!bHidden)
	{
	//	PlayLandingSound();
	}
	if (Velocity.Z < -MaxFallSpeed)
	{
//		SoundGroupClass.Static.PlayFallingDamageLandSound(self);
	}
	else if (Velocity.Z < MaxFallSpeed * -0.5)
	{
//		SoundGroupClass.Static.PlayLandSound(self);
	}

	SetBaseEyeheight();
}

simulated function PlayEmpty()
{
 //  TopHalfAnimSlot.PlayCustomAnim('WeaponReloadEmpty', 1.0, 0.2, 0.2, FALSE, TRUE);
   `log("PlayEmpty");
   `log("poop");
}

function WeaponEquip()
{
  // TopHalfAnimSlot.PlayCustomAnim('WeaponEquip', 0.5, 0.2, 0.2, FALSE, TRUE);
}
function WeaponChange()
{
  // TopHalfAnimSlot.PlayCustomAnim('WeaponChange', 0.5, 0.2, 0.2, FALSE, TRUE);
}




simulated function WeaponFired(Weapon InWeapon, bool bViaReplication, optional vector HitLocation)
{
	local UTPlayerController PLR;

        PLR = UTPlayerController(Controller);

        if (CurrentWeaponAttachment != None)
	{
		if ( IsFirstPerson() )
		{
			CurrentWeaponAttachment.ThirdPersonFireEffects(HitLocation);
			PLR.PlayCameraAnim(CameraAnim'ZombieWeapons.Camera.M4A1Fire');
		}
		else
		{
			CurrentWeaponAttachment.FirstPersonFireEffects(Weapon, HitLocation);
	                if ( class'Engine'.static.IsSplitScreen() && CurrentWeaponAttachment.EffectIsRelevant(CurrentWeaponAttachment.Location,false,CurrentWeaponAttachment.MaxFireEffectDistance) )
	                {
		                // third person muzzle flash
		                CurrentWeaponAttachment.CauseMuzzleFlash();
	                }
		}

		if ( HitLocation != Vect(0,0,0) && (WorldInfo.NetMode == NM_ListenServer || WorldInfo.NetMode == NM_Standalone || bViaReplication) )
		{
			CurrentWeaponAttachment.PlayImpactEffects(HitLocation);
		}
	}

}



simulated function WeaponStoppedFiring(Weapon InWeapon, bool bViaReplication)
{
	if (CurrentWeaponAttachment != None)
	{
		// always call function for both viewpoints, as during the delay between calling EndFire() on the weapon
		// and it actually stopping, we might have switched viewpoints (e.g. this commonly happens when entering a vehicle)
		CurrentWeaponAttachment.StopThirdPersonFireEffects();
		CurrentWeaponAttachment.StopFirstPersonFireEffects(Weapon);
	}
}




//Overeriding the default take damage so i can have custom effects and Special damage calls. Depending on the damage taken you will react differently.
//Check player controller for damage specific actions. " CALCULATEHealth(); function!!!!!!
event TakeDamage(int Damage, Controller EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
	local int OldHealth;
        local AdvKitPlayerController MPC;

        MPC = AdvKitPlayerController(Controller);

	// Attached Bio glob instigator always gets kill credit
	if (AttachedProj != None && !AttachedProj.bDeleteMe && AttachedProj.InstigatorController != None)
	   {
		         EventInstigator = AttachedProj.InstigatorController;
           }

	// reduce rocket jumping
	if (EventInstigator == Controller)
	   {
	   	            momentum *= 0.6;
           }

	// accumulate damage taken in a single tick
	if ( AccumulationTime != WorldInfo.TimeSeconds )
	   {
		              AccumulateDamage = 0;
		              AccumulationTime = WorldInfo.TimeSeconds;
           }
            OldHealth = Health;
            AccumulateDamage += Damage;
	    MPC.OldHealths -= Damage;
	    PlaySound(TakeDamageSound);
            MPC.CalculateHealth();
        AccumulateDamage = AccumulateDamage + OldHealth - Health - Damage;
        Super.TakeDamage(Damage, EventInstigator, HitLocation, Momentum, DamageType, HitInfo, DamageCauser);
	

	

}

simulated function UTGib SpawnGib(class<UTGib> GibClass, name BoneName, class<UTDamageType> UTDamageType, vector HitLocation, bool bSpinGib)
{

}

simulated function SetCharacterClassFromInfo(class<UTFamilyInfo> Info)
{
	Mesh.SetSkeletalMesh(defaultMesh);
	Mesh.SetMaterial(0,defaultMaterial0);
	Mesh.SetPhysicsAsset(defaultPhysicsAsset);
	Mesh.AnimSets=defaultAnimSet;
	Mesh.SetAnimTreeTemplate(defaultAnimTree);
	Mesh.SetOwnerNoSee(False);
    //    CurrCharClassInfo = Info;
}



function AIMP()

{
   bIsZoomedReady = true;
   Mesh.SetOwnerNoSee(False);
 //  TopHalfAnimSlot.PlayCustomAnim('WeaponAIM', 2.0, 0.2, 0.2, FALSE, TRUE);
   `log("zooming in");
   SetTimer(0.02, false,'ZoomHold');
   GroundSpeed=100;
 ZomHUD.ToggleCrosshair(false);
}






 function TommyGunAnim()
{
 //Mesh.AnimSets[0]=AnimSet'ZombiesCharacters.Crano.Crano_Suit_Anims_TommyGun';
 Mesh.UpdateAnimations();
}
 function M34AAnim()
{
// Mesh.AnimSets[0]=AnimSet'ZombiesCharacters.Crano.Crano_Suit_Anims_M34A';
 Mesh.UpdateAnimations();
}
 function CrowbarAnim()
{

}


//Sets the default animation when not holding any kind of weapon.
function DefaultAnim()
{
 //  Mesh.AnimSets[0]=AnimSet'ZombiesCharacters.Crano.Crano_Suit_Anims_Default';
   //Mesh.AnimTreeTemplate=AnimTree'GearPlayers.Mesh.RobertTree';
   Mesh.UpdateAnimations();
}







simulated State Dying
{
    // skip UTPawn's fancy damage/third person views
    simulated function bool CalcCamera( float fDeltaTime, out vector out_CamLoc, out rotator out_CamRot, out float out_FOV )
    {
        return Global.CalcCamera(fDeltaTime, out_CamLoc, out_CamRot, out_FOV);
    }

    simulated event rotator GetViewRotation()
    {
        local vector out_Loc;
        local rotator out_Rot;

        // no eye socket? No way I can tell you a rotation based on this socket then...
        if (EyeSocket == '')
            return Global.GetViewRotation(); // non-state version please
        
        Mesh.GetSocketWorldLocationAndRotation(EyeSocket, out_Loc, out_Rot);

        return out_Rot;
    }
}





defaultproperties
{
            HUDType = class'Phoenix.GameHUD'
        	GroundSpeed=440.0
	AirSpeed=640.0
	WaterSpeed=220.0
	DodgeSpeed=600.0
	DodgeSpeedZ=295.0
	AccelRate=2048.0

	AngleHit = 0.5
        bCanStrafe=false
	bPushesRigidBodies=true
        bCanDoubleJump=true
	JumpZ=300

	// double jump animation will be required
	OutofWaterZ=340
	MaxJumpHeight=430

	//GRENADEFUNCTIONS/////
        SprintTimer=5.0
	SprintRecoverTimer=4
	Stamina=8.0
        Empty=1.0
        bIsZoomedReady=false
        downPlayed = true
        //Setting up the light environment

//Setting up the mesh and animset components






   defaultMesh= SkeletalMesh'Main_characters.main_characters_skmesh.Human_SpellCastFBX01'
	defaultAnimTree=AnimTree'PhoenixGamesDonal.HumanAnims'
	defaultAnimSet(0)=AnimSet'Main_characters.main_characters_anim.Human_main_Animsets'
               	Scale=1.7 
               	
         	Begin Object Name=WPawnSkeletalMeshComponent
	AnimTreeTemplate=AnimTree'PhoenixGamesDonal.HumanAnims'
		SkeletalMesh=SkeletalMesh'Main_characters.main_characters_skmesh.Human_SpellCastFBX01'
		AnimSets(0)=AnimSet'Main_characters.main_characters_anim.Human_main_Animsets'

		Scale=7.7
	End Object

        Begin Object Name=CollisionCylinder
		CollisionRadius=+0024.000000
		CollisionHeight=+0044.000000
	End Object
	CylinderComponent=CollisionCylinder

	defaultPhysicsAsset=PhysicsAsset'PhoenixGamesDonal.main_characters_skmesh.Ulari_main_SKMESH_Physics'




	bCanCrouch=true
	bCanClimbLadders=True
	bCanPickupInventory=True
       // CurrCharClassInfo = class'FamilyInfo_Zombie'
        EyeSocket=Eyes
        WeaponPoint=WeaponPoint
      // 	SoundGroupClass=class'ZomPawnSoundGroup'
       	InventoryManagerClass=class'DemoInventoryManager'

	CurrentCameraScale=2.5
	CameraScale=5.0
	CameraScaleMin=.4
	CameraScaleMax=100.0
	StepInterval = 7.0
	EmptyWeapon = false
        TakeDamageSound = SoundCue'ZombiesSounds.Hurt.TakeDamage'

        BaseDamage = 100
        DamageRadius = 198
        bPressingKeyPad = false

        MadeNoise = false

        LightColor=(R=255,G=255,B=255,A=155)

  	CamHeight = 1
	CamMinDistance = 1.0
	CamMaxDistance = 650.0
   	CamOffsetDistance=70.0
	CamZoomTick=20.0
        LightScale = 0.3
             WeaponSocketName=WeaponPoint
               BaseEyeHeight=10.0
        Bob=0.002
        WalkBob=0.005
        MultiJumpBoost=750.0
        bUpdateEyeHeight=true
             	DefaultMeshScale=4.075
        
        	fRotationLerpSpeed = 10
	fFloorTraceLength = 55
	//Sliding
	fSlideTraceLength = 128
        WeaponSocket=WeaponPoint
	WeaponSocket2=DualWeaponPoint



}
