# Minerva XML Tool
Tool for editing Tera xml files, currently supports editing skills, npc data, and base stats. There are example configs in the conf folder.


### Skills

Usage:

`node xmltool.js [category] [class] [skill id] [apply linked skills y/n (optional)] [attributes]`

Edits just this one skill with the given values:

`node xmltool.js skill warrior 10100 totalAtk="100" mp="50"`

`node xmltool.js skill warrior 10100 n totalAtk="100" mp="50"`

Edits this skill, and applies modifiers to linked skills (specified in the conf):

`node xmltool.js skill warrior 10100 y totalAtk="100" mp="50"`

Supported attributes are:

totalAtk, timeRate, attackRange, coolTime, mp, hp, anger, startCancelEndTime, rearCancelStartTime, moveCancelStartTime.


### Npc Data

Usage:

`node xmltool.js [category] [area number] [mob id/size/elite/nothing for all] [attributes]`

Edits just one mob of the given id (formated as: huntingZoneId-npcId):

`node xmltool.js area 1 3-300811 maxHp="1000"`

`node xmltool.js area 1 3-300811 maxHp="+0.2"`

Edits all large monsters in the given area to have +20% hp and +20% def:

`node xmltool.js area 1 large maxHp="+0.2" def="+0.2"`

Edits ALL monsters in the given area to have +20% hp and +20% def:

`node xmltool.js area 1 maxHp="+0.2 def="+0.2""`

Supported attributes are:

maxHp, def, atk, str (crit), res (crit).

### Base Stats

Usage:

`node xmltool.js [category] [class] [race/nothing for all] [attributes]`

Edits maxMp for Human Warrior:

`node xmltool.js warrior human maxmp="1500"`

Edits mana effectValue and managementType for Warrior all races:

`node xmltool.js warrior effectValue="50" managementType="TypeA"`

Supported attributes are:

maxMp, managementType, tickCycle, effectValue, decayStartTime, decayStartTimeMpFull, recoveryStartTime