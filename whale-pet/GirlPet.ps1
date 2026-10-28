# ============================================================
#  鲸鱼娘女仆 · 桌面宠物 (立绘版)
#  使用 AI 生成的 girl_alpha.png 透明立绘
#  点一下，她就跳一下。仅此而已。
# ============================================================

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$ErrorActionPreference = 'SilentlyContinue'

$script:PetSize = 190
$script:Bounce = 0
$script:Tilt = 0            # 点击时的倾斜角度
$script:Dragging = $false
$script:DragOff = $null
$script:Frame = 0

# ---------- 加载立绘 ----------
$imgPath = Join-Path $PSScriptRoot 'girl_alpha.png'
if (-not (Test-Path $imgPath)) { $imgPath = 'C:\Users\tongguangdong\WorkBuddy\2026-10-26-19-32-50\whale-pet\girl_alpha.png' }
$script:GirlImg = [System.Drawing.Image]::FromFile($imgPath)

# ---------- 窗体 ----------
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

# ---------- 绘制 ----------
$form.Add_Paint({
    $g = $_.Graphics
    $g.SmoothingMode = 'AntiAlias'
    $g.InterpolationMode = 'HighQualityBicubic'

    $size = $script:PetSize - 10
    $x = 5; $y = 5

    if ($script:Bounce -gt 0) {
        # 弹跳: 上移 + 轻微左右倾斜摆动
        $t = $script:Bounce / 12.0
        $lift = [Math]::Sin($t * [Math]::PI) * 22
        $tilt = [Math]::Sin($t * [Math]::PI * 2) * 6
        $y -= $lift

        $g.TranslateTransform($x + $size/2, $y + $size/2)
        $g.RotateTransform($tilt)
        $g.TranslateTransform(-($x + $size/2), -($y + $size/2))
    }

    # 落地阴影(弹跳时缩小)
    if ($script:Bounce -gt 0) {
        $t = $script:Bounce / 12.0
        $shadowW = $size * 0.5 * (1 - 0.3 * [Math]::Sin($t * [Math]::PI))
        $shadowBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(50, 40, 60, 90))
        $g.FillEllipse($shadowBrush, ($script:PetSize/2 - $shadowW/2), ($script:PetSize - 14), $shadowW, 8)
        $shadowBrush.Dispose()
    }

    $g.DrawImage($script:GirlImg, $x, $y, $size, $size)
    $g.ResetTransform()
})

# ---------- 点击动一下 ----------
$form.Add_Click({ $script:Bounce = 12 })

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
$form.Add_MouseUp({ param($s,$e) $script:Dragging = $false })

# ---------- 退出 ----------
$cms = New-Object System.Windows.Forms.ContextMenuStrip
$miQuit = New-Object System.Windows.Forms.ToolStripMenuItem('退出')
$miQuit.Add_Click({ $form.Close() })
$cms.Items.Add($miQuit) | Out-Null
$form.ContextMenuStrip = $cms

# ---------- 动画 ----------
$timer = New-Object System.Windows.Forms.Timer
$timer.Interval = 40
$timer.Add_Tick({
    $script:Frame++
    if ($script:Bounce -gt 0) { $script:Bounce-- }
    $form.Invalidate()
})
$timer.Start()

$form.Add_FormClosed({ $script:GirlImg.Dispose() })

[System.Windows.Forms.Application]::Run($form)
