import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_reel_app/src/shared/presentation/providers.dart';

class ReelManagementScreen extends ConsumerStatefulWidget {
  const ReelManagementScreen({super.key});

  @override
  ConsumerState<ReelManagementScreen> createState() =>
      _ReelManagementScreenState();
}

class _ReelManagementScreenState extends ConsumerState<ReelManagementScreen> {
  @override
  Widget build(BuildContext context) {
    final reelsAsync = ref.watch(reelsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reel Management'),
      ),
      body: reelsAsync.when(
        data: (reels) => RefreshIndicator(
          onRefresh: () => ref.refresh(reelsProvider.future),
          child: ListView.builder(
            itemCount: reels.length,
            itemBuilder: (context, index) {
              final reel = reels[index];
              return ListTile(
                leading: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: NetworkImage(reel.videoUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                title: Text(reel.dishName, overflow: TextOverflow.ellipsis),
                subtitle: Text('ID: ${reel.id} • Likes: ${reel.likes}',
                    overflow: TextOverflow.ellipsis),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    await ref.read(reelRepositoryProvider).deleteReel(reel.id);
                    ref.invalidate(reelsProvider);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Reel removed from system.')),
                      );
                    }
                  },
                ),
              );
            },
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
