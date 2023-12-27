const fs = require('fs');
const path = require('path');
const cheerio = require('cheerio');

if(process.argv.length != 6) {
    console.error('Error: 4 arguments are required\nFolder\nSkill ID\nAttribute\nValue');
    process.exit(1);
}

const folder = process.argv[2];
const id = process.argv[3];
const attribute = process.argv[4];
const value = process.argv[5];

const dirPath = path.join(__dirname, folder);

fs.readdir(dirPath, (err, files) => {
    if(err) throw err;

    files.forEach(file => {
        const filePath = path.join(dirPath, file);

        fs.readFile(filePath, 'utf8', (err, data) => {
            if(err) throw err;
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
});