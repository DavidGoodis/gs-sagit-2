/*
	File: Script/Preload.nut
	Author: DG
*/

/*!
	@short	Scenes_Preload
	@author	DG
*/
class	Preload
{

	state = 0
	stateLbl = "init"
	i = 0
	LoaderLbl = 0
	baseItem = 0
	frameTimer = 0

	baseMat = 0

//=== preloaded objects ===
	nmgToPreload = [
	"Mesh/Cube.nmg",
	"Mesh/Cube6.nmg",
	"Mesh/ForceField.nmg",
	"Mesh/Spacecraft.nmg",
	"Mesh/Vehic1.nmg",
	"Mesh/Vehicle33.nmg",
	"Mesh/Vehicle32.nmg",
	"Mesh/Vehicle31.nmg",
	"Mesh/Vehicle3.nmg",
	"Mesh/reactor1.nmg",
	"Mesh/TunnelElement.nmg"
	]

	nmmToPreload = [
	"Mesh/CubeDefaultBlue.nmm"
	"Mesh/CubeMat1.nmm"
	"Mesh/CubeMat2.nmm"
	"Mesh/CubeMat3.nmm"
	"Mesh/CubeMat4.nmm"
	"Mesh/CubeMat5.nmm"
	"Mesh/CubeMat6.nmm"
	"Mesh/Below.nmm"
	]

	texToPreload = [
	"Tex/envmap_soft_edges.png"
	"Sav/pattern0.png"
	"Sav/pattern1.png"
	"Sav/pattern2.png"
	"Sav/pattern3.png"
	"Sav/pattern4.png"
	"Sav/pattern5.png"
	"Sav/pattern6.png"
	"Sav/pattern7.png"
	]

sndToPreload = [ 
		"data/soundbits/404Reasons.wav"
		"data/soundbits/Harp.wav",
		"data/soundbits/clapBasic.wav",
		"data/soundbits/KickBasic.wav",
		"data/soundbits/Arpegio5.wav",
		"data/soundbits/SeeTwo2.wav",
		"data/soundbits/CB_Snare.wav",
     	"data/soundbits/HatBasic.wav",
		"data/soundbits/SH101T.wav",
		"data/soundbits/kick2.wav",
		]

	/*!
		@short	OnUpdate
		Called each frame.
	*/
	function	OnUpdate(scene)
	{
		frameTimer = SystemGetClock()

		TextSetText(LoaderLbl[1], stateLbl)
		print(stateLbl)

		switch(state)
		{
			case 0:
				state = 1
				stateLbl = "Loading geometries..."
				break

			case 1:
				if (nmgToPreload.len() == 0)
					{ state=2; stateLbl = "Loading textures..."; }
				else
					if (FileExists(nmgToPreload.top()))
					{

						print("   loading " + nmgToPreload.top())
						stateLbl = "Loading geometry..." + nmgToPreload.top()
						ResourceFactoryLoadGeometry(g_factory, nmgToPreload.pop())
					} else throw "Geometry " + nmgToPreload[nmgToPreload.len()-1] + " not found"
				break

			case 2:
				if (texToPreload.len() == 0)
					{ state = 3; stateLbl = "Loading materials..." }
				else
					if (FileExists(texToPreload.top()))
					{
						print("   loading " + texToPreload.top())
						stateLbl = "Loading texture..." + texToPreload.top()
						ResourceFactoryLoadTexture(g_factory, texToPreload.pop())
					} else throw "Texture " + texToPreload[texToPreload.len()-1] + " not found"
				break

			case 3: //materials
				if (nmmToPreload.len() == 0)
					{ state=4; stateLbl = "Loading sounds..." }
				else
					if (FileExists(nmmToPreload.top()))
					{
						print("   loading " + nmmToPreload.top())
						stateLbl = "Loading material..." + nmmToPreload.top()
						ResourceFactoryLoadMaterial(g_factory, nmmToPreload.pop())
					} else throw "Material " + nmmToPreload[nmmToPreload.len()-1] + " not found"
				break

			case 4:
				if (sndToPreload.len() == 0)
//					{ state=5; stateLbl = "Computing..." }
						{ state = 5; stateLbl = "Preloading complete. Press Enter";  return; }
				else
					if (FileExists(sndToPreload.top()))
					{
						print("   loading " + sndToPreload.top())
						stateLbl = "Loading sound..." + sndToPreload.top()
						g_sounds.append(ResourceFactoryLoadSound(g_factory, sndToPreload.pop()))
					} else throw "Sound " + sndToPreload[sndToPreload.len()-1] + " not found"
				break

			case 5:
				while( TickToSec(SystemGetClock() - frameTimer) < g_dt_frame )
					if (i < maxPatterns)
					{
						local p = LoadPicture("Sav/pattern" + i + ".png")
						local w = PictureGetRect(p).GetWidth()
						local h = PictureGetRect(p).GetHeight()
						local patf = []
						local gridArLoc = [] //Initialize the location array of this pattern

						local offsetx = (w*tileSize)/2// - tileSize/2
						local offsety = (h*tileSize)/2// - tileSize/2
	
						for(local i=0; i<w; i++)
							for(local j=0; j<h; j++)
							{
								patf.append(PictureGetPixel(p,i,j))
	
								local x = i*tileSize - offsetx
								local y = offsety - j*tileSize
								gridArLoc.append(Vector(x,y,0))

								local px = PictureGetPixel(p,i,j)
								local key = px.x + "_" + px.y + "_" + px.z + "_" + px.w

								if ((px.w != 0) && !(key in g_geo))					//If first occurance of this color, create an item and store it in g_cubes
								{
									local id = g_geo.len() + 1
									local new_geo  = ResourceFactoryLoadGeometryEx(g_factory, "Mesh/CubeGeo" + id + ".nmg" , false)
									local new_mat  = ResourceFactoryLoadMaterialEx(g_factory, "Mesh/CubeMat" + id + ".nmm" , false)
									MaterialSetSelf(new_mat, Vector(px.x,px.y,px.z,1))
									GeometrySetMaterial(new_geo, 0, new_mat)

									g_geo.rawset(key,new_geo)
							}
						}
			
						//Append this location array to the array of locations
						g_patlocs.append(gridArLoc)
	
						//Append the pixel to the array of pixels
						g_patfs.append(patf)

						i++
						stateLbl = "Computing... " + i*100/maxPatterns + "%"
						print("Computing... " + i*100/maxPatterns + "%")
					}
					else
						{ state = 6; stateLbl = "Preloading complete. Press Enter";  return; }
				break

			case 6: return
				break
		}
	}

	/*!
		@short	OnSetup
		Called when the scene is about to be setup.
	*/
	function	OnSetup(scene)
	{
		print(state)
		local ui = SceneGetUI(scene)
		UISetInternalResolution(ui, UIWidth, UIHeight)

		LoaderLbl  = CreateLabel(ui, "Loading geometry...", UIWidth-640, UIHeight-50, 28, 640, 50,255,255,255,255,"Aldrich",TextAlignRight)

		baseItem = SceneFindItem(scene, "cubeTile")
		baseMat = GeometryGetMaterialFromIndex(ItemGetGeometry(baseItem), 0)

		tileSize = ItemGetMinMax(baseItem).max.x - ItemGetMinMax(baseItem).min.x

		SceneSetFixedDeltaFrame(scene, 1.0 / 60.0)
//		ItemSetCommandList(SceneFindItem(scene,"Vehic1"), "toalpha 0,0.5; loop; torotation 30,0,1080,0+toalpha 30,1; torotation 30,0,-1080,0+toalpha 3,0.5; next;")
	}
}