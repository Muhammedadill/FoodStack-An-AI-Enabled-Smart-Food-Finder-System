import 'package:flutter_riverpod/flutter_riverpod.dart';

class ReelComment {
  final String id;
  final String userName;
  final String text;
  final DateTime timestamp;
  final String userId; // Track who posted the comment

  ReelComment({
    required this.id,
    required this.userName,
    required this.text,
    required this.timestamp,
    required this.userId,
  });
}

class ReelState {
  final Map<String, int> likes; // reelId -> likes count
  final Map<String, bool> userLikes; // reelId -> user liked
  final Map<String, List<ReelComment>> comments; // reelId -> comments

  ReelState({
    this.likes = const {},
    this.userLikes = const {},
    this.comments = const {},
  });

  ReelState copyWith({
    Map<String, int>? likes,
    Map<String, bool>? userLikes,
    Map<String, List<ReelComment>>? comments,
  }) {
    return ReelState(
      likes: likes ?? this.likes,
      userLikes: userLikes ?? this.userLikes,
      comments: comments ?? this.comments,
    );
  }
}

class ReelNotifier extends StateNotifier<ReelState> {
  ReelNotifier() : super(ReelState());

  void toggleLike(String reelId, int currentLikes) {
    final isLiked = state.userLikes[reelId] ?? false;
    final newLikes = isLiked ? currentLikes - 1 : currentLikes + 1;

    final updatedLikes = {...state.likes, reelId: newLikes};
    final updatedUserLikes = {...state.userLikes, reelId: !isLiked};

    state = state.copyWith(
      likes: updatedLikes,
      userLikes: updatedUserLikes,
    );
  }

  void addComment(String reelId, String userName, String text, String userId) {
    final newComment = ReelComment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userName: userName,
      text: text,
      timestamp: DateTime.now(),
      userId: userId,
    );

    final currentComments = state.comments[reelId] ?? [];
    final updatedComments = {
      ...state.comments,
      reelId: [...currentComments, newComment],
    };

    state = state.copyWith(comments: updatedComments);
  }

  void deleteComment(String reelId, String commentId) {
    final currentComments = state.comments[reelId] ?? [];
    final updatedCommentsList =
        currentComments.where((comment) => comment.id != commentId).toList();

    final updatedComments = {
      ...state.comments,
      reelId: updatedCommentsList,
    };

    state = state.copyWith(comments: updatedComments);
  }

  int getLikes(String reelId, int defaultLikes) {
    return state.likes[reelId] ?? defaultLikes;
  }

  bool isLiked(String reelId) {
    return state.userLikes[reelId] ?? false;
  }

  List<ReelComment> getComments(String reelId) {
    return state.comments[reelId] ?? [];
  }
}

final reelProvider = StateNotifierProvider<ReelNotifier, ReelState>((ref) {
  return ReelNotifier();
});
