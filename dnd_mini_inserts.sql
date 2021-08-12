/*
	Title	: Project - DnD Miniature Database
	Author	: Jeremy Tobias
	Course	: IST659
	Term	: Spring 2020
*/

/*
	Miniature characteristic inserts
*/

-- inputing the primary DnD creature types
insert into dmd_Type (mini_type)
	values
		('Aberration'),
		('Beast'),
		('Celestial'),
		('Construct'),
		('Dragon'),
		('Elemental'),
		('Fey'),
		('Fiend'),
		('Giant'),
		('Humanoid'),
		('Monstrosity'),
		('Ooze'),
		('Plant'),
		('Undead')

select * from dmd_Type

-- adding subtype
insert into dmd_Sub_Type (mini_type_id, sub_type)
	values
		((select mini_type_id from dmd_Type
			where dmd_Type.mini_type = 'Aberration'), 'Shapechanger'),
		((select mini_type_id from dmd_Type
			where dmd_Type.mini_type = 'Monstrosity'), 'Shapechanger'),
		((select mini_type_id from dmd_Type
			where dmd_Type.mini_type = 'Celestial'), 'Angel'),
		((select mini_type_id from dmd_Type
			where dmd_Type.mini_type = 'Celestial'), 'Titan'),
		((select mini_type_id from dmd_Type
			where dmd_Type.mini_type = 'Fiend'), 'Demon'),
		((select mini_type_id from dmd_Type
			where dmd_Type.mini_type = 'Fiend'), 'Devil'),
		((select mini_type_id from dmd_Type
			where dmd_Type.mini_type = 'Fiend'), 'Yugoloth')

select * from dmd_Sub_Type

-- inputing alignments
insert into dmd_Alignment (alignment)
	values
		('Lawful Good'),('Neutral Good'),('Chaotic Good'),
		('Lawful Neutral'),('True Neutral'),('Chaotic Neutral'),
		('Lawful Evil'),('Neutral Evil'),('Chaotic Evil'),
		('Unaligned'),('Any')

select * from dmd_Alignment

-- inputing size
insert into dmd_Size (size)
	values
		('Tiny'),
		('Small'),
		('Medium'),
		('Large'),
		('Huge'),
		('Gargantuan')

select * from dmd_Size

-- inputing challenge rating
insert into dmd_Challenge_Rating (challenge_rating)
	values
		('0'),('1/8'),('1/4'),('1/2'),
		('1'),('2'),('3'),('4'),('5'),
		('6'),('7'),('8'),('9'),('10'),
		('11'),('12'),('13'),('14'),('15'),
		('16'),('17'),('18'),('19'),('20'),
		('21'),('22'),('23'),('24'),('25'),
		('26'),('27'),('28'),('29'),('30')

select * from dmd_Challenge_Rating

/*
	Environment inserts
*/

-- inputing environments
insert into dmd_Environment (environment_name)
	values
		('Arctic'),
		('Coastal'),
		('Desert'),
		('Forest'),
		('Grassland'),
		('Hill'),
		('Mountain'),
		('Swamp'),
		('Underdark'),
		('Underwater'),
		('Urban')

select * from dmd_Environment

/*
	Miniature inserts
*/

-- add some miniatures
insert into dmd_Mini (
	mini_name,
	mini_description,
	mini_type_id,
	alignment_id,
	size_id,
	challenge_rating_id,
	qty_on_hand
)
	values
		(
			'Beholder',
			'One glance at a beholder is enough to assess its foul and otherworldly 
			nature. Aggressive, hateful, and greedy, these aberrations dismiss all 
			other creatures as lesser beings, toying with them or destroying them as 
			they choose.',
			(select mini_type_id from dmd_Type
				where mini_type = 'Aberration'),
			(select alignment_id from dmd_Alignment
				where alignment = 'Lawful Evil'),
			(select size_id	from dmd_Size
				where size = 'Large'),
			(select challenge_rating_id from dmd_Challenge_Rating
				where challenge_rating = '13'),
			1
		),
		(
			'Kobold',
			'Kobolds are craven reptilian humanoids that worship evil dragons as 
			demigods and serve them as minions and toadies. Kobolds inhabit dragons’ 
			lairs when they can but more commonly infest dungeons, gathering 
			treasures and trinkets to add to their own tiny hoards.',
			(select mini_type_id from dmd_Type
				where mini_type = 'Humanoid'),
			(select alignment_id from dmd_Alignment
				where alignment = 'Lawful Evil'),
			(select size_id	from dmd_Size
				where size = 'Small'),
			(select challenge_rating_id from dmd_Challenge_Rating
				where challenge_rating = '1/8'),
			2
		),
		(
			'Giant Fire Ant',
			'Like ants but bigger and with FIRE!',
			(select mini_type_id from dmd_Type
				where mini_type = 'Beast'),
			(select alignment_id from dmd_Alignment
				where alignment = 'Unaligned'),
			(select size_id	from dmd_Size
				where size = 'Small'),
			(select challenge_rating_id from dmd_Challenge_Rating
				where challenge_rating = '1/8'),
			20
		)


select * from dmd_Mini

select
	dmd_Mini.mini_name as MiniName,
	dmd_Mini.mini_description as Description,
	dmd_Type.mini_Type as TypeName,
	dmd_Alignment.alignment as Alignment,
	dmd_Size.size as Size,
	dmd_Challenge_Rating.challenge_rating as CR,
	dmd_Mini.qty_on_hand as QtyOnHand
from dmd_Mini
join dmd_Type on dmd_Mini.mini_type_id = dmd_Type.mini_type_id
join dmd_Alignment on dmd_Mini.alignment_id = dmd_Alignment.alignment_id
join dmd_Size on dmd_Mini.size_id = dmd_Size.size_id
join dmd_Challenge_Rating on dmd_Mini.challenge_rating_id = dmd_Challenge_Rating.challenge_rating_id

/*
	Mini -> Environment Insert
*/

-- insert mini and environment to list
insert into dmd_Mini_Environment_List (environment_id, mini_id)
	values
		((select environment_id from dmd_Environment
			where environment_name = 'Arctic'),
		(select mini_id from dmd_Mini
			where mini_name = 'Kobold')),
		((select environment_id from dmd_Environment
			where environment_name = 'Forest'),
		(select mini_id from dmd_Mini
			where mini_name = 'Kobold')),
			((select environment_id from dmd_Environment
			where environment_name = 'Mountain'),
		(select mini_id from dmd_Mini
			where mini_name = 'Kobold')),
		((select environment_id from dmd_Environment
			where environment_name = 'Underdark'),
		(select mini_id from dmd_Mini
			where mini_name = 'Beholder')),
		((select environment_id from dmd_Environment
			where environment_name = 'Mountain'),
		(select mini_id from dmd_Mini
			where mini_name = 'Giant Fire Ant'))

select
	dmd_Mini.mini_name as Creature,
	dmd_Environment.environment_name as Environment
from dmd_Mini_Environment_List
join dmd_Mini on dmd_Mini_Environment_List.mini_id = dmd_Mini.mini_id
join dmd_Environment on dmd_Mini_Environment_List.environment_id = dmd_Environment.environment_id

/*
	Set inserts
*/

-- inputing Set
insert into dmd_Set (set_name)
	values
		('Icons of the Realms'),
		('Critical Role')

select * from dmd_Set

-- inputing sub Set
insert into dmd_Sub_Set (set_id, sub_set_name)
	values
		((select set_id from dmd_Set
			where dmd_Set.set_name = 'Icons of the Realms'), 'Monster Menagerie 2'),
		((select set_id from dmd_Set
			where dmd_Set.set_name = 'Icons of the Realms'), 'Monster Menagerie 8'),
		((select set_id from dmd_Set
			where dmd_Set.set_name = 'Critical Role'), 'Vox Machina'),
		((select set_id from dmd_Set
			where dmd_Set.set_name = 'Critical Role'), 'Mighty Nein')

select * from dmd_Sub_Set

/*
	Encounter/Campaign inserts
*/

-- inputing an encounter
insert into dmd_Encounter (
	encounter_name,
	encounter_description,
	environment_id
)
	values
		(
			'Ant Cave',
			'The entrance to the fire ant lair is too small for all of the ants to get
			 through at once. This will afford the PCs to have a funnel of death. 
			 However, the ants will enter the room to allow for more ants to enter 
			 behind them, and fill the room as quickly as possible. Initially 5 ants will 
			 attempt to enter the main chamber, and every round after they will move to 
			 allow more ants to flow in behind them. This will continue as long as the 
			 door remains opened.',
			 (select environment_id from dmd_Environment
			 	where environment_name = 'Mountain')
		)

select * from dmd_Encounter

-- inputing a campaign
insert into dmd_Campaign (campaign_name, campaign_description)
	values
		(
			'You Meet In A Tavern',
			'That''s it. You all just met randomly in some random tavern'
		)

select * from dmd_Campaign

-- inputing minis to encounters
insert into dmd_Mini_Encounter_List (
	encounter_id,
	mini_id,
	mini_qty
)
	values
		(
			(select encounter_id from dmd_Encounter
			where encounter_name = 'Ant Cave'),
			(select mini_id from dmd_Mini
			where mini_name = 'Giant Fire Ant'),
			20
		)

select
	dmd_Encounter.encounter_name as Encounter,
	(select
		dmd_Environment.environment_name
		from dmd_Environment, dmd_Encounter
		where dmd_Encounter.environment_id = dmd_Environment.environment_id) as Environment,
	dmd_Mini.mini_name as Mini,
	dmd_Mini_Encounter_List.mini_qty as Qty_Minis
from dmd_Mini_Encounter_List, dmd_Encounter, dmd_Mini
where dmd_Mini_Encounter_List.mini_id = dmd_Mini.mini_id
and dmd_Mini_Encounter_List.encounter_id = dmd_Encounter.encounter_id

-- Adding an ecounter to a campaign
insert into dmd_Campaign_Encounter_List (campaign_id, encounter_id)
	values
		(
			(select campaign_id from dmd_Campaign
			where campaign_name = 'You Meet In A Tavern'),
			(select encounter_id from dmd_Encounter
			where encounter_name = 'Ant Cave')
		)

select
	dmd_Campaign.campaign_name as Campaign,
	dmd_Encounter.encounter_name as Encounter
from dmd_Campaign_Encounter_List, dmd_Campaign, dmd_Encounter
where dmd_Campaign_Encounter_List.campaign_id = dmd_Campaign.campaign_id
and dmd_Campaign_Encounter_List.encounter_id = dmd_Encounter.encounter_id
