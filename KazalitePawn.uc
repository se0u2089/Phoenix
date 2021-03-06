class KazalitePawn extends DemoAIBasePawn
Placeable;

defaultproperties{

	Begin Object Name=WPawnSkeletalMeshComponent
		AnimTreeTemplate=AnimTree'PhoenixGamesDonal.Crano.KazaliteAnimationTree'
		SkeletalMesh=SkeletalMesh'Main_characters_Backup.main_characters_skmesh.Kazalite_main_SKMESH'
		AnimSets(0)=AnimSet'Main_characters_Backup.main_characters_anim.Kazalite_main_Animsets'
		PhysicsAsset=PhysicsAsset'PhoenixGamesDonal.main_characters_physicsassets.Kazalite_main_SKMESH_Physics'
		Scale=3.5
	End Object
        Begin Object Name=CollisionCylinder
      CollisionRadius=+0021.000000
      CollisionHeight=+0042.000000
   End Object
   CylinderComponent=CollisionCylinder
	RagdollLifespan=480.0 //how long the dead body will hang around for


	AirSpeed=140
	GroundSpeed=400
  ControllerClass=class'TestKazaliteBot'
	bDontPossess=false
                 HeadShotSocket="HeadShotSocket"
        LegSocketLeft = "LegSocketLeft"
        LegSocketRight = "LegSocketRight"
        TorsoSocket = "TorsoSocket"
        TorsoGibClass = class'ZomGibSkel'
        LegGibClass = class 'ZomGib'
        HeadGibClass = class 'ZomGib'
        Information = "Idle"
	DamageAmount=1
         ShieldAmount=100
	SuperHealthMax=199
	Health=200
        
                         }