import 'package:integration_test/integration_test.dart';
import '../test/orders_test.dart' as orders;
import '../test/integration/sync_engine_test.dart' as sync;
import '../test/integration/order_close_reconciliation_test.dart' as close;

// Real Drift with deterministic remote fixtures. No production backend writes.
// These verify repositories and sync, not missing cashier UI interactions.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  orders.main();
  sync.main();
  close.main();
}
