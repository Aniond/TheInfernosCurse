const fs = require('fs');
function check(p) {
    const txt = fs.readFileSync(p);
    console.log(p);
    console.log('BOM:', txt.subarray(0,3));
    const str = txt.toString('utf8');
    console.log('CRLF:', (str.match(/\r\n/g) || []).length, 'LF only:', (str.match(/(?<!\r)\n/g) || []).length);
}
check("C:/Projects/TheInfernoCurse/The Inferno's Curse/sprites/spr_apothecary/spr_apothecary.yy");
check("C:/Projects/TheInfernoCurse/The Inferno's Curse/sprites/spr_ponte_archway/spr_ponte_archway.yy");
