import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/wallet_controller.dart';

class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(walletControllerProvider);
    final controller = ref.read(walletControllerProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xfff3f4f6),
      appBar: AppBar(
        title: const Text('Balans'),
        centerTitle: true,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: controller.refreshAll,
        child: state.loading && state.wallet == null
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(10),
                children: [
                  if (state.wallet == null)
                    const Center(child: Text('Balans məlumatı yoxdur'))
                  else ...[
                    _WalletAmountCard(
                      title: 'Elanlar',
                      value: '${state.wallet!.wallet.adBalance}',
                      desc: 'Paket çərçivəsində sizə təqdim olunan elanların qalığı.',
                    ),
                    _WalletAmountCard(
                      title: 'Paketin balansı',
                      value: '${state.wallet!.wallet.packageBalance.toStringAsFixed(1)}',
                      desc: 'Paket çərçivəsində köçürülmüş məbləğ.',
                    ),
                    _WalletAmountCard(
                      title: 'Əsas balans',
                      value: '${state.wallet!.wallet.mainBalance.toStringAsFixed(1)} AZN',
                      desc: 'Şəxsi hesaba yatırdığınız məbləğ.',
                    ),
                    _WalletAmountCard(
                      title: 'Bonus balansı',
                      value: '${state.wallet!.wallet.bonusBalance.toStringAsFixed(1)}',
                      desc: 'Hədiyyə bonuslar şəklində əldə olunmuş məbləğ.',
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: const Color(0xffd1d5db), width: 2),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Şəxsi hesab',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 20,
                              ),
                            ),
                          ),
                          Text(
                            '${state.wallet!.total.toStringAsFixed(1)} AZN',
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
      ),
    );
  }
}

class _WalletAmountCard extends StatelessWidget {
  final String title;
  final String value;
  final String desc;

  const _WalletAmountCard({
    required this.title,
    required this.value,
    required this.desc,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xfff8fafc),
        border: Border.all(color: const Color(0xffeef2f7)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                    color: Color(0xff111827),
                  ),
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 20,
                  color: Color(0xff111827),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            desc,
            style: const TextStyle(
              color: Color(0xff9ca3af),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}