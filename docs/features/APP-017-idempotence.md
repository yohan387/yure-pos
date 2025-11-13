# APP-017 : Clés d'Idempotence

**Statut** : ✅ TERMINÉ
**Priorité** : CRITIQUE
**Effort** : 3h
**Date** : 2025-01-08

## Résumé
Implémentation des clés d'idempotence (UUID v4) pour tous les paiements (Stripe, Mobile Money) afin de prévenir les transactions dupliquées causées par clics multiples ou erreurs réseau.

## Choix d'Architecture
**Génération au niveau BLoC** : La clé est générée dans le BLoC (couche présentation) plutôt que dans le Repository car le BLoC gère l'intention utilisateur et contrôle les clics multiples. Permet le retry avec la même clé en cas d'erreur réseau et réinitialisation après succès.

## Implémentation

### Fichiers Créés
- `lib/core/utils/idempotency_key_manager.dart` - Service de génération UUID v4
- `test/core/utils/idempotency_key_manager_test.dart` - Tests unitaires (5 tests, 100% pass)
- `test/features/payments/presentation/bloc/stripe_payment_bloc_idempotency_test.dart` - Tests BLoC

### Fichiers Modifiés
- **Data Sources** : Ajout header `X-Idempotency-Key` dans `mobile_payment_remote_data_source.dart` et `stripe_payment_remote_data_source.dart`
- **BLoCs** : Intégration `IdempotencyKeyManager` dans `stripe_payment_bloc.dart` et `mobile_payment_bloc.dart` avec stockage temporaire `_currentIdempotencyKey`
- **Use Cases, Repositories, Interfaces** : Ajout paramètre `idempotencyKey` requis dans signatures (named parameters)

## Comportement
- **Nouveau paiement** : Génération clé unique
- **Erreur réseau** : Garde même clé pour retry
- **Succès** : Réinitialise clé (null)
- **Annulation utilisateur** : Réinitialise clé

## Tests
5 tests unitaires `IdempotencyKeyManager` + 5 tests BLoC d'idempotence. Vérifications : unicité UUID, retry avec même clé, reset après succès.
