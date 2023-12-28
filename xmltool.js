const fs = require('fs');
const path = require('path');
const cheerio = require('cheerio');

if(process.argv.length < 7) {
    console.error('Error: At least 5 arguments are required:\nConf category i.e. skill\nConf file i.e. warrior\nSkill id: i.e. 10100\nChain skills: i.e. y/n\nValues: i.e. totalAtk="100" hp="100"');
    process.exit(1);
}

const confCategory = process.argv[2].toLowerCase();
const confFile = process.argv[3].toLowerCase();
const id = process.argv[4];
const chain = process.argv[5].toLowerCase();
const values = process.argv.slice(6).map(value => {
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

function editFiles(err, files, dirPath) {
    if(err) {
        console.error(`Error: Could not open directory: ${dirPath}`);
        process.exit(1);
    };
    
    files.forEach(file => {
        const filePath = path.join(dirPath, file);

        fs.readFile(filePath, 'utf8', (err, data) => {
            if(err) {
                console.error(`Error: Could not open file: ${filePath}`)
                process.exit(1);
            }

            var $ = cheerio.load(data, { xmlMode: true, decodeEntities: false });

            $('SkillData').find('Skill').each((i, element) => {
                if($(element).attr('id') == id) {
                    $(element).attr(attribute, value);
                    console.log(`Changed skill id ${id} ${attribute}="${value}" in file: ${file}`)
                }
            });

            fs.writeFile(filePath, $.xml(), err => { if(err) throw err });
        });
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
                $('SkillData').find('Skill').each((i, e) => {
                    if($(e).attr('id') == id) {
                        if(value[0] == "mp" || value[0] == "hp" || value[0] == "anger") {
                            $(e).find('TargetingList').each((i, e) => {
                                $(e).find('Targeting').each((i,e) => {
                                    $(e).find('Cost').each((i,e) => {
                                        console.log('TargetingList/Targeting/Cost:');
                                        console.log(value[0]);
                                        console.log($(e).attr(value[0]));
                                    });
                                });
                            });

                            $(e).find('Precondition').each((i, e) => {
                                $(e).find('Cost').each((i, e) => {
                                    console.log('Precondition/Cost:');
                                    console.log(value[0]);
                                    console.log($(e).attr(value[0]));
                                });
                            });
                        } else if(value[0] == 'coolTime') {
                            $(e).find('Precondition').each((i, e) => {
                                console.log('Precondition:');
                                console.log(value[0]);
                                console.log($(e).attr(value[0]));
                            });
                        } else if(value[0] == 'startCancelEndTime' || value[0] == 'rearCancelStartTime' || value[0] == 'moveCancelStartTime') {
                            $(e).find('Action').each((i, e) => {
                                $(e).find('Cancel').each((i, e) => {
                                    console.log('Action/Cancel:')
                                    console.log(value[0]);
                                    console.log($(e).attr(value[0]));
                                });
                            });
                        } else if(value[0] == "totalAtk" || value[0] == "timeRate" || value[0] == 'attackRange' || value[0] == 'pushTarget') {
                            console.log('Skill:');
                            console.log(value[0]);
                            console.log($(e).attr(value[0]));
                        }
                    }
                });
            });
        });
    });
}

fs.readFile(`conf/${confCategory}/${confFile}.json`, 'utf8', (err, data) => {
    if(err) {
        console.error(`Error: conf/${confCategory}/${confFile}.json does not exist.`);
        process.exit(1);
    };

    const conf = JSON.parse(data);
    const datasheetPath = conf.Datasheet;
    const databasePath = conf.Database;

    if(chain == "y") {
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
    }

    //fs.readdir(datasheetPath, (err, files) => editSkills(err, files, datasheetPath, conf));
});

/*
fs.readFile('xmledit.json', 'utf8', (err, data) => {
    if(err) {
        console.error("Error: Could not open conf file xmledit.json")
        process.exit(1);
    }

    const conf = JSON.parse(data);
    const datasheetPath = conf[option].datasheet;
    const databasePath = conf[option].database;

    fs.readdir(datasheetPath, (err, files) => editFiles(err, files, datasheetPath));
    fs.readdir(databasePath, (err, files) => editFiles(err, files, databasePath));
});
*/