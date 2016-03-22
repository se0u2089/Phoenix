class HumanCharPawn extends DemoAIBasePawn
Placeable;
   var HumanPawn ZPawn;
defaultproperties{



          	Begin Object Name=WPawnSkeletalMeshComponent
	AnimTreeTemplate=AnimTree'PhoenixGamesDonal.HumanAnims'
          SkeletalMesh=SkeletalMesh'Main_characters.main_characters_skmesh.Human_SpellCastFBX01'
		AnimSets(0)=	AnimSet'Main_characters.main_characters_anim.Human_main_Animsets'
	PhysicsAsset= =PhysicsAsset'PhoenixGamesDonal.main_characters_skmesh.Ulari_main_SKMESH_Physics'
               	End Object





        Begin Object Name=CollisionCylinder
		CollisionRadius=+0024.000000
		CollisionHeight=+0044.000000
	End Object
	CylinderComponent=CollisionCylinder

	defaultPhysicsAsset=PhysicsAsset'PhoenixGamesDonal.main_characters_skmesh.Ulari_main_SKMESH_Physics'

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
                         
                         
                         

