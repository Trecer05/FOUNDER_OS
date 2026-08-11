import 'package:flutter_test/flutter_test.dart';
import 'package:founder_os/domain/catalog/product_strategy_catalog.dart';
import 'package:founder_os/domain/commands/game_action.dart';
import 'package:founder_os/domain/entities/game_state.dart';
import 'package:founder_os/domain/entities/models.dart';
import 'package:founder_os/domain/entities/product_strategy_models.dart';
import 'package:founder_os/domain/simulation/engine/game_engine.dart';

import '../support/fixtures.dart';

void main() {
  const engine = GameEngine();

  test(
    'satisfaction follows causal product experience rather than churn feedback',
    () {
      final state = GameState.initial();
      final comfortable = productFixture(
        quality: 96,
        reliability: 0.999,
        security: 95,
        intensity: 0.2,
      );
      final hostile = productFixture(
        quality: 40,
        reliability: 0.84,
        security: 35,
        intensity: 1,
      );
      expect(
        state.productUserSatisfaction(comfortable),
        greaterThan(state.productUserSatisfaction(hostile)),
      );
    },
  );

  test('user satisfaction is bounded to a player-facing percentage', () {
    final value = GameState.initial().productUserSatisfaction(productFixture());
    expect(value, inInclusiveRange(0, 100));
  });

  test('higher subscription price lowers paid conversion', () {
    final state = GameState.initial();
    final affordable = productFixture(
      blueprintId: 'team_saas',
      monetization: MonetizationModel.subscription,
      price: 300,
    );
    final expensive = affordable.copyWith(price: 3000);
    expect(
      state.productPaidConversionRate(affordable),
      greaterThan(state.productPaidConversionRate(expensive)),
    );
  });

  test('harder paywall trades satisfaction for higher short-term revenue', () {
    final state = GameState.initial();
    final mild = productFixture(
      blueprintId: 'team_saas',
      monetization: MonetizationModel.subscription,
      price: 500,
      intensity: 0.2,
      freeTierPercent: 0.60,
    );
    final hard = productFixture(
      blueprintId: 'team_saas',
      monetization: MonetizationModel.subscription,
      price: 500,
      intensity: 0.9,
      freeTierPercent: 0.05,
    );
    expect(
      state.productUserSatisfaction(hard),
      lessThan(state.productUserSatisfaction(mild)),
    );
    expect(
      state.productMonetizationRevenueEstimate(hard),
      greaterThan(state.productMonetizationRevenueEstimate(mild)),
    );
  });

  test('live monetization pressure reaches retention churn and activation', () {
    var mild = liveWebsiteState(paused: false);
    var harsh = mild;
    final product = mild.products.single;
    mild = mild.copyWith(
      products: <Product>[
        product.copyWith(
          monetization: MonetizationModel.subscription,
          price: 1,
          monetizationIntensity: 0.2,
          freeTierPercent: 0.65,
        ),
      ],
    );
    harsh = harsh.copyWith(
      products: <Product>[
        product.copyWith(
          monetization: MonetizationModel.subscription,
          price: 2500,
          monetizationIntensity: 1,
          freeTierPercent: 0,
        ),
      ],
    );

    mild = engine.reduce(mild, const AdvanceTime(360));
    harsh = engine.reduce(harsh, const AdvanceTime(360));

    expect(
      harsh.products.single.retention30d,
      lessThan(mild.products.single.retention30d),
    );
    expect(
      harsh.products.single.churnRate,
      greaterThan(mild.products.single.churnRate),
    );
    expect(
      harsh.products.single.activationRate,
      lessThan(mild.products.single.activationRate),
    );
  });

  test(
    'advertising forecast describes interest before actual product usage',
    () {
      final state = liveWebsiteState(cash: 10000000);
      final forecast = state.advertisingForecast(
        product: state.products.single,
        agencyId: 'signal_labs',
        channelId: 'social_feed',
        budget: 1000000,
      );
      expect(forecast.impressions, greaterThan(forecast.usersExpected));
      expect(forecast.note, contains('заинтересованных людей'));
      expect(forecast.note, contains('начнут пользоваться'));
    },
  );

  test('advertising is an ongoing campaign that can be stopped explicitly', () {
    var state = liveWebsiteState(cash: 10000000);
    final cashBefore = state.cash;
    state = engine.reduce(
      state,
      const StartAdvertisingCampaign(
        productId: 'website',
        agencyId: 'signal_labs',
        channelId: 'social_feed',
        budget: 600000,
      ),
    );
    expect(state.advertisingCampaigns, hasLength(1));
    expect(
      state.advertisingCampaigns.single.status,
      AdvertisingCampaignStatus.active,
    );
    expect(state.advertisingCampaigns.single.endsAtMinutes, -1);
    expect(state.cash, greaterThan(cashBefore - 600000));

    state = engine.reduce(
      state,
      StopAdvertisingCampaign(state.advertisingCampaigns.single.id),
    );
    expect(
      state.advertisingCampaigns.single.status,
      AdvertisingCampaignStatus.stopped,
    );
  });

  test(
    'revenue forecast uses real live audience and responds to monetization tuning',
    () {
      var state = liveSaasState();
      final product = state.products.single;
      final before = state.revenueForecastFor(product).high;
      expect(before, greaterThan(0));
      state = engine.reduce(
        state,
        SetProductMonetizationSettings(
          productId: product.id,
          intensity: 0.9,
          freeTierPercent: 0.05,
        ),
      );
      expect(
        state.revenueForecastFor(state.products.single).high,
        greaterThan(before),
      );
    },
  );

  test('organic acquisition share remains a bounded explainable metric', () {
    final state = liveSaasState();
    final share = state.productOrganicAcquisitionShare(state.products.single);
    expect(share, inInclusiveRange(0, 1));
  });

  test('catalog exposes multiple advertising channels and agencies', () {
    expect(ProductStrategyCatalog.agencies.length, greaterThanOrEqualTo(2));
    expect(ProductStrategyCatalog.channels.length, greaterThanOrEqualTo(3));
  });
}
