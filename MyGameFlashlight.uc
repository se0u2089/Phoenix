
class MyGameFlashlight extends SpotLightMovable
notplaceable;

DefaultProperties
{
Begin Object Name=SpotLightComponent0
// Sets the light color
LightColor=(R=255,G=255,B=255)
InnerConeAngle=10.0
OuterConeAngle=30.0
Radius=4000.0 

End Object 
// Cannot be deleted during play.
bNoDelete=false
}