# ===== FUNCTIONS =====

function GetIp
{
  curl -s ifconfig.me
}

function GetDate
{
  date -format 'yyyy-MM-ddTHH-mm-ss'
}

function IsIpAddress
{
    param(
        [parameter(mandatory = $true)]
        $string
    )

    #EXPL-1-
    $string -match "^(?:[0-9]{1,3}\.){3}[0-9]{1,3}$"
}

# ===== WORK =====

# Set vars with dummy values in case they were set outside of script
$startTime = "0"
$endTime = "0"
$lastIp = "0"
$historyInfo = "STARTUP"

# Initialize Task Bar icon
## https://www.reddit.com/r/PowerShell/comments/77gl4t/comment/dolnpey/
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
$objNotifyIcon = New-Object System.Windows.Forms.NotifyIcon
$objNotifyIcon.Icon = "$(pwd)/icon.ico"
$objNotifyIcon.Visible = $true

for ($i = 0 ; $i -le 10 ; $i++)
{
  $currentIp = GetIp

  # Check that fetching address succeeded
  while (-not(IsIpAddress $currentIp))
  {
    echo "CANNOT RETRIEVE IP (time: $(GetDate))"
    $currentIp = GetIp
  }

  # Set Message about current IP address
  $ipInfo = "IP: $currentIp ($i)"

  # Check if current IP address has changed since last poll
  if ($lastIp -eq $currentIp)
  {
    $historyInfo = "Same IP since $startTime"
  }
  else
  {
    $previousIp = "Previous IP was $lastIp"
    $startTime = GetDate
  }

  # Send Task Bar Message
  $objNotifyIcon.Text = "$ipInfo | $historyInfo | $previousIp"

  # Backup current IP info for next poll
  $lastIp = $currentIp

  sleep 5
}
