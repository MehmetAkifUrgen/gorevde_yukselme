import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/question_report_service.dart';
import '../../../../core/providers/auth_providers.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../../core/utils/error_utils.dart';

class QuestionReportDialog extends ConsumerStatefulWidget {
  final String questionId;
  final String questionText;

  const QuestionReportDialog({
    super.key,
    required this.questionId,
    required this.questionText,
  });

  @override
  ConsumerState<QuestionReportDialog> createState() => _QuestionReportDialogState();
}

class _QuestionReportDialogState extends ConsumerState<QuestionReportDialog> {
  ReportReason? _selectedReason;
  String? _customReason;
  String? _additionalNotes;
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Soruyu Bildir'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bu soruda bir sorun mu var? Lütfen nedenini belirtin:',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            
            // Reason selection
            ...ReportReason.values.map((reason) => RadioListTile<ReportReason>(
              title: Text(reason.displayName),
              value: reason,
              groupValue: _selectedReason,
              onChanged: (value) {
                setState(() {
                  _selectedReason = value;
                  if (value != ReportReason.other) {
                    _customReason = null;
                  }
                });
              },
            )),
            
            // Custom reason input
            if (_selectedReason == ReportReason.other) ...[
              const SizedBox(height: 8),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Diğer neden',
                  hintText: 'Lütfen nedeninizi açıklayın',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
                onChanged: (value) {
                  _customReason = value.trim();
                },
              ),
            ],
            
            const SizedBox(height: 16),
            
            // Additional notes
            TextField(
              decoration: const InputDecoration(
                labelText: 'Ek notlar (opsiyonel)',
                hintText: 'Ek bilgi verebilirsiniz',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              onChanged: (value) {
                _additionalNotes = value.trim();
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: const Text('İptal'),
        ),
        ElevatedButton(
          onPressed: _isSubmitting || _selectedReason == null ? null : _submitReport,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.errorRed,
            foregroundColor: Colors.white,
          ),
          child: _isSubmitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('Bildir'),
        ),
      ],
    );
  }

  Future<void> _submitReport() async {
    if (_selectedReason == null) return;
    
    print('[QuestionReportDialog] Starting report submission...');
    print('[QuestionReportDialog] Question ID: ${widget.questionId}');
    print('[QuestionReportDialog] Reason: ${_selectedReason!.displayName}');
    print('[QuestionReportDialog] Custom reason: $_customReason');
    print('[QuestionReportDialog] Additional notes: $_additionalNotes');
    
    setState(() {
      _isSubmitting = true;
    });

    try {
      final currentUser = ref.read(currentFirebaseUserProvider);
      final userId = currentUser?.uid ?? 'guest_${DateTime.now().millisecondsSinceEpoch}';
      final userEmail = currentUser?.email ?? 'guest@example.com';
      
      print('[QuestionReportDialog] User ID: $userId');
      print('[QuestionReportDialog] User Email: $userEmail');
      print('[QuestionReportDialog] User is authenticated: ${currentUser != null}');
      
      // Get device info (optional)
      String deviceInfoString = 'Unknown Device';
      try {
        final deviceInfo = DeviceInfoPlugin();
        final androidInfo = await deviceInfo.androidInfo;
        final version = androidInfo.version.release;
        final model = androidInfo.model;
        deviceInfoString = 'Android $version - $model';
        print('[QuestionReportDialog] Device info: $deviceInfoString');
      } catch (e) {
        deviceInfoString = 'Device info unavailable';
        print('[QuestionReportDialog] Device info error: $e');
      }
      
      String appVersion = '1.0.0';
      try {
        final packageInfo = await PackageInfo.fromPlatform();
        appVersion = packageInfo.version;
        print('[QuestionReportDialog] App version: $appVersion');
      } catch (e) {
        appVersion = 'Version unavailable';
        print('[QuestionReportDialog] App version error: $e');
      }
      
      print('[QuestionReportDialog] Calling reportQuestion service...');
      
      await ref.read(questionReportServiceProvider).reportQuestion(
        questionId: widget.questionId,
        questionText: widget.questionText,
        userId: userId,
        userEmail: userEmail,
        reason: _selectedReason!,
        customReason: _customReason,
        additionalNotes: _additionalNotes,
        appVersion: appVersion,
        deviceInfo: deviceInfoString,
      );

      print('[QuestionReportDialog] Report submitted successfully!');

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bildiriminiz başarıyla gönderildi. Teşekkürler!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('[QuestionReportDialog] ERROR: Failed to submit report: $e');
      print('[QuestionReportDialog] Error type: ${e.runtimeType}');
      print('[QuestionReportDialog] Error details: ${e.toString()}');
      
      if (mounted) {
        ErrorUtils.showFirestoreError(context, e);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}
