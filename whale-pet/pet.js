// ============ 小鲸鱼 · 电子宠物 逻辑 ============
const $ = (s) => document.querySelector(s);

// 状态：hp 饱食度 / happy 心情 / energy 精力，范围 0-100
let pet = load('whale-pet', { hp: 90, happy: 70, energy: 80, asleep: false, born: Date.now() });

const whale = $('#whale');
const bubble = $('#bubble');
const spout = $('#spout');

let bubbleTimer = null;

// ---------- 渲染 ----------
function render() {
  $('#hp-val').textContent = pet.hp;
  $('#happy-val').textContent = pet.happy;
  $('#energy-val').textContent = pet.energy;
  $('#hp-bar').style.width = pet.hp + '%';
  $('#happy-bar').style.width = pet.happy + '%';
  $('#energy-bar').style.width = pet.energy + '%';
  save('whale-pet', pet);
}

// ---------- 气泡说话 ----------
function say(msg, ms = 1800) {
  bubble.textContent = msg;
  bubble.classList.add('show');
  clearTimeout(bubbleTimer);
  bubbleTimer = setTimeout(() => bubble.classList.remove('show'), ms);
}

// ---------- 互动 ----------
function feed() {
  if (pet.asleep) return say('嘘…我在睡觉💤');
  pet.hp = Math.min(100, pet.hp + 20);
  pet.happy = Math.min(100, pet.happy + 5);
  spoutPlay();
  bounce();
  say('咕噜～好吃！🦐');
  render();
}
function play() {
  if (pet.asleep) return say('睡醒了再玩吧');
  if (pet.energy < 10) return say('好累，想休息😪');
  pet.happy = Math.min(100, pet.happy + 20);
  pet.energy = Math.max(0, pet.energy - 15);
  pet.hp = Math.max(0, pet.hp - 3);
  bounce();
  say('耶！好玩！🫧');
  render();
}
function pet() {
  pet.happy = Math.min(100, pet.happy + 10);
  pet.energy = Math.min(100, pet.energy + 5);
  whale.classList.remove('bounce'); void whale.offsetWidth;
  whale.classList.add('bounce');
  say('嘿嘿～好舒服😊');
  render();
}
function sleepToggle() {
  pet.asleep = !pet.asleep;
  setSleepVisual(pet.asleep);
  if (pet.asleep) say('晚安💤');
  else { say('睡醒啦！精神满满☀️'); pet.energy = Math.min(100, pet.energy + 20); render(); }
}
function setSleepVisual(s) {
  $('#eye-sleep').style.display = s ? '' : 'none';
  whale.classList.toggle('sleep', s);
  whale.classList.toggle('swim', !s);
}

// ---------- 动画 ----------
function bounce() {
  whale.classList.remove('bounce'); void whale.offsetWidth;
  whale.classList.add('bounce');
}
function spoutPlay() {
  spout.classList.add('on');
  setTimeout(() => spout.classList.remove('on'), 1100);
}

// ---------- 点鲸鱼本身 ----------
whale.addEventListener('click', () => {
  pet();
});

// ---------- 数值自然衰减（每 30 秒） ----------
setInterval(() => {
  if (pet.asleep) {
    // 睡觉时恢复精力、缓慢消耗饱食
    pet.energy = Math.min(100, pet.energy + 6);
    pet.hp = Math.max(0, pet.hp - 1);
  } else {
    pet.hp = Math.max(0, pet.hp - 2);
    pet.happy = Math.max(0, pet.happy - 1);
    pet.energy = Math.max(0, pet.energy - 1);
  }
  render();
  // 状态提示
  if (pet.hp <= 15) say('好饿…投喂我一点吧🥺');
  else if (pet.happy <= 15) say('有点无聊，陪我玩嘛');
  else if (pet.energy <= 15) say('好困…想睡觉了💤');
}, 30000);

// ---------- 随机小动作 ----------
setInterval(() => {
  if (pet.asleep) return;
  const r = Math.random();
  if (r < 0.4) { whale.classList.add('swim'); setTimeout(() => whale.classList.remove('swim'), 3200); }
  else if (r < 0.55) say(['今天也要加油呀！','呼噜噜～','想听你说话','要摸摸头吗？'][Math.floor(Math.random()*4)]);
}, 20000);

// ---------- 存储 ----------
function save(k, v) { localStorage.setItem(k, JSON.stringify(v)); }
function load(k, def) { try { const v = localStorage.getItem(k); return v === null ? def : JSON.parse(v); } catch(e){ return def; } }

// ---------- 初始化 ----------
setSleepVisual(pet.asleep);
if (!pet.asleep) whale.classList.add('swim');
render();
say('你好呀，我是小鲸鱼🐳');
