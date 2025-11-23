# 🥚 Kubernetes Easter Egg Hunt
# Run this script to discover a surprise!

# Colors for fun output
function Write-ColorOutput {
    param(
        [string]$Message,
        [System.ConsoleColor]$ForegroundColor = [System.ConsoleColor]::White
    )
    $fc = $host.UI.RawUI.ForegroundColor
    $host.UI.RawUI.ForegroundColor = $ForegroundColor
    Write-Output $Message
    $host.UI.RawUI.ForegroundColor = $fc
}

Clear-Host

Write-ColorOutput -Message @"
K   K  U   U  B B   E E E E  R R R   N   N  E E E E  T T T  E E E E  SSS 
K  K   U   U  B  B  E        R   R   NN  N  E        T       E        S   
KKK    U   U  BBB   EEE      RRR     N N N  EEE      TTT     EEE      SSS 
K  K   U   U  B  B  E        R  R    N  NN  E        T       E           S
K   K   UUU   B B   E E E E  R   R   N   N  E E E E  T       E E E E  SSS 
"@ -ForegroundColor Cyan

Write-ColorOutput -Message "🎉 Congratulations! You found the Easter Egg! 🎉`n" -ForegroundColor Yellow

Start-Sleep -Seconds 1

Write-ColorOutput -Message "Checking cluster status..." -ForegroundColor Green
Start-Sleep -Milliseconds 500

Write-ColorOutput -Message "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Blue
Write-ColorOutput -Message "Pod Status:" -ForegroundColor White
Write-ColorOutput -Message "  ✅ All pods are running perfectly!" -ForegroundColor Green
Write-ColorOutput -Message "Node Status:" -ForegroundColor White
Write-ColorOutput -Message "  ✅ All nodes are healthy and ready!" -ForegroundColor Green
Write-ColorOutput -Message "Deployment Status:" -ForegroundColor White
Write-ColorOutput -Message "  ✅ All deployments are up-to-date!" -ForegroundColor Green
Write-ColorOutput -Message "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━`n" -ForegroundColor Blue

Start-Sleep -Seconds 1

Write-ColorOutput -Message "🐳 Here's a special message from your cluster:`n" -ForegroundColor Magenta

Write-ColorOutput -Message "    `"Containers may contain things," -ForegroundColor Cyan
Write-ColorOutput -Message "     but they'll never contain our spirits!`"`n" -ForegroundColor Cyan

Start-Sleep -Seconds 1

Write-ColorOutput -Message "💡 Fun Kubernetes Fact:" -ForegroundColor Yellow
$facts = @(
    "Kubernetes comes from the Greek word 'κυβερνήτης' meaning 'helmsman' or 'pilot'",
    "The original codename for Kubernetes was 'Project Seven' - named after Star Trek's Borg character Seven of Nine",
    "Kubernetes was originally designed by Google based on their internal system called 'Borg'",
    "The first version of Kubernetes was released in 2015, and it was 15,000+ lines of Go code",
    "The Kubernetes logo has 7 sides because of the 'Project Seven' reference"
)

$randomFact = $facts | Get-Random
Write-ColorOutput -Message "  $randomFact`n" -ForegroundColor White

Start-Sleep -Seconds 1

Write-ColorOutput -Message "🎁 Special Commands to Try:" -ForegroundColor Green
Write-ColorOutput -Message "  kubectl get pods --all-namespaces | grep -i egg" -ForegroundColor Cyan
Write-ColorOutput -Message "  kubectl describe node `$(hostname) | grep -i chocolate" -ForegroundColor Cyan
Write-ColorOutput -Message "  kubectl logs -n kube-system -l k8s-app=kube-proxy | tail -1`n" -ForegroundColor Cyan

Write-ColorOutput -Message "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Red
Write-ColorOutput -Message "         Have a wonderful day! 🌟" -ForegroundColor Yellow
Write-ColorOutput -Message "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━`n" -ForegroundColor Red

# Animated "deploying" message
$fc = $host.UI.RawUI.ForegroundColor
$host.UI.RawUI.ForegroundColor = [System.ConsoleColor]::Green
Write-Host -NoNewline "Deploying smiles"
for ($i = 1; $i -le 3; $i++) {
    Write-Host -NoNewline "."
    Start-Sleep -Milliseconds 300
}
Write-Host " ✅ Successfully deployed!`n"
$host.UI.RawUI.ForegroundColor = $fc

Write-ColorOutput -Message "💝 Made with ❤️  by the team" -ForegroundColor Magenta
Write-ColorOutput -Message "   Keep calm and kubectl on! 🚀`n" -ForegroundColor Cyan

