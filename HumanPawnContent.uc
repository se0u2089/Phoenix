
class HumanPawnContent extends HumanPawn ;



// ****************Mesh Attributes****************** //
var SkeletalMesh defaultMesh;
var MaterialInterface defaultMaterial0;
var AnimTree defaultAnimTree;
var array<AnimSet> defaultAnimSet;
var AnimNodeSequence defaultAnimSeq;
var PhysicsAsset defaultPhysicsAsset;
var array<AnimSet> transformedAnimSet;
  
simulated function name GetDefaultCameraMode( PlayerController RequestedBy )
{
	return 'default';
}

defaultproperties
{


          	Begin Object Name=WPawnSkeletalMeshComponent
	//	AnimTreeTemplate=AnimTree'CH_AnimHuman_Tree.AT_CH_Human'
          SkeletalMesh=SkeletalMesh'Main_characters.main_characters_skmesh.Human_SpellCastFBX01'
		AnimSets(0)=	AnimSet'Main_characters.main_characters_anim.Human_main_Animsets'
	//	PhysicsAsset=

               defaultMesh=SkeletalMesh'Main_characters.main_characters_skmesh.Human_SpellCastFBX01'

                       	fRotationLerpSpeed = 10
	fFloorTraceLength = 55
	//Sliding
	fSlideTraceLength = 128      
        WeaponSocket=WeaponPoint
	AnimTreeTemplate=AnimTree'PhoenixGamesDonal.HumanAnims'

           	End Object


       defaultMesh=SkeletalMesh'PhoenixGamesDonal.main_characters_skmesh.Ulari_main_SKMESH'
	defaultAnimTree=AnimTree'PhoenixGamesDonal.Crano.UlariAnimationTree'
	defaultAnimSet(0)=AnimSet'Main_characters_Backup.main_characters_anim.Ulari_main_Animsets'





        Begin Object Name=CollisionCylinder
		CollisionRadius=+0024.000000
		CollisionHeight=+0044.000000
	End Object
	CylinderComponent=CollisionCylinder

	defaultPhysicsAsset=PhysicsAsset'PhoenixGamesDonal.main_characters_skmesh.Ulari_main_SKMESH_Physics'
                       	fRotationLerpSpeed = 10
	fFloorTraceLength = 55
	//Sliding
	fSlideTraceLength = 128      
        WeaponSocket=WeaponPoint

}
