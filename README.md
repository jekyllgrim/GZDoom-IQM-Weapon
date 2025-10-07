Example project for GZDoom showcasing the use of the [IQM 3D model format](https://www.zdoom.org/wiki/MODELDEF#IQM) with [decoupled animations](https://zdoom.org/wiki/SetAnimation) in a weapon.

ZScript version set to 4.15.1 (at the moment of writing this requires a GZDoom 4.15pre [development build](https://devbuilds.drdteam.org/gzdoom/)). While most of the things showcased here will work on earlier versions, 4.15.1 supports direct bone manipulation, which is used to procedurally animate the muzzle flash. If you don't care about that, remove `SetNamedBoneScaling` and `SetNamedBoneRotationAngles` from `A_ShowMuzzleFlash` in jgpZScript/weapon.zs, and it'll work on an earlier version.

### Credits

Procedural materials, muzzle flash texture, code - Agent_Ash

Pistol 3D model - Programaton (CC BY 4.0)
https://sketchfab.com/3d-models/pistol-34ebc77c59eb47ef89e0463469237dac

sounds - https://quicksounds.com/
