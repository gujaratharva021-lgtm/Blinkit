# Run this script from the folder that CONTAINS "lib" (e.g. Blinkit-main\Blinkit-main)
# It updates/creates 7 files:
#  - GST double-tap fix (add_edit_gst_screen.dart)
#  - Profile avatar: removes camera/gallery upload, adds preset avatar picker

$ErrorActionPreference = "Stop"

if (-not (Test-Path "lib")) {
    Write-Host "ERROR: 'lib' folder not found. Run this script from the folder that contains 'lib'." -ForegroundColor Red
    exit 1
}

function Write-File($Path, $Content) {
    $dir = Split-Path $Path
    if ($dir -and -not (Test-Path $dir)) {
        New-Item -ItemType Directory -Force -Path $dir | Out-Null
    }
    Set-Content -Path $Path -Value $Content -Encoding UTF8
    Write-Host "Updated $Path" -ForegroundColor Green
}

# ---------------------------------------------------------------------------
# 1) GST double-tap guard fix
# ---------------------------------------------------------------------------
Write-File "lib/features/gst_details/presentation/screens/add_edit_gst_screen.dart" @'
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/validators/validators.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../domain/entities/gst_entity.dart';
import '../providers/gst_provider.dart';

class AddEditGstScreen extends StatefulWidget {
  final GstEntity? existing;

  const AddEditGstScreen({super.key, this.existing});

  @override
  State<AddEditGstScreen> createState() => _AddEditGstScreenState();
}

class _AddEditGstScreenState extends State<AddEditGstScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _gstNumber;
  late final TextEditingController _businessName;
  late final TextEditingController _businessAddress;

  bool _isSubmitting = false;

  bool get isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _gstNumber = TextEditingController(text: e?.gstNumber ?? '');
    _businessName = TextEditingController(text: e?.businessName ?? '');
    _businessAddress = TextEditingController(text: e?.businessAddress ?? '');
  }

  @override
  void dispose() {
    _gstNumber.dispose();
    _businessName.dispose();
    _businessAddress.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    // Guard against a fast double-tap firing this twice before the
    // isSaving-driven rebuild has a chance to disable the button.
    if (_isSubmitting) return;
    _isSubmitting = true;

    if (!_formKey.currentState!.validate()) {
      _isSubmitting = false;
      return;
    }

    final provider = context.read<GstProvider>();
    final entity = GstEntity(
      id: widget.existing?.id ?? const Uuid().v4(),
      gstNumber: _gstNumber.text.trim().toUpperCase(),
      businessName: _businessName.text.trim(),
      businessAddress: _businessAddress.text.trim(),
    );

    final ok = isEditing
        ? await provider.updateGst(entity)
        : await provider.addGst(entity);

    _isSubmitting = false;
    if (!mounted) return;
    if (ok) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not save GST details. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSaving = context.watch<GstProvider>().isSaving;

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit GST Details' : 'Add GST Details')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            CustomTextField(
              controller: _gstNumber,
              label: 'GST Number',
              maxLength: 15,
              autoValidate: true,
              inputFormatters: [
                UpperCaseTextFormatter(),
                LengthLimitingTextInputFormatter(15),
              ],
              validator: Validators.gstNumber,
            ),
            const SizedBox(height: 14),
            CustomTextField(
              controller: _businessName,
              label: 'Business Name',
              autoValidate: true,
              validator: (v) => Validators.required(v, field: 'Business name'),
            ),
            const SizedBox(height: 14),
            CustomTextField(
              controller: _businessAddress,
              label: 'Business Address',
              maxLines: 3,
              autoValidate: true,
              validator: (v) => Validators.required(v, field: 'Business address'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: isSaving ? null : _submit,
              child: isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : Text(isEditing ? 'Save Changes' : 'Save GST Details'),
            ),
          ],
        ),
      ),
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}
'@

# ---------------------------------------------------------------------------
# 2) UserProfileModel: avatarPath (file) -> avatarId (preset)
# ---------------------------------------------------------------------------
Write-File "lib/data/models/user_profile_model.dart" @'
class UserProfileModel {
  final String name;
  final String email;
  final String phone;
  final String gender;
  final DateTime? dob;
  final String? avatarId;

  UserProfileModel({
    required this.name,
    required this.email,
    required this.phone,
    required this.gender,
    this.dob,
    this.avatarId,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      gender: json['gender'] ?? 'Not specified',
      dob: json['dob'] != null ? DateTime.tryParse(json['dob']) : null,
      avatarId: json['avatarId'] ?? json['avatarPath'],
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'phone': phone,
        'gender': gender,
        'dob': dob?.toIso8601String(),
        'avatarId': avatarId,
      };

  UserProfileModel copyWith({
    String? name,
    String? email,
    String? phone,
    String? gender,
    DateTime? dob,
    String? avatarId,
  }) {
    return UserProfileModel(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      gender: gender ?? this.gender,
      dob: dob ?? this.dob,
      avatarId: avatarId ?? this.avatarId,
    );
  }
}
'@

# ---------------------------------------------------------------------------
# 3) New: preset avatar catalog + display widget
# ---------------------------------------------------------------------------
Write-File "lib/core/avatar/avatar_catalog.dart" @'
import 'package:flutter/material.dart';

/// One selectable preset avatar: an icon on a coloured background.
class AvatarOption {
  final String id;
  final IconData icon;
  final Color color;

  const AvatarOption(this.id, this.icon, this.color);
}

/// The fixed set of avatar "types" a user can pick from.
/// No photo upload -- just pick one of these.
const List<AvatarOption> kAvatarOptions = [
  AvatarOption('avatar_leaf', Icons.eco, Color(0xFF0C831F)),
  AvatarOption('avatar_star', Icons.star, Color(0xFFFFA000)),
  AvatarOption('avatar_pet', Icons.pets, Color(0xFF6D4C41)),
  AvatarOption('avatar_sport', Icons.sports_soccer, Color(0xFF1976D2)),
  AvatarOption('avatar_music', Icons.music_note, Color(0xFF8E24AA)),
  AvatarOption('avatar_food', Icons.local_pizza, Color(0xFFE64A19)),
  AvatarOption('avatar_travel', Icons.flight, Color(0xFF00838F)),
  AvatarOption('avatar_game', Icons.sports_esports, Color(0xFFC2185B)),
  AvatarOption('avatar_smile', Icons.emoji_emotions, Color(0xFFFBC02D)),
  AvatarOption('avatar_robot', Icons.smart_toy, Color(0xFF455A64)),
];

AvatarOption? findAvatarOption(String? id) {
  if (id == null) return null;
  for (final option in kAvatarOptions) {
    if (option.id == id) return option;
  }
  return null;
}

/// Renders the user's chosen preset avatar, or an initial-letter fallback
/// (green circle with the first letter of [fallbackName]) if none is set.
class AvatarDisplay extends StatelessWidget {
  final String? avatarId;
  final String fallbackName;
  final double radius;

  const AvatarDisplay({
    super.key,
    required this.avatarId,
    required this.fallbackName,
    this.radius = 42,
  });

  @override
  Widget build(BuildContext context) {
    final option = findAvatarOption(avatarId);
    if (option != null) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: option.color,
        child: Icon(option.icon, color: Colors.white, size: radius),
      );
    }
    final scheme = Theme.of(context).colorScheme;
    return CircleAvatar(
      radius: radius,
      backgroundColor: scheme.surfaceContainerHighest,
      child: Text(
        fallbackName.isNotEmpty ? fallbackName[0].toUpperCase() : 'U',
        style: TextStyle(
          fontSize: radius * 0.8,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF0C831F),
        ),
      ),
    );
  }
}
'@

# ---------------------------------------------------------------------------
# 4) Avatar picker: preset grid instead of camera/gallery
# ---------------------------------------------------------------------------
Write-File "lib/widgets/avatar_picker_sheet.dart" @'
import 'package:flutter/material.dart';
import '../core/avatar/avatar_catalog.dart';

const Color kGreen = Color(0xFF0C831F);

/// Bottom sheet offering a grid of preset avatar "types" to choose from.
/// No camera/gallery upload -- returns the chosen avatar id, or null if
/// the user cancels without picking anything.
class AvatarPickerSheet {
  static Future<String?> show(BuildContext context, {String? currentAvatarId}) async {
    return showModalBottomSheet<String?>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Text(
                'Choose an avatar',
                style: Theme.of(ctx)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: 5,
                shrinkWrap: true,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                physics: const NeverScrollableScrollPhysics(),
                children: kAvatarOptions.map((option) {
                  final selected = option.id == currentAvatarId;
                  return GestureDetector(
                    onTap: () => Navigator.pop(ctx, option.id),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: selected
                            ? Border.all(color: kGreen, width: 3)
                            : null,
                      ),
                      padding: const EdgeInsets.all(2),
                      child: CircleAvatar(
                        backgroundColor: option.color,
                        child: Icon(option.icon, color: Colors.white),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pop(ctx, null),
                child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
'@

# ---------------------------------------------------------------------------
# 5) ProfileProvider: avatarId instead of File
# ---------------------------------------------------------------------------
Write-File "lib/providers/profile_provider.dart" @'
import 'package:flutter/material.dart';
import '../data/models/user_profile_model.dart';
import '../data/repositories/profile_repository.dart';

enum ProfileStatus { idle, loading, success, error }

class ProfileProvider extends ChangeNotifier {
  final ProfileRepository _repo = ProfileRepository();

  UserProfileModel? profile;
  ProfileStatus status = ProfileStatus.idle;
  String? errorMessage;
  String? pendingAvatarId;

  Future<void> load() async {
    status = ProfileStatus.loading;
    notifyListeners();
    profile = await _repo.fetchProfile();
    pendingAvatarId = profile?.avatarId;
    status = ProfileStatus.idle;
    notifyListeners();
  }

  void setPendingAvatar(String avatarId) {
    pendingAvatarId = avatarId;
    notifyListeners();
  }

  String? validateName(String value) {
    if (value.trim().isEmpty) return 'Name cannot be empty';
    if (value.trim().length < 2) return 'Name is too short';
    return null;
  }

  String? validateEmail(String value) {
    if (value.trim().isEmpty) return 'Email cannot be empty';
    final regex = RegExp(r'^[\w\.\-]+@[\w\-]+\.[\w\-\.]+$');
    if (!regex.hasMatch(value.trim())) return 'Enter a valid email';
    return null;
  }

  Future<bool> save({
    required String name,
    required String phone,
    String? email,
    String? gender,
    DateTime? dob,
  }) async {
    status = ProfileStatus.loading;
    errorMessage = null;
    notifyListeners();
    try {
      final updated = (profile ??
              UserProfileModel(
                  name: '', email: '', phone: '', gender: 'Not specified'))
          .copyWith(
        name: name.trim(),
        phone: phone.trim(),
        email: email?.trim(),
        gender: gender,
        dob: dob,
        avatarId: pendingAvatarId,
      );
      profile = await _repo.updateProfile(updated);
      status = ProfileStatus.success;
      notifyListeners();
      return true;
    } catch (e) {
      status = ProfileStatus.error;
      errorMessage = 'Something went wrong. Please try again.';
      notifyListeners();
      return false;
    }
  }
}
'@

# ---------------------------------------------------------------------------
# 6) EditProfileScreen: use preset picker + AvatarDisplay
# ---------------------------------------------------------------------------
Write-File "lib/screens/profile/edit_profile_screen.dart" @'
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/profile_provider.dart';
import '../../core/avatar/avatar_catalog.dart';
import '../../widgets/avatar_picker_sheet.dart';

const Color kGreen = Color(0xFF0C831F);

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) {
      final p = context.read<ProfileProvider>().profile;
      if (p != null) {
        _nameCtrl.text = p.name;
        _phoneCtrl.text = p.phone;
      }
      _loaded = true;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProfileProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(title: const Text('Edit profile')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Center(
                child: GestureDetector(
                  onTap: () async {
                    final avatarId = await AvatarPickerSheet.show(
                      context,
                      currentAvatarId: provider.pendingAvatarId,
                    );
                    if (avatarId != null) {
                      context.read<ProfileProvider>().setPendingAvatar(avatarId);
                    }
                  },
                  child: Stack(
                    children: [
                      AvatarDisplay(
                        avatarId: provider.pendingAvatarId,
                        fallbackName: _nameCtrl.text,
                        radius: 48,
                      ),
                      const Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          radius: 15,
                          backgroundColor: kGreen,
                          child: Icon(Icons.edit,
                              size: 16, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                    labelText: 'Name', border: OutlineInputBorder()),
                validator: (v) =>
                    context.read<ProfileProvider>().validateName(v ?? ''),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                maxLength: 10,
                decoration: const InputDecoration(
                  labelText: 'Mobile',
                  prefixText: '+91 ',
                  border: OutlineInputBorder(),
                  counterText: '',
                ),
                validator: (v) {
                  if (v == null || v.trim().length != 10) {
                    return 'Enter a valid 10-digit mobile number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: provider.status == ProfileStatus.loading
                      ? null
                      : () async {
                          if (!_formKey.currentState!.validate()) return;
                          final ok = await context.read<ProfileProvider>().save(
                                name: _nameCtrl.text,
                                phone: _phoneCtrl.text,
                              );
                          if (ok && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Profile updated'),
                                backgroundColor: kGreen,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                            Navigator.pop(context);
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kGreen,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: provider.status == ProfileStatus.loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Save changes',
                          style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
'@

# ---------------------------------------------------------------------------
# 7) ProfileScreen header: use AvatarDisplay
# ---------------------------------------------------------------------------
Write-File "lib/screens/profile_screen.dart" @'
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../providers/settings_provider.dart';
import '../providers/profile_provider.dart';
import '../core/avatar/avatar_catalog.dart';
import 'login_screen.dart';
import 'profile/edit_profile_screen.dart';
import 'settings/notification_preferences_screen.dart';
import 'notifications/notification_list_screen.dart';
import 'settings/account_privacy_screen.dart';
import 'share/share_app_screen.dart';
import 'orders/order_list_screen.dart';
import 'order_screen.dart';
import 'wallet/wallet_screen.dart';
import 'support/support_home_screen.dart';
import 'about/about_us_screen.dart';
import '../features/wishlist/presentation/screens/wishlist_screen.dart';
import '../features/gst_details/presentation/screens/gst_list_screen.dart';
import 'categories_screen.dart';
import 'home_screen.dart';

const Color kGreen = Color(0xFF0C831F);

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Make sure we have the latest saved profile (e.g. after returning from
    // Edit profile on a previous visit, or first load in this session).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final profile = context.watch<ProfileProvider>().profile;
    final name = (profile?.name.trim().isNotEmpty ?? false) ? profile!.name : 'User';
    final phone = profile?.phone ?? '';
    final scheme = Theme.of(context).colorScheme;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const HomeScreen()));
      },
      child: Scaffold(
      backgroundColor: scheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(scheme, name, phone, profile?.avatarId),
              const SizedBox(height: 16),
              _buildQuickActions(scheme),
              const SizedBox(height: 16),
              _buildSettingsCard(settings, scheme),
              const SizedBox(height: 20),
              _buildSectionLabel('Your information', scheme),
              _buildSectionCard(scheme, [
                _tile(Icons.favorite_border, 'Your wishlist', () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const WishlistScreen()));
                }, scheme),
                _tile(Icons.description_outlined, 'GST details', () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const GstListScreen()));
                }, scheme, isLast: true),
              ]),
              const SizedBox(height: 20),
              _buildSectionLabel('Payment and coupons', scheme),
              _buildSectionCard(scheme, [
                _tile(Icons.account_balance_wallet_outlined, 'GoFresh Money', () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const WalletScreen()));
                }, scheme),
                _tile(Icons.credit_card_outlined, 'Payment settings',
                    () => _showComingSoon('Payment settings'), scheme, isLast: true),
              ]),
              const SizedBox(height: 20),
              _buildSectionLabel('Other information', scheme),
              _buildSectionCard(scheme, [
                _tile(Icons.ios_share_outlined, 'Share the app', () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const ShareAppScreen()));
                }, scheme),
                _tile(Icons.info_outline, 'About us', () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const AboutUsScreen()));
                }, scheme),
                _tile(Icons.lock_outline, 'Account privacy', () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const AccountPrivacyScreen()));
                }, scheme),
                _tile(Icons.notifications_active_outlined,
                    'Notifications', () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const NotificationListScreen()));
                }, scheme),
                _tile(Icons.notifications_none_outlined,
                    'Notification preferences', () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const NotificationPreferencesScreen()));
                }, scheme),
                _tile(Icons.logout, 'Log out', _confirmLogout, scheme, isLast: true),
              ]),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.popUntil(context, (route) => route.isFirst);
              break;
            case 1:
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const CategoriesScreen()));
              break;
            case 2:
              break;
          }
        },
        selectedItemColor: kGreen,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle:
            GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.poppins(fontSize: 11),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.category), label: 'Categories'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
      ),
    );
  }

  // ---------- Header ----------

  Widget _buildHeader(ColorScheme scheme, String name, String phone, String? avatarId) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [scheme.primaryContainer, scheme.surface],
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              InkWell(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.arrow_back, color: scheme.onSurface),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const EditProfileScreen()));
            },
            child: AvatarDisplay(
              avatarId: avatarId,
              fallbackName: name,
              radius: 42,
            ),
          ),
          const SizedBox(height: 12),
          Text('Your account',
              style: GoogleFonts.poppins(
                  fontSize: 20, fontWeight: FontWeight.bold, color: scheme.onSurface)),
          if (phone.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text('+91 $phone',
                style: GoogleFonts.poppins(
                    fontSize: 13, color: scheme.onSurface.withOpacity(0.6))),
          ],
        ],
      ),
    );
  }

  // ---------- Quick actions ----------

  Widget _buildQuickActions(ColorScheme scheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _quickAction(Icons.shopping_bag_outlined, 'Your orders', () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const OrderScreen()));
            }, scheme),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _quickAction(Icons.account_balance_wallet_outlined,
                'GoFresh Money', () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const WalletScreen()));
            }, scheme),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _quickAction(Icons.headset_mic_outlined, 'Need help?', () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const SupportHomeScreen()));
            }, scheme),
          ),
        ],
      ),
    );
  }

  Widget _quickAction(IconData icon, String label, VoidCallback onTap, ColorScheme scheme) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: kGreen, size: 24),
            const SizedBox(height: 8),
            Text(label,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                    fontSize: 12, fontWeight: FontWeight.w600, color: scheme.onSurface)),
          ],
        ),
      ),
    );
  }

  // ---------- Settings ----------

  Widget _buildSettingsCard(SettingsProvider settings, ColorScheme scheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            SwitchListTile(
              value: settings.hideSensitive,
              activeColor: kGreen,
              onChanged: (val) {
                context.read<SettingsProvider>().setHideSensitive(val);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(val
                        ? 'Sensitive items hidden'
                        : 'Sensitive items visible'),
                    backgroundColor: kGreen,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              secondary: Icon(Icons.visibility_off_outlined, color: scheme.onSurface),
              title: Text('Hide sensitive items',
                  style: GoogleFonts.poppins(
                      fontSize: 14, fontWeight: FontWeight.w600, color: scheme.onSurface)),
              subtitle: Text('Hide sensitive products from recommendations and search',
                  style: GoogleFonts.poppins(
                      fontSize: 11, color: scheme.onSurface.withOpacity(0.6))),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- Generic section helpers ----------

  Widget _buildSectionLabel(String title, ColorScheme scheme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(title,
            style: GoogleFonts.poppins(
                fontSize: 16, fontWeight: FontWeight.bold, color: scheme.onSurface)),
      ),
    );
  }

  Widget _buildSectionCard(ColorScheme scheme, List<Widget> tiles) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(children: tiles),
      ),
    );
  }

  Widget _tile(IconData icon, String title, VoidCallback onTap, ColorScheme scheme,
      {bool isLast = false}) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: scheme.onSurface),
          title: Text(title,
              style: GoogleFonts.poppins(
                  fontSize: 14, fontWeight: FontWeight.w600, color: scheme.onSurface)),
          trailing: Icon(Icons.chevron_right, color: scheme.onSurface.withOpacity(0.5)),
          onTap: onTap,
        ),
        if (!isLast)
          Divider(height: 1, indent: 16, endIndent: 16, color: scheme.outlineVariant),
      ],
    );
  }

  // ---------- Actions ----------

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature - Coming Soon',
            style: GoogleFonts.poppins()),
        backgroundColor: kGreen,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Logout', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to logout?', style: GoogleFonts.poppins()),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.grey))),
          ElevatedButton(
              onPressed: () async {
                await ApiService.clearToken();
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear();
                if (context.mounted) {
                  context.read<SettingsProvider>().clear();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              child: Text('Logout', style: GoogleFonts.poppins(color: Colors.white))),
        ],
      ),
    );
  }
}
'@

Write-Host ""
Write-Host "All files updated successfully." -ForegroundColor Cyan
Write-Host "Note: 'image_picker' import is no longer used anywhere in lib/." -ForegroundColor Yellow
Write-Host "Run 'flutter pub get' and rebuild the app to test." -ForegroundColor Cyan
