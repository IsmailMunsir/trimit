import 'package:flutter/foundation.dart';
import '../models/wallet.dart';
import '../db/database_helper.dart';

class WalletProvider extends ChangeNotifier {
  List<Wallet> _wallets = [];
  bool _isLoading = true;

  List<Wallet> get wallets => _wallets;
  bool get isLoading => _isLoading;

  Future<void> loadWallets() async {
    _isLoading = true;
    notifyListeners();

    _wallets = await DatabaseHelper.instance.getAllWallets();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addOrUpdate(Wallet wallet) async {
    await DatabaseHelper.instance.insertWallet(wallet);
    await loadWallets();
  }

  Future<void> delete(String id) async {
    await DatabaseHelper.instance.deleteWallet(id);
    await loadWallets();
  }

  Wallet? byId(String? id) {
    if (id == null) return null;
    try {
      return _wallets.firstWhere((w) => w.id == id);
    } catch (_) {
      return null;
    }
  }
}