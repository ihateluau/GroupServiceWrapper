--!strict

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

local GroupInfo: { [number]: GroupInfo } = {}
local PlayerGroups: { [number]: { GroupInfo } } = {}
local PlayerRoles: { [number]: { [number]: Roles | false } } = {}

-- Returns GroupInfo for a group
function GroupServiceWrapper:GetGroupInfo(GroupId: number): GroupInfo?
	if GroupInfo[GroupId] then
		return GroupInfo[GroupId]
	end

	local success, result = pcall(function()
		return GroupService:GetGroupInfoAsync(GroupId)
	end)

	if not success then
		warn("[GROUP-SERVICE-WRAPPER/ERROR] " .. tostring(result))
		return nil
	end

	local info = result :: GroupInfo
	GroupInfo[GroupId] = info
	return info
end

-- Returns all the groups a UserId is in
function GroupServiceWrapper:GetPlayerGroups(UserId: number): {GroupInfo}?
	if PlayerGroups[UserId] then
		return PlayerGroups[UserId]
	end

	local success, result = pcall(function()
		return GroupService:GetGroupsAsync(UserId :: any)
	end)

	if not success then
		warn("[GROUP-SERVICE-WRAPPER/ERROR] " .. tostring(result))
		return nil
	end

	local groups = result :: { GroupInfo }
	PlayerGroups[UserId] = groups
	return groups
end

-- Returns a UserId's roles inside a group | Returns false if they are not in the group
function GroupServiceWrapper:GetPlayerRolesInGroup(UserId: number, GroupId: number): Roles | false | nil
	local cachedForUser = PlayerRoles[UserId]
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

	local rolesResult: Roles | false = false
	if result.IsMember then
		rolesResult = result.Roles
	end

	if not PlayerRoles[UserId] then
		PlayerRoles[UserId] = {}
	end
	(PlayerRoles[UserId] :: { [number]: Roles | false })[GroupId] = rolesResult

	return rolesResult
end

-- Check if a UserId has a specific role
function GroupServiceWrapper:HasRole(UserId: number, GroupId: number, RoleId: number): boolean
	local result = GroupServiceWrapper:GetPlayerRolesInGroup(UserId, GroupId)
	if not result then
		return false
	end

	local roles = result :: Roles
	for _, RoleInfo in roles do
		if RoleInfo.Rank == RoleId then
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
	local roles = result :: Roles
	for _, RoleInfo in roles do
		if highest == nil then
			highest = RoleInfo
		elseif RoleInfo.Rank > highest.Rank then
			highest = RoleInfo
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
	local roles = result :: Roles
	for _, RoleInfo in roles do
		if lowest == nil then
			lowest = RoleInfo
		elseif RoleInfo.Rank < lowest.Rank then
			lowest = RoleInfo
		end
	end

	return lowest
end

-- Checks if a UserId has a role greater or equal to a number
function GroupServiceWrapper:PlayerHasRoleGreaterThan(UserId: number, GroupId: number, Number: number): boolean
	local result = GroupServiceWrapper:GetPlayerRolesInGroup(UserId, GroupId)
	if not result then
		return false
	end

	local roles = result :: Roles
	for _, RoleInfo in roles do
		if RoleInfo.Rank >= Number then
			return true
		end
	end

	return false
end

-- Checks if a UserId has a role less or equal to a number
function GroupServiceWrapper:PlayerHasRoleLessThan(UserId: number, GroupId: number, Number: number): boolean
	local result = GroupServiceWrapper:GetPlayerRolesInGroup(UserId, GroupId)
	if not result then
		return false
	end

	local roles = result :: Roles
	for _, RoleInfo in roles do
		if RoleInfo.Rank <= Number then
			return true
		end
	end

	return false
end

-- Returns the name of a UserId's highest role inside a group
function GroupServiceWrapper:GetPlayerHighestRoleName(UserId: number, GroupId: number): string?
	local highest = GroupServiceWrapper:GetPlayerHighestRole(UserId, GroupId)
	if highest then
		return highest.Name
	end
	return nil
end

-- Returns a boolean if a UserId is in a group or not
function GroupServiceWrapper:IsPlayerInGroup(UserId: number, GroupId: number): boolean
	local result = GroupServiceWrapper:GetPlayerRolesInGroup(UserId, GroupId)
	if result then
		return true
	end
	return false
end

return GroupServiceWrapper