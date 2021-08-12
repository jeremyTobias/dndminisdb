/*
	Title	: Project - DnD Miniature Database
	Author	: Jeremy Tobias
	Course	: IST659
	Term	: Spring 2020
*/

/*
	DROP VIEW references
*/
drop view if exists All_Minis
drop view if exists All_Encounters
drop view if exists Campaign_Encounters
drop view if exists MinisPerEncounter
drop view if exists Mini_Environments
go

/*
	VIEWS
*/

/*
	All Minis View
	This view attempts to display all of a miniature's basic characterists.
	MiniName: The creature name of the miniature
	Description: Brief description of the creature (taken from dndbeyond.com...sometimes)
	TypeName: The type of creature the miniature is
	Environment: The typical environment the creature can be found
	Alignment: The creatures default alignment
	Size: The relative size of the creature as determined by D&D 5E rules
	CR: The creatures Challenge Rating as determined by D&D 5E rules
	QtyOnHand: Amount of miniatures currently available to be used within in an encounter
*/

create view All_Minis as
	select
		mini.mini_name as MiniName,
		mini.mini_description as Description,
		dmd_Type.mini_Type as TypeName,
		dmd_Sub_Type.sub_type as SubType,
		-- Since creatures can be present in multiple environments we need to combine all of a creatures environment types into a single cell
		stuff((select
			', ' + dmd_Environment.environment_name
			from dmd_Mini_Environment_List mel, dmd_Environment
			where mel.mini_id = mini.mini_id
			and mel.environment_id = dmd_Environment.environment_id
			for xml path ('')),1, 1, '') as Environment,
		dmd_Alignment.alignment as Alignment,
		dmd_Size.size as Size,
		dmd_Challenge_Rating.challenge_rating as CR,
		mini.qty_on_hand as QtyOnHand
	from dmd_Mini mini
	join dmd_Type on mini.mini_type_id = dmd_Type.mini_type_id
	full outer join dmd_Sub_Type on mini.sub_type_id = dmd_Sub_Type.sub_type_id
	join dmd_Alignment on mini.alignment_id = dmd_Alignment.alignment_id
	join dmd_Size on mini.size_id = dmd_Size.size_id
	join dmd_Challenge_Rating on mini.challenge_rating_id = dmd_Challenge_Rating.challenge_rating_id
go

select * from All_Minis
order by QtyOnHand desc
go

/*
	All Mini Encounters View
	A view that displays all of the encounters and the minis associated with them
	Encounter: The encounter name
	Encounter_Description: Description of the encounter
	Environment: The environment this encounter takes place in
	Mini: Creature(s) involved in the encounter
	Encounter_Qty: Quantity of miniatures required for this encounter
*/

create view All_Encounters as
	select
		dmd_Encounter.encounter_name as Encounter,
		dmd_Encounter.encounter_description as Encounter_Description,
		(select
			dmd_Environment.environment_name
			from dmd_Environment, dmd_Encounter
			where dmd_Encounter.environment_id = dmd_Environment.environment_id) as Environment,
		dmd_Mini.mini_name as Mini,
		dmd_Mini_Encounter_List.mini_qty as Encounter_Qty
	from dmd_Mini_Encounter_List, dmd_Encounter, dmd_Mini
	where dmd_Mini_Encounter_List.encounter_id = dmd_Encounter.encounter_id
	and dmd_Mini_Encounter_List.mini_id = dmd_Mini.mini_id
go

select * from All_Encounters
go

create view Campaign_Encounters as
	select
		dmd_Campaign.campaign_name as Campaign,
		dmd_Encounter.encounter_name as Encounter,
		(select
			dmd_Environment.environment_name
			from dmd_Environment, dmd_Encounter
			where dmd_Encounter.environment_id = dmd_Environment.environment_id) as Environment,
		stuff((select
			', ' + dmd_Mini.mini_name
			from dmd_Mini_Encounter_List mel, dmd_Mini
			where mel.mini_id = dmd_Mini.mini_id
			and mel.encounter_id = dmd_Encounter.encounter_id
			for xml path ('')),1, 1, '') as Creatures
	from dmd_Campaign_Encounter_List CEL
	join dmd_Campaign on CEL.campaign_id = dmd_Campaign.campaign_id
	join dmd_Encounter on CEL.encounter_id = dmd_Encounter.encounter_id
go

select * from Campaign_Encounters
go

create view MinisPerEncounter as
	select
		dmd_Encounter.encounter_name as Encounter,
		count(mini_id) as NumDiffMinis,
		sum(mini_qty) as NumTotalMinis
	from dmd_Mini_Encounter_List MEL
	join dmd_Encounter on MEL.encounter_id = dmd_Encounter.encounter_id
	group by dmd_Encounter.encounter_name
go

select * from MinisPerEncounter
go

/*
	Miniatures by Environment Type
	A view that displays environments and the current miniature stock associated with them
	Environment: An environment in the database
	Mini(s): Current stock of miniatures associated to a given environment
*/

create view Mini_Environments as
	select
		env.environment_name as Environment,
		stuff((select
			', ' + dmd_Mini.mini_name
			from dmd_Mini_Environment_List mel, dmd_Mini
			where mel.mini_id = dmd_Mini.mini_id
			and mel.environment_id = env.environment_id
			for xml path ('')),1, 1, '') as Creature
	from dmd_Environment env
go

select * from Mini_Environments
go