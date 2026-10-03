import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:exquisssita_manager/data/remote/remote_providers.dart';
import 'loyalty_repository.dart';

part 'loyalty_providers.g.dart';

@Riverpod(keepAlive: true)
LoyaltyRepository loyaltyRepository(Ref ref) =>
    SupabaseLoyaltyRepository(ref.watch(supabaseDataSourceProvider));
