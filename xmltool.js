const fs = require('fs');
const path = require('path');
const cheerio = require('cheerio');

/***********************************************/
/* Process and validate command line arguments */
/***********************************************/
if(process.argv.length < 7) {
    console.error('Error: At least 5 arguments are required:\nConf category i.e. skill\nConf file i.e. warrior\nSkill id: i.e. 10100\nSkill link: y/n\nAttributes: i.e. totalAtk="100" mp="100"');
    process.exit(1);
}

const confCategory = process.argv[2].toLowerCase();
const confFile = process.argv[3].toLowerCase();
const skillId = process.argv[4];
let skillLink = process.argv[5].toLowerCase();
let values;

if(skillLink == 'y' || skillLink == 'n') {
    values = process.argv.slice(6)
} else {
    values = process.argv.slice(5);
    skillLink = 'n';
}

values = values.map(value => {
    if(!value.includes('=')) {
        console.error(`Error: Invalid value given: ${value}`);
        process.exit(1);
    }

    return value.split('=');
});

if(confCategory != 'skill') {
    console.error(`Error: ${confCategory} is an invalid category.`);
    process.exit(1);
}

/**********************************************/

/************************/
/* Function Definitions */
/************************/
function editSkill($, file, id, attribute, value) {
    $('SkillData').find('Skill').each((i, e) => {
        if($(e).attr('id') == id) {
            let changed = false;

            if(attribute == "mp" || attribute == "hp" || attribute == "anger") {
                $(e).find('TargetingList').each((i, e) => {
                    $(e).find('Targeting').each((i,e) => {
                        $(e).find('Cost').each((i,e) => {
                            if($(e).attr(attribute) != undefined) {
                                value = Math.floor(value);
                                $(e).attr(attribute, value);
                                changed = true;
                            }
                        });
                    });
                });

                $(e).find('Precondition').each((i, e) => {
                    $(e).find('Cost').each((i, e) => {
                        if($(e).attr(attribute) != undefined) {
                            value = Math.floor(value);
                            $(e).attr(attribute, value);
                            changed = true;
                        }
                    });
                });
            } else if(attribute == 'coolTime') {
                $(e).find('Precondition').each((i, e) => {
                    if($(e).attr(attribute) != undefined) {
                        value = Math.floor(value);
                        $(e).attr(attribute, value);
                        changed = true;
                    }
                });
            } else if(attribute == 'startCancelEndTime' || attribute == 'rearCancelStartTime' || attribute == 'moveCancelStartTime') {
                $(e).find('Action').each((i, e) => {
                    $(e).find('Cancel').each((i, e) => {
                        if($(e).attr(attribute) != undefined) {
                            value = Math.floor(value);
                            $(e).attr(attribute, value);
                            changed = true;
                        }
                    });
                });
            } else if(attribute == "totalAtk" || attribute == "timeRate" || attribute == 'attackRange') {
                if($(e).attr(attribute) != undefined) {
                    value = value.toFixed(2);
                    $(e).attr(attribute, value);
                    changed = true;
                }
            }

            if(changed) {
                console.log(`Changed skill id ${id} ${attribute}="${value}" in file: ${file}`);
            }
        }
    });
}

function editSkills(err, files, dir, conf) {
    if(err) {
        console.error(`Error: Could not open directory: ${dir}`);
        process.exit(1);
    };

    files.forEach(file => {
        const filePath = path.join(dir, file);

        fs.readFile(filePath, 'utf8', (err, data) => {
            if(err) {
                console.error(`Error: Could not open file: ${filePath}`)
                process.exit(1);
            }

            var $ = cheerio.load(data, { xmlMode: true, decodeEntities: false });

            values.forEach(value => {
                editSkill($, file, skillId, value[0], value[1]);

                if(skillLink == 'y') {
                    conf.Skills[skillId].forEach((skill, i) => {
                        const baseFloat = parseFloat(value[1]);
                        const modFloat = parseFloat(conf.Attributes[value[0]][skillId][i]);
                        const modifiedValue = baseFloat + baseFloat * modFloat;
                        
                        editSkill($, file, skill, value[0], modifiedValue);
                    });
                }
            });

            fs.writeFile(filePath, $.xml(), err => { if(err) throw err });
        });
    });
}

/*************************************************/

/**************************************/
/* Read conf file and begin execution */
/**************************************/
fs.readFile(`conf/${confCategory}/${confFile}.json`, 'utf8', (err, data) => {
    if(err) {
        console.error(`Error: conf/${confCategory}/${confFile}.json does not exist.`);
        process.exit(1);
    };

    const conf = JSON.parse(data);
    const datasheetPath = conf.Datasheet;
    const databasePath = conf.Database;

    // Validate conf file if Y given
    if(skillLink == "y") {
        if(conf.Skills[skillId] == undefined) {
            console.error(`Error: Invalid conf. Y given but no skill chain specified for Skill ID "${skillId}" in the conf.`);
            process.exit(1);
        }

        values.forEach(value => {
            if(conf.Attributes[value[0]] == undefined) {
                console.error(`Error: Invalid conf. Y given but no Attribute "${value[0]}" specified in the conf.`);
                process.exit(1);
            }

            if(conf.Attributes[value[0]][skillId] == undefined) {
                console.error(`Error: Invalid conf. Y given but no Skill ID "${skillId}" specified for Attribute "${value[0]}" in the conf.`)
                process.exit(1);
            }

            if(conf.Attributes[value[0]][skillId].length != conf.Skills[skillId].length) {
                console.error(`Error: Invalid conf. Y given but length of list for "${value[0]}" does not equal length of list for Skill ID "${id}" in the conf.`);
                process.exit(1);
            }
        });
    }

    fs.readdir(datasheetPath, (err, files) => editSkills(err, files, datasheetPath, conf));
    fs.readdir(databasePath, (err, files) => editSkills(err, files, databasePath, conf));
});

/*****************************************************/ 