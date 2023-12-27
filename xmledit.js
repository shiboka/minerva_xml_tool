const fs = require('fs');
const path = require('path');
const cheerio = require('cheerio');
const readline = require('node:readline').createInterface({
    input: process.stdin,
    output: process.stdout,
});

readline.question("What folder would you like to edit? ", folder => {
    readline.question("What skill id would you like to edit? ", id => {
        readline.question("What attribute would you like to change? ", attribute => {
            readline.question("What would you like to change the value to? ", value => {
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
                
                            fs.writeFile(filePath, $.xml(), err => {if(err) throw err});
                        });
                    });
                });

                readline.close();
            });
        });
    });
});