SWEP.Author = "Gak"
SWEP.Base = "weapon_base"
SWEP.PrintName = "Laser Weapon"
SWEP.Instructions = [[Left-Click: Shoot Right-Click: Charge]]
SWEP.ViewModel = "models/weapons/w_alyx_gun.mdl"
SWEP.ViewModelFlip = false 
SWEP.ViewModelFOV = 160
SWEP.UseHands = false  
SWEP.WorldModel = "models/weapons/w_alyx_gun.mdl"

SWEP.Spawnable = true 
SWEP.AdminSpawnable = true 

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Ammo = "none"
SWEP.Primary.Automatic = false

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1

function SWEP:SetupDataTables()
    self:NetworkVar("Int", 0, "laserWeaponCharge")
end


