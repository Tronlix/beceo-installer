Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# ── Theme ──────────────────────────────────────────────
$BG      = [System.Drawing.Color]::FromArgb(18, 18, 24)
$CARD    = [System.Drawing.Color]::FromArgb(30, 30, 40)
$ACCENT  = [System.Drawing.Color]::FromArgb(99, 102, 241)
$FG      = [System.Drawing.Color]::White
$MUTED   = [System.Drawing.Color]::FromArgb(160, 160, 180)
$INPUT_BG= [System.Drawing.Color]::FromArgb(40, 40, 55)

function New-Label($text, $x, $y, $w=360, $h=20, $color=$FG, $size=10) {
    $l = New-Object System.Windows.Forms.Label
    $l.Text = $text; $l.Location = [System.Drawing.Point]::new($x,$y)
    $l.Size = [System.Drawing.Size]::new($w,$h)
    $l.ForeColor = $color; $l.BackColor = [System.Drawing.Color]::Transparent
    $l.Font = New-Object System.Drawing.Font("Segoe UI", $size)
    return $l
}

function New-TextBox($x, $y, $w=360, $password=$false) {
    $t = New-Object System.Windows.Forms.TextBox
    $t.Location = [System.Drawing.Point]::new($x,$y)
    $t.Size = [System.Drawing.Size]::new($w, 32)
    $t.BackColor = $INPUT_BG; $t.ForeColor = $FG
    $t.BorderStyle = "FixedSingle"
    $t.Font = New-Object System.Drawing.Font("Segoe UI", 10)
    if ($password) { $t.PasswordChar = '●' }
    return $t
}

function New-Button($text, $x, $y, $w=120, $primary=$true) {
    $b = New-Object System.Windows.Forms.Button
    $b.Text = $text; $b.Location = [System.Drawing.Point]::new($x,$y)
    $b.Size = [System.Drawing.Size]::new($w, 36)
    $b.FlatStyle = "Flat"
    $b.FlatAppearance.BorderSize = 0
    $b.BackColor = if ($primary) { $ACCENT } else { $CARD }
    $b.ForeColor = $FG
    $b.Font = New-Object System.Drawing.Font("Segoe UI Semibold", 10)
    $b.Cursor = [System.Windows.Forms.Cursors]::Hand
    return $b
}

# ── Pages ──────────────────────────────────────────────
$answers = @{ apiKey=""; agentName=""; role=""; botToken="" }
$page = 0

$pages = @(
    @{
        title   = "Welcome to BeCEO 🎯"
        subtitle= "Let's get you set up in a few steps."
        fields  = @()
        next    = "Get Started"
    },
    @{
        title   = "Step 1 — API Key"
        subtitle= "Enter your BeCEO API key."
        fields  = @(@{ label="API Key"; key="apiKey"; password=$true; hint="Starts with sk-..." })
        next    = "Next"
    },
    @{
        title   = "Step 2 — Agent Name"
        subtitle= "What should your AI assistant be called?"
        fields  = @(@{ label="Agent Name"; key="agentName"; password=$false; hint='e.g. "Max"' })
        next    = "Next"
    },
    @{
        title   = "Step 3 — Role"
        subtitle= "Choose a role for your agent."
        fields  = @(@{ label="Role (research/tech/admin/custom)"; key="role"; password=$false; hint="research" })
        next    = "Next"
    },
    @{
        title   = "Step 4 — Telegram Bot"
        subtitle= "Create a bot via @BotFather and paste the token below."
        fields  = @(@{ label="Telegram Bot Token"; key="botToken"; password=$false; hint="123456:ABC-DEF..." })
        next    = "Finish"
    }
)

# ── Main Form ──────────────────────────────────────────
$form = New-Object System.Windows.Forms.Form
$form.Text = "BeCEO Setup"
$form.Size = [System.Drawing.Size]::new(460, 360)
$form.StartPosition = "CenterScreen"
$form.BackColor = $BG
$form.FormBorderStyle = "FixedDialog"
$form.MaximizeBox = $false

# Header bar
$header = New-Object System.Windows.Forms.Panel
$header.Size = [System.Drawing.Size]::new(460, 60)
$header.BackColor = $CARD
$form.Controls.Add($header)

$lblTitle = New-Label "BeCEO Setup" 20 18 300 30 $FG 13
$lblTitle.Font = New-Object System.Drawing.Font("Segoe UI Semibold", 13)
$header.Controls.Add($lblTitle)

# Content panel
$content = New-Object System.Windows.Forms.Panel
$content.Location = [System.Drawing.Point]::new(0, 60)
$content.Size = [System.Drawing.Size]::new(460, 240)
$content.BackColor = $BG
$form.Controls.Add($content)

# Footer
$footer = New-Object System.Windows.Forms.Panel
$footer.Location = [System.Drawing.Point]::new(0, 300)
$footer.Size = [System.Drawing.Size]::new(460, 55)
$footer.BackColor = $CARD
$form.Controls.Add($footer)

$btnBack = New-Button "Back" 20 10 100 $false
$btnNext = New-Button "Next" 330 10 110 $true
$footer.Controls.Add($btnBack)
$footer.Controls.Add($btnNext)

$currentInput = $null

function Render-Page {
    $content.Controls.Clear()
    $p = $pages[$script:page]

    $content.Controls.Add((New-Label $p.title 30 20 400 30 $FG 13))
    $content.Controls.Add((New-Label $p.subtitle 30 52 400 20 $MUTED 9))

    $script:currentInput = $null
    if ($p.fields.Count -gt 0) {
        $f = $p.fields[0]
        $content.Controls.Add((New-Label $f.label 30 95 400 18 $MUTED 9))
        $tb = New-TextBox 30 115 390 $f.password
        if ($answers[$f.key]) { $tb.Text = $answers[$f.key] }
        $tb.Add_KeyDown({ if ($_.KeyCode -eq "Return") { $btnNext.PerformClick() } })
        $content.Controls.Add($tb)
        $content.Controls.Add((New-Label $f.hint 30 150 400 18 $MUTED 8))
        $script:currentInput = @{ tb=$tb; key=$f.key }
        $form.ActiveControl = $tb
    }

    $btnNext.Text = $p.next
    $btnBack.Visible = ($script:page -gt 0)
}

$btnNext.Add_Click({
    if ($script:currentInput) {
        $val = $script:currentInput.tb.Text.Trim()
        if (-not $val) {
            [System.Windows.Forms.MessageBox]::Show("Please fill in this field.", "BeCEO Setup", "OK", "Warning") | Out-Null
            return
        }
        $answers[$script:currentInput.key] = $val
    }
    if ($script:page -ge ($pages.Count - 1)) {
        $form.Tag = "done"
        $form.Close()
    } else {
        $script:page++
        Render-Page
    }
})

$btnBack.Add_Click({
    if ($script:page -gt 0) { $script:page--; Render-Page }
})

Render-Page
$form.ShowDialog() | Out-Null

if ($form.Tag -ne "done") { exit 0 }

# ── Run beceo setup with answers piped in ──────────────
$input = "$($answers.apiKey)`n$($answers.agentName)`n$($answers.role)`n$($answers.botToken)`n"
$input | beceo setup
