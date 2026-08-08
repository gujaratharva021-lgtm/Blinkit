import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../providers/support_provider.dart';
import '../../models/support_model.dart';

const Color kGreen = Color(0xFF0C831F);

class ReportIssueScreen extends StatefulWidget {
  const ReportIssueScreen({super.key});
  @override
  State<ReportIssueScreen> createState() => _ReportIssueScreenState();
}

class _ReportIssueScreenState extends State<ReportIssueScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descCtrl = TextEditingController();
  String _categoryId = kIssueCategories.first.id;
  File? _screenshot;

  @override
  void dispose() {
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickScreenshot() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (file != null) setState(() => _screenshot = File(file.path));
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await context.read<SupportProvider>().submitIssue(
          categoryId: _categoryId,
          description: _descCtrl.text.trim(),
          screenshotPath: _screenshot?.path,
        );
    if (ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Issue reported. Our team will get back to you soon.'),
            backgroundColor: kGreen,
            behavior: SnackBarBehavior.floating),
      );
      Navigator.pop(context);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not submit. Please try again.'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        backgroundColor: scheme.surface,
        elevation: 0,
        iconTheme: IconThemeData(color: scheme.onSurface),
        title: Text('Report Issue', style: GoogleFonts.poppins(color: scheme.onSurface, fontWeight: FontWeight.bold)),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Category', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: scheme.onSurface)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _categoryId,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: kIssueCategories.map((c) => DropdownMenuItem(value: c.id, child: Text(c.label))).toList(),
              onChanged: (v) => setState(() => _categoryId = v ?? _categoryId),
            ),
            const SizedBox(height: 20),
            Text('Description',
                style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: scheme.onSurface)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _descCtrl,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'Describe the issue in detail...',
                border: OutlineInputBorder(),
              ),
              validator: (v) => (v == null || v.trim().length < 10)
                  ? 'Please describe the issue in at least 10 characters'
                  : null,
            ),
            const SizedBox(height: 20),
            Text('Screenshot (optional)',
                style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: scheme.onSurface)),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickScreenshot,
              child: Container(
                height: 140,
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: scheme.outlineVariant),
                ),
                child: _screenshot == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate_outlined, color: scheme.onSurface.withOpacity(0.5), size: 32),
                          const SizedBox(height: 8),
                          Text('Tap to attach a screenshot',
                              style: GoogleFonts.poppins(fontSize: 12, color: scheme.onSurface.withOpacity(0.5))),
                        ],
                      )
                    : Stack(
                        fit: StackFit.expand,
                        children: [
                          ClipRRect(borderRadius: BorderRadius.circular(14), child: Image.file(_screenshot!, fit: BoxFit.cover)),
                          Positioned(
                            top: 6,
                            right: 6,
                            child: GestureDetector(
                              onTap: () => setState(() => _screenshot = null),
                              child: const CircleAvatar(
                                  radius: 14,
                                  backgroundColor: Colors.black54,
                                  child: Icon(Icons.close, size: 16, color: Colors.white)),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 28),
            Consumer<SupportProvider>(
              builder: (context, provider, _) {
                final submitting = provider.submitStatus == SubmitStatus.submitting;
                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: submitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kGreen,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: submitting
                        ? const SizedBox(
                            height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Text('Submit', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
