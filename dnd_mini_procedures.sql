/*
	Title	: Project - DnD Miniature Database
	Author	: Jeremy Tobias
	Course	: IST659
	Term	: Spring 2020
*/

/*
	DROP PROCEDURES references
*/

-- //TODO: drop procs
drop proc if exists InsertType
drop proc if exists UpdateType
drop proc if exists InsertSubType
drop proc if exists UpdateSubType
drop proc if exists InsertAlignment
drop proc if exists UpdateAlignment
drop proc if exists InsertSize
drop proc if exists UpdateSize
drop proc if exists InsertChallengRating
drop proc if exists UpdateChallengeRating
drop proc if exists InsertEnvironment
drop proc if exists UpdateEnvironment
drop proc if exists InsertMiniEnvironment
drop proc if exists DeleteMiniEnvironment
drop proc if exists AddMiniature
drop proc if exists UpdateMini
drop proc if exists DeleteMini
drop proc if exists InsertEncounter
drop proc if exists UpdateEncounter
drop proc if exists DeleteEncounter
drop proc if exists InsertMiniEncounter
drop proc if exists InsertCampaign
drop proc if exists UpdateCampaign
drop proc if exists DeleteCampaign
drop proc if exists InsertCampaignEncounter
go

/*
	PROCEDURES
*/

-- Proc to insert new mini type
create proc InsertType(@mini_type varchar(20))
as
begin
	insert into dmd_Type (mini_type)
		values (@mini_type)
end
go

-- Proc to update type
create proc UpdateType(@mini_old_type varchar(20), @mini_new_type varchar(20))
as
begin
	declare @mini_type_id int
	set @mini_type_id = dbo.GetTypeID(@mini_old_type)

	update dmd_Type set mini_type = @mini_new_type
		where mini_type_id = @mini_type_id
end
go

-- Proc to insert new mini sub type
create proc InsertSubType(@mini_type varchar(20), @sub_type varchar(20))
as
begin
	declare @mini_type_id int

	set @mini_type_id = dbo.GetTypeID(@mini_type)

	insert into dmd_Sub_Type (mini_type_id, sub_type)
		values (@mini_type_id, @sub_type)
end
go

-- Proc to update subtype
create proc UpdateSubType(
	@mini_type varchar(20),
	@old_sub_type varchar(20),
	@new_sub_type varchar(20))
as
begin
	declare @mini_type_id int
	declare @mini_sub_type_id int

	set @mini_type_id = dbo.GetTypeID(@mini_type)
	set @mini_sub_type_id = dbo.GetSubTypeID(@mini_type, @old_sub_type)

	update dmd_Sub_Type set sub_type = @new_sub_type
		where mini_type_id = @mini_type_id and sub_type_id = @mini_sub_type_id
end
go

-- Proc to insert new alignment
create proc InsertAlignment(@alignment varchar(20))
as
begin
	insert into dmd_Alignment (alignment)
		values (@alignment)
end
go

-- Proc to update alignment
create proc UpdateAlignment(@old_alignment varchar(20), @new_alignment varchar(20))
as
begin
	declare @alignment_id int
	set @alignment_id = dbo.GetAlignmentID(@old_alignment)

	update dmd_Alignment set alignment = @new_alignment
		where alignment_id = @alignment_id
end
go

-- Proc to insert new creature size
create proc InsertSize(@size varchar(20))
as
begin
	insert into dmd_Size (size)
		values (@size)
end
go

-- Proc to update size
create proc UpdateSize(@old_size varchar(20), @new_size varchar(20))
as
begin
	declare @size_id int
	set @size_id = dbo.GetSizeID(@old_size)

	update dmd_Size set size = @new_size
		where size_id = @size_id
end
go

-- Proc to insert new challenge rating
create proc InsertChallengRating(@challenge_rating varchar(3))
as
begin
	insert into dmd_Challenge_Rating (challenge_rating)
		values (@challenge_rating)
end
go

-- Proc to update challenge rating
create proc UpdateChallengeRating(@old_cr varchar(3), @new_cr varchar(3))
as
begin
	declare @challenge_rating_id int
	set @challenge_rating_id = dbo.GetCRID(@old_cr)

	update dmd_Challenge_Rating set challenge_rating = @new_cr
		where challenge_rating_id = @challenge_rating_id
end
go

-- Proc to insert new environment
create proc InsertEnvironment(@environment varchar(20))
as
begin
	insert into dmd_Environment (environment_name)
	values (@environment)
end
go

-- Proc to update environment
create proc UpdateEnvironment(@old_environment varchar(20), @new_environment varchar(20))
as
begin
	declare @environment_id int
	set @environment_id = dbo.GetEnvironmentID(@old_environment)

	update dmd_Environment set environment_name = @new_environment
		where environment_id = @environment_id
end
go

-- Proc to insert new mini/environment relationship
create proc InsertMiniEnvironment(@environment varchar(200), @mini_name varchar(20))
as
begin
	insert into dmd_Mini_Environment_List
	select
		dbo.GetEnvironmentID(trim(value)),
		dbo.GetMiniID(@mini_name)
	from string_split(@environment, ',')
end
go

declare @multienvs varchar(200) = 'Hill, Swamp, Coastal'
exec InsertMiniEnvironment @multienvs, 'Kobold'
select * from Mini_Environments
go

-- Proc to delete mini/environment relationship
create proc DeleteMiniEnvironment(@environment varchar(200), @mini_name varchar(20))
as
begin
	delete from dmd_Mini_Environment_List
	where mini_environment_list_id in (select
										dbo.GetMiniEnvironmentID(trim(value), @mini_name)
										from string_split(@environment, ','))
end
go

declare @multienvs nvarchar(400) = 'Swamp, Forest'
exec DeleteMiniEnvironment @multienvs, 'Kobold'
select * from Mini_Environments
go

--Proc to add miniature to database
create proc AddMiniature(
	@mini_name varchar(20),
	@mini_description varchar(500),
	@mini_type varchar(20),
	@mini_sub_type varchar(20),
	@mini_environment varchar(200),
	@mini_alignment varchar(20),
	@mini_size varchar(20),
	@mini_legendary bit,
	@mini_challenge_rating varchar(3),
	@mini_qty int
)
as
begin
	set nocount on
	/*
		Probably a better way to do this, but it works...
	*/
	-- check if type is null
	declare @type_id int
	set @type_id = dbo.GetTypeID(@mini_type)

	if @type_id is NULL
	begin	
		exec InsertType @mini_type
		set @type_id = dbo.TypeID(@mini_type)
	end
	-- check if subtype is null
	declare @sub_type_id int
	set @sub_type_id = dbo.GetSubTypeID(@mini_type, @mini_sub_type)

	if @mini_sub_type is not null and @sub_type_id is NULL
	begin	
		exec InsertSubType @mini_type, @mini_sub_type
		set @sub_type_id = dbo.GetSubTypeID(@mini_type, @mini_sub_type)
	end
	-- check if alignment null
	declare @alignment_id int
	set @alignment_id = dbo.GetAlignmentID(@mini_alignment)

	/*if @alignment_id is NULL
	begin	
		exec InsertAlignment @mini_alignment
		set @sub_type_id = dbo.GetAlignmentID(@mini_alignment)
	end*/
	-- check if size is null
	declare @size_id int
	set @size_id = dbo.GetSizeID(@mini_size)

	/*if @size_id is NULL
	begin	
		exec InsertSize @mini_size
		set @size_id = dbo.GetSizeID(@mini_size)
	end*/
	-- check if CR is null
	declare @challenge_rating_id int
	set @challenge_rating_id = dbo.GetCRID(@mini_challenge_rating)

	/*if @challenge_rating_id is NULL
	begin	
		exec InsertChallengRating @mini_challenge_rating
		set @challenge_rating_id = dbo.GetCRID(@mini_challenge_rating)
	end*/


	insert into dmd_Mini (
		mini_name,
		mini_description,
		mini_type_id,
		sub_type_id,
		alignment_id,
		size_id,
		legendary,
		challenge_rating_id,
		qty_on_hand
	)
	values
		(
			@mini_name,
			@mini_description,
			@type_id,
			@sub_type_id,
			@alignment_id,
			@size_id,
			isnull(@mini_legendary, 0),
			@challenge_rating_id,
			@mini_qty
		)
	if @mini_environment is not null
		exec InsertMiniEnvironment @mini_environment, @mini_name
end
go

exec AddMiniature 'Mimic',
					'Mimics are shapeshifting predators able to take on the form of 
					inanimate objects to lure creatures to their doom. In dungeons, 
					these cunning creatures most often take the form of doors and 
					chests, having learned that such forms attract a steady stream of 
					prey.',
					'Monstrosity',
					'Shapechanger',
					'Underdark',
					'True Neutral',
					'Medium',
					0,
					'2',
					1
exec AddMiniature 'Hobgoblin',
					'Hobgoblins are large goblinoids with dark orange or red-orange skin. 
					A hobgoblin measures virtue by physical strength and martial prowess, 
					caring about nothing except skill and cunning in battle.',
					'Humanoid',
					'Goblinoid',
					'Desert, Forest, Grassland, Hill, Underdark',
					'Lawful Evil',
					'Medium',
					0,
					'1/2',
					1
select * from All_Minis
go

-- Proc to update miniature
create proc UpdateMini(
	@mini_old_name varchar(20),
	@mini_new_name varchar(20),
	@mini_description varchar(500),
	@mini_type varchar(20),
	@mini_sub_type varchar(20),
	@mini_environment varchar(20),
	@mini_alignment varchar(20),
	@mini_size varchar(20),
	@mini_challenge_rating varchar(3),
	@mini_qty int
)
as
begin
	set nocount on

	declare @mini_id int
	set @mini_id = dbo.GetMiniID(@mini_old_name)

	if @mini_new_name is not null
	begin
		update dmd_Mini set mini_name = @mini_new_name
			where mini_id = @mini_id
	end

	if @mini_description is not null
	begin
		update dmd_Mini set mini_description = @mini_description
			where mini_id = @mini_id
	end

	if @mini_type is not null
	begin
		update dmd_Mini set mini_type_id = dbo.GetTypeID(@mini_type)
			where mini_id = @mini_id
	end

	if @mini_sub_type is not null
	begin
		update dmd_Mini set sub_type_id = dbo.GetSubTypeID(@mini_type, @mini_sub_type)
			where mini_id = @mini_id
	end

	if @mini_environment is not null
	begin
		if @mini_new_name is not null
			exec InsertMiniEnvironment @mini_environment, @mini_new_name
		else
			exec InsertMiniEnvironment @mini_environment, @mini_old_name
	end

	if @mini_alignment is not null
	begin
		update dmd_Mini set alignment_id = dbo.GetAlignmentID(@mini_alignment)
			where mini_id = @mini_id
	end

	if @mini_size is not null
	begin
		update dmd_Mini set size_id = dbo.GetSizeID(@mini_size)
			where mini_id = @mini_id
	end

	if @mini_challenge_rating is not null
	begin
		update dmd_Mini set challenge_rating_id = dbo.GetCRID(@mini_challenge_rating)
			where mini_id = @mini_id
	end

	if @mini_qty is not null
	begin
		update dmd_Mini set qty_on_hand = @mini_qty
			where mini_id = @mini_id
	end
end
go

exec UpdateMini 'Mimic', null, null, null, null, 'Urban', null, null, null, null
select * from All_Minis
go

-- Proc to delete a mini from the database
create proc DeleteMini(@mini_name varchar(20))
as
begin
	declare @mini_id int
	set @mini_id = dbo.GetMiniID(@mini_name)
	delete from dmd_Set_Mini_List where mini_id = @mini_id
	delete from dmd_Mini_Encounter_List where mini_id = @mini_id
	delete from dmd_Mini_Environment_List where mini_id = @mini_id
	delete from dmd_Mini where mini_id = @mini_id
end
go

exec DeleteMini 'Kobold'
exec DeleteMini 'Mimic'
exec DeleteMini 'Hobgoblin'
exec DeleteMini 'Beholder'
select * from All_Minis
go

-- Proc to add encounters
create proc InsertEncounter(
	@encounter_name varchar(50),
	@description varchar(500),
	@environment varchar(20))
as
begin
	insert into dmd_Encounter (encounter_name, encounter_description, environment_id)
		values (@encounter_name, @description, dbo.GetEnvironmentID(@environment))
end
go

-- Proc to update encounter
create proc UpdateEncounter (
	@encounter_old_name varchar(30),
	@encounter_new_name varchar(30),
	@description varchar(500),
	@environment varchar(20))
as
begin
	declare @encounter_id int
	set @encounter_id = dbo.GetEncounterID(@encounter_old_name)

	if @encounter_new_name is not NULL
	begin
		update dmd_Encounter set encounter_name = @encounter_new_name
			where encounter_id = @encounter_id
	end

	if @description is not NULL
	begin
		update dmd_Encounter set encounter_description = @description
			where encounter_id = @encounter_id
	end

	if @environment is not NULL
	begin
		update dmd_Encounter set environment_id = dbo.GetEnvironmentID(@environment)
			where encounter_id = @encounter_id
	end
end
go

exec UpdateEncounter 'Sooo Many Ants', 'Ant Cave', null, 'Coastal'
select * from All_Encounters
go

-- Proc to delete an encounter
create proc DeleteEncounter(@encounter_name varchar(50))
as
begin
	declare @encounter_id int
	set @encounter_id = dbo.GetEncounterID(@encounter_name)
	delete from dmd_Mini_Encounter_List
		where encounter_id = @encounter_id
	delete from dmd_Campaign_Encounter_List
		where encounter_id = @encounter_id
	delete from dmd_Encounter
		where encounter_id = @encounter_id
end
go

exec DeleteEncounter 'Ant Cave'
select * from All_Encounters
go

-- Proc to add minis to encounter
create proc InsertMiniEncounter(
	@encounter_name varchar(50),
	@mini_name varchar(30),
	@mini_qty int)
as
begin
	insert into dmd_Mini_Encounter_List (encounter_id, mini_id, mini_qty)
		values
			(
				dbo.GetEncounterID(@encounter_name),
				dbo.GetMiniID(@mini_name),
				@mini_qty
			)
end
go

-- Proc to add campaigns
create proc InsertCampaign(@campaign_name varchar(30), @description varchar(500))
as
begin
	insert into dmd_Campaign (campaign_name, campaign_description)
		values (@campaign_name, @description)
end
go

-- Proc to update campaign
create proc UpdateCampaign(
	@campaign_old_name varchar(30),
	@campaign_new_name varchar(30),
	@campaign_description varchar(500))
as
begin
	declare @campaign_id int
	set @campaign_id = dbo.GetCampaignID(@campaign_old_name)

	if @campaign_new_name is not null
	begin
		update dmd_Campaign set campaign_name = @campaign_new_name
			where campaign_id = @campaign_id
	end

	if @campaign_description is not null
	begin
		update dmd_Campaign set campaign_description = @campaign_description
			where campaign_id = @campaign_id
	end
end
go

-- Proc to delete campaign
create proc DeleteCampaign(@campaign_name varchar(30))
as
begin
	declare @campaign_id int
	set @campaign_id = dbo.GetCampaignID(@campaign_name)

	delete from dmd_Campaign_Encounter_List where campaign_id = @campaign_id
	delete from dmd_Campaign where campaign_id = @campaign_id
end
go

-- Proc to add encounters to campaigns
create proc InsertCampaignEncounter(
	@campaign_name varchar(30),
	@encounter_name varchar(50))
as
begin
	insert into dmd_Campaign_Encounter_List (campaign_id, encounter_id)
		values (dbo.GetCampaignID(@campaign_name), dbo.GetEncounterID(@encounter_name))
end
go
