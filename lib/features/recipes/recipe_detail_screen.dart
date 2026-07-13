import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/recipes/recipes.dart';
import '../../core/constants/api_constants.dart';
import '../../models/recipes/recipes.dart';
import '../../repositories/recipes/recipes_repository_interface.dart';
import '../../ui/theme/app_colors.dart';
import '../../ui/widgets/widgets.dart';

@RoutePage()
class RecipeDetailScreen extends StatefulWidget {
  final int spoonacularId;

  const RecipeDetailScreen({super.key, required this.spoonacularId});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<RecipeDetailBloc>(
      create: (context) => RecipeDetailBloc(
        recipesRepository: context.read<RecipesRepositoryInterface>(),
      )..add(RecipeDetailLoadRequested(spoonacularId: widget.spoonacularId)),
      child: _RecipeDetailView(spoonacularId: widget.spoonacularId),
    );
  }
}

class _RecipeDetailView extends StatelessWidget {
  final int spoonacularId;

  const _RecipeDetailView({required this.spoonacularId});

  Future<void> _refreshRecipe(BuildContext context) async {
    context.read<RecipeDetailBloc>().add(
      RecipeDetailLoadRequested(spoonacularId: spoonacularId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: BlocConsumer<RecipeDetailBloc, RecipeDetailState>(
          listener: (context, state) {
            if (state is RecipeDetailFailure) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
          builder: (context, state) {
            if (state is RecipeDetailInitial || state is RecipeDetailLoading) {
              return Center(
                child: CircularProgressIndicator(color: colors.primary),
              );
            }

            if (state is RecipeDetailFailure) {
              return _RecipeDetailErrorView(
                message: state.message,
                onRetry: () => _refreshRecipe(context),
              );
            }

            if (state is RecipeDetailLoaded) {
              return _RecipeDetailContent(
                recipe: state.recipe,
                onRefresh: () => _refreshRecipe(context),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _RecipeDetailContent extends StatelessWidget {
  final RecipeDetailModel recipe;
  final Future<void> Function() onRefresh;

  const _RecipeDetailContent({required this.recipe, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final imageUrl = recipe.image == null || recipe.image!.isEmpty
        ? null
        : ApiConstants.resolveImageUrl(recipe.image);

    return RefreshIndicator(
      color: colors.primary,
      backgroundColor: colors.card,
      onRefresh: onRefresh,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
        children: [
          _RecipeDetailHeader(onBack: () => context.router.maybePop()),
          const SizedBox(height: 20),
          _RecipeHeroImage(imageUrl: imageUrl),
          const SizedBox(height: 22),
          Text(
            recipe.title,
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w900,
              height: 1.18,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 16),
          _RecipeMetaRow(
            readyInMinutes: recipe.readyInMinutes,
            servings: recipe.servings,
            calories: recipe.calories,
          ),
          const SizedBox(height: 26),
          const _SectionTitle(title: 'Ingredients'),
          const SizedBox(height: 12),
          for (final ingredient in recipe.ingredients) ...[
            _IngredientTile(ingredient: ingredient, recipe: recipe),
            const SizedBox(height: 10),
          ],
          const SizedBox(height: 18),
          const _SectionTitle(title: 'Steps'),
          const SizedBox(height: 12),
          if (recipe.steps.isEmpty)
            const _EmptyStepsCard()
          else
            for (final step in recipe.steps) ...[
              _StepTile(step: step),
              const SizedBox(height: 10),
            ],
        ],
      ),
    );
  }
}

class _RecipeDetailHeader extends StatelessWidget {
  final VoidCallback onBack;

  const _RecipeDetailHeader({required this.onBack});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Row(
      children: [
        _HeaderButton(icon: Icons.chevron_left, onTap: onBack),
        Expanded(
          child: Text(
            'Recipe Details',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(width: 42),
      ],
    );
  }
}

class _HeaderButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _HeaderButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: colors.surfaceSoft,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.border),
        ),
        child: Icon(icon, color: colors.primary, size: 24),
      ),
    );
  }
}

class _RecipeHeroImage extends StatelessWidget {
  final String? imageUrl;

  const _RecipeHeroImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;

    return Container(
      height: 210,
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: colors.shadow,
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: hasImage
          ? AppCachedNetworkImage(
              imageUrl: imageUrl!,
              fallback: Icon(
                Icons.restaurant_menu_outlined,
                color: colors.primary,
                size: 70,
              ),
            )
          : Icon(
              Icons.restaurant_menu_outlined,
              color: colors.primary,
              size: 70,
            ),
    );
  }
}

class _RecipeMetaRow extends StatelessWidget {
  final int? readyInMinutes;
  final int? servings;
  final double? calories;

  const _RecipeMetaRow({
    required this.readyInMinutes,
    required this.servings,
    required this.calories,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MetaCard(
            icon: Icons.schedule_outlined,
            label: readyInMinutes == null ? 'Time' : '$readyInMinutes min',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MetaCard(
            icon: Icons.people_outline,
            label: servings == null ? 'Servings' : '$servings servings',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MetaCard(
            icon: Icons.local_fire_department_outlined,
            label: calories == null
                ? 'Calories'
                : '${_formatAmount(calories!)} kcal',
          ),
        ),
      ],
    );
  }
}

class _MetaCard extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetaCard({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: colors.surfaceSoft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: colors.primary, size: 20),
          const SizedBox(height: 6),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Text(
      title,
      style: TextStyle(
        color: colors.textPrimary,
        fontSize: 21,
        fontWeight: FontWeight.w900,
        letterSpacing: -0.3,
      ),
    );
  }
}

class _IngredientTile extends StatelessWidget {
  final RecipeIngredientModel ingredient;
  final RecipeDetailModel recipe;

  const _IngredientTile({required this.ingredient, required this.recipe});

  @override
  Widget build(BuildContext context) {
    final statusData = _statusDataForIngredient(
      context: context,
      ingredient: ingredient,
    );

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
      decoration: BoxDecoration(
        color: statusData.fillColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: statusData.borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(statusData.icon, color: statusData.iconColor, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: _IngredientInfo(
              ingredient: ingredient,
              statusLabel: statusData.label,
              statusColor: statusData.iconColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _IngredientInfo extends StatelessWidget {
  final RecipeIngredientModel ingredient;
  final String statusLabel;
  final Color statusColor;

  const _IngredientInfo({
    required this.ingredient,
    required this.statusLabel,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final requiredText = _buildRequiredText(ingredient);
    final inventoryText = _buildInventoryText(ingredient);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          ingredient.name,
          style: TextStyle(
            color: colors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          requiredText,
          style: TextStyle(
            color: colors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (inventoryText != null) ...[
          const SizedBox(height: 4),
          Text(
            inventoryText,
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
        const SizedBox(height: 7),
        Text(
          statusLabel,
          style: TextStyle(
            color: statusColor,
            fontSize: 12,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _StepTile extends StatelessWidget {
  final RecipeStepModel step;

  const _StepTile({required this.step});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: colors.shadow,
            blurRadius: 18,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colors.primary,
              shape: BoxShape.circle,
            ),
            child: Text(
              '${step.number}',
              style: TextStyle(
                color: colors.textOnPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              step.step,
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyStepsCard extends StatelessWidget {
  const _EmptyStepsCard();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.border),
      ),
      child: Text(
        'No preparation steps available for this recipe.',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: colors.textSecondary,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _RecipeDetailErrorView extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const _RecipeDetailErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 52, color: colors.danger),
            const SizedBox(height: 16),
            Text(
              'Failed to load recipe details',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 17,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Try again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: colors.textOnPrimary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IngredientStatusData {
  final IconData icon;
  final String label;
  final Color fillColor;
  final Color borderColor;
  final Color iconColor;

  const _IngredientStatusData({
    required this.icon,
    required this.label,
    required this.fillColor,
    required this.borderColor,
    required this.iconColor,
  });
}

_IngredientStatusData _statusDataForIngredient({
  required BuildContext context,
  required RecipeIngredientModel ingredient,
}) {
  final colors = context.appColors;

  if (ingredient.isAvailable) {
    return _IngredientStatusData(
      icon: Icons.check_circle_outline,
      label: 'Available in your inventory',
      fillColor: colors.successSoft,
      borderColor: colors.successBorder,
      iconColor: colors.success,
    );
  }

  if (ingredient.isInsufficient) {
    return _IngredientStatusData(
      icon: Icons.warning_amber_rounded,
      label: 'Not enough in inventory',
      fillColor: colors.warningSoft,
      borderColor: colors.warningBorder,
      iconColor: colors.warning,
    );
  }

  if (ingredient.isUnknownAmount) {
    return _IngredientStatusData(
      icon: Icons.help_outline,
      label: 'You have this item, check amount manually',
      fillColor: colors.primarySoft,
      borderColor: colors.primaryBorder,
      iconColor: colors.primary,
    );
  }

  return _IngredientStatusData(
    icon: Icons.remove_circle_outline,
    label: 'Missing from inventory',
    fillColor: colors.dangerSoft,
    borderColor: colors.dangerBorder,
    iconColor: colors.danger,
  );
}

String _buildRequiredText(RecipeIngredientModel ingredient) {
  final amount = _formatAmount(ingredient.amount);

  if (ingredient.unit.trim().isEmpty) {
    return 'Required: $amount';
  }

  return 'Required: $amount ${ingredient.unit}';
}

String? _buildInventoryText(RecipeIngredientModel ingredient) {
  if (ingredient.inventoryAmount == null && ingredient.inventoryUnit == null) {
    return null;
  }

  final amount = ingredient.inventoryAmount == null
      ? ''
      : _formatAmount(ingredient.inventoryAmount!);

  final unit = ingredient.inventoryUnit ?? '';

  final text = '$amount $unit'.trim();

  if (text.isEmpty) {
    return null;
  }

  return 'In inventory: $text';
}

String _formatAmount(double amount) {
  if (amount % 1 == 0) {
    return amount.toStringAsFixed(0);
  }

  return amount.toStringAsFixed(1);
}
