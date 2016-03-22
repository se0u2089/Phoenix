
class HumanPawn extends UDKPawn ;


   var float CameraInitialOut;

var()	vector	HoverCamOffset;
var()	rotator	HoverCamRotOffset;
var()	vector	VelLookAtOffset;
var()	vector	VelBasedCamOffset;
var()	float	VelRollFactor;
var()	float	HoverCamMaxVelUsed;
var()	float	ViewRollRate;
var					int		CurrentViewRoll;

 var repnotify	class<DemoAttachmentClass>	CurrentWeaponAttachmentClass;
 var				DemoAttachmentClass			CurrentWeaponAttachment;
 var bool bDualWielding;
var(DemoGame3) const Name WeaponSocketName;

 var HumanPawn ZPawn;
/*hold a AdvKitPlayerController reference to prevent alot of unecessary casting (set in PossessedBy)*/
var AdvKitPlayerController advController;
// var		bool	bSpawnIn;
var		bool	bShieldAbsorb;			// set true when shield absorbs damage
var		bool	bDodging;				// true while in air after dodging
var		bool	bStopOnDoubleLanding;
var		bool	bIsInvulnerable;
var		bool	bJustDroppedOrb;
var	LinearColor SpawnProtectionColor;
var protected repnotify bool bPuttingDownWeapon;
var float CameraZOffset;

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


       var vector 	FixedViewLoc;
var rotator FixedViewRot;
var float CameraScale, CurrentCameraScale; /** multiplier to default camera distance */
var float CameraScaleMin, CameraScaleMax;


 /**
 * Replacement for AnimNodeBlendDirectional as described here:
 * http://www.sanzpont.com/chosker/elium/?p=326
 */
var float fAnimTreeSideDirectionBlend;
/**
 * Replacement for AnimNodeBlendDirectional as described here:
 * http://www.sanzpont.com/chosker/elium/?p=326
 */

var float fAnimTreeFrontDirectionBlend;
/**----------Root Motion Control----------**/
/**Pawn is currently executing RootMotion*/
var PrivateWrite bool bInRootMotion;
/**Pawn is currently executing RootMotion Rotation*/
var PrivateWrite bool bInRootRotation;

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
var DemoPlayerController2 MP;
var SoundCue TakeDamageSound;
// Post begin play

// Slam Variables ******
var float BaseDamage;
var float DamageRadius;
var EmitterSpawnable GroundSlamEffect;
var bool bPressingKeyPad;

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
  var vector CamOffset;
var bool bWinnerCam;
var vector CamShoulder;

  var float CameraYOffset;

enum EAdventureState
{
	EAS_Default,

};
var EAdventureState adventureState;





 var bool    bFeigningDeath ;
     var bool    bForcedFeignDeath  ;
var bool bIsObjective;


  simulated function AdjustPPEffects(DemoPlayerController PC, bool bRemove);


 simulated function SetThirdPersonCamera(bool bNewBehindView)
{
	if ( bNewBehindView )
	{
		CurrentCameraScale = 1.0;
		CameraZOffset = GetCollisionHeight() + Mesh.Translation.Z;
	}
	SetMeshVisibility(bNewBehindView);
}

simulated function Rotator GetAdjustedAimFor( Weapon W, vector StartFireLoc )
{

		return GetBaseAimRotation();

}


simulated event Vector GetPawnViewLocation()
{
    local vector viewLoc;




    // no eye socket? No way I can tell you a location based on this socket then...
    if (WeaponPoint == '')
        return Location + BaseEyeHeight * vect(0,0,0);

    // HACK - force the first person weapon and arm models to hide
    // NOTE: You should remove all first person only weapon/arm meshes instead.
    SetWeaponVisibility(false);

    // HACK - force the world model and attachments to be visible
    // NOTE: You should make sure the mesh/attachments are always rendered.
    SetMeshVisibility(true);

    Mesh.GetSocketWorldLocationAndRotation(WeaponPoint, viewLoc);




    return viewLoc + WalkBob/4;




}





reliable server function ServerFeignDeath()
{
	if (Role == ROLE_Authority && !WorldInfo.Game.IsInState('MatchOver') && DrivenVehicle == None && Controller != None && !bFeigningDeath)
	{
		bFeigningDeath = true;
	//	PlayFeignDeath();
	}
}

exec simulated function FeignDeath()
{
	ServerFeignDeath();
}

function ForceRagdoll()
{
	bFeigningDeath = true;
	bForcedFeignDeath = true;
//	PlayFeignDeath();
}













simulated event PostBeginPlay()
{
	super.PostBeginPlay();
	`Log("Custom Pawn up"); //debug

}
//stop aim node from aiming up or down



simulated event PostInitAnimTree(SkeletalMeshComponent SkelComp)
{
	super.PostInitAnimTree(SkelComp);
	AimNode.bForceAimDir = true; //forces centercenter
}

 simulated function SetCharacterMeshInfo(SkeletalMesh SkelMesh, MaterialInterface HeadMaterial, MaterialInterface BodyMaterial)
{
    Mesh.SetSkeletalMesh(SkelMesh);

	if (WorldInfo.NetMode != NM_DedicatedServer)
	{

	}
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





simulated function FaceRotation(rotator NewRotation, float DeltaTime)
{
	if ( Physics == PHYS_Ladder )
	{
		NewRotation = OnLadder.Walldir;
	}
	else if ( (Physics == PHYS_Walking) || (Physics == PHYS_Falling) )
	{
		NewRotation.Pitch = 0;
	}
	NewRotation.Roll = Rotation.Roll;
	SetRotation(NewRotation);
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




final function Vector Global2RelativePosition(Vector _vGlobalPosition)
{
	/*
	//Long explained version
	
	local Vector vRelativePosition;

	//only do stuff if Pawn has a base
	if(Base!=none)
	{
		vRelativePosition = _vGlobalPosition - Base.Location;
		vRelativePosition = vRelativePosition << Base.Rotation;

		return vRelativePosition;
	}

	//Short optimized version
	*/
	return (Base!=none) ? ((_vGlobalPosition - Base.Location) << Base.Rotation) : _vGlobalPosition;
}



/**Convert a global direction into a relative direction of Base
 * 
 * @param   _vGlobalDirection   direction in global space
 * @return                      direction in local space
 */
final function Vector Global2RelativeDirection(Vector _vGlobalDirection)
{
	/*
	//Long explained version
	
	if(Base!=none)
	{
		return _vGlobalDirection << Base.Rotation;
	}
	return _vGlobalDirection;
	
	//Short optimized version
	*/
	return (Base!=none) ? (_vGlobalDirection << Base.Rotation) : _vGlobalDirection;
}

/**Convert a relative direction in Base space into a global direction
 * 
 * @param   _vRelativeDirection     direction in local space
 * @return                          direction in global space
 */
final function Vector Relative2GlobalDirection(Vector _vRelativeDirection)
{
	/*
	//Long explained version
	
	if(Base!=none)
	{
		return _vRelativeDirection >> Base.Rotation;
	}
	return _vRelativeDirection;
	
	//Short optimized version
	*/

	return (Base!=none) ? (_vRelativeDirection >> Base.Rotation) : _vRelativeDirection;
}

/**Actor.uc:
 * Event called when an AnimNodeSequence (in the animation tree of one of this Actor's SkeletalMeshComponents) reaches the end and stops.
 * Will not get called if bLooping is 'true' on the AnimNodeSequence.
 * bCauseActorAnimEnd must be set 'true' on the AnimNodeSequence for this event to get generated.
 *
 * @param	_seqNode		- Node that finished playing. You can get to the SkeletalMeshComponent by looking at SeqNode->SkelComponent
 * @param	_fPlayedTime	- Time played on this animation. (play rate independant).
 * @param	_fExcessTime	- how much time overlapped beyond end of animation. (play rate independant).
 */
event OnAnimEnd(AnimNodeSequence _seqNode, float _fPlayedTime, float _fExcessTime)
{
	DeactivateRootMotion();

	//notify the advController if present
	if(advController!=none)
	{
		advController.NotifyOnAnimEnd(_seqNode,_fPlayedTime, _fExcessTime);
	}
}

/**Pawn.uc:
 * returns default camera mode when viewing this pawn.
 * Mainly called when controller possesses this pawn.
 *
 * @param	_requestedBy    requesting the default camera view
 * @return	                default camera view player should use when controlling this pawn.
 */
simulated function name GetDefaultCameraMode(PlayerController _requestedBy)
{
	return 'ThirdPerson';
}


/**Activate root motion for animations
 *
 * @param   _RMMode     translation mode
 * @param   _RMRMode    rotation mode
 */
final function ActivateRootMotion(optional ERootMotionMode _RMMode, optional ERootMotionRotationMode _RMRMode)
{
	//Reset everything first
	DeactivateRootMotion();

	//set flags
	bInRootMotion = (_RMMode!=RMM_Ignore);
	bInRootRotation = (_RMRMode!=RMRM_Ignore);

	//set modes
	Mesh.RootMotionMode = _RMMode;
	Mesh.RootMotionRotationMode = _RMRMode;
}

simulated function SetWeaponVisibility(bool bWeaponVisible)
{
	local AimingDemoWeaponClass Weap;
	local AnimNodeSequence WeaponAnimNode, ArmAnimNode;
	local int i;

	Weap = AimingDemoWeaponClass(Weapon);
	if (Weap != None)
	{
		Weap.ChangeVisibility(bWeaponVisible);

		// make the arm animations copy the current weapon anim
		WeaponAnimNode = Weap.GetWeaponAnimNodeSeq();
		if (WeaponAnimNode != None)
		{
			for (i = 0; i < ArrayCount(ArmsMesh); i++)
			{
				if (ArmsMesh[i].bAttached)
				{
					ArmAnimNode = AnimNodeSequence(ArmsMesh[i].Animations);
					if (ArmAnimNode != None)
					{
						ArmAnimNode.SetAnim(WeaponAnimNode.AnimSeqName);
						ArmAnimNode.PlayAnim(WeaponAnimNode.bLooping, WeaponAnimNode.Rate, WeaponAnimNode.CurrentTime);
					}
				}
			}
		}
	}
}

/**Deactivate root motion for animations
*/
final function DeactivateRootMotion()
{
	//disable flags
	bInRootMotion=false;
	bInRootRotation=false;

	//set modes
	Mesh.RootMotionMode = RMM_Ignore;
	Mesh.RootMotionRotationMode = RMRM_Ignore;
}





simulated function SetMeshVisibility(bool bVisible)
{
	local UTCarriedObject Flag;

	// Handle the main player mesh
	if (Mesh != None)
	{
		Mesh.SetOwnerNoSee(!bVisible);
	}

//	SetOverlayVisibility(bVisible);

	// Handle any weapons they might have
	SetWeaponVisibility(!bVisible);

	// realign any attached flags
	foreach BasedActors(class'UTCarriedObject', Flag)
	{
		HoldGameObject(Flag);
	}
}


defaultproperties
{
//	Components.Remove(Sprite)

	Begin Object Class=DynamicLightEnvironmentComponent Name=MyLightEnvironment
		bSynthesizeSHLight=TRUE
		bIsCharacterLightEnvironment=TRUE
		bUseBooleanEnvironmentShadowing=FALSE
		InvisibleUpdateTime=1
		MinTimeBetweenFullUpdates=.2
	End Object
	Components.Add(MyLightEnvironment)
	LightEnvironment=MyLightEnvironment

	Begin Object Class=SkeletalMeshComponent Name=WPawnSkeletalMeshComponent
		bCacheAnimSequenceNodes=FALSE
		AlwaysLoadOnClient=true
		AlwaysLoadOnServer=true
		bOwnerNoSee=true
		CastShadow=true
		BlockRigidBody=TRUE
		bUpdateSkelWhenNotRendered=false
		bIgnoreControllersWhenNotRendered=TRUE
		bUpdateKinematicBonesFromAnimation=true
		bCastDynamicShadow=true
		Translation=(Z=8.0)
		Translation=(y=8.0)
		RBChannel=RBCC_Untitled3
		RBCollideWithChannels=(Untitled3=true)
		LightEnvironment=MyLightEnvironment
		bOverrideAttachmentOwnerVisibility=true
		bAcceptsDynamicDecals=FALSE
	//	AnimTreeTemplate=AnimTree'CH_AnimHuman_Tree.AT_CH_Human'
		bHasPhysicsAssetInstance=true
		TickGroup=TG_PreAsyncWork
		MinDistFactorForKinematicUpdate=0.2
		bChartDistanceFactor=true
		//bSkipAllUpdateWhenPhysicsAsleep=TRUE
		RBDominanceGroup=20
		Scale=7.075
		// Nice lighting for hair
		bUseOnePassLightingOnTranslucency=TRUE
		bPerBoneMotionBlur=true
	End Object
	Mesh=WPawnSkeletalMeshComponent
	Components.Add(WPawnSkeletalMeshComponent)

	DefaultMeshScale=1.075
	BaseTranslationOffset=6.0

	Begin Object Name=OverlayMeshComponent0 Class=SkeletalMeshComponent
		Scale=4.015
		bAcceptsDynamicDecals=FALSE
		CastShadow=false
		bOwnerNoSee=true
		bUpdateSkelWhenNotRendered=false
		bOverrideAttachmentOwnerVisibility=true
		TickGroup=TG_PostAsyncWork
		bPerBoneMotionBlur=true
	End Object
	OverlayMesh=OverlayMeshComponent0

	Begin Object class=AnimNodeSequence Name=MeshSequenceA
	End Object

	Begin Object class=AnimNodeSequence Name=MeshSequenceB
	End Object

	Begin Object Class=UDKSkeletalMeshComponent Name=FirstPersonArms
		PhysicsAsset=None
		FOV=55
		Animations=MeshSequenceA
		DepthPriorityGroup=SDPG_Foreground
		bUpdateSkelWhenNotRendered=false
		bIgnoreControllersWhenNotRendered=true
		bOnlyOwnerSee=true
		bOverrideAttachmentOwnerVisibility=true
		bAcceptsDynamicDecals=FALSE
		AbsoluteTranslation=false
		AbsoluteRotation=true
		AbsoluteScale=true
		bSyncActorLocationToRootRigidBody=false
		CastShadow=false
		TickGroup=TG_DuringASyncWork
	End Object
	ArmsMesh[0]=FirstPersonArms

	Begin Object Class=UDKSkeletalMeshComponent Name=FirstPersonArms2
		PhysicsAsset=None
		FOV=55
		Scale3D=(Y=-1.0)
		Animations=MeshSequenceB
		DepthPriorityGroup=SDPG_Foreground
		bUpdateSkelWhenNotRendered=false
		bIgnoreControllersWhenNotRendered=true
		bOnlyOwnerSee=true
		bOverrideAttachmentOwnerVisibility=true
		HiddenGame=true
		bAcceptsDynamicDecals=FALSE
		AbsoluteTranslation=false
		AbsoluteRotation=true
		AbsoluteScale=true
		bSyncActorLocationToRootRigidBody=false
		CastShadow=false
		TickGroup=TG_DuringASyncWork
	End Object
	ArmsMesh[1]=FirstPersonArms2

	Begin Object Name=CollisionCylinder
		CollisionRadius=+0021.000000
		CollisionHeight=+0044.000000
	End Object
	CylinderComponent=CollisionCylinder

	Begin Object Class=UTAmbientSoundComponent name=AmbientSoundComponent
	End Object
	PawnAmbientSound=AmbientSoundComponent
	Components.Add(AmbientSoundComponent)

	Begin Object Class=UTAmbientSoundComponent name=AmbientSoundComponent2
	End Object
	WeaponAmbientSound=AmbientSoundComponent2
	Components.Add(AmbientSoundComponent2)

	ViewPitchMin=-18000
	ViewPitchMax=18000

	WalkingPct=+0.4
	CrouchedPct=+0.4
	BaseEyeHeight=38.0
	EyeHeight=38.0
	GroundSpeed=440.0
	AirSpeed=440.0
	WaterSpeed=220.0
	DodgeSpeed=600.0
	DodgeSpeedZ=295.0
	AccelRate=2048.0
	JumpZ=322.0
	CrouchHeight=29.0
	CrouchRadius=21.0
	WalkableFloorZ=0.78
       CamHeight = 40.0
	CamMinDistance = 40.0
	CamMaxDistance = 350.0
   	CamOffsetDistance=150.0
	CamZoomTick=20.0
	AlwaysRelevantDistanceSquared=+1960000.0
	InventoryManagerClass=class'UTInventoryManager'

	MeleeRange=+20.0
	bMuffledHearing=true

	Buoyancy=+000.99000000
	UnderWaterTime=+00020.000000
	bCanStrafe=True
	bCanSwim=true
	RotationRate=(Pitch=20000,Yaw=20000,Roll=20000)
	MaxLeanRoll=2048
	AirControl=+0.35
	DefaultAirControl=+0.35
	bCanCrouch=true
	bCanClimbLadders=True
	bCanPickupInventory=True
	bCanDoubleJump=true
	SightRadius=+12000.0

	MaxMultiJump=1
	MultiJumpRemaining=1
	MultiJumpBoost=-45.0

	SoundGroupClass=class'UTGame.UTPawnSoundGroup'

	TransInEffects(0)=class'UTEmit_TransLocateOutRed'
	TransInEffects(1)=class'UTEmit_TransLocateOut'

	MaxStepHeight=26.0
	MaxJumpHeight=49.0
	MaxDoubleJumpHeight=87.0
	DoubleJumpEyeHeight=43.0

	HeadRadius=+9.0
	HeadHeight=5.0
	HeadScale=+1.0
	HeadOffset=32

	SpawnProtectionColor=(R=40,G=40)
	TranslocateColor[0]=(R=20)
	TranslocateColor[1]=(B=20)
	DamageParameterName=DamageOverlay
	SaturationParameterName=Char_DistSatRangeMultiplier

	TeamBeaconMaxDist=3000.f
	TeamBeaconPlayerInfoMaxDist=3000.f
	RagdollLifespan=18.0

	bPhysRigidBodyOutOfWorldCheck=TRUE
	bRunPhysicsWithNoController=true



	CurrentCameraScale=1.0
	CameraScale=9.0
	CameraScaleMin=3.0
	CameraScaleMax=40.0

	LeftFootControlName=LeftFootControl
	RightFootControlName=RightFootControl
	bEnableFootPlacement=true
	MaxFootPlacementDistSquared=56250000.0 // 7500 squared

	SlopeBoostFriction=0.2
	bStopOnDoubleLanding=true
	DoubleJumpThreshold=160.0
	FireRateMultiplier=1.0

	ArmorHitSound=SoundCue'A_Gameplay.Gameplay.A_Gameplay_ArmorHitCue'
	SpawnSound=SoundCue'A_Gameplay.A_Gameplay_PlayerSpawn01Cue'
	TeleportSound=SoundCue'A_Weapon_Translocator.Translocator.A_Weapon_Translocator_Teleport_Cue'

	MaxFallSpeed=+1250.0
	AIMaxFallSpeedFactor=1.1 // so bots will accept a little falling damage for shorter routes
	LastPainSound=-1000.0

	FeignDeathBodyAtRestSpeed=12.0
	bReplicateRigidBodyLocation=true

	MinHoverboardInterval=0.7
	HoverboardClass=class'UTVehicle_Hoverboard'

	FeignDeathPhysicsBlendOutSpeed=2.0
	TakeHitPhysicsBlendOutSpeed=0.5

	TorsoBoneName=b_Spine2
	FallImpactSound=SoundCue'A_Character_BodyImpacts.BodyImpacts.A_Character_BodyImpact_BodyFall_Cue'
	FallSpeedThreshold=125.0

	SuperHealthMax=199

	// moving here for now until we can fix up the code to have it pass in the armor object
	ShieldBeltMaterialInstance=Material'Pickups.Armor_ShieldBelt.M_ShieldBelt_Overlay'
	ShieldBeltTeamMaterialInstances(0)=Material'Pickups.Armor_ShieldBelt.M_ShieldBelt_Red'
	ShieldBeltTeamMaterialInstances(1)=Material'Pickups.Armor_ShieldBelt.M_ShieldBelt_Blue'
	ShieldBeltTeamMaterialInstances(2)=Material'Pickups.Armor_ShieldBelt.M_ShieldBelt_Red'
	ShieldBeltTeamMaterialInstances(3)=Material'Pickups.Armor_ShieldBelt.M_ShieldBelt_Blue'

	HeroCameraPitch=6000
	HeroCameraScale=6.0

	//@TEXTURECHANGEFIXME - Needs actual UV's for the Player Icon
	IconCoords=(U=657,V=129,UL=68,VL=58)
	MapSize=1.0

	// default bone names
	WeaponSocket=WeaponPoint
	WeaponSocket2=DualWeaponPoint
	HeadBone=b_Head
	PawnEffectSockets[0]=L_JB
	PawnEffectSockets[1]=R_JB


	MinTimeBetweenEmotes=1.0

	DeathHipLinSpring=10000.0
	DeathHipLinDamp=500.0
	DeathHipAngSpring=10000.0
	DeathHipAngDamp=500.0

	bWeaponAttachmentVisible=true

	TransCameraAnim[0]=CameraAnim'Envy_Effects.Camera_Shakes.C_Res_IN_Red'
	TransCameraAnim[1]=CameraAnim'Envy_Effects.Camera_Shakes.C_Res_IN_Blue'
	TransCameraAnim[2]=CameraAnim'Envy_Effects.Camera_Shakes.C_Res_IN'

	MaxFootstepDistSq=9000000.0
	MaxJumpSoundDistSq=16000000.0

	SwimmingZOffset=-30.0
	SwimmingZOffsetSpeed=45.0

	TauntNames(0)=TauntA
	TauntNames(1)=TauntB
	TauntNames(2)=TauntC
	TauntNames(3)=TauntD
	TauntNames(4)=TauntE
	TauntNames(5)=TauntF

	Begin Object Class=ForceFeedbackWaveform Name=ForceFeedbackWaveformFall
		Samples(0)=(LeftAmplitude=50,RightAmplitude=40,LeftFunction=WF_Sin90to180,RightFunction=WF_Sin90to180,Duration=0.200)
	End Object
	FallingDamageWaveForm=ForceFeedbackWaveformFall

	CamOffset=(X=0.0,Y=50.0,Z=0.0)

          	fRotationLerpSpeed = 10
	fFloorTraceLength = 55
	//Sliding
	fSlideTraceLength = 128      
        WeaponSocket=WeaponPoint
        	//HoverCamOffset=(X=60,Y=-20,Z=-15)
        //	HoverCamOffset=(X=0,Y=40,Z=0)
//	HoverCamRotOffset=(Pitch=728)
	VelLookAtOffset=(X=-0.07,Y=-0.07,Z=-0.03)
	VelBasedCamOffset=(Z=-0.02)
	VelRollFactor=0.4
	HoverCamMaxVelUsed=800
	ViewRollRate=100


}
