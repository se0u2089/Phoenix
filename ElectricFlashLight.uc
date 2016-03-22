
  ///---------------------------------------------------------------------------------------
    /// Created By : Tetra > Adel Laggoune
    /// EMail: sadam007Ghost@Hotmail.Com  -  Kamikaz_Exe@Hotmail.Fr  -  Amcv013@Gmail.Com
    /// Www.MaxForums.Net  -  Www.Montada.Com
  ///---------------------------------------------------------------------------------------

class ElectricFlashLight extends SpotLightComponent;

defaultproperties
{
	InnerConeAngle = 20
	OuterConeAngle = 25
	FalloffExponent = 2
	
	CastShadows = true
    CastStaticShadows = true
    CastDynamicShadows = true
	
	

	
    Begin Object Class=LightFunction Name=ElectricFlashLightFunction
       Scale = (X=1024,Y=1024,Z=1024)
       SourceMaterial = Material'OWsWeap_AS50.Materials.FlashLight_Mat'
    End Object
	
	Begin Object Class=SpotLightComponent Name=SpotLightComponent0 
       Function=ElectricFlashLightFunction
    End Object

}
