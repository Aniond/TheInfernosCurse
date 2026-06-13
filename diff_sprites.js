const fs = require('fs');

const ap = fs.readFileSync("C:/Projects/TheInfernoCurse/The Inferno's Curse/sprites/spr_apothecary/spr_apothecary.yy", 'utf8');
const po = fs.readFileSync("C:/Projects/TheInfernoCurse/The Inferno's Curse/sprites/spr_ponte_archway/spr_ponte_archway.yy", 'utf8');

const apLines = ap.split('\n');
const poLines = po.split('\n');

for (let i = 0; i < apLines.length; i++) {
    if (apLines[i].replace(/spr_apothecary/g, "TEST").replace(/[a-f0-9\-]{36}/g, "GUID").replace(/224/g, "DIM") !==
        poLines[i].replace(/spr_ponte_archway/g, "TEST").replace(/[a-f0-9\-]{36}/g, "GUID").replace(/256/g, "DIM")) {
        console.log(`Line ${i+1}:`);
        console.log(`AP: ${apLines[i]}`);
        console.log(`PO: ${poLines[i]}`);
    }
}
