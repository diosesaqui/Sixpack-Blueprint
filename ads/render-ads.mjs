import { createCanvas } from 'canvas';
import fs from 'fs';
import path from 'path';

const OUT_DIR = '/home/node/.openclaw/workspace/coreblastfy/ads/creatives';
fs.mkdirSync(OUT_DIR, { recursive: true });

// Each ad: intro + bold pain phrase + outro
const ads = [
  { id: 'sp01', bold: 'suck in your stomach every time you look in the mirror' },
  { id: 'sp02', bold: 'had a belly since your 20s and nothing has worked' },
  { id: 'sp03', bold: 'are skinny everywhere except your stomach' },
  { id: 'sp04', bold: 'work out regularly but still can\'t see your abs' },
  { id: 'sp05', bold: 'lost weight but your belly fat still won\'t budge' },
  { id: 'sp06', bold: 'hate taking your shirt off at the beach or pool' },
  { id: 'sp07', bold: 'do 100 crunches a day and still see no results' },
  { id: 'sp08', bold: 'can\'t stay consistent with any workout plan' },
  { id: 'sp09', bold: 'feel bloated and soft no matter what you eat' },
  { id: 'sp10', bold: 'have love handles you just can\'t get rid of' },
  { id: 'sp11', bold: 'look fit in clothes but soft without a shirt' },
  { id: 'sp12', bold: 'have tried every diet but your core never changes' },
  { id: 'sp13', bold: 'want abs but don\'t have time for the gym' },
  { id: 'sp14', bold: 'have been putting off getting your body right for years' },
  { id: 'sp15', bold: 'feel embarrassed about your stomach in photos' },
];

// Render a single canvas given dimensions
function renderAd(ad, W, H) {
  const canvas = createCanvas(W, H);
  const ctx = canvas.getContext('2d');

  // Background — dark navy like reference
  ctx.fillStyle = '#16213e';
  ctx.fillRect(0, 0, W, H);

  // Very subtle vignette
  const vig = ctx.createRadialGradient(W/2, H/2, 0, W/2, H/2, Math.max(W,H)*0.65);
  vig.addColorStop(0, 'rgba(255,255,255,0.03)');
  vig.addColorStop(1, 'rgba(0,0,0,0.25)');
  ctx.fillStyle = vig;
  ctx.fillRect(0, 0, W, H);

  const SIDE_PAD = Math.round(W * 0.1);
  const maxWidth = W - SIDE_PAD * 2;
  const FONT_SIZE = Math.round(W * 0.048); // ~52px at 1080
  const LINE_H = Math.round(FONT_SIZE * 1.55);

  ctx.textAlign = 'center';

  // Build the full paragraph as segments: [text, isBold]
  const intro   = 'If you wake up and ';
  const boldTxt = ad.bold + ',';
  const outro   = ' we made this for you.';

  // Wrap mixed-weight text into lines
  const lines = wrapMixed(ctx, intro, boldTxt, outro, maxWidth, FONT_SIZE);

  const totalTextH = lines.length * LINE_H;
  // For 9:16 (tall), position text at 42% from top instead of true center
  const centerRatio = H > W ? 0.42 : 0.5;
  let startY = H * centerRatio - totalTextH / 2 + FONT_SIZE * 0.8;

  for (const line of lines) {
    drawMixedLine(ctx, line, W / 2, startY, FONT_SIZE);
    startY += LINE_H;
  }

  // Tiny app name at bottom
  const labelSize = Math.round(W * 0.018);
  ctx.font = `${labelSize}px sans-serif`;
  ctx.fillStyle = 'rgba(255,255,255,0.28)';
  ctx.fillText('Six Pack in 30 Days Blueprint', W / 2, H - Math.round(H * 0.04));

  return canvas.toBuffer('image/png');
}

// Segment type: { text, bold }
function makeParagraphSegments(intro, bold, outro) {
  return [
    { text: intro, bold: false },
    { text: bold,  bold: true  },
    { text: outro, bold: false },
  ];
}

// Wrap mixed segments into lines, each line = array of {text, bold}
function wrapMixed(ctx, intro, bold, outro, maxWidth, fontSize) {
  const segments = makeParagraphSegments(intro, bold, outro);
  // Flatten all words with their bold flag
  const words = [];
  for (const seg of segments) {
    const ws = seg.text.split(' ').filter(w => w.length > 0);
    ws.forEach((w, i) => {
      // re-attach space except last of segment (we handle spacing separately)
      words.push({ word: w, bold: seg.bold });
    });
  }

  const lines = [];
  let currentLine = [];
  let currentWidth = 0;
  const SPACE = measureText(ctx, ' ', false, fontSize);

  for (let i = 0; i < words.length; i++) {
    const { word, bold } = words[i];
    const wWidth = measureText(ctx, word, bold, fontSize);
    const addWidth = currentLine.length === 0 ? wWidth : SPACE + wWidth;

    if (currentLine.length > 0 && currentWidth + addWidth > maxWidth) {
      lines.push(currentLine);
      currentLine = [{ word, bold }];
      currentWidth = wWidth;
    } else {
      currentLine.push({ word, bold });
      currentWidth += addWidth;
    }
  }
  if (currentLine.length > 0) lines.push(currentLine);
  return lines;
}

function measureText(ctx, text, bold, fontSize) {
  ctx.font = `${bold ? 'bold ' : ''}${fontSize}px sans-serif`;
  return ctx.measureText(text).width;
}

function drawMixedLine(ctx, words, centerX, y, fontSize) {
  // Measure total line width
  let totalW = 0;
  for (let i = 0; i < words.length; i++) {
    if (i > 0) totalW += measureText(ctx, ' ', false, fontSize);
    totalW += measureText(ctx, words[i].word, words[i].bold, fontSize);
  }

  let x = centerX - totalW / 2;

  for (let i = 0; i < words.length; i++) {
    if (i > 0) {
      const spaceW = measureText(ctx, ' ', false, fontSize);
      x += spaceW;
    }
    const { word, bold } = words[i];
    ctx.font = `${bold ? 'bold ' : ''}${fontSize}px sans-serif`;
    ctx.fillStyle = bold ? 'rgba(255,255,255,0.96)' : 'rgba(255,255,255,0.78)';
    ctx.textAlign = 'left';
    ctx.fillText(word, x, y);
    x += measureText(ctx, word, bold, fontSize);
  }
  ctx.textAlign = 'center'; // reset
}

// Render all 15 in 1:1 square
console.log('=== Rendering 1:1 square (1080×1080) ===');
for (const ad of ads) {
  const buf = renderAd(ad, 1080, 1080);
  fs.writeFileSync(path.join(OUT_DIR, `${ad.id}.png`), buf);
  console.log(`✅ ${ad.id}.png`);
}

// Top 6 for 9:16 Stories
const top6 = ['sp01','sp02','sp03','sp06','sp07','sp10'];
console.log('\n=== Rendering 9:16 stories (1080×1920) for top 6 ===');
for (const id of top6) {
  const ad = ads.find(a => a.id === id);
  const buf = renderAd(ad, 1080, 1920);
  fs.writeFileSync(path.join(OUT_DIR, `${id}_story.png`), buf);
  console.log(`✅ ${id}_story.png`);
}

console.log('\nAll done.');
