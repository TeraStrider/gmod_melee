-- This is not a real scripted class. It is derivated from prop_dynamic and it will be recognized as this by the engine and by some Lua functions.
-- The prop_dynamic class has a fixed physics that cannot move without the prop itself. This is what I need.


--## Header data ##--
ENT.Type = "ai"
local ENT = {}
local BaseClass = FindMetaTable("Entity")
local BaseClassName = "monster_alien_grunt"
local ClassName = "prop_vehicle_mr"


--## Code that would be nearly written for a normal scripted entity ##--
AddCSLuaFile()

-- If the default material is not the model's one, then it should be set again when a Material tool tries to set the default material.
local old_SetMaterial = BaseClass.SetMaterial
function ENT:SetMaterial (materialName)
	if materialName != nil and materialName != "" then
		return old_SetMaterial(self, materialName)
	else
		if self.DefaultMaterial != nil then
			return old_SetMaterial(self, self.DefaultMaterial)
		else
			return old_SetMaterial(self, "")
		end
	end
end

function ENT:Initialize ()
	ENT.Model = "models/props_combine/breenglobe.mdl"
end


--## Footer treatment ##--
local old_FindByClass = ents.FindByClass
function ents.FindByClass (class, ...)
	if class == ClassName then  -- Look for ClassName excluding anything else.
		local entities = {}
		for _, ent in pairs(old_FindByClass(BaseClassName)) do
			if ent:GetClass() == ClassName then
				entities[#entities+1] = ent
			end
		end
		return entities
	elseif class == BaseClassName then -- Look for BaseClassName excluding ClassName.
		local entities = {}
		for _, ent in pairs(old_FindByClass(BaseClassName)) do
			if ent:GetClass() != ClassName then
				entities[#entities+1] = ent
			end
		end
		return entities
	else
		return old_FindByClass(class, ...)
	end
end
local old_GetClass = BaseClass.GetClass
function BaseClass:GetClass (...)
	-- if self[ClassName] then -- Non-networked classname
	if self:GetNWBool(ClassName, false) then -- Networked classname
		return ClassName
	else
		return old_GetClass(self, ...)
	end
end
local SENT_values = {}
for FuncName, Func in pairs(ENT) do
	if isfunction(Func) then -- This is a function value.
		local old_Func = BaseClass[FuncName]
		if isfunction(old_Func) then -- The method is re-defined in the base class.
			BaseClass[FuncName] = function (self, ...)
				if self:GetClass() == ClassName then
					return Func(self, ...)
				else
					return old_Func(self, ...)
				end
			end
		else -- The method is not defined in the base class.
			SENT_values[FuncName] = Func
		end
	else -- This is a value that is not a function.
		SENT_values[FuncName] = Func
	end
end
local old_Create = ents.Create
function ents.Create (class, ...)
	if class == ClassName then
		local ent = old_Create(BaseClassName, ...)
		if IsValid(ent) then
			-- ent[ClassName] = true -- Non-networked classname
			ent:SetNWBool(ClassName, true) -- Networked classname
			for k, v in pairs(SENT_values) do
				ent[k] = v
			end
		end
		return ent
	else
		return old_Create(class, ...)
	end
end