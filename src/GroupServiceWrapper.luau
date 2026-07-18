--!strict
-- had to use abit of AI to assist with Type Checking, though i've redone most of it

local GroupService = game:GetService("GroupService")
local GroupServiceWrapper = {}

export type RoleInfo = {
	Name: string,
	Rank: number,
}

export type Roles = {RoleInfo}

export type GroupInfo = {
	Name: string,
	Id: number,
	Owner: {
		Name: string,
		Id: number,
	},
	EmblemUrl: string,
	Description: string,
}

local GroupInfoCache: { [number]: GroupInfo } = {}
local PlayerGroupsCache: { [number]: { GroupInfo } } = {}
local PlayerRolesCache: { [number]: { [number]: Roles | false } } = {}

-- Returns GroupInfo for a group
function GroupServiceWrapper:GetGroupInfo(GroupId: number): GroupInfo?
	if GroupInfoCache[GroupId] then
		return GroupInfoCache[GroupId]
	end

	local success, result = pcall(function()
		return GroupService:GetGroupInfoAsync(GroupId)
	end)

	if not success then
		warn("[GROUP-SERVICE-WRAPPER/ERROR] " .. tostring(result))
		return nil
	end

	local info = result :: GroupInfo
	GroupInfoCache[GroupId] = info
	return info
end

-- Returns all the groups a UserId is in
function GroupServiceWrapper:GetPlayerGroups(UserId: number): {GroupInfo}?
	if PlayerGroupsCache[UserId] then
		return PlayerGroupsCache[UserId]
	end

	local success, result = pcall(function()
		return GroupService:GetGroupsAsync(UserId :: any)
	end)

	if not success then
		warn("[GROUP-SERVICE-WRAPPER/ERROR] " .. tostring(result))
		return nil
	end

	local groups = result :: { GroupInfo }
	PlayerGroupsCache[UserId] = groups
	return groups
end

-- Returns a UserId's roles inside a group | Returns false if they are not in the group
function GroupServiceWrapper:GetPlayerRolesInGroup(UserId: number, GroupId: number): Roles | false | nil
	local cachedForUser = PlayerRolesCache[UserId]
	if cachedForUser and cachedForUser[GroupId] ~= nil then
		return cachedForUser[GroupId]
	end

	local success, result = pcall(function()
		return GroupService:GetRolesInGroupAsync(UserId :: any, GroupId)
	end)

	if not success then
		warn("[GROUP-SERVICE-WRAPPER/ERROR] " .. tostring(result))
		return nil
	end

	local rolesResult: Roles | false = if result.IsMember then result.Roles else false

	if not PlayerRolesCache[UserId] then
		PlayerRolesCache[UserId] = {}
	end
	(PlayerRolesCache[UserId] :: { [number]: Roles | false })[GroupId] = rolesResult

	return rolesResult
end

-- Check if a UserId has a specific role
function GroupServiceWrapper:HasRole(UserId: number, GroupId: number, Rank: number): boolean
	local result = GroupServiceWrapper:GetPlayerRolesInGroup(UserId, GroupId)
	if not result then
		return false
	end

	for _, roleInfo in result do
		if roleInfo.Rank == Rank then
			return true
		end
	end

	return false
end

-- Finds a UserId's highest role inside of a group
function GroupServiceWrapper:GetPlayerHighestRole(UserId: number, GroupId: number): RoleInfo?
	local result = GroupServiceWrapper:GetPlayerRolesInGroup(UserId, GroupId)
	if not result then
		return nil
	end

	local highest: RoleInfo? = nil
	for _, roleInfo in result do
		if not highest or roleInfo.Rank > highest.Rank then
			highest = roleInfo
		end
	end

	return highest
end

-- Finds a UserId's lowest role inside of a group
function GroupServiceWrapper:GetPlayerLowestRole(UserId: number, GroupId: number): RoleInfo?
	local result = GroupServiceWrapper:GetPlayerRolesInGroup(UserId, GroupId)
	if not result then
		return nil
	end

	local lowest: RoleInfo? = nil
	for _, roleInfo in result do
		if not lowest or roleInfo.Rank < lowest.Rank then
			lowest = roleInfo
		end
	end

	return lowest
end

-- Checks if a UserId has a role (rank >= Number)
function GroupServiceWrapper:PlayerHasRoleGreaterThan(UserId: number, GroupId: number, Number: number): boolean
	local result = GroupServiceWrapper:GetPlayerRolesInGroup(UserId, GroupId)
	if not result then
		return false
	end

	for _, roleInfo in result do
		if roleInfo.Rank >= Number then
			return true
		end
	end

	return false
end

-- Checks if a UserId has a role (rank <= Number)
function GroupServiceWrapper:PlayerHasRoleLessThan(UserId: number, GroupId: number, Number: number): boolean
	local result = GroupServiceWrapper:GetPlayerRolesInGroup(UserId, GroupId)
	if not result then
		return false
	end

	for _, roleInfo in result do
		if roleInfo.Rank <= Number then
			return true
		end
	end

	return false
end

-- Returns the name of a UserId's highest role inside a group
function GroupServiceWrapper:GetPlayerHighestRoleName(UserId: number, GroupId: number): string?
	local highest = GroupServiceWrapper:GetPlayerHighestRole(UserId, GroupId)
	return highest and highest.Name or nil
end

-- Returns a boolean if a UserId is in a group or not
function GroupServiceWrapper:IsPlayerInGroup(UserId: number, GroupId: number): boolean
	local result = GroupServiceWrapper:GetPlayerRolesInGroup(UserId, GroupId)
	return result ~= false and result ~= nil
end

return GroupServiceWrapper