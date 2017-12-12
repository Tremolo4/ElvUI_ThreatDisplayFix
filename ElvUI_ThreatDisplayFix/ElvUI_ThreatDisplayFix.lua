local E, L, V, P, G = unpack(ElvUI)
local addon = E:NewModule("ElvUI_ThreatDisplayFix")
local LibBanzai = LibStub("LibBanzai-2.0")
LibBanzai:RegisterCallback(function() end) -- FIXME hacky: doesn't work if 0 callbacks are registered

local ThreatLib = LibStub("Threat-2.0", true)
function UnitThreatSituation(unit, targetUnit)
	if not ThreatLib then
		ThreatLib = LibStub("Threat-2.0", true)
	end

	if targetUnit then
		-- specific targetUnit
		if not UnitCanAttack(unit, targetUnit) then
			return nil
		end

		local UnitHasAggro = UnitIsUnit(unit, targetUnit.."target")

		if not ThreatLib then
			if UnitHasAggro then return 3 else return 0 end
		else
			local unitGuid = UnitGUID(unit)
			if UnitHasAggro then
				if select(2, ThreatLib:GetMaxThreatOnTarget(targetGUID)) == unitGuid then
					return 3
				else
					return 2
				end
			else
				if ThreatLib:GetThreat(unitGuid, targetGUID) > ThreatLib:GetThreat(UnitGUID(targetUnit.."target"), targetGUID) then
					return 1
				else
					return 0
				end
			end
		end
	else
		-- any/all enemy units
		local UnitHasAggro = LibBanzai:GetUnitAggroByUnitId(unit)

		if not ThreatLib then
			if UnitHasAggro then return 3 else return 0 end
		else
			local unitGuid = UnitGUID(unit)

			local UnitHasMaxThreatOnOneTarget = false
			for targetGUID,_ in ThreatLib:IteratePlayerThreat(unitGuid) do
				if select(2, ThreatLib:GetMaxThreatOnTarget(targetGUID)) == unitGuid then
					UnitHasMaxThreatOnOneTarget = true
					break
				end
			end

			if UnitHasAggro then
				if UnitHasMaxThreatOnOneTarget then
					return 3
				else
					return 2
				end
			else
				-- Caveat: we also need to return 1 if unit has higher threat than tank, not only if unit has max threat
				-- I have not found an efficient way to do this
				if UnitHasMaxThreatOnOneTarget then
					return 1
				else
					return 0
				end
			end
		end
	end
end
