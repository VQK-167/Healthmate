import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as image_lib;
import 'package:image_picker/image_picker.dart';

import '../models/user.dart';
import '../services/auth_service.dart';
import '../widgets/user_avatar.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key, required this.onSelectTab});

  final void Function(int) onSelectTab;

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  final _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _picker = ImagePicker();

  String? _gender;
  String? _editingProfileId;
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  void _fillForm(AppUser profile, String fallbackName) {
    if (_editingProfileId == profile.id) return;
    _editingProfileId = profile.id;
    _nameController.text = profile.displayName.isNotEmpty
        ? profile.displayName
        : fallbackName;
    _ageController.text = profile.age?.toString() ?? '';
    _heightController.text = profile.heightCm?.toString() ?? '';
    _gender = profile.gender;
  }

  Future<void> _saveProfile(AppUser profile) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      final updated = AppUser(
        id: profile.id,
        email: profile.email,
        displayName: _nameController.text.trim(),
        photoUrl: profile.photoUrl,
        createdAt: profile.createdAt,
        age: int.tryParse(_ageController.text.trim()),
        gender: _gender,
        heightCm: double.tryParse(_heightController.text.trim()),
        weightKg: profile.weightKg,
        avatarBase64: profile.avatarBase64,
        avatarIndex: profile.avatarIndex,
      );
      await _auth.updateProfile(updated);
      if (mounted) _showMessage('Đã lưu hồ sơ.');
    } catch (_) {
      if (mounted) _showMessage('Không thể lưu hồ sơ. Vui lòng thử lại.');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _showJourneySheet() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black26,
      builder: (context) => SafeArea(
        child: Container(
          constraints: const BoxConstraints(maxHeight: 620),
          padding: const EdgeInsets.fromLTRB(24, 14, 24, 24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 42, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(4)))),
              const SizedBox(height: 16),
              Text('Hành trình của bạn', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Ngày đến hạn: 12/10/2026 · Còn 18 ngày'),
              const SizedBox(height: 4),
              const Text('Còn 3,4 kg nữa để đạt mục tiêu 65,0 kg', style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              const Text('Lịch sử hành trình', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Expanded(
                child: ListView(
                  children: const [
                    _JourneyHistoryTile(date: '12/09/2026', weight: '70,0 kg', note: 'Bắt đầu hành trình', isFirst: true),
                    _JourneyHistoryTile(date: '20/09/2026', weight: '69,2 kg', note: 'Giảm 0,8 kg'),
                    _JourneyHistoryTile(date: '28/09/2026', weight: '68,8 kg', note: 'Giảm 0,4 kg'),
                    _JourneyHistoryTile(date: 'Hôm nay', weight: '68,4 kg', note: 'Hiện tại', isLast: true),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Future<void> _showGoalSheet(AppUser profile) async {
    var targetWeight = profile.targetWeightKg ?? 65.0;
    var dailyCalories = profile.dailyCalorieTarget ?? 2000;
    var dailySteps = profile.dailyStepsTarget ?? 10000;
    var dailyWater = profile.dailyWaterTargetMl ?? 2000;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black26,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => SafeArea(
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(child: Container(width: 42, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(4)))),
                  const SizedBox(height: 16),
                  Row(children: [
                    Expanded(child: Text('Mục tiêu của tôi', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold))),
                    Text('Bấm − hoặc + để chỉnh', style: Theme.of(context).textTheme.bodySmall),
                  ]),
                  const SizedBox(height: 20),
                  _GoalEditorRow(icon: Icons.monitor_weight_outlined, color: Colors.indigo, title: 'Cân nặng mục tiêu', subtitle: 'Hiện tại 68,4 kg', value: '${targetWeight.toStringAsFixed(1)} kg', onMinus: () => setSheetState(() => targetWeight = (targetWeight - .5).clamp(30, 300)), onPlus: () => setSheetState(() => targetWeight = (targetWeight + .5).clamp(30, 300))),
                  _GoalEditorRow(icon: Icons.local_fire_department_outlined, color: Colors.orange, title: 'Calo mỗi ngày', subtitle: 'Trung bình tuần này 1.850', value: '$dailyCalories kcal', onMinus: () => setSheetState(() => dailyCalories = (dailyCalories - 100).clamp(500, 10000)), onPlus: () => setSheetState(() => dailyCalories = (dailyCalories + 100).clamp(500, 10000))),
                  _GoalEditorRow(icon: Icons.directions_walk_outlined, color: Colors.deepOrange, title: 'Bước chân mỗi ngày', subtitle: 'Hôm nay 6.230 bước', value: '${dailySteps.toString()} bước', onMinus: () => setSheetState(() => dailySteps = (dailySteps - 500).clamp(1000, 100000)), onPlus: () => setSheetState(() => dailySteps = (dailySteps + 500).clamp(1000, 100000))),
                  _GoalEditorRow(icon: Icons.water_drop_outlined, color: Colors.blue, title: 'Nước uống mỗi ngày', subtitle: 'Hôm nay 750 ml', value: '$dailyWater ml', onMinus: () => setSheetState(() => dailyWater = (dailyWater - 250).clamp(250, 10000)), onPlus: () => setSheetState(() => dailyWater = (dailyWater + 250).clamp(250, 10000))),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () async {
                        await _auth.updateProfile(
                          profile.copyWith(
                            targetWeightKg: targetWeight,
                            dailyCalorieTarget: dailyCalories,
                            dailyStepsTarget: dailySteps,
                            dailyWaterTargetMl: dailyWater,
                          ),
                        );
                        if (context.mounted) {
                          Navigator.pop(context);
                          _showMessage('Đã cập nhật mục tiêu.');
                        }
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(12),
                        child: Text('Lưu mục tiêu'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showAvatarOptions(AppUser profile) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Chọn ảnh từ thư viện'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(profile);
              },
            ),
            ListTile(
              leading: const Icon(Icons.face_outlined),
              title: const Text('Chọn avatar có sẵn'),
              onTap: () {
                Navigator.pop(context);
                _showPresetAvatars(profile);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text('Xóa ảnh'),
              onTap: () async {
                Navigator.pop(context);
                await _saveAvatar(profile.copyWith(clearAvatar: true));
              },
            ),
          ],
        ),
      ),
    );
  }
  Future<void> _showPresetAvatars(AppUser profile) async {
    const avatarCount = 8;
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => GridView.builder(
        padding: const EdgeInsets.all(24),
        shrinkWrap: true,
        itemCount: avatarCount,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 18,
          crossAxisSpacing: 18,
        ),
        itemBuilder: (context, index) => UserAvatar(
          user: profile.copyWith(
            avatarBase64: null,
            avatarIndex: index,
            clearAvatarBase64: true,
          ),
          radius: 30,
          onTap: () async {
            Navigator.pop(context);
            await _saveAvatar(
              profile.copyWith(
                avatarIndex: index,
                clearAvatarBase64: true,
              ),
            );
          },
        ),
      ),
    );
  }


  Future<void> _pickImage(AppUser profile) async {
    try {
      final file = await _picker.pickImage(source: ImageSource.gallery);
      if (file == null) return;
      final original = image_lib.decodeImage(await file.readAsBytes());
      if (original == null) {
        _showMessage('Không đọc được ảnh đã chọn.');
        return;
      }
      final resized = image_lib.copyResize(original, width: 200, height: 200);
      final bytes = image_lib.encodeJpg(resized, quality: 80);
      await _saveAvatar(
        profile.copyWith(
          avatarBase64: base64Encode(bytes),
          avatarIndex: null,
        ),
      );
    } catch (_) {
      if (mounted) _showMessage('Không thể chọn ảnh. Vui lòng thử lại.');
    }
  }

  Future<void> _saveAvatar(AppUser profile) async {
    try {
      await _auth.updateProfile(profile);
      if (mounted) _showMessage('Đã cập nhật ảnh đại diện.');
    } catch (_) {
      if (mounted) _showMessage('Không thể cập nhật ảnh đại diện.');
    }
  }

  Future<void> _changePassword() async {
    _oldPasswordController.clear();
    _newPasswordController.clear();
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đổi mật khẩu'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _oldPasswordController,
              obscureText: true,
              autocorrect: false,
              enableSuggestions: false,
              keyboardType: TextInputType.visiblePassword,
              decoration: const InputDecoration(labelText: 'Mật khẩu hiện tại'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _newPasswordController,
              obscureText: true,
              autocorrect: false,
              enableSuggestions: false,
              keyboardType: TextInputType.visiblePassword,
              decoration: const InputDecoration(labelText: 'Mật khẩu mới'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Lưu')),
        ],
      ),
    );
    if (result != true) return;
    final oldPassword = _oldPasswordController.text;
    final newPassword = _newPasswordController.text;
    if (oldPassword.isEmpty || newPassword.length < 6) {
      _showMessage('Mật khẩu mới phải có ít nhất 6 ký tự.');
      return;
    }
    try {
      await _auth.changePassword(
        currentPassword: oldPassword,
        newPassword: newPassword,
      );
      if (mounted) _showMessage('Đã đổi mật khẩu.');
    } on FirebaseAuthException catch (error) {
      if (mounted) {
        _showMessage(error.code == 'wrong-password' || error.code == 'invalid-credential'
            ? 'Mật khẩu hiện tại không đúng.'
            : 'Không thể đổi mật khẩu.');
      }
    }
  }

  Future<void> _deleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa tài khoản?'),
        content: const Text('Toàn bộ hồ sơ của bạn sẽ bị xóa và không thể hoàn tác.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa tài khoản'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await _auth.deleteAccount();
    } on FirebaseAuthException catch (error) {
      if (mounted) {
        _showMessage(error.code == 'requires-recent-login'
            ? 'Vui lòng đăng nhập lại trước khi xóa tài khoản.'
            : 'Không thể xóa tài khoản.');
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) {
      return const Scaffold(body: Center(child: Text('Chưa đăng nhập')));
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Hồ sơ')),
      body: StreamBuilder<AppUser?>(
        stream: _auth.watchProfile(firebaseUser.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final profile = snapshot.data ?? AppUser(
                id: firebaseUser.uid,
                email: firebaseUser.email ?? '',
                displayName: firebaseUser.displayName ?? '',
              );
          final fallbackName = firebaseUser.displayName ?? 'Bạn';
          _fillForm(profile, fallbackName);
          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Center(
                  child: UserAvatar(
                    user: profile,
                    radius: 52,
                    showCamera: true,
                    onTap: () => _showAvatarOptions(profile),
                  ),
                ),
                const SizedBox(height: 12),
                Center(child: Text(profile.displayName.isEmpty ? fallbackName : profile.displayName, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold))),
                Center(child: Text(profile.email, style: Theme.of(context).textTheme.bodyMedium)),
                const SizedBox(height: 24),
                _JourneyCard(
                  onTap: _showJourneySheet,
                ),
                const SizedBox(height: 12),
                _GoalSummaryCard(
                  onTap: () => _showGoalSheet(profile),
                ),
                const SizedBox(height: 28),
                Text('Thông tin cá nhân', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                TextFormField(controller: _nameController, decoration: const InputDecoration(labelText: 'Họ tên', prefixIcon: Icon(Icons.person_outline)), validator: (value) => value == null || value.trim().isEmpty ? 'Họ tên không được để trống' : null),
                const SizedBox(height: 12),
                TextFormField(controller: _ageController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Tuổi', prefixIcon: Icon(Icons.cake_outlined)), validator: (value) { final age = int.tryParse(value?.trim() ?? ''); return age == null || age < 1 || age > 120 ? 'Tuổi phải từ 1 đến 120' : null; }),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(initialValue: _gender, decoration: const InputDecoration(labelText: 'Giới tính', prefixIcon: Icon(Icons.wc_outlined)), items: const [DropdownMenuItem(value: 'Nam', child: Text('Nam')), DropdownMenuItem(value: 'Nữ', child: Text('Nữ')), DropdownMenuItem(value: 'Khác', child: Text('Khác'))], onChanged: (value) => setState(() => _gender = value)),
                const SizedBox(height: 12),
                TextFormField(controller: _heightController, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Chiều cao (cm)', prefixIcon: Icon(Icons.height)), validator: (value) { final height = double.tryParse(value?.trim() ?? ''); return height == null || height < 50 || height > 250 ? 'Chiều cao phải từ 50 đến 250 cm' : null; }),
                const SizedBox(height: 16),
                FilledButton(onPressed: _isSaving ? null : () => _saveProfile(profile), child: _isSaving ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Lưu hồ sơ')),
                const SizedBox(height: 28),
                Text('Tài khoản', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Card(child: Column(children: [ListTile(leading: const Icon(Icons.lock_outline), title: const Text('Đổi mật khẩu'), trailing: const Icon(Icons.chevron_right), onTap: _changePassword), ListTile(leading: const Icon(Icons.logout, color: Colors.red), title: const Text('Đăng xuất', style: TextStyle(color: Colors.red)), onTap: () async { final ok = await _confirmSignOut(); if (ok) await _auth.signOut(); })])),
                const SizedBox(height: 24),
                OutlinedButton.icon(onPressed: _deleteAccount, icon: const Icon(Icons.delete_forever, color: Colors.red), label: const Text('Xóa tài khoản', style: TextStyle(color: Colors.red)), style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red))),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<bool> _confirmSignOut() async => await showDialog<bool>(context: context, builder: (context) => AlertDialog(title: const Text('Đăng xuất?'), content: const Text('Bạn có chắc muốn đăng xuất không?'), actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')), FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Đăng xuất'))])) ?? false;
}

class _JourneyHistoryTile extends StatelessWidget {
  const _JourneyHistoryTile({
    required this.date,
    required this.weight,
    required this.note,
    this.isFirst = false,
    this.isLast = false,
  });

  final String date;
  final String weight;
  final String note;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 28,
            child: Column(children: [
              Container(width: 14, height: 14, decoration: BoxDecoration(color: isLast ? Colors.deepPurple : Colors.indigo, shape: BoxShape.circle)),
              if (!isLast) Container(width: 2, height: 52, color: Colors.indigo.shade100),
            ]),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(date, style: const TextStyle(fontWeight: FontWeight.w600)), const SizedBox(height: 3), Text(note, style: Theme.of(context).textTheme.bodySmall)]),
                Text(weight, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
              ]),
            ),
          ),
        ],
      );
}
class _JourneyCard extends StatelessWidget {
  const _JourneyCard({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: Text('Hành trình của bạn', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold))),
                TextButton(onPressed: onTap, child: const Text('Chi tiết')),
              ]),
              const SizedBox(height: 8),
              const Text('Ngày đến hạn: 12/10/2026 · Còn 18 ngày'),
              const SizedBox(height: 4),
              const Text('Còn 3,4 kg nữa · Mục tiêu 65,0 kg', style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold)),
              const SizedBox(height: 14),
              const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Bắt đầu\n70,0 kg', style: TextStyle(fontWeight: FontWeight.bold)), Text('Hiện tại\n68,4 kg', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple)), Text('Mục tiêu\n65,0 kg', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold))]),
              const SizedBox(height: 10),
              ClipRRect(borderRadius: BorderRadius.circular(8), child: const LinearProgressIndicator(value: .65, minHeight: 10)),
            ]),
          ),
        ),
      );
}


class _GoalSummaryCard extends StatelessWidget {
  const _GoalSummaryCard({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
        child: ListTile(
          onTap: onTap,
          leading: const CircleAvatar(child: Icon(Icons.flag_outlined)),
          title: const Text('Mục tiêu của tôi', style: TextStyle(fontWeight: FontWeight.bold)),
          subtitle: const Text('Cân nặng mục tiêu · 65,0 kg\nTiến độ hiện tại 68,4 kg'),
          trailing: const Icon(Icons.chevron_right),
        ),
      );
}

class _GoalEditorRow extends StatelessWidget {
  const _GoalEditorRow({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onMinus,
    required this.onPlus,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final String value;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 18),
        child: Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: color.withValues(alpha: .14),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            IconButton.filledTonal(onPressed: onMinus, icon: const Icon(Icons.remove)),
            const SizedBox(width: 4),
            SizedBox(width: 72, child: Text(value, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold))),
            const SizedBox(width: 4),
            IconButton.filled(onPressed: onPlus, icon: const Icon(Icons.add)),
          ],
        ),
      );
}
