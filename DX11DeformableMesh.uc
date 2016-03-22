class DX11DeformableMesh extends Actor
	placeable;

var() const LightEnvironmentComponent LightEnvironmentComponent;
var() const SkeletalMeshComponent SkeletalMeshComponent;
var() const SceneCapture2DHitMaskComponent SceneCapture2DHitMaskComponent;
var() const IntPoint HitMaskSize;
var() const Name HitMaskMaterialParameterName;
var() const Name MinimumDisplacementParameterName;
var() const Name MaximumDisplacementParameterName;
var() const float MinimumDisplacement;
var() const float MaximumDisplacement;

var TextureRenderTarget2D HitMaskRenderTarget;

simulated function PostBeginPlay()
{
	local MaterialInstanceConstant MaterialInstanceConstant;
	local LinearColor LC;
	local Vector V;

	Super.PostBeginPlay();

	HitMaskRenderTarget = class'TextureRenderTarget2D'.static.Create(HitMaskSize.X, HitMaskSize.Y, PF_G8, MakeLinearColor(0, 0, 0, 1));
	if (HitMaskRenderTarget != None)
	{
		SceneCapture2DHitMaskComponent.SetCaptureTargetTexture(HitMaskRenderTarget);
		SceneCapture2DHitMaskComponent.SetFadingStartTimeSinceHit(-1.f);

		if (SkeletalMeshComponent != None)
		{
			MaterialInstanceConstant = SkeletalMeshComponent.CreateAndSetMaterialInstanceConstant(0);
			if (MaterialInstanceConstant != None)
			{
				MaterialInstanceConstant.SetTextureParameterValue(HitMaskMaterialParameterName, HitMaskRenderTarget);

				V = Vector(Rotation);
				V *= MinimumDisplacement;
				LC.R = V.X;
				LC.G = V.Y;
				LC.B = V.Z;
				MaterialInstanceConstant.SetVectorParameterValue(MinimumDisplacementParameterName, LC);

				V = Vector(Rotation);
				V *= MaximumDisplacement;
				LC.R = V.X;
				LC.G = V.Y;
				LC.B = V.Z;
				MaterialInstanceConstant.SetVectorParameterValue(MaximumDisplacementParameterName, LC);
			}
		}
	}
}

simulated function Destroyed()
{
	Super.Destroyed();

	SceneCapture2DHitMaskComponent.SetCaptureTargetTexture(None);
	HitMaskRenderTarget = None;
}

simulated function TakeDamage(int DamageAmount, Controller EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
	Super.TakeDamage(DamageAmount, EventInstigator, HitLocation, Momentum, DamageType, HitInfo, DamageCauser);

	SceneCapture2DHitMaskComponent.SetCaptureParameters(HitLocation, 16.f, HitLocation, false);
}

defaultproperties
{
	Begin Object Class=ArrowComponent Name=Arrow
		ArrowColor=(R=150,G=200,B=255)
		bTreatAsASprite=True
	End Object
	Components.Add(Arrow)

	Begin Object Class=DynamicLightEnvironmentComponent Name=MyDynamicLightEnvironmentComponent
	End Object
	LightEnvironmentComponent=MyDynamicLightEnvironmentComponent
	Components.Add(MyDynamicLightEnvironmentComponent)

	Begin Object Class=SkeletalMeshComponent Name=MySkeletalMeshComponent
		LightEnvironment=MyDynamicLightEnvironmentComponent
        bHasPhysicsAssetInstance=true
		CollideActors=true
		BlockActors=true
		BlockZeroExtent=true
		BlockNonZeroExtent=true
		BlockRigidBody=true
	End Object
	SkeletalMeshComponent=MySkeletalMeshComponent
	CollisionComponent=MySkeletalMeshComponent
	Components.Add(MySkeletalMeshComponent);	

	Begin Object Class=SceneCapture2DHitMaskComponent Name=MySceneCapture2DHitMaskComponent
	End Object
	SceneCapture2DHitMaskComponent=MySceneCapture2DHitMaskComponent
	Components.Add(MySceneCapture2DHitMaskComponent)

	CollisionType=COLLIDE_BlockAll
	BlockRigidBody=true
	bCollideActors=true
	bBlockActors=true
	HitMaskSize=(X=512,Y=512)
	HitMaskMaterialParameterName="HeightMask"
}