const fs = require('fs');
const path = require('path');
const cheerio = require('cheerio');

/***********************************************/
/* Process and validate command line arguments */
/***********************************************/
if(process.argv.length < 3) {
    console.error('Error: No category given.');
    process.exit(1);
}

const category = process.argv[2].toLowerCase();
let selector;
let id;
let skillLink;
let values;

// node xmltool.js skill warrior 10100 hp
if(category == 'skill') {
    if(process.argv.length < 5) {
        console.error('Error: At least 3 arguments are required for skill category.');
        process.exit(1);
    }

    selector = process.argv[3].toLowerCase();
    id = process.argv[4].toLowerCase();

    if(selector != 'warrior' && selector != 'berserker' && selector != 'slayer' && selector != 'archer'
    && selector != 'sorcerer' && selector != 'lancer' && selector != 'priest' && selector != 'elementalist'
    && selector != 'soulless' && selector != 'engineer' && selector != 'fighter' && selector != 'assassin' && selector != 'glaiver') {
        console.error(`Error: Invalid class ${selector}`);
        process.exit(1);
    }
    
    if(id != 'genconf') {
        skillLink = process.argv[5].toLowerCase();

        if(skillLink == 'y' || skillLink == 'n') {
            values = process.argv.slice(6)
        } else {
            values = process.argv.slice(5);
            skillLink = 'n';
        }
    }
// node xmltool.js area 1 hp
} else if(category == 'area') {
    if(process.argv.length < 5) {
        console.error('Error: At least 3 arguments are required for area category.');
        process.exit(1);
    }

    selector = process.argv[3];
    id = process.argv[4];

    if(id.includes('=')) {
        values = process.argv.slice(4);
        id = 'all';
    } else {
        values = process.argv.slice(5)
    }
// node xmltool.js stats warrior castanic effectValue="10"
} else if(category == "stats") {
    if(process.argv.length < 5) {
        console.error('Error: At least 3 arguments are required for stats category.');
        process.exit(1);
    }

    selector = process.argv[3].toLowerCase();
    id = process.argv[4].toLowerCase();

    if(id.includes('=')) {
        values = process.argv.slice(4);
        id = 'all';
    } else {
        values = process.argv.slice(5)
    }
} else {
    console.error(`Error: ${category} is an invalid category.`);
    process.exit(1);
}

if(values != undefined) {
    values = values.map(value => {
        if(!value.includes('=')) {
            console.error(`Error: Invalid value given: ${value}`);
            process.exit(1);
        }

        return value.split('=');
    });
}

/**********************************************/

/************************/
/* Function Definitions */
/************************/
function reverse(s){
    return s.split('').reverse().join('');
}

function getValue($, e, attribute) {
    let value;

    if(attribute == 'mp' || attribute == 'hp' || attribute == 'anger') {
        $(e).find('Precondition').each((i, e) => {
            $(e).find('Cost').each((i, e) => {
                if($(e).attr(attribute) != undefined) {
                    value = $(e).attr(attribute);
                }
            });
        });
    } else if(attribute == 'coolTime') {
        $(e).find('Precondition').each((i, e) => {
            if($(e).attr(attribute) != undefined) {
                value = $(e).attr(attribute);
            }
        });
    } else if(attribute == 'frontCancelEndTime' || attribute == 'rearCancelStartTime' || attribute == 'moveCancelStartTime') {
        $(e).find('Action').each((i, e) => {
            $(e).find('Cancel').each((i, e) => {
                if($(e).attr(attribute) != undefined) {
                    value = $(e).attr(attribute);
                }
            });
        });
    } else if(attribute == 'totalAtk' || attribute == 'timeRate' || attribute == 'attackRange') {
        if($(e).attr(attribute) != undefined) {
            value = $(e).attr(attribute);
        }
    }

    return value;
}

function genSkillConf(dir) {
    const attributes = ['totalAtk', 'timeRate', 'attackRange', 'coolTime', 'mp', 'hp', 'anger', 'frontCancelEndTime', 'rearCancelStartTime', 'moveCancelStartTime'];
    const className = selector.charAt(0).toUpperCase() + selector.slice(1);
    let file;

    switch(className) {
        case 'Warrior':
        case 'Berserker':
        case 'Slayer':
        case 'Archer':
        case 'Sorcerer':
        case 'Lancer':
        case 'Priest':
        case 'Elementalist':
        case 'Soulless':
        case 'Engineer':
        case 'Assassin':
            file = `UserSkillData_${className}_Popori_F.xml`;
            break;
        case 'Fighter':
            file = 'UserSkillData_Fighter_Human_F.xml';
            break;
        case 'Glaiver':
            file = 'UserSkillData_Glaiver_Castanic_F.xml';
            break;
    }

    const filePath = path.join(dir, file);
    let baseValues = {};
    let jsonObj = {};

    fs.readFile(filePath, 'utf8', (err, data) => {
        if(err) {
            console.error(`Error: Could not open file: ${filePath}`)
            process.exit(1);
        }

        let $ = cheerio.load(data, { xmlMode: true, decodeEntities: false });

        $('SkillData').find('Skill').each((i, e) => {
            const id = $(e).attr('id');
            const idRev = reverse(id);
            const lvlRev = idRev.slice(2, 4);
            const lvl = reverse(lvlRev);

            if(lvl == '01') {
                baseValues[$(e).attr('id')] = {};
                baseValues[$(e).attr('id')].name = $(e).attr('name');
                baseValues[$(e).attr('id')].prev = {};
                jsonObj[$(e).attr('id')] = {};

                attributes.forEach(attribute => {
                    const value = getValue($, e, attribute)

                    if(value != undefined) {
                        baseValues[$(e).attr('id')][attribute] = value;
                        baseValues[$(e).attr('id')].prev[attribute] = value;
                    };
                });
            }
        });

        for(const [key, value] of Object.entries(jsonObj)) {
            let problems = [];
            console.log(`Generating chain for skill ${key}`);

            for(let i = 2; i < 20; i++) {
                const level = String(i).padStart(2, '0');
                let found = false;

                $('SkillData').find('Skill').each((i, e) => {
                    const idRev = key.split('').reverse();
                    let newId = idRev;
                    newId[2] = level[1]
                    newId[3] = level[0];
                    newId = newId.reverse().join('');

                    if($(e).attr('id') == newId) {
                        found = true;

                        jsonObj[key][$(e).attr('id')] = {};
                        jsonObj[key][$(e).attr('id')].name = $(e).attr('name');
        
                        attributes.forEach(attribute => {
                            const value = getValue($, e, attribute);
                            const prev = baseValues[key].prev[attribute];
        
                            if(value != undefined && prev != undefined) {
                                let modifier;
        
                                if(parseFloat(prev) == 0 && parseFloat(value) != 0) {
                                    problems.push(attribute);
                                }
        
                                if(parseFloat(prev) == 0) {
                                    modifier = 0.0;
                                } else {
                                    modifier = parseFloat(value) / parseFloat(prev) - 1;
                                }
                                
                                if(modifier >= 0) {
                                    jsonObj[key][$(e).attr('id')][attribute] = `+${modifier.toFixed(4)}`;
                                } else {
                                    jsonObj[key][$(e).attr('id')][attribute] = `${modifier.toFixed(4)}`;
                                }
                            }
        
                            if(value != undefined) {
                                baseValues[key].prev[attribute] = value;
                            } else if(value == undefined && prev != undefined) {
                                delete baseValues[key].prev[attribute]
                            }
                        });
                    }
                });

                if(!found) {
                    break;
                }
            }

            for(const [k, v] of Object.entries(jsonObj[key])) {
                problems.forEach(problem => {
                    console.log(`Removing problematic value ${problem} for skill ${k}`);
                    delete v[problem];
                });
            }
        }

        fs.writeFile(`conf/skill/${selector}.json`, JSON.stringify(jsonObj, null, 4), err => { if(err) throw err });
    });
}

function editSkill($, file, skill, className, attribute, value) {
    let changeToFile = false;

    $('SkillData').find('Skill').each((i, e) => {
        if($(e).attr('id') == skill && $(e).attr('name').toLowerCase().includes(selector)) {
            let changed = false;

            if(attribute == "mp" || attribute == "hp" || attribute == "anger") {
                $(e).find('Precondition').each((i, e) => {
                    $(e).find('Cost').each((i, e) => {
                        if($(e).attr(attribute) != undefined) {
                            value = parseInt(value);
                            $(e).attr(attribute, value);
                            changed = true;
                        }
                    });
                });
            } else if(attribute == 'coolTime') {
                $(e).find('Precondition').each((i, e) => {
                    if($(e).attr(attribute) != undefined) {
                        value = parseInt(value);
                        $(e).attr(attribute, value);
                        changed = true;
                    }
                });
            } else if(attribute == 'frontCancelEndTime' || attribute == 'rearCancelStartTime' || attribute == 'moveCancelStartTime') {
                $(e).find('Action').each((i, e) => {
                    $(e).find('Cancel').each((i, e) => {
                        if($(e).attr(attribute) != undefined) {
                            value = parseInt(value);
                            $(e).attr(attribute, value);
                            changed = true;
                        }
                    });
                });
            } else if(attribute == "totalAtk" || attribute == "timeRate" || attribute == 'attackRange') {
                if($(e).attr(attribute) != undefined) {
                    $(e).attr(attribute, value);
                    changed = true;
                }
            }

            if(changed) {
                console.log(`Changed skill id ${skill} ${attribute}="${value}" in file: ${file}`);
                changeToFile = true;
            }
        }
    });

    return changeToFile;
}

function editSkills(err, files, dir, conf) {
    if(err) {
        console.error(`Error: Could not open directory: ${dir}`);
        process.exit(1);
    };

    const className = selector.charAt(0).toUpperCase() + selector.slice(1);

    for(const file of files) {
        if(!file.startsWith('SkillData') && !file.startsWith(`UserSkillData_${className}`)) {
            continue;
        }

        const filePath = path.join(dir, file);

        fs.readFile(filePath, 'utf8', (err, data) => {
            if(err) {
                console.error(`Error: Could not open file: ${filePath}`)
                process.exit(1);
            }

            let $ = cheerio.load(data, { xmlMode: true, decodeEntities: false });
            let changeToFile = false;

            values.forEach(value => {
                changeToFile = changeToFile ? true : editSkill($, file, id, className, value[0], value[1]);

                if(skillLink == 'y') {
                    let prev = value[1];

                    for(const [k, v] of Object.entries(conf[id])) {
                        if(v[value[0]] == undefined) {
                            continue;
                        }

                        const baseFloat = parseFloat(prev);
                        const modFloat = parseFloat(v[value[0]]);
                        const modifiedValue = baseFloat + baseFloat * modFloat;

                        editSkill($, file, k, className, value[0], modifiedValue.toFixed(4));

                        prev = `${modifiedValue.toFixed(4)}`;
                    }
                }
            });

            if(changeToFile) {
                fs.writeFile(filePath, $.xml(), err => { if(err) throw err });
                console.log(`Wrote to file ${file}\n`);
            }
        });
    }
}

function editNpcStat($, e, attribute, value, area) {
    let modifiedValue;

    if(area && (value[0] != '+' && value[0] != '-')) {
        console.error(`Error: Only percentages are allowed for area edits.`)
        process.exit(1);
    }

    if(attribute == 'str' || attribute == 'res') {
        $(e).find('Critical').each((i, e) => {
            if($(e).attr(attribute) != undefined) {
                if(value[0] == '+' || value[0] == '-') {
                    const base = parseFloat($(e).attr(attribute));
                    const modifier = parseFloat(value);
                    modifiedValue = base + base * modifier;
                } else {
                    modifiedValue = parseFloat(value);
                }


                modifiedValue = Math.floor(modifiedValue)
                $(e).attr(attribute, modifiedValue);
            }
        });
    } else {
        $(e).find('Stat').each((i, e) => {
            if($(e).attr(attribute) != undefined) {
                if(value[0] == '+' || value[0] == '-') {
                    const base = parseFloat($(e).attr(attribute));
                    const modifier = parseFloat(value);
                    modifiedValue = base + base * modifier;
                } else {
                    modifiedValue = parseFloat(value);
                }

                if(attribute == 'atk' || attribute == 'def') {
                    modifiedValue = Math.floor(modifiedValue)
                    $(e).attr(attribute, modifiedValue);
                } else {
                    modifiedValue = modifiedValue.toFixed(4);
                    $(e).attr(attribute, modifiedValue);
                }
            }
        });
    }

    return modifiedValue;
}

function editNpcSpawn($, e, attribute, value, area) {
    let modifiedValue;

    if(area && (value[0] != '+' && value[0] != '-')) {
        console.error(`Error: Only percentages are allowed for area edits.`)
        process.exit(1);
    }

    if($(e).attr(attribute) != undefined) {
        if(value[0] == '+' || value[0] == '-') {
            const base = parseFloat($(e).attr(attribute));
            const modifier = parseFloat(value);
            modifiedValue = base + base * modifier;
        } else {
            modifiedValue = parseFloat(value);
        }

        modifiedValue = Math.floor(modifiedValue);
        $(e).attr(attribute, modifiedValue);
    }

    return modifiedValue;
}

function editArea(files) {
    files.forEach(file => {
        const fileName = file.replace(/^.*[\\/]/, '');

        fs.readFile(file, 'utf8', (err, data) => {
            if(err) {
                console.error(`Error: Could not open file: ${file}`)
                process.exit(1);
            }

            let $ = cheerio.load(data, { xmlMode: true, decodeEntities: false });
            let changeToFile = false;

            values.forEach(value => {
                if(value[0] == 'maxHp' || value[0] == 'atk' || value[0] == 'def' || value[0] == 'str' || value[0] == 'res') {
                    $('NpcData').find('Template').each((i, e) => {
                        let modifiedValue;

                        if(id == 'all') {
                            modifiedValue = editNpcStat($, e, value[0], value[1], true);
                        } else if(id == 'small') {
                            if($(e).attr('size') == 'small') {
                                modifiedValue = editNpcStat($, e, value[0], value[1], true);
                            }
                        } else if(id == 'medium') {
                            if($(e).attr('size') == 'medium') {
                                modifiedValue = editNpcStat($, e, value[0], value[1], true);
                            }
                        } else if(id == 'large') {
                            if($(e).attr('size') == 'large') {
                                modifiedValue = editNpcStat($, e, value[0], value[1], true);
                            }
                        } else if(id == 'elite') {
                            if($(e).attr('elite').toLowerCase() == 'true') {
                                modifiedValue = editNpcStat($, e, value[0], value[1], true);
                            }
                        } else {
                            if(!id.includes('-')) {
                                console.error(`Error: Invalid id ${id}.`);
                                process.exit(1);
                            }
                            
                            const ids = id.split('-');

                            if($('NpcData').attr('huntingZoneId') == ids[0] && $(e).attr('id') == ids[1]) {
                                modifiedValue = editNpcStat($, e, value[0], value[1], false);
                            }
                        }

                        if(modifiedValue != undefined) {
                            console.log(`Changed NPC ${$(e).attr('id')} ${value[0]}="${modifiedValue}" in file: ${fileName}`);
                            changeToFile = true;
                        }
                    });
                } else if(value [0] == 'respawnTime') {
                    $('TerritoryData').find('TerritoryGroup').each((i, e) => {
                        $(e).find('TerritoryList').each((i, e) => {
                            $(e).find('Territory').each((i, e) => {
                                let elements = [];
                                let modifiedValue;

                                if($(e).find('Party').length > 0) {
                                    $(e).find('Party').each((i, e) => {
                                        elements[i] = e;
                                    });
                                } else {
                                    elements[0] = e;
                                }

                                elements.forEach(element => {
                                    $(element).find('Npc').each((i, e) => {
                                        if(id == 'small' || id == 'medium' || id == 'large' || id == 'elite') {
                                            console.error('Error: Size/Elite isn\'t allowed for spawn edits. You can either edit by ID or edit the whole area.');
                                            process.exit(1);
                                        } else if(id == 'all') {
                                            modifiedValue = editNpcSpawn($, e, value[0], value[1], true);
                                        } else {
                                            if(!id.includes('-')) {
                                                console.error(`Error: Invalid id ${id}.`);
                                                process.exit(1);
                                            }
                                            
                                            const ids = id.split('-');
                    
                                            if($('TerritoryData').attr('huntingZoneId') == ids[0] && $(e).attr('npcTemplateId') == ids[1]) {
                                                modifiedValue = editNpcSpawn($, e, value[0], value[1], false);
                                            }
                                        }
                    
                                        if(modifiedValue != undefined) {
                                            console.log(`Changed NPC ${$(e).attr('npcTemplateId')} ${value[0]}="${modifiedValue}" in file: ${fileName}`);
                                            changeToFile = true;
                                        }
                                    });
                                });
                            });
                        });
                    });
                } else {
                    console.error(`Error: Unsupported attribute ${value[0]}.`);
                    process.exit(1);
                }
            });

            if(changeToFile) {
                fs.writeFile(file, $.xml(), err => { if(err) throw err });
                console.log(`Wrote to file ${fileName}\n`);
            }
        });
    });
}

function editBaseStats(file) {
    const fileName = file.replace(/^.*[\\/]/, '');

    fs.readFile(file, 'utf8', (err, data) => {
        if(err) {
            console.error(`Error: Could not open file: ${file}`)
            process.exit(1);
        }

        let $ = cheerio.load(data, { xmlMode: true, decodeEntities: false });
        let changeToFile = false;

        values.forEach(value => {
            if(value[0] != 'maxMp' && value[0] != 'managementType' && value[0] != 'tickCycle' && value[0] != 'effectValue'
            && value[0] != 'decayStartTime' && value[0] != 'decayStartTimeMpFull' && value[0] != 'recoveryStartTime') {
                console.error(`Error: Unsupported attribute ${value[0]}.`);
                process.exit(1);
            }

            $('UserData').find('Template').each((i, e) => {
                if($(e).attr('class') == selector && ($(e).attr('race') == id || id == 'all')) {
                    let race = $(e).attr('race');
                    let changed = false;

                    if(value[0] == 'maxMp') {
                        $(e).find('StatByLevelTable').each((i, e) => {
                            $(e).find('StatByLevel').each((i, e) => {
                                if($(e).attr('maxMp') != undefined) {
                                    $(e).attr('maxMp', parseInt(value[1]));
                                    changed = true;
                                }
                            });
                        });
                    } else {
                        $(e).find('ManaPoint').each((i, e) => {
                            if(value[0] == 'managementType') {
                                if(value[1] != 'TypeA' || value[1] != 'TypeB' || value[1] != 'TypeC') {
                                    console.error(`Error: Invalid value given for managementType: ${value[1]}.`);
                                    process.exit(1);
                                }

                                if($(e).attr('managementType') != undefined) {
                                    $(e).attr('managementType', value[1]);
                                    changed = true;
                                }
                            } else {
                                if($(e).attr(value[0]) != undefined) {
                                    $(e).attr(value[0], parseInt(value[1]));
                                    changed = true;
                                }
                            }
                        });
                    }

                    if(changed) {
                        console.log(`Changed ${selector} ${race} ${value[0]}="${value[1]}" in file: ${fileName}`);
                        changeToFile = true;
                    }
                }
            });
        });

        if(changeToFile) {
            fs.writeFile(file, $.xml(), err => { if(err) throw err });
            console.log(`Wrote to file ${fileName}\n`);
        }
    });
}

/*************************************************/

/**************************************/
/* Read conf file and begin execution */
/**************************************/
fs.readFile('conf/sources.json', 'utf8', (err, data) => {
    if(err) {
        console.error('Error: Could not open conf/sources.json');
        process.exit(1);
    };

    let conf = JSON.parse(data);
    const datasheetPath = conf.Datasheet;
    let databasePath = conf.Database;

    if(category == 'skill') {
        if(id == 'genconf') {
            genSkillConf(datasheetPath);
        }
        // Validate conf file if Y given
        else if(skillLink == 'y') {
            fs.readFile(`conf/${category}/${selector}.json`, 'utf8', (err, data) => {
                if(err) {
                    console.error(`Error: Could not open conf/${category}/${selector}.json`);
                    process.exit(1);
                }

                conf = JSON.parse(data);
                /*
                if(conf.Skills[id] == undefined) {
                    console.error(`Error: Invalid conf. Y given but no skill chain specified for Skill ID "${id}" in the conf.`);
                    process.exit(1);
                }

                values.forEach(value => {
                    if(conf.Attributes[value[0]] == undefined) {
                        console.error(`Error: Invalid conf. Y given but no Attribute "${value[0]}" specified in the conf.`);
                        process.exit(1);
                    }

                    if(conf.Attributes[value[0]][id] == undefined) {
                        console.error(`Error: Invalid conf. Y given but no Skill ID "${id}" specified for Attribute "${value[0]}" in the conf.`)
                        process.exit(1);
                    }

                    if(conf.Attributes[value[0]][id].length != conf.Skills[id].length) {
                        console.error(`Error: Invalid conf. Y given but length of list for "${value[0]}" does not equal length of list for Skill ID "${id}" in the conf.`);
                        process.exit(1);
                    }
                });
                */

                if(conf[id] == undefined) {
                    console.error(`Error: Invalid conf. Y given but no skill chain for skill "${id}".`);
                    process.exit(1);
                }

                databasePath = path.join(databasePath, 'SkillData');
                fs.readdir(datasheetPath, (err, files) => editSkills(err, files, datasheetPath, conf));
                fs.readdir(databasePath, (err, files) => editSkills(err, files, databasePath, conf));
            });
        } else {
            databasePath = path.join(databasePath, 'SkillData');
            fs.readdir(datasheetPath, (err, files) => editSkills(err, files, datasheetPath, null));
            fs.readdir(databasePath, (err, files) => editSkills(err, files, databasePath, null));
        }
    } else if(category == 'area') {
        if(conf.Area[selector] == undefined) {
            console.error(`Error: Area ${selector} not in path.json`);
            process.exit(1);
        }

        if(conf.Area[selector].length != 2) {
            console.error(`Error: Area ${selector} has incorrect array length. Must be of length 2.`);
            process.exit(1);
        }

        const dbNpcPath = path.join(databasePath, 'NpcData');
        const dbTerritoryPath = path.join(databasePath, 'TerritoryData');
        const datasheetFiles = conf.Area[selector][0].map(file => path.join(datasheetPath, file));
        const databaseFiles = conf.Area[selector][1].map(file => {
            if(file.startsWith('NpcData')) {
                return path.join(dbNpcPath, file);
            } else if(file.startsWith('TerritoryData')) {
                return path.join(dbTerritoryPath, file);
            } else {
                console.error(`Error: Unsupported file in conf: ${file}`);
                process.exit(1);
            }
        });

        editArea(datasheetFiles);
        editArea(databaseFiles);
    } else if(category == 'stats') {
        const userDataPath = path.join(datasheetPath, 'UserData.xml');
        editBaseStats(userDataPath);
    }
});

/*****************************************************/ 