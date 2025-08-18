# PowerShell setup script for Windows
# Get the local IP address (excluding loopback)
$HOST_IP = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -ne "127.0.0.1" -and $_.PrefixOrigin -eq "Dhcp" -or $_.PrefixOrigin -eq "Manual" } | Select-Object -First 1).IPAddress

if (-not $HOST_IP) {
    # Fallback method to get IP address
    $HOST_IP = (Get-WmiObject -Class Win32_NetworkAdapterConfiguration | Where-Object { $_.IPEnabled -eq $true -and $_.IPAddress[0] -ne "127.0.0.1" } | Select-Object -First 1).IPAddress[0]
}

if (-not $HOST_IP) {
    Write-Host "Warning: Could not determine host IP address. Using localhost."
    $HOST_IP = "localhost"
}

Write-Host "Using HOST_IP: $HOST_IP"

# Build Docker images
Write-Host "Building backend Docker image..."
docker build -t studentbackend --build-arg HOST_IP="$HOST_IP" -f ./backend/Dockerfile ./backend

Write-Host "Building frontend Docker image..."
docker build -t studentfrontend --build-arg HOST_IP="$HOST_IP" -f ./frontend/Dockerfile ./frontend

# Start services with docker-compose
Write-Host "Starting services with docker-compose..."
docker-compose -f docker-compose.yml up -d

# Open the application in default browser
Write-Host "Opening application in browser..."
Start-Process "http://localhost:80"
