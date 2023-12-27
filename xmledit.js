const fs = require('fs')
const cheerio = require('cheerio')
const readline = require('node:readline').createInterface({
    input: process.stdin,
    output: process.stdout,
});

readline.question("What file would you like to edit? ", file => {
    fs.readFile(file, 'utf8', (err, data) => {
        if(err) throw err;
        var $ = cheerio.load(data, { xmlMode: true, decodeEntities: false });

        readline.question("What skill id would you like to edit? ", id => {
            readline.question("What attribute would you like to change? ", attribute => {
                readline.question("What would you like to change the value to? ", value => {
                    $('SkillData').find('Skill').each((i, element) => {
                        if($(element).attr('id') == id) {
                            $(element).attr(attribute, value);
                            console.log(`Changed skill id ${id} ${attribute}="${value}"`)
                        }
                    });
        
                    fs.writeFile(file, $.xml(), err => {if(err) throw err});
                    readline.close();
                });
            })
        });
    });
});