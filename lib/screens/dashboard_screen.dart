import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_constants.dart';
import '../controllers/auth_provider.dart';
import '../widgets/common/base_button.dart';
import '../widgets/common/base_card.dart';
import 'inventory_screen.dart';
import 'quotes_sales_screen.dart';
import 'history_screen.dart';
import 'login_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appTitle),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: Drawer(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.screenPadding),
          child: Column(
            children: [
              const SizedBox(height: 50),
              BaseButton(
                text: AppConstants.logoutButton,
                onPressed: () async {
                  Navigator.of(context).pop(); // Cerrar el drawer
                  final authProvider = Provider.of<AuthProvider>(
                    context,
                    listen: false,
                  );
                  await authProvider.signOut();
                  if (context.mounted) {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppConstants.screenPadding),
        child: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.4,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: BaseCard(
                      title: AppConstants.inventoryTitle,
                      icon: Icons.inventory,
                      description: AppConstants.inventoryDescription,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const InventoryScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: AppConstants.gridSpacing),
                  SizedBox(
                    width: double.infinity,
                    child: BaseCard(
                      title: AppConstants.quotesSalesTitle,
                      icon: Icons.shopping_cart,
                      description: AppConstants.quotesSalesDescription,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const QuotesSalesScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: AppConstants.gridSpacing),
                  SizedBox(
                    width: double.infinity,
                    child: BaseCard(
                      title: AppConstants.historyTitle,
                      icon: Icons.history,
                      description: AppConstants.historyDescription,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HistoryScreen(),
                          ),
                        );
                      },
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
}
