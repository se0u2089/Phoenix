class ZomGibSkel extends KAssetSpawnable
  placeable;



function HideSpecificBone (name BonetoHide)
{
  local Vector ImpulsePower;
  
  ImpulsePower.X =5;
  ImpulsePower.Y =5;
  ImpulsePower.Z =6;

  SkeletalMeshComponent.HideBoneByName(BonetoHide, PBO_Disable );
  SkeletalMeshComponent.AddImpulse(ImpulsePower);
}

DefaultProperties
{
	Begin Object name=MyLightEnvironment
	End Object
	Components.Add(MyLightEnvironment)

	Begin Object  name=KAssetSkelMeshComponent
	    Animations=None
        // SkeletalMesh=SkeletalMesh'ZombiesMonsters.ZombieGen.ZombieGenM'
       //  PhysicsAsset=PhysicsAsset'ZombiesMonsters.ZombieGen.ZombieGenM_Physics'
         bHasPhysicsAssetInstance=true
		bUpdateKinematicBonesFromAnimation=false
		PhysicsWeight=1.0
       RBChannel=RBCC_GameplayPhysics 
       		RBCollideWithChannels=(default=TRUE,BlockingVolume=TRUE,GameplayPhysics=TRUE, Pawn=true)
		LightEnvironment=MyLightEnvironment
		bSkipAllUpdateWhenPhysicsAsleep=TRUE
        bNotifyRigidBodyCollision=true
        bCastDynamicShadow=true
	End Object
	CollisionComponent=KAssetSkelMeshComponent
	SkeletalMeshComponent=KAssetSkelMeshComponent
	Components.Add(KAssetSkelMeshComponent)

	SupportedEvents.Add(class'SeqEvent_ConstraintBroken')
	SupportedEvents.Add(class'SeqEvent_RigidBodyCollision')


    bWakeOnLevelStart=false
	bDamageAppliesImpulse=true
	bNetInitialRotation=true
	CollisionType=COLLIDE_BlockAll

	bEdShouldSnap=true
	bStatic=false
	bCollideActors=true
	bBlockActors=true
	bWorldGeometry=true
	bCollideWorld=true
	bProjTarget=true
	BlockRigidBody=true
	bBlockPawns=true



}