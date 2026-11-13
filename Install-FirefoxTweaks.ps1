#Requires -Version 5.1
# ============================================================
#  Установщик твиков Firefox (userChrome / userContent / user.js / AutoConfig)
#  Повторный запуск безопасен: блоки между маркерами заменяются, остальное
#  содержимое ваших файлов не трогается.
# ============================================================
$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [Text.Encoding]::UTF8
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$Utf8NoBom = New-Object Text.UTF8Encoding($false)

# ---------- CSS-блоки ----------

$CSS_FONT = @'
/* Размер обычных и контекстных меню */
menupopup > menu,
menupopup > menuitem,
menupopup .menu-text {
    font-size: __FONT__ !important;
}

/* Бургер-меню */
#appMenu-popup .subviewbutton,
#appMenu-popup .toolbarbutton-text,
#appMenu-popup label,
#appMenu-popup description {
    font-size: __FONT__ !important;
}

/* Остальные всплывающие панели */
panelview .subviewbutton,
panelview .toolbarbutton-text,
panelview label,
panelview description,
.panel-subview-footer-button {
    font-size: __FONT__ !important;
}

/* Панель вкладок */
#TabsToolbar .tab-text {
    font-size: __FONT__ !important;
}

/* Панель закладок */
#PersonalToolbar .toolbarbutton-text,
#PersonalToolbar menu,
#PersonalToolbar menuitem {
    font-size: __FONT__ !important;
}

/* Верхнее меню */
#toolbar-menubar menu,
#toolbar-menubar menuitem,
#toolbar-menubar .menubar-text {
    font-size: __FONT__ !important;
}
'@

$CSS_CONTAINER_LINE = @'
/* Линия цвета под вкладкой контейнера */
.tabbrowser-tab[usercontextid] .tab-context-line {
  display: none !important;
}
'@

$CSS_GROUP_TEXT = @'
/* Линия под вкладками группы */
tab-group .tab-group-line {
  height: 1px !important;
  opacity: 0.5 !important;
}

/* Контейнер и обёртка: растягиваются на всю высоту строки */
tab-group .tab-group-label-container {
  height: auto !important;
  min-height: 0 !important;
  align-self: stretch !important;
  padding: 0 !important;
  background: transparent !important;
  border-radius: 0 !important;
}

tab-group .tab-group-label-hover-highlight {
  flex: 1 1 auto !important;
  height: auto !important;
  min-height: 0 !important;
  padding: 0 !important;
  align-items: stretch !important;
  background: transparent !important;
  border-radius: 0 !important;
}

/* Ярлык: вся высота строки кликабельна, «таблетка» рисуется фоном */
tab-group .tab-group-label {
  --d: 24px;                 /* высота таблетки и диаметр круга */
  --c: var(--tab-group-color);

  flex: 1 1 auto !important;
  height: auto !important;
  min-height: 0 !important;
  width: auto !important;
  min-width: 32px !important;
  max-width: 100px !important;       /* ограничение ширины */
  margin: 0 2px !important;
  padding: 0 8px !important;        /* отступы текста от краёв */
  box-sizing: border-box !important;

  /* текст */
  display: block !important;
  align-content: center !important;  /* по центру по вертикали */
  font-size: 12px !important;
  color: var(--tab-group-color-invert) !important;
  text-align: center !important;
  white-space: nowrap !important;
  overflow: hidden !important;
  text-overflow: ellipsis !important;

  /* фон: левый круг + правый круг + прямоугольник между ними */
  border-radius: 0 !important;
  background-color: transparent !important;
  background-image:
    radial-gradient(circle at center, var(--c) calc(var(--d) / 2 - 1px), transparent calc(var(--d) / 2)),
    radial-gradient(circle at center, var(--c) calc(var(--d) / 2 - 1px), transparent calc(var(--d) / 2)),
    linear-gradient(var(--c), var(--c)) !important;
  background-size:
    var(--d) var(--d),
    var(--d) var(--d),
    calc(100% - var(--d)) var(--d) !important;
  background-position: left center, right center, center !important;
  background-repeat: no-repeat !important;
  opacity: 0.5 !important;
}

/* Группа без названия: просто круг, как раньше */
tab-group:not([label]) .tab-group-label,
tab-group[label=""] .tab-group-label,
tab-group[label="\200b"] .tab-group-label {
  --dot: 24px;   /* диаметр круга */

  width: 32px !important;
  min-width: 32px !important;
  max-width: 32px !important;
  padding: 0 !important;
  background-image: radial-gradient(
    circle at center,
    var(--tab-group-color) calc(var(--dot) / 2 - 1px),
    transparent calc(var(--dot) / 2)
  ) !important;
  background-size: auto !important;
  background-position: center !important;
}

/* Ярлык группы и его контейнер */
tab-group .tab-group-label-container,
tab-group .tab-group-label {
  border-bottom-width: 1px !important;
  box-shadow: none !important;
}

/* Псевдоэлементы, если линия нарисована ими */
tab-group .tab-group-label-container::before,
tab-group .tab-group-label-container::after,
tab-group .tab-group-label::before,
tab-group .tab-group-label::after {
  height: 1px !important;
  opacity: 0.5 !important;
}

/* Счётчик свёрнутой группы и линия под ним */
tab-group .tab-group-overflow-count-container,
tab-group .tab-group-overflow-count {
  border-bottom-width: 1px !important;
  box-shadow: none !important;
}

tab-group .tab-group-overflow-count-container::before,
tab-group .tab-group-overflow-count-container::after {
  height: 1px !important;
  opacity: 0.5 !important;
}
'@

$CSS_GROUP_NOTEXT = @'
/* Линия под вкладками группы */
tab-group .tab-group-line {
  height: 1px !important;
  opacity: 0.5 !important;
}

/* Контейнер и обёртка: растягиваются на всю высоту строки */
tab-group .tab-group-label-container {
  height: auto !important;
  min-height: 0 !important;
  align-self: stretch !important;
  padding: 0 !important;
  background: transparent !important;
  border-radius: 0 !important;
}

tab-group .tab-group-label-hover-highlight {
  flex: 1 1 auto !important;
  height: auto !important;
  min-height: 0 !important;
  padding: 0 !important;
  align-items: stretch !important;
  background: transparent !important;
  border-radius: 0 !important;
}

/* Ярлык: вся высота строки кликабельна, «таблетка» рисуется фоном */
tab-group .tab-group-label {
  --dot: 24px;   /* диаметр круга */
	
  font-size: 0 !important;
  width: 32px !important;
  min-width: 32px !important;
  max-width: 32px !important;
  flex: 1 1 auto !important;
  height: auto !important;
  min-height: 0 !important;
  padding: 0 !important;
  margin: 0 2px !important;
  border-radius: 0 !important;
  background-color: transparent !important;
  background-image: radial-gradient(
    circle at center,
    var(--tab-group-color) calc(var(--dot) / 2 - 1px),
    transparent calc(var(--dot) / 2)
  ) !important;
  background-repeat: no-repeat !important;
  opacity: 0.5 !important;
}

/* Ярлык группы и его контейнер */
tab-group .tab-group-label-container,
tab-group .tab-group-label {
  border-bottom-width: 1px !important;
  box-shadow: none !important;
}

/* Псевдоэлементы, если линия нарисована ими */
tab-group .tab-group-label-container::before,
tab-group .tab-group-label-container::after,
tab-group .tab-group-label::before,
tab-group .tab-group-label::after {
  height: 1px !important;
  opacity: 0.5 !important;
}

/* Счётчик свёрнутой группы и линия под ним */
tab-group .tab-group-overflow-count-container,
tab-group .tab-group-overflow-count {
  border-bottom-width: 1px !important;
  box-shadow: none !important;
}

tab-group .tab-group-overflow-count-container::before,
tab-group .tab-group-overflow-count-container::after {
  height: 1px !important;
  opacity: 0.5 !important;
}
'@

$CSS_HOME = @'
@-moz-document url("about:newtab"), url("about:home") {

  /* Убираем обводку при фокусе */
  #newtab-search-text:focus,
  #newtab-search-text:focus-visible {
    outline: none !important;
  }

  /* Скругляем и опускаем подсказки */
  .contentSearchSuggestionTable {
    border-radius: 12px !important;
    overflow: hidden !important;
    transform: translateY(8px) !important;
  }

  /* Скрыть все ярлыки кроме закрепленных */
  .top-site-outer:not(:has(.icon-pin-small)) {
    display: none !important;
  }
}
'@

$AUTOCONFIG_JS = @'
// AutoConfig loader for Tab Click Scroll to Top.
pref("general.config.filename", "tab-click-scroll-top.cfg");
pref("general.config.obscure_value", 0);
pref("general.config.sandbox_enabled", false);
'@

$CFG_NAME = 'tab-click-scroll-top.cfg'

# ---------- Вспомогательные функции ----------

function Write-Title($text) {
    Write-Host ""
    Write-Host $text -ForegroundColor Cyan
}

function Ask-YesNo($title, $desc, [bool]$default) {
    Write-Title $title
    Write-Host "  $desc" -ForegroundColor DarkGray
    $hint = if ($default) { '[Д/н]' } else { '[д/Н]' }
    while ($true) {
        $a = (Read-Host "  Применить? $hint").Trim().ToLower()
        if ($a -eq '') { return $default }
        if ($a -in 'д', 'да', 'y', 'yes') { return $true }
        if ($a -in 'н', 'нет', 'n', 'no') { return $false }
        Write-Host "  Введите д или н." -ForegroundColor Yellow
    }
}

function Ask-Choice($title, $desc, [string[]]$options, [int]$default) {
    Write-Title $title
    Write-Host "  $desc" -ForegroundColor DarkGray
    for ($i = 0; $i -lt $options.Count; $i++) {
        $mark = if (($i + 1) -eq $default) { ' (по умолчанию)' } else { '' }
        Write-Host ("  {0}) {1}{2}" -f ($i + 1), $options[$i], $mark)
    }
    while ($true) {
        $a = (Read-Host "  Ваш выбор").Trim()
        if ($a -eq '') { return $default }
        $n = 0
        if ([int]::TryParse($a, [ref]$n) -and $n -ge 1 -and $n -le $options.Count) { return $n }
        Write-Host "  Введите число от 1 до $($options.Count)." -ForegroundColor Yellow
    }
}

function Ask-FontSize($title, $desc, [int]$default) {
    Write-Title $title
    Write-Host "  $desc" -ForegroundColor DarkGray
    while ($true) {
        $a = (Read-Host "  Размер в px (Enter = $default, 0 = не менять)").Trim().ToLower() -replace 'px$', ''
        if ($a -eq '') { return $default }
        $n = 0
        if ([int]::TryParse($a, [ref]$n) -and ($n -eq 0 -or ($n -ge 8 -and $n -le 40))) { return $n }
        Write-Host "  Введите число от 8 до 40 (или 0)." -ForegroundColor Yellow
    }
}

# Вставляет/заменяет/удаляет наш блок между маркерами, остальное содержимое файла не трогает
function Set-Block([string]$path, [string]$content, [string]$begin, [string]$end) {
    $exists = Test-Path -LiteralPath $path
    if (-not $exists -and -not $content) { return }

    $text = ''
    if ($exists) { $text = [IO.File]::ReadAllText($path) }
    $pattern = '(?s)\r?\n?' + [regex]::Escape($begin) + '.*?' + [regex]::Escape($end) + '\r?\n?'
    $text = ([regex]::Replace($text, $pattern, '')).TrimEnd()

    if ($content) {
        $block = $begin + "`n" + $content.Trim() + "`n" + $end + "`n"
        if ($text) { $text = $text + "`n`n" + $block } else { $text = $block }
    }
    elseif ($text) { $text += "`n" }

    $dir = Split-Path -Parent $path
    if (-not (Test-Path -LiteralPath $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    [IO.File]::WriteAllText($path, $text, $Utf8NoBom)
}

function Get-FirefoxProfiles {
    $root = Join-Path $env:APPDATA 'Mozilla\Firefox'
    $ini = Join-Path $root 'profiles.ini'
    if (-not (Test-Path -LiteralPath $ini)) { return @() }

    $sections = [ordered]@{}
    $cur = $null
    foreach ($line in (Get-Content -LiteralPath $ini -Encoding UTF8)) {
        if ($line -match '^\[(.+)\]\s*$') { $cur = $Matches[1]; $sections[$cur] = @{}; continue }
        if ($cur -and $line -match '^([^=]+)=(.*)$') { $sections[$cur][$Matches[1].Trim()] = $Matches[2].Trim() }
    }

    $installDefaults = @()
    foreach ($k in $sections.Keys) {
        if ($k -like 'Install*' -and $sections[$k].ContainsKey('Default')) {
            $installDefaults += ($sections[$k]['Default'] -replace '/', '\')
        }
    }

    $result = @()
    foreach ($k in $sections.Keys) {
        if ($k -notlike 'Profile*') { continue }
        $s = $sections[$k]
        if (-not $s.ContainsKey('Path')) { continue }
        $p = $s['Path'] -replace '/', '\'
        $full = if ($s['IsRelative'] -eq '1') { Join-Path $root $p } else { $p }
        $isDef = ($installDefaults -contains $p) -or ($installDefaults.Count -eq 0 -and $s['Default'] -eq '1')
        $result += [pscustomobject]@{
            Name      = $s['Name']
            Path      = $full
            Leaf      = (Split-Path -Leaf $full)
            IsDefault = $isDef
        }
    }
    return $result
}

function Find-FirefoxDir {
    $cands = @(
        (Join-Path $env:ProgramFiles 'Mozilla Firefox'),
        (Join-Path ${env:ProgramFiles(x86)} 'Mozilla Firefox'),
        (Join-Path $env:LOCALAPPDATA 'Mozilla Firefox')
    ) | Where-Object { $_ -and (Test-Path -LiteralPath (Join-Path $_ 'firefox.exe')) }
    return @($cands)
}

function Test-Writable([string]$dir) {
    try {
        if (-not (Test-Path -LiteralPath $dir)) { return $false }
        $tmp = Join-Path $dir ('.w' + [guid]::NewGuid().ToString('N'))
        [IO.File]::WriteAllText($tmp, 'x')
        Remove-Item -LiteralPath $tmp -Force
        return $true
    }
    catch { return $false }
}

# ---------- Начало ----------

Clear-Host
Write-Host "==============================================" -ForegroundColor Green
Write-Host "   Установщик настроек Firefox" -ForegroundColor Green
Write-Host "==============================================" -ForegroundColor Green
Write-Host "Скрипт задаст несколько вопросов, потом покажет сводку"
Write-Host "и применит выбранное. Enter = значение по умолчанию."

# Firefox должен быть закрыт
if (Get-Process -Name firefox -ErrorAction SilentlyContinue) {
    Write-Host ""
    Write-Host "Firefox сейчас запущен. Закройте его, чтобы настройки применились корректно." -ForegroundColor Yellow
    Read-Host "Закройте Firefox и нажмите Enter"
    if (Get-Process -Name firefox -ErrorAction SilentlyContinue) {
        Write-Host "Firefox всё ещё запущен. Продолжаю, но перезапустить его придётся позже." -ForegroundColor Yellow
    }
}

# Выбор профиля
$profiles = @(Get-FirefoxProfiles)
if ($profiles.Count -eq 0) {
    Write-Host ""
    Write-Host "Не удалось найти профили Firefox (profiles.ini). Запустите Firefox хотя бы раз." -ForegroundColor Red
    return
}

$selProfile = $null
if ($profiles.Count -eq 1) {
    $selProfile = $profiles[0]
}
else {
    Write-Title "Выберите профиль Firefox"
    $defIdx = 1
    for ($i = 0; $i -lt $profiles.Count; $i++) {
        $p = $profiles[$i]
        $mark = ''
        if ($p.IsDefault) { $mark = ' (основной)'; $defIdx = $i + 1 }
        Write-Host ("  {0}) {1}{2}" -f ($i + 1), $p.Name, $mark)
        Write-Host ("     {0}" -f $p.Path) -ForegroundColor DarkGray
    }
    while (-not $selProfile) {
        $a = (Read-Host "  Номер профиля (Enter = $defIdx)").Trim()
        if ($a -eq '') { $a = "$defIdx" }
        $n = 0
        if ([int]::TryParse($a, [ref]$n) -and $n -ge 1 -and $n -le $profiles.Count) { $selProfile = $profiles[$n - 1] }
    }
}
Write-Host ""
Write-Host "Профиль: $($selProfile.Name)" -ForegroundColor Green
Write-Host "Путь:    $($selProfile.Path)" -ForegroundColor DarkGray

# ---------- Вопросы ----------

Write-Host ""
Write-Host "----- userChrome.css (интерфейс браузера) -----" -ForegroundColor Magenta

$fontSize = Ask-FontSize "Размер шрифта интерфейса" `
    "Меняет размер шрифта в меню, бургер-меню, панелях, панели вкладок и закладок, верхнем меню." 14

$disableContainerLine = Ask-YesNo "Отключить цветную линию у контейнеров" `
    "Убирает цветную линию под вкладками контейнеров (Multi-Account Containers)." $true

$groupMode = Ask-Choice "Вид ярлыка группы вкладок" `
    "Меняет оформление заголовка группы вкладок и линию под ней." `
    @("С текстом (таблетка с названием группы, до 100px)",
      "Без текста (только цветной кружок)",
      "Не менять") 2

Write-Host ""
Write-Host "----- userContent.css (внутренние страницы) -----" -ForegroundColor Magenta

$homeTweaks = Ask-YesNo "Улучшить домашнюю страницу" `
    "Убирает обводку у поиска, скругляет и опускает подсказки, прячет все ярлыки кроме закреплённых." $true

Write-Host ""
Write-Host "----- about:config (запишется в user.js) -----" -ForegroundColor Magenta

$prefDrag = Ask-YesNo "Отключить миниатюру при перетаскивании вкладки" `
    "nglayout.enable_drag_images = false" $true

$prefHandoff = Ask-YesNo "Поиск прямо на домашней странице" `
    "browser.newtabpage.activity-stream.improvesearch.handoffToAwesomebar = false`n  Поиск остаётся в поле на странице, а не уходит в адресную строку." $true

$prefMenuKey = Ask-YesNo "Убрать подчёркивание букв в меню" `
    "ui.key.menuAccessKey = 0" $true

Write-Host ""
Write-Host "----- AutoConfig-скрипт -----" -ForegroundColor Magenta

$installScript = Ask-YesNo "Tab Click Scroll to Top" `
    "Клик по активной вкладке прокручивает страницу наверх.`n  Нужны файлы: autoconfig.js (создаётся скриптом) и $CFG_NAME (положите рядом с установщиком).`n  Пишется в папку установки Firefox: может потребоваться запуск от имени администратора." $true

$ffDir = $null
$cfgSource = Join-Path $ScriptDir $CFG_NAME
if ($installScript) {
    if (-not (Test-Path -LiteralPath $cfgSource)) {
        Write-Host "  Файл $CFG_NAME не найден рядом со скриптом ($ScriptDir). Пункт пропущен." -ForegroundColor Yellow
        $installScript = $false
    }
    else {
        $found = @(Find-FirefoxDir)
        if ($found.Count -eq 1) { $ffDir = $found[0] }
        elseif ($found.Count -gt 1) {
            Write-Host "  Найдено несколько установок Firefox:" -ForegroundColor Yellow
            for ($i = 0; $i -lt $found.Count; $i++) { Write-Host ("  {0}) {1}" -f ($i + 1), $found[$i]) }
            while (-not $ffDir) {
                $n = 0
                [void][int]::TryParse((Read-Host "  Номер").Trim(), [ref]$n)
                if ($n -ge 1 -and $n -le $found.Count) { $ffDir = $found[$n - 1] }
            }
        }
        else {
            while (-not $ffDir) {
                $a = (Read-Host "  Папка установки Firefox не найдена. Укажите путь (где лежит firefox.exe), пусто = пропустить").Trim('" ')
                if ($a -eq '') { break }
                if (Test-Path -LiteralPath (Join-Path $a 'firefox.exe')) { $ffDir = $a }
            }
        }

        if ($ffDir -and -not (Test-Writable (Join-Path $ffDir 'defaults\pref'))) {
            Write-Host "  Нет прав на запись в $ffDir" -ForegroundColor Yellow
            Write-Host "  Запустите install.bat от имени администратора (ПКМ -> Запуск от имени администратора)." -ForegroundColor Yellow
            $ffDir = $null
        }
        if (-not $ffDir) { $installScript = $false; Write-Host "  Пункт пропущен." -ForegroundColor Yellow }
    }
}

# ---------- Сводка ----------

$cssFont = $null
if ($fontSize -gt 0) { $cssFont = $CSS_FONT.Replace('__FONT__', "$($fontSize)px") }
$chromeParts = @()
if ($cssFont) { $chromeParts += $cssFont }
if ($disableContainerLine) { $chromeParts += $CSS_CONTAINER_LINE }
if ($groupMode -eq 1) { $chromeParts += $CSS_GROUP_TEXT }
if ($groupMode -eq 2) { $chromeParts += $CSS_GROUP_NOTEXT }
$chromeCss = $chromeParts -join "`n`n"

$contentCss = if ($homeTweaks) { $CSS_HOME } else { '' }

$prefs = @()
if ($prefDrag) { $prefs += 'user_pref("nglayout.enable_drag_images", false);' }
if ($prefHandoff) { $prefs += 'user_pref("browser.newtabpage.activity-stream.improvesearch.handoffToAwesomebar", false);' }
if ($prefMenuKey) { $prefs += 'user_pref("ui.key.menuAccessKey", 0);' }
# Нужен для работы userChrome.css / userContent.css, пользователя об этом не спрашиваем
if ($chromeCss -or $contentCss) { $prefs += 'user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);' }
$userJs = $prefs -join "`n"

Write-Host ""
Write-Host "==============================================" -ForegroundColor Green
Write-Host "   Будет применено" -ForegroundColor Green
Write-Host "==============================================" -ForegroundColor Green
$groupNames = @{ 1 = 'с текстом'; 2 = 'без текста'; 3 = 'не менять' }
Write-Host ("  Размер шрифта интерфейса:    {0}" -f $(if ($fontSize -gt 0) { "$($fontSize)px" } else { 'не менять' }))
Write-Host ("  Линия у контейнеров:         {0}" -f $(if ($disableContainerLine) { 'отключить' } else { 'не менять' }))
Write-Host ("  Ярлык группы вкладок:        {0}" -f $groupNames[$groupMode])
Write-Host ("  Улучшенная домашняя:         {0}" -f $(if ($homeTweaks) { 'да' } else { 'нет' }))
Write-Host ("  Без миниатюры при drag:      {0}" -f $(if ($prefDrag) { 'да' } else { 'нет' }))
Write-Host ("  Поиск на домашней странице:  {0}" -f $(if ($prefHandoff) { 'да' } else { 'нет' }))
Write-Host ("  Без подчёркивания в меню:    {0}" -f $(if ($prefMenuKey) { 'да' } else { 'нет' }))
Write-Host ("  Tab Click Scroll to Top:     {0}" -f $(if ($installScript) { "да ($ffDir)" } else { 'нет' }))
Write-Host ""

$go = (Read-Host "Применить? [Д/н]").Trim().ToLower()
if ($go -in 'н', 'нет', 'n', 'no') { Write-Host "Отменено."; return }

# ---------- Применение ----------

$chromeDir = Join-Path $selProfile.Path 'chrome'
$cssBegin = '/* >>> firefox-tweaks begin >>> */'
$cssEnd = '/* <<< firefox-tweaks end <<< */'
$jsBegin = '// >>> firefox-tweaks begin >>>'
$jsEnd = '// <<< firefox-tweaks end <<<'

Write-Host ""
Set-Block (Join-Path $chromeDir 'userChrome.css') $chromeCss $cssBegin $cssEnd
Write-Host "  [OK] chrome\userChrome.css" -ForegroundColor Green

Set-Block (Join-Path $chromeDir 'userContent.css') $contentCss $cssBegin $cssEnd
Write-Host "  [OK] chrome\userContent.css" -ForegroundColor Green

Set-Block (Join-Path $selProfile.Path 'user.js') $userJs $jsBegin $jsEnd
Write-Host "  [OK] user.js" -ForegroundColor Green

if ($installScript) {
    try {
        $prefDir = Join-Path $ffDir 'defaults\pref'
        [IO.File]::WriteAllText((Join-Path $prefDir 'autoconfig.js'), $AUTOCONFIG_JS, $Utf8NoBom)
        Write-Host "  [OK] $prefDir\autoconfig.js" -ForegroundColor Green
        Copy-Item -LiteralPath $cfgSource -Destination (Join-Path $ffDir $CFG_NAME) -Force
        Write-Host "  [OK] $ffDir\$CFG_NAME" -ForegroundColor Green

        # Сбрасываем кэш запуска, чтобы Firefox подхватил новый cfg
        $cache = Join-Path $env:LOCALAPPDATA ("Mozilla\Firefox\Profiles\" + $selProfile.Leaf + "\startupCache")
        if (Test-Path -LiteralPath $cache) {
            Remove-Item -LiteralPath $cache -Recurse -Force -ErrorAction SilentlyContinue
            Write-Host "  [OK] кэш запуска очищен" -ForegroundColor Green
        }
    }
    catch {
        Write-Host "  [ОШИБКА] Не удалось записать файлы AutoConfig: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "  Запустите установщик от имени администратора." -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "Готово. Запустите Firefox, чтобы изменения вступили в силу." -ForegroundColor Green
