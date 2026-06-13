const fs = require('fs');

const yypPath = "C:/Projects/TheInfernoCurse/The Inferno's Curse/The Inferno's Curse.yyp";
let raw = fs.readFileSync(yypPath, 'utf8');

const spritesToAdd = [
  "spr_ponte_archway",
  "spr_ponte_statue",
  "spr_sign_calzolaio",
  "spr_sign_fabbro",
  "spr_sign_fioraio",
  "spr_sign_fornaio",
  "spr_sign_gilda",
  "spr_sign_libraio",
  "spr_sign_orafo",
  "spr_sign_osteria",
  "spr_sign_pergamene",
  "spr_sign_speziere",
  "spr_sign_tessitore",
  "spr_sign_vetraio"
];

let newLines = "";
for (const name of spritesToAdd) {
    if (!raw.includes(`"name":"${name}"`)) {
        newLines += `    {"id":{"name":"${name}","path":"sprites/${name}/${name}.yy",},},\n`;
    }
}

if (newLines !== "") {
    const anchor = '  "resources":[\n';
    const idx = raw.indexOf(anchor);
    if (idx !== -1) {
        const insertAt = idx + anchor.length;
        raw = raw.substring(0, insertAt) + newLines + raw.substring(insertAt);
        fs.writeFileSync(yypPath, Buffer.from(raw, 'utf8'));
        console.log("Added " + spritesToAdd.length + " sprites.");
    }
}
