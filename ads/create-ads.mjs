import fs from 'fs';
import path from 'path';
import FormData from 'form-data';
import fetch from 'node-fetch';

const AD_ACCOUNT   = 'act_253451158661796';
const ACCESS_TOKEN = process.env.FB_ACCESS_TOKEN;
const API          = 'https://graph.facebook.com/v21.0';
const PAGE_ID      = '104027662277976';
const APP_LINK     = 'https://apps.apple.com/app/id1511323845';
const CREATIVE_DIR = '/home/node/.openclaw/workspace/coreblastfy/ads/creatives';

const ADSETS = [
  { id: '120237991854360227', name: 'Broad 18-45',  ads: ['sp01','sp02','sp03','sp06','sp07','sp10'] },
  { id: '120237991854670227', name: 'Male 22-40',   ads: ['sp04','sp05','sp08','sp09','sp11','sp12'] },
  { id: '120237991855030227', name: 'Broad 25-55',  ads: ['sp13','sp14','sp15','sp01','sp06','sp10'] },
];

// Story adset — separate adset for 9:16 placements (will create if needed)
const STORY_ADS = ['sp01','sp02','sp03','sp06','sp07','sp10'];

const PRIMARY_TEXT = `Here's a hard truth: most people who struggle with belly fat aren't lazy.

It doesn't matter how many crunches you do.

If you're working out, watching what you eat, and still seeing the same stomach every morning — the problem isn't effort. It's the wrong approach.

Most ab routines are built for athletes with 2 hours a day. Not for real people with real lives.

We built Six Pack Blueprint differently. 5 minutes a day, no equipment, no gym. Just the most direct path to a visible core — starting from wherever you are right now.

50,000 people are already on their way.

If you're tired of waking up feeling the same way, click below.`;

const HEADLINE = 'Get Visible Abs in 5 Minutes a Day';

async function uploadImage(filePath) {
  const form = new FormData();
  form.append('access_token', ACCESS_TOKEN);
  form.append('source', fs.createReadStream(filePath), path.basename(filePath));
  const res = await fetch(`${API}/${AD_ACCOUNT}/adimages`, { method: 'POST', body: form });
  const data = await res.json();
  if (data.images) {
    const key = Object.keys(data.images)[0];
    return data.images[key].hash;
  }
  throw new Error(`Upload failed: ${JSON.stringify(data)}`);
}

async function createCreative(name, imageHash) {
  const res = await fetch(`${API}/${AD_ACCOUNT}/adcreatives`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      access_token: ACCESS_TOKEN,
      name,
      object_story_spec: {
        page_id: PAGE_ID,
        link_data: {
          link: APP_LINK,
          message: PRIMARY_TEXT,
          name: HEADLINE,
          call_to_action: { type: 'DOWNLOAD', value: { link: APP_LINK } },
          image_hash: imageHash,
        }
      }
    })
  });
  const data = await res.json();
  if (data.id) return data.id;
  throw new Error(`Creative failed: ${JSON.stringify(data)}`);
}

async function createAd(adsetId, creativeId, name) {
  const res = await fetch(`${API}/${AD_ACCOUNT}/ads`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      access_token: ACCESS_TOKEN,
      name,
      adset_id: adsetId,
      creative: { creative_id: creativeId },
      status: 'PAUSED',
    })
  });
  const data = await res.json();
  if (data.id) return data.id;
  throw new Error(`Ad failed: ${JSON.stringify(data)}`);
}

// ── MAIN ──────────────────────────────────────────────────────────
console.log('🚀 Uploading images...\n');

const hashes = {};

// Upload all 15 square images
const squareFiles = fs.readdirSync(CREATIVE_DIR).filter(f => /^sp\d+\.png$/.test(f)).sort();
for (const file of squareFiles) {
  const id = file.replace('.png', '');
  hashes[id] = await uploadImage(path.join(CREATIVE_DIR, file));
  console.log(`  ✅ ${id}: ${hashes[id]}`);
}

// Upload 6 story images
const storyFiles = fs.readdirSync(CREATIVE_DIR).filter(f => /^sp\d+_story\.png$/.test(f)).sort();
for (const file of storyFiles) {
  const id = file.replace('.png', '');
  hashes[id] = await uploadImage(path.join(CREATIVE_DIR, file));
  console.log(`  ✅ ${id}: ${hashes[id]}`);
}

// Create square creatives
console.log('\n🎨 Creating square creatives...');
const squareCreatives = {};
const allAdIds = [...new Set(ADSETS.flatMap(a => a.ads))];
for (const id of allAdIds) {
  squareCreatives[id] = await createCreative(`Sixpack | ${id} | square`, hashes[id]);
  console.log(`  ✅ ${id} creative: ${squareCreatives[id]}`);
}

// Create story creatives
console.log('\n🎨 Creating story creatives...');
const storyCreatives = {};
for (const id of STORY_ADS) {
  storyCreatives[id] = await createCreative(`Sixpack | ${id} | story`, hashes[`${id}_story`]);
  console.log(`  ✅ ${id} story creative: ${storyCreatives[id]}`);
}

// Create ads in adsets (square)
console.log('\n📋 Creating square ads in adsets...');
for (const adset of ADSETS) {
  console.log(`\n  → ${adset.name}`);
  for (const id of adset.ads) {
    const adId = await createAd(adset.id, squareCreatives[id], `Sixpack | ${id} | ${adset.name}`);
    console.log(`    ✅ ${id} → ad ${adId}`);
  }
}

// Create story ads in Adset A (top 6 stories go in Broad 18-45)
console.log('\n📋 Creating story ads in Adset A (Broad 18-45)...');
// Note: Adset A already has 6 square ads (at limit). Stories need a new adset.
// Create a Stories-specific adset
console.log('  Creating Stories adset...');
const storiesAdsetRes = await fetch(`${API}/${AD_ACCOUNT}/adsets`, {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    access_token: ACCESS_TOKEN,
    name: 'Sixpack - Stories [AppInstalls]',
    campaign_id: '120237991851600227',
    status: 'PAUSED',
    optimization_goal: 'APP_INSTALLS',
    billing_event: 'IMPRESSIONS',
    promoted_object: {
      application_id: '1130695069161877',
      object_store_url: 'https://apps.apple.com/app/id1511323845'
    },
    targeting: {
      age_min: 18,
      age_max: 45,
      app_install_state: 'not_installed',
      geo_locations: { countries: ['US','CA','GB','AU'], location_types: ['home','recent'] },
      user_os: ['iOS_ver_14.0_and_above'],
      publisher_platforms: ['instagram','facebook'],
      instagram_positions: ['story','reels'],
      facebook_positions: ['story']
    }
  })
});
const storiesAdset = await storiesAdsetRes.json();
const storiesAdsetId = storiesAdset.id;
if (!storiesAdsetId) throw new Error(`Stories adset failed: ${JSON.stringify(storiesAdset)}`);
console.log(`  ✅ Stories adset: ${storiesAdsetId}`);

for (const id of STORY_ADS) {
  const adId = await createAd(storiesAdsetId, storyCreatives[id], `Sixpack | ${id} | stories`);
  console.log(`  ✅ ${id} story ad → ${adId}`);
}

console.log('\n🎉 ALL DONE. Everything is PAUSED — ready to activate on app approval.');
