/*
	Title	: Project - DnD Miniature Database
	Author	: Jeremy Tobias
	Course	: IST659
	Term	: Spring 2020
*/

/*
	DROP FUNCTIONS references
*/
-- //TODO: drop functions
drop function if exists dbo.GetTypeId
drop function if exists dbo.GetSubTypeID
drop function if exists dbo.GetAlignmentID
drop function if exists dbo.GetSizeID
drop function if exists dbo.GetCRID
drop function if exists dbo.GetMiniID
drop function if exists dbo.GetEnvironmentID
drop function if exists dbo.GetMiniEnvironmentID
drop function if exists dbo.GetSetID
drop function if exists dbo.GetSubSetID
drop function if exists dbo.GetSetMiniListID
drop function if exists dbo.GetEncounterID
drop function if exists dbo.GetMiniEncounterID
drop function if exists dbo.GetCampaignID
drop function if exists dbo.GetCampaignEncounterID
drop function if exists dbo.TotalDiffMinis
drop function if exists dbo.TotalPhysMinis
go

/*
	FUNCTIONS
*/

/*
	Getters
*/
create function dbo.GetTypeID(@mini_type varchar(20))
returns int as
begin
	declare @return_val int

	select @return_val = mini_type_id
	from dmd_Type
	where mini_type = @mini_type

	return @return_val
end
go

create function dbo.GetSubTypeID(@mini_type varchar(20), @sub_type varchar(20))
returns int as
begin
	declare @return_val int
	declare @mini_type_id int

	set @mini_type_id = dbo.GetTypeId(@mini_type)

	select @return_val = sub_type_id
	from dmd_Sub_Type
	where sub_type = @sub_type and mini_type_id = @mini_type_id

	return @return_val
end
go

create function dbo.GetAlignmentID(@alignment varchar(20))
returns int as
begin
	declare @return_val int

	select @return_val = alignment_id
	from dmd_Alignment
	where alignment = @alignment

	return @return_val
end
go

create function dbo.GetSizeID(@size varchar(20))
returns int as
begin
	declare @return_val int

	select @return_val = size_id
	from dmd_Size
	where size = @size

	return @return_val
end
go

create function dbo.GetCRID(@challenge_rating varchar(3))
returns int as
begin
	declare @return_val int

	select @return_val = challenge_rating_id
	from dmd_Challenge_Rating
	where challenge_rating = @challenge_rating

	return @return_val
end
go

create function dbo.GetMiniID(@mini_name varchar(20))
returns int as
begin
	declare @return_val int

	select @return_val = mini_id
	from dmd_Mini
	where mini_name = @mini_name

	return @return_val
end
go

create function dbo.GetEnvironmentID(@environment varchar(20))
returns int as
begin
	declare @return_val int

	select @return_val = environment_id
	from dmd_Environment
	where environment_name = @environment

	return @return_val
end
go

create function dbo.GetMiniEnvironmentID(@environment varchar(20), @mini varchar(20))
returns int as
begin
	declare @return_val int
	declare @mini_id int
	declare @environment_id int

	set @mini_id = dbo.GetMiniID(@mini)
	set @environment_id = dbo.GetEnvironmentID(@environment)

	select @return_val = mini_environment_list_id
	from dmd_Mini_Environment_List
	where environment_id = @environment_id and mini_id = @mini_id

	return @return_val
end
go

create function dbo.GetSetID(@set_name varchar(50))
returns int as
begin
	declare @return_val int

	select @return_val = set_id
	from dmd_Set
	where set_name = @set_name

	return @return_val
end
go

create function dbo.GetSubSetID(@set_name varchar(50), @sub_set_name varchar(50))
returns int as
begin
	declare @return_val int
	declare @set_id int

	set @set_id = dbo.GetSetID(@set_name)

	select @return_val = sub_set_id
	from dmd_Sub_Set
	where set_id = @set_id and sub_set_name = @sub_set_name

	return @return_val
end
go

create function dbo.GetSetMiniListID(
		@mini_name varchar(20),
		@set_name varchar(50),
		@sub_set_name varchar(50),
		@set_mini_num varchar(10))
returns int as
begin
	declare @return_val int
	declare @sub_set_id int
	declare @mini_id int

	set @sub_set_id = dbo.GetSubSetID(@set_name, @sub_set_name)
	set @mini_id = dbo.GetMiniID(@mini_name)

	select @return_val = set_mini_list_id
	from dmd_Set_Mini_List
	where sub_set_id = @sub_set_id
	and mini_id = @mini_id
	and set_mini_num = @set_mini_num

	return @return_val
end
go

create function dbo.GetEncounterID(@encounter_name varchar(50))
returns int as
begin
	declare @return_val int

	select @return_val = encounter_id
	from dmd_Encounter
	where encounter_name = @encounter_name

	return @return_val
end
go

create function dbo.GetMiniEncounterID(@encounter_name varchar(50), @mini_name varchar(20))
returns int as
begin
	declare @return_val int
	declare @encounter_id int
	declare @mini_id int

	set @encounter_id = dbo.GetEncounterID(@encounter_name)
	set @mini_id = dbo.GetMiniID(@mini_name)

	select @return_val = mini_encounter_list_id
	from dmd_Mini_Encounter_List
	where encounter_id = @encounter_id and mini_id = @mini_id

	return @return_val
end
go

create function dbo.GetCampaignID(@campaign varchar(30))
returns int as
begin
	declare @return_val int

	select @return_val = campaign_id
	from dmd_Campaign
	where campaign_name = @campaign

	return @return_val
end
go

create function dbo.GetCampaignEncounterID(@campaign varchar(30), @encounter varchar(50))
returns int as
begin
	declare @return_val int
	declare @campaign_id int
	declare @encounter_id int

	set @campaign_id = dbo.GetCampaignID(@campaign)
	set @encounter_id = dbo.GetEncounterID(@encounter)

	select @return_val = campaign_encounter_list_id
	from dmd_Campaign_Encounter_List
	where campaign_id = @campaign_id and encounter_id = @encounter_id

	return @return_val
end
go

/*
	Maths
*/
create function dbo.TotalDiffMinis()
returns int as
begin
	declare @return_val int

	select
		@return_val = count(mini_id)
	from dmd_Mini

	return @return_val
end
go

create function dbo.TotalPhysMinis()
returns int as
begin
	declare @return_val int

	select
		@return_val = sum(qty_on_hand)
	from dmd_Mini

	return @return_val
end
go
