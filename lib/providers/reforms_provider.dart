import 'package:flutter/material.dart';
import '../models/app_models.dart';
import '../services/continuous_voting_service.dart';

class ReformsProvider extends ChangeNotifier {
  final ContinuousVotingService _votingService = ContinuousVotingService();
  List<Reform> _reforms = [];

  ReformsProvider() {
    _setupReformsStream();
  }

  List<Reform> get reforms => _reforms;

  void _setupReformsStream() {
    _votingService.reformsStream.listen((reforms) {
      _reforms = reforms;
      notifyListeners();
    });
  }

  Future<void> voteReform(String reformId) async {
    try {
      _votingService.voteReform(reformId);
      notifyListeners();
    } catch (e) {
      print('Error voting on reform: $e');
    }
  }

  String formatVotes(int votes) {
    return _votingService.formatVotes(votes);
  }

  double getVotePercentage(Reform reform) {
    final totalVotes = _reforms.fold<int>(0, (sum, r) => sum + r.votes);
    return totalVotes > 0 ? (reform.votes / totalVotes) * 100 : 0;
  }

  @override
  void dispose() {
    _votingService.dispose();
    super.dispose();
  }
}
