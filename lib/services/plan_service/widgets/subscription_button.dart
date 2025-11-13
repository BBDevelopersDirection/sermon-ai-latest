import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sermon/services/plan_service/plan_purchase_state.dart';

import '../plan_purchase_cubit.dart';

class SubscribeButton extends StatelessWidget {
  const SubscribeButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlanPurchaseCubit, PlanPurchaseState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.only(right: 18, left: 18),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromRGBO(216, 145, 24, 1),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                if (state.loading) {
                  return;
                }

                context.read<PlanPurchaseCubit>().rechargeNowCallBack(
                  context: context,
                );
              },
              child: state.loading
                  ? CircularProgressIndicator.adaptive(
                      backgroundColor: Colors.white,
                    )
                  : Text(
                      "Subscribe Now",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }
}
