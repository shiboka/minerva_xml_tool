# Minerva XML Tool
Tool for editing Tera xml files. Currently supports editing skills, npc data, and base stats. There are pre-generated/example configs in the conf folder.


### Skills

Usage:

`node xmltool.js skill [class] [skill id] [apply linked skills y/n (optional)] [attributes]`

`node xmltool.js skill [class] genconf`

`node xmltool.js skill [class] restore`

Edits just this one skill with the given values:

`node xmltool.js skill warrior 10100 totalAtk="100" mp="50"`

`node xmltool.js skill warrior 10100 n totalAtk="100" mp="50"`

Edits this skill, and applies modifiers to all linked skills (specified in the conf):

`node xmltool.js skill warrior 10100 y totalAtk="100" mp="50"`

Generates a config for warrior:

`node xmltool.js skill warrior genconf`

Restore warrior files from backup:

`node xmltool.js skill warrior restore`

Supported attributes are:

totalAtk, timeRate, attackRange, coolTime, mp, hp, anger, startCancelEndTime, rearCancelStartTime, moveCancelStartTime.


### Area (Npc data)

Usage:

`node xmltool.js area [area name] [mob id/size/elite/nothing for all] [attributes]`

`node xmltool.js area [area name] restore`

Edits just one mob of the given id (Oblivion Woods Basilisks) (id formated as huntingZoneId-npcId):

`node xmltool.js area OblivionWoods 3-300811 maxHp="1000"`

Edits all elite monsters in the given area (Oblivion Woods) to have +20% hp and +20% def:

`node xmltool.js area OblivionWoods elite maxHp="+0.2" def="+0.2"`

Edits all large monsters in the given area (Oblivion Woods) to have +20% def and +20% crit resist:

`node xmltool.js area OblivionWoods large def="+0.2" res="+0.2"`

Edits ALL monsters in the given area (Oblivion Woods) to have +20% hp and +20% def:

`node xmltool.js area OblivionWoods maxHp="+0.2 def="+0.2""`

Restore Oblivion Woods files from backup:

`node xmltool.js area OblivionWoods restore`

Supported mob sizes are:

small, medium, large.

Supported attributes are:

maxHp, def, atk, str (crit), res (crit), respawnTime.


### Base Stats

Usage:

`node xmltool.js stats [class] [race/nothing for all] [attributes]`

Edits maxMp for Human Warrior:

`node xmltool.js stats warrior human maxMp="1500"`

Edits mana effectValue and managementType for Warrior all races:

`node xmltool.js stats warrior effectValue="50" managementType="TypeA"`

Supported attributes are:

maxMp, managementType, tickCycle, effectValue, decayStartTime, decayStartTimeMpFull, recoveryStartTime