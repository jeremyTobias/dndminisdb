/*
	Title	: Project - DnD Miniature Database
	Author	: Jeremy Tobias
	Course	: IST659
	Term	: Spring 2020
*/

/*
	DROP TABLE references
*/

drop table if exists dbo.dmd_Campaign_Encounter_List
drop table if exists dbo.dmd_Mini_Encounter_List
drop table if exists dbo.dmd_Set_Mini_List
drop table if exists dbo.dmd_Mini_Environment_List
drop table if exists dbo.dmd_Campaign
drop table if exists dbo.dmd_Encounter
drop table if exists dbo.dmd_Sub_Set
drop table if exists dbo.dmd_Set
drop table if exists dbo.dmd_Mini
drop table if exists dbo.dmd_Environment
drop table if exists dbo.dmd_Challenge_Rating
drop table if exists dbo.dmd_Size
drop table if exists dbo.dmd_Alignment
drop table if exists dbo.dmd_Sub_Type
drop table if exists dbo.dmd_Type

/*
	Miniature and miniature characteristics tables
*/

-- Create miniature type table
create table dmd_Type (
	mini_type_id int identity primary key,
	mini_type varchar(20) not null unique,
)

-- Create sub type table
create table dmd_Sub_Type (
	sub_type_id int identity primary key,
	sub_type varchar(20) not null,
	mini_type_id int foreign key references dmd_Type(mini_type_id)
	constraint U1_dmd_TypeSubType unique (mini_type_id, sub_type_id)
)

-- Create alignment table
create table dmd_Alignment (
	alignment_id int identity primary key,
	alignment varchar(20) not null
)

-- Create size table
create table dmd_Size (
	size_id int identity primary key,
	size varchar(20) not null
)

-- Create challenge rating table
create table dmd_Challenge_Rating (
	challenge_rating_id int identity primary key,
	challenge_rating varchar(3) not null
)

/*
	Miniature Table
*/

-- Create miniature table
create table dmd_Mini (
	mini_id int identity primary key,
	mini_name varchar(30) not null unique,
	mini_description varchar(500),
	mini_type_id int foreign key references dmd_Type(mini_type_id),
	sub_type_id int foreign key references dmd_Sub_Type(sub_type_id),
	alignment_id int foreign key references dmd_Alignment(alignment_id),
	size_id int foreign key references dmd_Size(size_id),
	legendary bit not null default 0,
	challenge_rating_id int foreign key references dmd_Challenge_Rating(challenge_rating_id),
	qty_on_hand int not null
)

/*
	Environment tables
*/

-- Create environment table
create table dmd_Environment (
	environment_id int identity primary key,
	environment_name varchar(20) not null unique
)

-- Create miniature-environment table
create table dmd_Mini_Environment_List (
	mini_environment_list_id int identity primary key,
	environment_id int foreign key references dmd_Environment(environment_id),
	mini_id int foreign key references dmd_Mini(mini_id),
	constraint U1_dmd_MiniEnvironmentList unique (environment_id, mini_id)
)

/*
	Set tables
*/

-- Create Set table
create table dmd_Set (
	set_id int identity primary key,
	set_name varchar(50) not null unique,
)

-- Create sub Set table
create table dmd_Sub_Set (
	sub_set_id int identity primary key,
	sub_set_name varchar(50) not null,
	set_id int foreign key references dmd_Set(set_id),
	constraint U1_dmd_SetSubSet unique (set_id, sub_set_id)
)

-- Create mini Set list table
create table dmd_Set_Mini_List (
	set_mini_list_id int identity primary key,
	sub_set_id int foreign key references dmd_Sub_Set(sub_set_id),
	mini_id int foreign key references dmd_Mini(mini_id),
	set_mini_num varchar(10),
	constraint U1_dmd_SetMiniList unique (sub_set_id, mini_id, set_mini_num)
)

/*
	Encounter/Campaign tables
*/

-- Create encounter table
create table dmd_Encounter (
	encounter_id int identity primary key,
	encounter_name varchar(50) not null unique,
	encounter_description varchar(500),
	environment_id int foreign key references dmd_Environment(environment_id)
)

-- Create min encounter list table
create table dmd_Mini_Encounter_List (
	mini_encounter_list_id int identity primary key,
	encounter_id int foreign key references dmd_Encounter(encounter_id),
	mini_id int foreign key references dmd_Mini(mini_id),
	mini_qty int not null,
	constraint U1_dmd_MiniEncounterList unique (encounter_id, mini_id)
)

-- Create campaign table
create table dmd_Campaign (
	campaign_id int identity primary key,
	campaign_name varchar(30) not null,
	campaign_description varchar(500)
)

--create campaign encounter list
create table dmd_Campaign_Encounter_List (
	campaign_encounter_list_id int identity primary key,
	campaign_id int foreign key references dmd_Campaign(campaign_id),
	encounter_id int foreign key references dmd_Encounter(encounter_id),
	constraint U1_dmd_CampaignEncounterList unique (campaign_id, encounter_id)
)
