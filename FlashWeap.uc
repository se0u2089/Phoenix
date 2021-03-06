class FlashWeap extends FlashLight;

var config color CrosshairColor;


   simulated function DrawWeaponCrosshair( Hud HUD )
{
	local vector2d CrosshairSize;
	local float x,y,PickupScale, ScreenX, ScreenY, TargetDist;
	local UTHUDBase	H;

	H = UTHUDBase(HUD);
	if ( H == None )
		return;

	TargetDist = GetTargetDistance();
	// Apply pickup scaling
	if ( H.LastPickupTime > WorldInfo.TimeSeconds - 0.3 )
	{
		if ( H.LastPickupTime > WorldInfo.TimeSeconds - 0.15 )
		{
			PickupScale = (1 + 5 * (WorldInfo.TimeSeconds - H.LastPickupTime));
		}
		else
		{
			PickupScale = (1 + 5 * (H.LastPickupTime + 0.3 - WorldInfo.TimeSeconds));
		}
	}
	else
	{
		PickupScale = 1.0;
	}

 	CrosshairSize.Y = H.ConfiguredCrosshairScaling * CrosshairScaling * CrossHairCoordinates.VL * PickupScale * H.Canvas.ClipY/720;
  	CrosshairSize.X = CrosshairSize.Y * ( CrossHairCoordinates.UL / CrossHairCoordinates.VL );

	X = H.Canvas.ClipX * 0.5;
	Y = H.Canvas.ClipY * 0.5;
	ScreenX = X - (CrosshairSize.X * 0.5);
	ScreenY = Y - (CrosshairSize.Y * 0.5);
	if ( CrosshairImage != none )
	{
		// crosshair drop shadow
		H.Canvas.DrawColor = H.BlackColor;
		H.Canvas.SetPos( ScreenX+1, ScreenY+1, TargetDist);
		H.Canvas.DrawTile(CrosshairImage,CrosshairSize.X, CrosshairSize.Y, CrossHairCoordinates.U, CrossHairCoordinates.V, CrossHairCoordinates.UL,CrossHairCoordinates.VL);

	//	CrosshairColor = (LinkStrength > 1) ? H.Default.LightGoldColor : default.CrosshairColor;
		CrosshairColor = H.bGreenCrosshair ? H.Default.LightGreenColor : CrosshairColor;
		H.Canvas.DrawColor = (WorldInfo.TimeSeconds - LastHitEnemyTime < 0.3) ? H.RedColor : CrosshairColor;
		H.Canvas.SetPos(ScreenX, ScreenY, TargetDist);
		H.Canvas.DrawTile(CrosshairImage,CrosshairSize.X, CrosshairSize.Y, CrossHairCoordinates.U, CrossHairCoordinates.V, CrossHairCoordinates.UL,CrossHairCoordinates.VL);
	}
}



defaultproperties
{
  LightAttachmentInterval   =1.3
 LightOnInterval           =0.5
Begin Object Name=TorchLightComponent

  Begin Object class=LightFunction Name=MyLightFunction
  SourceMaterial=Material'WP_ShockRifle.Effects.M_WP_ShockRifle_SoftLight_Z2'

  Scale=(X=25000.000000, Y=30550.000000, Z=20050.000000)
  end Object
InnerConeAngle=22
OuterConeAngle=40
Radius=512
Brightness=65.5
LightShaftConeAngle=49
//bRenderLightShafts=true
LightColor=(R=255,G=226,B=216,A=0)
CastShadows=false


CastStaticShadows=False
CastDynamicShadows=True
bCastCompositeShadow=False
bAffectCompositeShadowDirection=False
End Object
 	MaxFireEffectDistance=55000.0
	MuzzleFlashSocket=MF


        	MuzzleFlashPSCTemplate=ParticleSystem'gaz661-darkarts3dweapons.Effects.asgMuzzleFlash'
	MuzzleFlashDuration=0.66
	MuzzleFlashLightClass=class'Phoenix.TorchMF'
         MuzzleFlashLightClass=class'Phoenix.MyGameFlashlight'
 LightAttachmentClass=TorchLightComponent

  	Begin Object Name=FirstPersonMesh
	SkeletalMesh=SkeletalMesh'Main_characters_Backup.main_characters_weapons_skmesh.Ulari_main_rifle_Skmesh'
		Scale=0.9
	End Object

             Begin Object Name=PickupMesh
	SkeletalMesh=SkeletalMesh'Main_characters_Backup.main_characters_weapons_skmesh.Ulari_main_rifle_Skmesh'

	AttachmentClass=class'item_attatchment_flashlight'
Components.Add(MyLightEnvironment)
End Object
 	CrossHairCoordinates=(U=384,V=0,UL=64,VL=64)
        	CrossHairTexture=Texture2D'UI_HUD.HUD.UI_HUD_BaseA'
}