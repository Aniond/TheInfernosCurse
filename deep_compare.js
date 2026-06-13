const fs = require('fs');

function parseGM(path) {
    let raw = fs.readFileSync(path, 'utf8');
    raw = raw.replace(/,\s*}/g, '}').replace(/,\s*\]/g, ']');
    return JSON.parse(raw);
}

const ap = parseGM("C:/Projects/TheInfernoCurse/The Inferno's Curse/sprites/spr_apothecary/spr_apothecary.yy");
const po = parseGM("C:/Projects/TheInfernoCurse/The Inferno's Curse/sprites/spr_ponte_archway/spr_ponte_archway.yy");

function compare(obj1, obj2, path = "") {
    if (typeof obj1 !== typeof obj2) {
        console.log(`Type mismatch at ${path}: ${typeof obj1} vs ${typeof obj2}`);
        return;
    }
    if (typeof obj1 === 'object' && obj1 !== null) {
        if (Array.isArray(obj1)) {
            if (obj1.length !== obj2.length) {
                console.log(`Array length mismatch at ${path}: ${obj1.length} vs ${obj2.length}`);
            } else {
                for (let i = 0; i < obj1.length; i++) compare(obj1[i], obj2[i], path + "[" + i + "]");
            }
        } else {
            const k1 = Object.keys(obj1);
            const k2 = Object.keys(obj2);
            for (const k of k1) {
                if (!k2.includes(k)) console.log(`Key ${k} missing in obj2 at ${path}`);
                else compare(obj1[k], obj2[k], path + "." + k);
            }
            for (const k of k2) {
                if (!k1.includes(k)) console.log(`Key ${k} missing in obj1 at ${path}`);
            }
        }
    }
}
compare(ap, po, "root");
