import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_data_source.dart';

part 'remote_providers.g.dart';

@Riverpod(keepAlive: true)
SupabaseDataSource supabaseDataSource(Ref ref) =>
    SupabaseDataSource(Supabase.instance.client);
