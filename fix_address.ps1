$path = "C:\Users\ABC\Downloads\Blinkit-main\Blinkit-main\lib\screens\address_screen.dart"
$raw = [System.IO.File]::ReadAllText($path)
$content = $raw -replace "`r`n", "`n"

function NormalizeLF($s) { $s -replace "`r`n", "`n" }

# 1. Add import
$old1 = "import '../services/location_service.dart';"
$new1 = "import '../services/location_service.dart';`nimport 'location_picker_screen.dart';"
if ($content.Contains($old1)) { $content = $content.Replace($old1, $new1); Write-Host "Edit 1: SUCCESS" } else { Write-Host "Edit 1: FAILED" }

# 2. Add buildingController
$old2 = "    final phoneController = TextEditingController(text: existing?['phone'] ?? '');"
$new2 = "    final phoneController = TextEditingController(text: existing?['phone'] ?? '');`n    final buildingController = TextEditingController(text: existing?['building'] ?? '');"
if ($content.Contains($old2)) { $content = $content.Replace($old2, $new2); Write-Host "Edit 2: SUCCESS" } else { Write-Host "Edit 2: FAILED" }

# 3. Replace form fields block
$old3 = NormalizeLF(@"
                  _buildTextField(nameController, 'Full Name', Icons.person_outline),
                  const SizedBox(height: 12),
                  _buildTextField(phoneController, 'Phone Number', Icons.phone_outlined,
                      keyboardType: TextInputType.phone),
                  const SizedBox(height: 12),
                  _buildTextField(addressController, 'Flat, Street, Area',
                      Icons.location_on_outlined, maxLines: 2),
                  const SizedBox(height: 12),
                  _buildTextField(cityController, 'City, State, Pincode',
                      Icons.location_city_outlined),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: isLocatingModal
                            ? null
                            : () async {
                                setModalState(() {
                                  isLocatingModal = true;
                                  locationErrorModal = null;
                                });
                                try {
                                  final result = await LocationService.getCurrentLocation();
                                  setModalState(() {
                                    capturedLat = result.latitude;
                                    capturedLng = result.longitude;
                                    isLocatingModal = false;
                                  });
                                } catch (e) {
                                  setModalState(() {
                                    locationErrorModal = e.toString().replaceFirst('Exception: ', '');
                                    isLocatingModal = false;
                                  });
                                }
                              },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.my_location, size: 14, color: Color(0xFF0C831F)),
                              const SizedBox(width: 6),
                              Text(
                                isLocatingModal ? 'Locating...' : 'Use my current location',
                                style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF0C831F)),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (capturedLat != null && capturedLng != null) ...[
                        const SizedBox(width: 8),
                        Text('Location captured',
                            style: GoogleFonts.poppins(fontSize: 11, color: Colors.green)),
                      ],
                    ],
                  ),
                  if (locationErrorModal != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(locationErrorModal!,
                          style: GoogleFonts.poppins(fontSize: 11, color: Colors.red)),
                    ),
                  const SizedBox(height: 24),
"@)

$new3 = NormalizeLF(@"
                  _buildTextField(buildingController, 'Building & Block No. (Optional)',
                      Icons.home_outlined),
                  const SizedBox(height: 12),
                  _buildTextField(addressController, 'House No. & Floor',
                      Icons.apartment_outlined),
                  const SizedBox(height: 12),
                  _buildTextField(cityController, 'City, State, Pincode',
                      Icons.location_city_outlined),
                  const SizedBox(height: 12),
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          final picked = await Navigator.push<PickedLocation>(
                            context,
                            MaterialPageRoute(
                              builder: (_) => LocationPickerScreen(
                                initialLat: capturedLat,
                                initialLng: capturedLng,
                              ),
                            ),
                          );
                          if (picked != null) {
                            setModalState(() {
                              capturedLat = picked.lat;
                              capturedLng = picked.lng;
                              if (picked.streetLine.isNotEmpty) {
                                addressController.text = picked.streetLine;
                              }
                              if (picked.cityLine.isNotEmpty) {
                                cityController.text = picked.cityLine;
                              }
                              locationErrorModal = null;
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.map_outlined, size: 14, color: Color(0xFF0C831F)),
                              const SizedBox(width: 6),
                              Text(
                                'Select on map',
                                style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF0C831F)),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (capturedLat != null && capturedLng != null)
                        Text('Location captured',
                            style: GoogleFonts.poppins(fontSize: 11, color: Colors.green)),
                    ],
                  ),
                  if (locationErrorModal != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(locationErrorModal!,
                          style: GoogleFonts.poppins(fontSize: 11, color: Colors.red)),
                    ),
                  const SizedBox(height: 20),
                  Text('Receiver details',
                      style: GoogleFonts.poppins(
                          fontSize: 15, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _buildTextField(nameController, "Receiver's Name", Icons.person_outline),
                  const SizedBox(height: 12),
                  _buildTextField(phoneController, "Receiver's Phone Number",
                      Icons.phone_outlined, keyboardType: TextInputType.phone),
                  const SizedBox(height: 24),
"@)

if ($content.Contains($old3)) { $content = $content.Replace($old3, $new3); Write-Host "Edit 3: SUCCESS" } else { Write-Host "Edit 3: FAILED" }

# 4. Add 'building' key
$old4 = "                              'address': addressController.text,"
$new4 = "                              'address': addressController.text,`n                              'building': buildingController.text,"
if ($content.Contains($old4)) { $content = $content.Replace($old4, $new4); Write-Host "Edit 4: SUCCESS" } else { Write-Host "Edit 4: FAILED" }

$content = $content -replace "`n", "`r`n"
$utf8NoBom = New-Object System.Text.UTF8Encoding $false
[System.IO.File]::WriteAllText($path, $content, $utf8NoBom)
Write-Host "File written successfully."