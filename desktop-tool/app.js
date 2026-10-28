// ============ 桌面小工具 核心逻辑 ============
// 数据存储：localStorage（本地持久化，关闭不丢失）

// ---------- 通用工具 ----------
const $ = (s) => document.querySelector(s);
function save(key, val) { localStorage.setItem(key, JSON.stringify(val)); }
function load(key, def) {
  try { const v = localStorage.getItem(key); return v === null ? def : JSON.parse(v); }
  catch (e) { return def; }
}

// ---------- 标签切换 ----------
function switchTab(name) {
  document.querySelectorAll('.tab').forEach(t => t.classList.toggle('active', t.dataset.p === name));
  document.querySelectorAll('.panel').forEach(p => p.classList.toggle('active', p.id === 'p-' + name));
  if (name === 'clip') renderClip();
}

// ============ 1. 便签 ============
function addNote() {
  const input = $('#note-input');
  const text = input.value.trim();
  if (!text) return;
  const notes = load('notes', []);
  notes.unshift({ text, time: Date.now() });
  save('notes', notes);
  input.value = '';
  renderNotes();
}
function delNote(i) {
  const notes = load('notes', []);
  notes.splice(i, 1);
  save('notes', notes);
  renderNotes();
}
function clearNotes() {
  if (confirm('确定清空所有便签？')) { save('notes', []); renderNotes(); }
}
function renderNotes() {
  const notes = load('notes', []);
  const el = $('#note-list');
  if (!notes.length) { el.innerHTML = '<div class="empty">还没有便签，写一条吧</div>'; return; }
  el.innerHTML = notes.map((n, i) => `
    <div class="note-item">
      <div class="nt">${escapeHtml(n.text)}</div>
      <div class="nm"><span>${fmtTime(n.time)}</span><button class="ghost" style="padding:2px 8px;font-size:11px;" onclick="delNote(${i})">删除</button></div>
    </div>`).join('');
}

// ============ 2. 倒计时 ============
let cdTotal = 0, cdLeft = 0, cdTimer = null, cdRunning = false;
function startCountdown() {
  const m = parseInt($('#cd-min').value) || 0;
  const s = parseInt($('#cd-sec').value) || 0;
  cdTotal = m * 60 + s;
  if (cdTotal <= 0) return;
  cdLeft = cdTotal;
  cdRunning = true;
  clearInterval(cdTimer);
  cdTimer = setInterval(tick, 1000);
  $('#cd-state').textContent = '计时中...';
  tick();
}
function tick() {
  if (cdLeft <= 0) { stopCd(); $('#cd-state').textContent = '时间到！'; flashOver(); return; }
  $('#cd-display').textContent = fmtCd(cdLeft);
  $('#cd-display').classList.toggle('over', cdLeft <= 10);
  cdLeft--;
}
function pauseCountdown() {
  if (!cdTimer) return;
  if (cdRunning) { clearInterval(cdTimer); cdRunning = false; $('#cd-state').textContent = '已暂停'; }
  else { cdTimer = setInterval(tick, 1000); cdRunning = true; $('#cd-state').textContent = '计时中...'; }
}
function resetCountdown() {
  stopCd();
  cdLeft = cdTotal = 0;
  $('#cd-display').textContent = fmtCd(0);
  $('#cd-display').classList.remove('over');
  $('#cd-state').textContent = '就绪';
}
function stopCd() { clearInterval(cdTimer); cdTimer = null; cdRunning = false; }
function flashOver() { $('#cd-display').classList.add('over'); }
function fmtCd(s) {
  const m = Math.floor(s / 60), sec = s % 60;
  return String(m).padStart(2, '0') + ':' + String(sec).padStart(2, '0');
}

// ============ 3. 剪贴板 ============
function watchClipboard() {
  document.addEventListener('copy', () => {
    try {
      navigator.clipboard.readText().then(txt => {
        if (!txt) return;
        const clips = load('clips', []);
        if (clips[0] !== txt) { clips.unshift(txt); save('clips', clips.slice(0, 50)); }
      }).catch(() => {});
    } catch (e) {}
  });
}
function renderClip() {
  const clips = load('clips', []);
  const el = $('#clip-list');
  if (!clips.length) { el.innerHTML = '<div class="empty">暂无记录，复制文字后自动出现</div>'; return; }
  el.innerHTML = clips.map((c, i) => `<div class="clip-item" onclick="copyClip(${i})" title="点击复制">${escapeHtml(shorten(c))}</div>`).join('');
}
function copyClip(i) {
  const clips = load('clips', []);
  navigator.clipboard.writeText(clips[i]).then(() => toast('已复制'));
}
function copyLast() {
  const clips = load('clips', []);
  if (clips.length) navigator.clipboard.writeText(clips[0]).then(() => toast('已复制最新一条'));
}
function clearClip() { if (confirm('清空剪贴板历史？')) { save('clips', []); renderClip(); } }

// ============ 4. 待办 ============
function addTodo() {
  const input = $('#todo-input');
  const text = input.value.trim();
  if (!text) return;
  const todos = load('todos', []);
  todos.push({ text, done: false });
  save('todos', todos);
  input.value = '';
  renderTodo();
}
function toggleTodo(i) {
  const todos = load('todos', []);
  todos[i].done = !todos[i].done;
  save('todos', todos);
  renderTodo();
}
function delTodo(i) {
  const todos = load('todos', []);
  todos.splice(i, 1);
  save('todos', todos);
  renderTodo();
}
function renderTodo() {
  const todos = load('todos', []);
  const el = $('#todo-list');
  if (!todos.length) { el.innerHTML = '<div class="empty">暂无待办</div>'; return; }
  el.innerHTML = todos.map((t, i) => `
    <div class="todo-item ${t.done ? 'done' : ''}">
      <input type="checkbox" ${t.done ? 'checked' : ''} onchange="toggleTodo(${i})">
      <span class="tt">${escapeHtml(t.text)}</span>
      <button class="del" onclick="delTodo(${i})">✕</button>
    </div>`).join('');
}

// ============ 5. 速算 & 换算 ============
function doConv() {
  const v = parseFloat($('#conv-val').value);
  const type = $('#conv-type').value;
  const el = $('#conv-result');
  if (isNaN(v)) { el.textContent = '—'; return; }
  const rate = {
    'cm-in': v / 2.54, 'in-cm': v * 2.54,
    'kg-lb': v * 2.2046, 'lb-kg': v / 2.2046,
    'c-f': v * 9 / 5 + 32, 'f-c': (v - 32) * 5 / 9,
    'km-mi': v / 1.609, 'mi-km': v * 1.609,
    'cny-usd': v / 7.2
  }[type];
  el.textContent = (v + ' → ' + rate.toFixed(4));
}
function doCalc() {
  const expr = $('#calc-input').value.trim();
  const el = $('#calc-result');
  if (!expr) { el.textContent = '—'; return; }
  try {
    if (!/^[0-9+\-*/().\s]+$/.test(expr)) throw new Error('非法字符');
    const r = Function('"use strict";return (' + expr + ')')();
    el.textContent = Number.isFinite(r) ? ('= ' + r) : '无法计算';
  } catch (e) { el.textContent = '表达式有误'; }
}

// ---------- 辅助 ----------
function escapeHtml(s) { return s.replace(/[&<>"']/g, c => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c])); }
function shorten(s, n = 60) { return s.length > n ? s.slice(0, n) + '…' : s; }
function fmtTime(t) {
  const d = new Date(t);
  return d.getFullYear() + '-' + String(d.getMonth()+1).padStart(2,'0') + '-' + String(d.getDate()).padStart(2,'0') + ' ' + String(d.getHours()).padStart(2,'0') + ':' + String(d.getMinutes()).padStart(2,'0');
}
function toast(msg) {
  let t = $('#toast');
  if (!t) { t = document.createElement('div'); t.id = 'toast';
    t.style.cssText = 'position:fixed;bottom:20px;left:50%;transform:translateX(-50%);background:#1f2329;color:#fff;padding:8px 16px;border-radius:8px;font-size:13px;z-index:999;transition:.3s;opacity:0;';
    document.body.appendChild(t);
  }
  t.textContent = msg; t.style.opacity = '1';
  clearTimeout(t._tm); t._tm = setTimeout(() => t.style.opacity = '0', 1500);
}

// ---------- 初始化 ----------
renderNotes();
renderTodo();
watchClipboard();
