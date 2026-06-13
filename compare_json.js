const fs = require('fs');

function parseGM(path) {
    let raw = fs.readFileSync(path, 'utf8');
    // GM JSON has trailing commas. We can strip them to parse cleanly.
    raw = raw.replace(/,\s*}/g, '}').replace(/,\s*\]/g, ']');
    return JSON.parse(raw);
}

const ap = parseGM("C:/Projects/TheInfernoCurse/The Inferno's Curse/sprites/spr_apothecary/spr_apothecary.yy");
const po = parseGM("C:/Projects/TheInfernoCurse/The Inferno's Curse/sprites/spr_ponte_archway/spr_ponte_archway.yy");

const apKeys = Object.keys(ap).sort();
const poKeys = Object.keys(po).sort();

console.log("Keys only in apothecary: ", apKeys.filter(k => !poKeys.includes(k)));
console.log("Keys only in archway: ", poKeys.filter(k => !apKeys.includes(k)));

console.log("Checking sequence keys...");
const apSeqKeys = Object.keys(ap.sequence).sort();
const poSeqKeys = Object.keys(po.sequence).sort();
console.log("Seq keys only in apothecary: ", apSeqKeys.filter(k => !poSeqKeys.includes(k)));
console.log("Seq keys only in archway: ", poSeqKeys.filter(k => !apSeqKeys.includes(k)));
