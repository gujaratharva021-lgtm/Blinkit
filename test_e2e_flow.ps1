# End-to-end API test for the Blinkit clone backend.
# Runs: send-otp -> verify-otp -> browse products -> add to cart -> place order -> check orders -> tracking
# Usage: .\test_e2e_flow.ps1

$ErrorActionPreference = 'Stop'
$baseUrl = 'https://ecommerce-backend-dd4u.onrender.com/api/v1'
$phone = '9999999999'

function Write-Step($msg) {
    Write-Host "`n=== $msg ===" -ForegroundColor Cyan
}

# ---- Step 1: Send OTP ----
Write-Step "1. Sending OTP to $phone"
$sendResp = Invoke-RestMethod -Uri "$baseUrl/auth/send-otp" -Method POST -ContentType "application/json" -Body (@{ phone = $phone } | ConvertTo-Json)
$sendResp | ConvertTo-Json -Depth 5

# Try to find the OTP in the response (test-mode backends usually return it directly)
$otp = $null
foreach ($key in @('otp','test_otp','debug_otp')) {
    if ($sendResp.$key) { $otp = $sendResp.$key }
}
if (-not $otp) {
    Write-Host "Could not auto-detect OTP field in response above. Please check the JSON and enter it manually." -ForegroundColor Yellow
    $otp = Read-Host "Enter OTP"
}
Write-Host "Using OTP: $otp"

# ---- Step 2: Verify OTP ----
Write-Step "2. Verifying OTP"
$verifyResp = Invoke-RestMethod -Uri "$baseUrl/auth/verify-otp" -Method POST -ContentType "application/json" -Body (@{ phone = $phone; otp = $otp } | ConvertTo-Json)
$verifyResp | ConvertTo-Json -Depth 5

$token = $verifyResp.token
if (-not $token) {
    Write-Host "FAILED: No token returned. Stopping." -ForegroundColor Red
    exit 1
}
$headers = @{ Authorization = "Bearer $token"; "Content-Type" = "application/json" }
Write-Host "Token acquired." -ForegroundColor Green

# ---- Step 3: Browse products, pick a few (including newly seeded ones) ----
Write-Step "3. Fetching products"
$page1 = Invoke-RestMethod -Uri "$baseUrl/products/?limit=100&page=1" -Headers $headers
$allProducts = $page1.products
$totalPages = $page1.total_pages
for ($p = 2; $p -le $totalPages; $p++) {
    $pageData = Invoke-RestMethod -Uri "$baseUrl/products/?limit=100&page=$p" -Headers $headers
    $allProducts += $pageData.products
    Start-Sleep -Milliseconds 200
}
Write-Host "Total products fetched: $($allProducts.Count)"

$targets = @('Aashirvaad Atta', 'Chicken Breast', 'Watermelon')
$pickedProducts = $allProducts | Where-Object { $targets -contains $_.name }
if ($pickedProducts.Count -eq 0) {
    Write-Host "None of the target products found, picking first 3 available instead." -ForegroundColor Yellow
    $pickedProducts = $allProducts | Select-Object -First 3
}
$pickedProducts | Select-Object id, name, price, category_id | Format-Table

# ---- Step 4: Add to cart ----
Write-Step "4. Adding items to cart"
foreach ($prod in $pickedProducts) {
    $body = @{ product_id = $prod.id; quantity = 1 } | ConvertTo-Json
    $addResp = Invoke-RestMethod -Uri "$baseUrl/cart" -Method POST -Headers $headers -Body $body
    Write-Host "  Added: $($prod.name) (id $($prod.id))"
}

# ---- Step 5: View cart ----
Write-Step "5. Fetching cart"
$cart = Invoke-RestMethod -Uri "$baseUrl/cart" -Headers $headers
$cart | ConvertTo-Json -Depth 6

function Get-ErrorBody($errRecord) {
    if ($errRecord.ErrorDetails.Message) { return $errRecord.ErrorDetails.Message }
    if ($errRecord.Exception.Response) {
        try {
            $stream = $errRecord.Exception.Response.GetResponseStream()
            $reader = New-Object System.IO.StreamReader($stream)
            return $reader.ReadToEnd()
        } catch { return "(could not read response body: $($_.Exception.Message))" }
    }
    return $errRecord.Exception.Message
}

# ---- Step 6: Create an address, then checkout ----
Write-Step "6a. Creating address"
$addressBody = @{
    full_name    = "Test User"
    line1        = "221B Test Lane"
    line2        = ""
    city         = "Mumbai"
    state        = "Maharashtra"
    pincode      = "400001"
    phone        = $phone
    landmark     = "Near Test Landmark"
    latitude     = 19.0760
    longitude    = 72.8777
    type         = "home"
} | ConvertTo-Json

$addressId = $null
try {
    $addressResp = Invoke-RestMethod -Uri "$baseUrl/addresses" -Method POST -Headers $headers -Body $addressBody
    $addressResp | ConvertTo-Json -Depth 6
    $addressId = $addressResp.id
    if (-not $addressId -and $addressResp.address) { $addressId = $addressResp.address.id }
} catch {
    Write-Host "Address creation failed: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Server said:" (Get-ErrorBody $_) -ForegroundColor Red
}

$orderResp = $null
if ($addressId) {
    Write-Step "6b. Checking out with address_id $addressId"
    $checkoutBody = @{ address_id = $addressId; payment_method = "online" } | ConvertTo-Json
    try {
        $orderResp = Invoke-RestMethod -Uri "$baseUrl/orders/checkout" -Method POST -Headers $headers -Body $checkoutBody
        $orderResp | ConvertTo-Json -Depth 6
    } catch {
        Write-Host "Checkout failed: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "Server said:" (Get-ErrorBody $_) -ForegroundColor Red
    }
} else {
    Write-Host "No address_id available; skipping checkout." -ForegroundColor Yellow
}

$orderId = $null
if ($orderResp) {
    $orderId = $orderResp.id
    if (-not $orderId -and $orderResp.order) { $orderId = $orderResp.order.id }
    if (-not $orderId -and $orderResp.order_id) { $orderId = $orderResp.order_id }
}

# ---- Step 7: Fetch orders list ----
Write-Step "7. Fetching order history"
$orders = Invoke-RestMethod -Uri "$baseUrl/orders?page=1&limit=10" -Headers $headers
$orders.orders | Select-Object id, status, total_amount, created_at | Format-Table

# ---- Step 8: Order tracking (if we have an order id) ----
if ($orderId) {
    Write-Step "8. Fetching tracking for order $orderId"
    try {
        $tracking = Invoke-RestMethod -Uri "$baseUrl/orders/$orderId/tracking" -Headers $headers
        $tracking | ConvertTo-Json -Depth 6
    } catch {
        Write-Host "Tracking fetch failed: $($_.Exception.Message)" -ForegroundColor Yellow
    }
} else {
    Write-Host "Could not determine order id from place-order response; skipping tracking check." -ForegroundColor Yellow
}

Write-Step "DONE - End-to-end flow complete"
