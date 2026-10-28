# ============================================================
#  小鲸鱼 · 桌面宠物 (最简版)
#  点一下，它就动一下。仅此而已。
# ============================================================

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$ErrorActionPreference = 'SilentlyContinue'

$script:PetSize = 140
$script:Dir = 1              # 1 向右, -1 向左
$script:Bounce = 0           # 弹跳动画帧(0=静止)
$script:Dragging = $false
$script:DragOff = $null
$script:Blinking = $false
$script:BlinkTimer = 0
$script:Frame = 0

# ---------- 窗体：透明、无边框、置顶 ----------
$form = New-Object System.Windows.Forms.Form
$form.Size = New-Object System.Drawing.Size($script:PetSize, $script:PetSize)
$form.StartPosition = 'Manual'
$form.FormBorderStyle = 'None'
$form.ShowInTaskbar = $false
$form.TopMost = $true
$form.BackColor = [System.Drawing.Color]::Magenta
$form.TransparencyKey = [System.Drawing.Color]::Magenta
$form.AllowTransparency = $true

$screen = [System.Windows.Forms.Screen]::PrimaryScreen.WorkingArea
$form.Location = New-Object System.Drawing.Point(($screen.Right - $script:PetSize - 60), ($screen.Bottom - $script:PetSize - 40))

# ---------- 绘制鲸鱼 ----------
function Draw-Whale([System.Drawing.Graphics]$g, [int]$w, [int]$h) {
    $g.SmoothingMode = 'AntiAlias'
    $cx = $w / 2
    $cy = $h / 2

    $g.TranslateTransform($cx, $cy)
    if ($script:Dir -lt 0) { $g.ScaleTransform(-1, 1) }
    $g.TranslateTransform(-$cx, -$cy)

    # 弹跳时整体上移
    $bob = 0
    if ($script:Bounce -gt 0) {
        $t = $script:Bounce / 12.0   # 12 帧弹跳周期
        $bob = -[Math]::Sin($t * [Math]::PI) * 22
    }

    # 尾巴
    $tail = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255,59,102,214))
    $g.FillPolygon($tail, @(
        (New-Object System.Drawing.PointF(($cx-52), ($cy+$bob-2))),
        (New-Object System.Drawing.PointF(($cx-78), ($cy+$bob-22))),
        (New-Object System.Drawing.PointF(($cx-70), ($cy+$bob+6))),
        (New-Object System.Drawing.PointF(($cx-52), ($cy+$bob+2)))
    ))

    # 身体
    $body = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255,79,125,249))
    $g.FillEllipse($body, $cx-58, $cy+$bob-48, 116, 92)

    # 高光
    $hl = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(40,255,255,255))
    $g.FillEllipse($hl, $cx-30, $cy+$bob-40, 56, 26)

    # 肚皮
    $belly = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255,238,244,255))
    $g.FillEllipse($belly, $cx-38, $cy+$bob-14, 72, 52)

    # 鱼鳍
    $g.FillPolygon($tail, @(
        (New-Object System.Drawing.PointF(($cx+26), ($cy+$bob+8))),
        (New-Object System.Drawing.PointF(($cx+46), ($cy+$bob-4))),
        (New-Object System.Drawing.PointF(($cx+46), ($cy+$bob+14))),
        (New-Object System.Drawing.PointF(($cx+28), ($cy+$bob+16)))
    ))

    # 眼睛
    $eye = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255,31,42,68))
    $white = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)
    if ($script:Blinking) {
        $pen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255,31,42,68), 2)
        $g.DrawArc($pen, $cx-34, $cy+$bob-8, 18, 12, 200, 140)
        $g.DrawArc($pen, $cx+16, $cy+$bob-8, 18, 12, 200, 140)
        $pen.Dispose()
    } else {
        $g.FillEllipse($eye, $cx-30, $cy+$bob-14, 14, 14)
        $g.FillEllipse($eye, $cx+18, $cy+$bob-14, 14, 14)
        $g.FillEllipse($white, $cx-27, $cy+$bob-16, 5, 5)
        $g.FillEllipse($white, $cx+21, $cy+$bob-16, 5, 5)
    }

    # 腮红
    $cheek = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(90,255,150,160))
    $g.FillEllipse($cheek, $cx-40, $cy+$bob+2, 14, 9)
    $g.FillEllipse($cheek, $cx+28, $cy+$bob+2, 14, 9)

    # 嘴巴
    $mp = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255,31,42,68), 2)
    if ($script:Bounce -gt 0) {
        # 点它时张嘴笑
        $g.DrawArc($mp, $cx-8, $cy+$bob+2, 16, 12, 20, 140)
    } else {
        $g.DrawArc($mp, $cx-5, $cy+$bob+6, 10, 8, 20, 140)
    }
    $mp.Dispose()

    # 喷水孔
    $hp = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255,59,102,214), 2)
    $g.DrawArc($hp, $cx-6, $cy+$bob-46, 12, 8, 200, 140)
    $hp.Dispose()

    # 释放
    $tail.Dispose(); $body.Dispose(); $hl.Dispose(); $belly.Dispose()
    $eye.Dispose(); $white.Dispose(); $cheek.Dispose()

    $g.ResetTransform()
}

$form.Add_Paint({ Draw-Whale $_.Graphics $form.Width $form.Height })

# ---------- 点击：动一下（弹跳 + 笑） ----------
$form.Add_Click({
    $script:Bounce = 12
})

# ---------- 拖动 ----------
$form.Add_MouseDown({
    param($s,$e)
    if ($e.Button -eq [System.Windows.Forms.MouseButtons]::Left) {
        $script:Dragging = $true
        $script:DragOff = New-Object System.Drawing.Point($e.X, $e.Y)
    }
})
$form.Add_MouseMove({
    param($s,$e)
    if ($script:Dragging) {
        $form.Location = New-Object System.Drawing.Point($form.Left + $e.X - $script:DragOff.X, $form.Top + $e.Y - $script:DragOff.Y)
    }
})
$form.Add_MouseUp({
    param($s,$e)
    $script:Dragging = $false
})

# ---------- 退出：右键菜单 ----------
$cms = New-Object System.Windows.Forms.ContextMenuStrip
$miQuit = New-Object System.Windows.Forms.ToolStripMenuItem('退出')
$miQuit.Add_Click({ $form.Close() })
$cms.Items.Add($miQuit) | Out-Null
$form.ContextMenuStrip = $cms

# ---------- 动画循环 ----------
$timer = New-Object System.Windows.Forms.Timer
$timer.Interval = 50
$timer.Add_Tick({
    $script:Frame++
    if ($script:Bounce -gt 0) { $script:Bounce-- }
    # 偶尔眨眼
    if ($script:BlinkTimer -gt 0) { $script:BlinkTimer--; $script:Blinking = $true }
    else {
        $script:Blinking = $false
        if ((Get-Random -Maximum 150) -eq 0) { $script:BlinkTimer = 3 }
    }
    $form.Invalidate()
})
$timer.Start()

[System.Windows.Forms.Application]::Run($form)
