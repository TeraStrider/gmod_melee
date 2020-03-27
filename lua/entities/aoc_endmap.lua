AddCSLuaFile()
ENT.Type = "point"
-- local ENT = {}

-- local BaseClass = FindMetaTable( "Entity" )
-- local BaseClassName = "logic_relay"
-- local ClassName = "aoc_endmap"

-- local old_Create = ents.Create
-- function ents.Create ( class, ... )
-- 	print("ghe")
-- 	print(SENT_values)
-- 	for k, v in pairs( SENT_values ) do
-- 		print(v)
-- 	end
-- 	return old_Create( class, ... )

-- 	-- if class == ClassName then
-- 	-- 	print("not exist")
-- 	-- 	local ent = old_Create( BaseClassName, ... )
-- 	-- 	if IsValid( ent ) then
-- 	-- 		-- ent[ClassName] = true -- Non-networked classname
-- 	-- 		ent:SetNWBool( ClassName, true ) -- Networked classname
-- 	-- 		for k, v in pairs( SENT_values ) do
-- 	-- 			ent[k] = v
-- 	-- 		end
-- 	-- 		if isfunction( ent.Initialize ) then
-- 	-- 			ent:Initialize()
-- 	-- 		end
-- 	-- 	end
-- 	-- 	return ent
-- 	-- else
-- 	-- 	print("exist")
-- 	-- 	return old_Create( class, ... )
-- 	-- end
-- end