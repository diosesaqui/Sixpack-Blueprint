import { createCanvas } from 'canvas';
import fs from 'fs';
import path from 'path';

const OUT_DIR = '/home/node/.openclaw/workspace/coreblastfy/ads/creatives';

const ads = [
  { id: 'sp01', pain: 'suck in your stomach\nevery time you look\nin the mirror' },
  { id: 'sp02', pain: "had a belly since\nyour 20s and nothing\nhas worked" },
  { id: 'sp03', pain: "skinny everywhere\nexcept your stomach" },
  { id: 'sp04', pain: "work out regularly\nbut still can't\nsee your abs" },
  { id: 'sp05', pain: "lost weight but your\nbelly fat still\nwon't budge" },
  { id: 'sp06', pain: "hate taking your shirt\noff at the beach\nor pool" },
  { id: 'sp07', pain: "do 100 crunches a day\nand still see\nno results" },
  { id: 'sp08', pain: "can't stay consistent\nwith any\nworkout plan" },
  { id: 'sp09', pain: "bloated and soft\nno matter\nwhat you eat" },
  { id: 'sp10', pain: "have love handles\nyou just can't\nget rid of" },
  { id: 'sp11', pain: "look fit in clothes\nbut soft without\na shirt" },
  { id: 'sp12', pain: "tried every diet\nbut your core\nnever changes" },
  { id: 'sp13', pain: "want abs but don't\nhave time for\nthe gym" },
  { id: 'sp14', pain: "been putting off\ngetting your body\nright for years" },
  { id: 'sp15', pain: "feel embarrassed about\nyour stomach\nin photos" },
];

const W = 1080, H = 1080;
const CYAN = '#00DDB4';

function renderAd(ad) {
  const canvas = createCanvas(W, H);
  const ctx = canvas.getContext('2d');

  // BACKGROUND
  ctx.fillStyle = '#0d1117';
  ctx.fillRect(0, 0, W, H);

  // Subtle vignette glow center
  const glow = ctx.createRadialGradient(W / 2, H * 0.45, 60, W / 2, H * 0.45, 520);
  glow.addColorStop(0, 'rgba(15, 40, 80, 0.6)');
  glow.addColorStop(1, 'rgba(0,0,0,0)');
  ctx.fillStyle = glow;
  ctx.fillRect(0, 0, W, H);

  // Cyan top accent line
  const topLine = ctx.createLinearGradient(220, 0, 860, 0);
  topLine.addColorStop(0, 'rgba(0,221,180,0)');
  topLine.addColorStop(0.5, 'rgba(0,221,180,1)');
  topLine.addColorStop(1, 'rgba(0,221,180,0)');
  ctx.fillStyle = topLine;
  ctx.fillRect(220, 52, 640, 3);

  // BRAND
  ctx.font = 'bold 22px sans-serif';
  ctx.fillStyle = CYAN;
  ctx.textAlign = 'center';
  ctx.fillText('SIX PACK BLUEPRINT', W / 2, 94);

  // INTRO
  ctx.font = 'italic 38px sans-serif';
  ctx.fillStyle = 'rgba(255,255,255,0.45)';
  ctx.fillText('If you wake up and', W / 2, 186);

  // PAIN POINT
  const painLines = ad.pain.split('\n');
  const n = painLines.length;
  const fontSize = n <= 2 ? 86 : 74;
  const lineH = n <= 2 ? 100 : 88;
  ctx.font = `bold ${fontSize}px sans-serif`;
  ctx.fillStyle = '#FFFFFF';

  const totalPainH = n * lineH;
  // Start pain block so it ends around y=640
  const painStartY = Math.max(240, 640 - totalPainH);

  painLines.forEach((line, i) => {
    ctx.fillText(line, W / 2, painStartY + i * lineH);
  });

  const painEndY = painStartY + totalPainH;

  // DIVIDER
  const divY = painEndY + 44;
  const divGrad = ctx.createLinearGradient(160, divY, 920, divY);
  divGrad.addColorStop(0, 'rgba(255,255,255,0)');
  divGrad.addColorStop(0.5, 'rgba(255,255,255,0.22)');
  divGrad.addColorStop(1, 'rgba(255,255,255,0)');
  ctx.strokeStyle = divGrad;
  ctx.lineWidth = 1.5;
  ctx.beginPath();
  ctx.moveTo(160, divY);
  ctx.lineTo(920, divY);
  ctx.stroke();

  // "we made this for you."
  const ctaY = divY + 68;
  ctx.font = 'bold 50px sans-serif';
  ctx.fillStyle = 'rgba(255,255,255,0.93)';
  ctx.fillText('we made this for you.', W / 2, ctaY);

  // SOCIAL PROOF ROW
  const spY = ctaY + 70;
  ctx.font = '26px sans-serif';
  ctx.fillStyle = 'rgba(255,255,255,0.35)';
  ctx.fillText('★★★★★  50,000+ users  •  5-min daily workouts', W / 2, spY);

  // BOTTOM BADGE
  const badgeW = 460, badgeH = 58, badgeR = 29;
  const badgeX = (W - badgeW) / 2;
  const badgeCY = H - 80;

  // Pill background
  ctx.fillStyle = 'rgba(0,221,180,0.10)';
  roundRect(ctx, badgeX, badgeCY - badgeH / 2, badgeW, badgeH, badgeR);
  ctx.fill();

  ctx.strokeStyle = 'rgba(0,221,180,0.40)';
  ctx.lineWidth = 1.5;
  roundRect(ctx, badgeX, badgeCY - badgeH / 2, badgeW, badgeH, badgeR);
  ctx.stroke();

  ctx.font = 'bold 23px sans-serif';
  ctx.fillStyle = 'rgba(255,255,255,0.80)';
  ctx.fillText('Six Pack in 30 Days Blueprint', W / 2, badgeCY + 9);

  return canvas.toBuffer('image/png');
}

function roundRect(ctx, x, y, w, h, r) {
  ctx.beginPath();
  ctx.moveTo(x + r, y);
  ctx.lineTo(x + w - r, y);
  ctx.quadraticCurveTo(x + w, y, x + w, y + r);
  ctx.lineTo(x + w, y + h - r);
  ctx.quadraticCurveTo(x + w, y + h, x + w - r, y + h);
  ctx.lineTo(x + r, y + h);
  ctx.quadraticCurveTo(x, y + h, x, y + h - r);
  ctx.lineTo(x, y + r);
  ctx.quadraticCurveTo(x, y, x + r, y);
  ctx.closePath();
}

for (const ad of ads) {
  const buf = renderAd(ad);
  fs.writeFileSync(path.join(OUT_DIR, `${ad.id}.png`), buf);
  console.log(`✅ ${ad.id}.png`);
}
console.log('\nDone — 15 ads rendered.');
