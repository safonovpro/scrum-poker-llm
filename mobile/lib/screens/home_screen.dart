import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../blocs/app_bloc.dart';
import '../l10n/app_localizations.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _roomNameController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _inviteLinkController = TextEditingController();
  bool _isCreating = false;

  @override
  void dispose() {
    _roomNameController.dispose();
    _nicknameController.dispose();
    _inviteLinkController.dispose();
    super.dispose();
  }

  void _handleCreate() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isCreating = true);
    context.read<AppBloc>().add(
          CreateRoomEvent(
            _roomNameController.text,
            _nicknameController.text,
          ),
        );
    setState(() => _isCreating = false);
  }

  void _handleJoin() {
    if (!_formKey.currentState!.validate()) return;
    final roomId = _inviteLinkController.text.trim().split('/').last;
    if (roomId.isEmpty) return;
    context.read<AppBloc>().add(
          JoinRoomEvent(roomId, _nicknameController.text, 'player'),
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => GoRouter.of(context).go('/settings'),
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => GoRouter.of(context).go('/about'),
          ),
        ],
      ),
      body: BlocListener<AppBloc, AppState>(
        listener: (context, state) {
          if (state.status == AppStatus.creating && state.room != null) {
            GoRouter.of(context).go('/room/${state.room!.id}');
          }
          if (state.status == AppStatus.joining && state.room != null) {
            GoRouter.of(context).go('/room/${state.room!.id}');
          }
          if (state.status == AppStatus.error && state.error != null) {
            _showError(state.error!);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Создание комнаты
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.createRoom,
                            style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _roomNameController,
                          decoration: InputDecoration(
                            labelText: l10n.roomName,
                            hintText: l10n.roomNameHint,
                          ),
                          validator: (v) =>
                              v == null || v.isEmpty ? l10n.roomName : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _nicknameController,
                          decoration: InputDecoration(
                            labelText: l10n.nickname,
                            hintText: l10n.nicknameHint,
                          ),
                          validator: (v) =>
                              v == null || v.isEmpty ? l10n.nickname : null,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _isCreating ? null : _handleCreate,
                          child: _isCreating
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Text(l10n.create),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Вступление по ссылке
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.joinRoom,
                            style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _inviteLinkController,
                          decoration: InputDecoration(
                            labelText: l10n.inviteLink,
                            hintText: l10n.inviteLinkHint,
                          ),
                          validator: (v) =>
                              v == null || v.isEmpty ? l10n.inviteLink : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _nicknameController,
                          decoration: InputDecoration(
                            labelText: l10n.nickname,
                            hintText: l10n.nicknameHint,
                          ),
                          validator: (v) =>
                              v == null || v.isEmpty ? l10n.nickname : null,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _handleJoin,
                          child: Text(l10n.join),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
