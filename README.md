# Minerva XML Tool
Tool for editing Tera xml files, only supports editing skills currently. There is an example config file for Warrior in the conf folder.

Usage:

`node xmltool.js [conf category] [conf file] [skill id] [apply linked skills y/n (optional)] [attributes]`

Edits just this one skill with the given values:

`node xmltool.js skill warrior 10100 totalAtk="100" mp="50"`

`node xmltool.js skill warrior 10100 n totalAtk="100" mp="50"`

Edits this skill, and applies modifiers to linked skills (specified in the conf):

`node xmltool.js skill warrior 10100 y totalAtk="100" mp="50"`

Supported attributes are:

totalAtk, timeRate, attackRange, pushTarget, coolTime, mp, hp, anger, startCancelEndTime, rearCancelStartTime, moveCancelStartTime.