ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "gPrinter"
ENT.Category = "Gak Printer"
ENT.Author = "Gak"
ENT.Purpose = "Learning gmod entites"
ENT.Spawnable = true

function ENT:SetupDataTables()
    self:NetworkVar("Int", 0, "StoredMoney")
    self:NetworkVar("Int", 1, "MinPrint")
    self:NetworkVar("Int", 2, "MaxPrint")
    self:NetworkVar("Int", 3, "MoneyToPrint")
end