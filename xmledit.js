const fs = require('fs');
const path = require('path');
const cheerio = require('cheerio');

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

if(process.argv.length != 6) {
    console.error('Error: 4 arguments are required:\nJSON option: i.e. Warrior\nSkill ID: i.e. 10100\nAttribute: i.e. totalAtk\nValue: i.e. 3.3');
    process.exit(1);
}

const option = process.argv[2];
const id = process.argv[3];
const attribute = process.argv[4];
const value = process.argv[5];

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