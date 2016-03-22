
class DemoPawns extends UTPawn abstract;
    var bool    bFeigningDeath ;
     var bool    bForcedFeignDeath  ;
var bool bIsObjective;
 var name WeaponPoint;
  var ZomHUD ZHUD;
  var float StepInterval;   

 
var() float HearingRadius;
var() float SightDistance;
var() float BodyStayTime;
var() bool bRandomMovement;
var() float RandomInterval;       
var vector TargetLocation;
var vector NewLocation;
 var bool bDead;
  
  

enum EAdventureState
{
	EAS_Default,

};
var EAdventureState adventureState;



  /*trace length for CheckFloor function in the Controller*/
var float fFloorTraceLength;
 var bool bIsZoomedReady;
/*lerp speed used to smoothly rotate pawn*/
var float fRotationLerpSpeed;

 var AdvKitPlayerController advController;

var float fAnimTreeSideDirectionBlend;


var float fAnimTreeFrontDirectionBlend;
/**----------Root Motion Control----------**/
/**Pawn is currently executing RootMotion*/
var PrivateWrite bool bInRootMotion;
/**Pawn is currently executing RootMotion Rotation*/
var PrivateWrite bool bInRootRotation;



 function Rotator GetAdjustedAimFor(Weapon W, Vector StartFireLoc)
{
   		// If controller doesn't exist or we're a client, get the where the Pawn is aiming at
	if ( Controller == None || Role < Role_Authority )
	{
		return GetBaseAimRotation();
	}

	// otherwise, give a chance to controller to adjust this Aim Rotation
	return Controller.GetAdjustedAimFor( W, StartFireLoc );


}




 simulated event Vector GetWeaponStartTraceLocation(optional Weapon CurrentWeapon)
{
	local Vector SocketLocation;
	local Rotator SocketRotation;
	local UTWeapon UTWeapon;
	local SkeletalMeshComponent WeaponSkeletalMeshComponent;

	UTWeapon = UTWeapon(Weapon);
	if (UTWeapon != None)
	{
		WeaponSkeletalMeshComponent = SkeletalMeshComponent(UTWeapon.Mesh);
		if (WeaponSkeletalMeshComponent != None && WeaponSkeletalMeshComponent.GetSocketByName(UTWeapon.MuzzleFlashSocket) != None)
		{
			WeaponSkeletalMeshComponent.GetSocketWorldLocationAndRotation(UTWeapon.MuzzleFlashSocket, SocketLocation, SocketRotation);
			return SocketLocation;
		}
	}

	return Super.GetWeaponStartTraceLocation(CurrentWeapon);
}


function AIMP()

{
   bIsZoomedReady = true;
   Mesh.SetOwnerNoSee(False);
  // FullBodyAnimSlot.PlayCustomAnim('UlariRifleAimIdleFBX01', 2.0, 0.2, 0.2, FALSE, TRUE);
   `log("zooming in");
   SetTimer(0.02, false,'ZoomHold');
   GroundSpeed=100;
 //ZomHUD.ToggleCrosshair(false);
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

 function AIMPRelease()

{
  bIsZoomedReady = false;
 //FullBodyAnimSlot.PlayCustomAnim('UlariRifleAimIdleFBX01', 1.0, 0.2, 0.2, FALSE, TRUE);
  GroundSpeed=180;

    // ZomHUD.ToggleCrosshair(false);
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

/**Get the default collision height of the cylinder
 * Since the cylinder is modified in some controller state it helps
 * to have a function to get the default value
 *
 * @return  the default height
 */
final function float GetCollisionHeightDefault()
{
	if(CylinderComponent != none)
	{
		return CylinderComponent.default.CollisionHeight;
	}

	return 0;
}

/**Get the default collision radius of the cylinder
 * Since the cylinder is modified in some controller state it helps
 * to have a function to get the default value
 * 
 * @return  the default radius
 */
final function float GetCollisionRadiusDefault()
{
	if(CylinderComponent != none)
	{
		return CylinderComponent.default.CollisionRadius;
	}

	return 0;
}


simulated event Vector GetPawnViewLocation()
{
    local vector viewLoc;




    // no eye socket? No way I can tell you a location based on this socket then...
    if (WeaponPoint == '')
        return Location + BaseEyeHeight * vect(0,1,2);

    // HACK - force the first person weapon and arm models to hide
    // NOTE: You should remove all first person only weapon/arm meshes instead.
    SetWeaponVisibility(false);

    // HACK - force the world model and attachments to be visible
    // NOTE: You should make sure the mesh/attachments are always rendered.
    SetMeshVisibility(true);

    Mesh.GetSocketWorldLocationAndRotation(WeaponPoint, viewLoc);




    return viewLoc + WalkBob/4;
    



}


   simulated singular function Rotator GetBaseAimRotation()
{
    local vector    POVLoc;
    local rotator   POVRot;
    local AdvKitPlayerController PC;


	if( Controller != None )
	{
		Controller.GetPlayerViewPoint(POVLoc, POVRot);
		return POVRot;      //only use the playercontroller's viewpoint if in first person
	}

	POVRot = Rotation;  //otherwise use the pawn's rotation
	// If our Pitch is 0, then use RemoveViewPitch
	if( POVRot.Pitch == 0 )
	{
		POVRot.Pitch = RemoteViewPitch << 8;   //and also get his aim pitch (not the PAWN'S pitch, which is 0)
	}
 	return POVRot;
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

 defaultproperties
{ 	BaseEyeHeight=28.0

        	fRotationLerpSpeed = 10
	fFloorTraceLength = 55
	//Sliding
	fSlideTraceLength = 128
//	CamOffset=(X=24.0,Y=36.0,Z=-15)

   
	
	bCanBeBaseForPawns=true;

}
