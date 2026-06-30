import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/recipes/recipes.dart';
import '../../core/constants/api_constants.dart';
import '../../models/recipes/recipes.dart';
import '../../ui/theme/app_colors.dart';
import '../../ui/widgets/widgets.dart';
import '../../repositories/recipes/recipes_repository_interface.dart';

@RoutePage()
class RecipeDetailScreen extends StatefulWidget {
  final int spoonacularId;

  const RecipeDetailScreen({
    super.key,
    required this.spoonacularId,
  });

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RecipeDetailBloc>(
      create: (context) => RecipeDetailBloc(
        recipesRepository: context.read<RecipesRepositoryInterface>(),
      )..add(
        RecipeDetailLoadRequested(
          spoonacularId: widget.spoonacularId,
        ),
      ),
      child: _RecipeDetailView(
        spoonacularId: widget.spoonacularId,
      ),
    );
  }
}

class _RecipeDetailView extends StatelessWidget {
  final int spoonacularId;

  const _RecipeDetailView({
    required this.spoonacularId,
  });

  Future<void> _refreshRecipe(BuildContext context) async {
    context.read<RecipeDetailBloc>().add(
      RecipeDetailLoadRequested(
        spoonacularId: spoonacularId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocConsumer<RecipeDetailBloc, RecipeDetailState>(
          listener: (context, state) {
            if (state is RecipeDetailFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is RecipeDetailInitial ||
                state is RecipeDetailLoading) {
              return const Center(
                child: CircularProgressIndicator(),
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

  const _RecipeDetailContent({
    required this.recipe,
    required this.onRefresh,
  });


  @override
  Widget build(BuildContext context) {
    final imageUrl = recipe.image == null || recipe.image!.isEmpty
        ? null
        : ApiConstants.resolveImageUrl(recipe.image);

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
        children: [
          _RecipeDetailHeader(
            onBack: () => context.router.maybePop(),
          ),
          const SizedBox(height: 20),
          _RecipeHeroImage(
            imageUrl: imageUrl,
          ),
          const SizedBox(height: 22),
          Text(
            recipe.title,
            style: const TextStyle(
              color: Color(0xFF17183B),
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
          const _SectionTitle(
            title: 'Ingredients',
          ),
          const SizedBox(height: 12),
          for (final ingredient in recipe.ingredients) ...[
            _IngredientTile(
              ingredient: ingredient,
              recipe: recipe,
            ),
            const SizedBox(height: 10),
          ],
          const SizedBox(height: 18),
          const _SectionTitle(
            title: 'Steps',
          ),
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

  const _RecipeDetailHeader({
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _HeaderButton(
          icon: Icons.chevron_left,
          onTap: onBack,
        ),
        const Expanded(
          child: Text(
            'Recipe Details',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF1F2147),
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

  const _HeaderButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: AppColors.categoryActiveFill,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: AppColors.bottomNavigationBar,
          size: 24,
        ),
      ),
    );
  }
}

class _RecipeHeroImage extends StatelessWidget {
  final String? imageUrl;

  const _RecipeHeroImage({
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;

    return Container(
      height: 210,
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: hasImage
          ? AppCachedNetworkImage(
        imageUrl: imageUrl!,
        fit: BoxFit.cover,
        fallback: const Icon(
          Icons.restaurant_menu_outlined,
          color: AppColors.bottomNavigationBar,
          size: 70,
        ),
      )
          : const Icon(
        Icons.restaurant_menu_outlined,
        color: AppColors.bottomNavigationBar,
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
            label: readyInMinutes == null
                ? 'Time'
                : '$readyInMinutes min',
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

  const _MetaCard({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.categoryActiveFill,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.categoryActiveBorder,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: AppColors.bottomNavigationBar,
            size: 20,
          ),
          const SizedBox(height: 6),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF1F2147),
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

  const _SectionTitle({
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: Color(0xFF17183B),
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

  const _IngredientTile({
    required this.ingredient,
    required this.recipe,
  });

  @override
  Widget build(BuildContext context) {
    final statusData = _statusDataForIngredient(ingredient);

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
      decoration: BoxDecoration(
        color: statusData.fillColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: statusData.borderColor,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            statusData.icon,
            color: statusData.iconColor,
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _IngredientInfo(
              ingredient: ingredient,
              statusLabel: statusData.label,
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

  const _IngredientInfo({
    required this.ingredient,
    required this.statusLabel,
  });

  @override
  Widget build(BuildContext context) {
    final requiredText = _buildRequiredText(ingredient);
    final inventoryText = _buildInventoryText(ingredient);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          ingredient.name,
          style: const TextStyle(
            color: Color(0xFF1F2147),
            fontSize: 14,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          requiredText,
          style: const TextStyle(
            color: Colors.black54,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (inventoryText != null) ...[
          const SizedBox(height: 4),
          Text(
            inventoryText,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
        const SizedBox(height: 7),
        Text(
          statusLabel,
          style: const TextStyle(
            color: Color(0xFF1F2147),
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

  const _StepTile({
    required this.step,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 7),
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
            decoration: const BoxDecoration(
              color: AppColors.bottomNavigationBar,
              shape: BoxShape.circle,
            ),
            child: Text(
              '${step.number}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              step.step,
              style: const TextStyle(
                color: Color(0xFF1F2147),
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
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Text(
        'No preparation steps available for this recipe.',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.black54,
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

  const _RecipeDetailErrorView({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 52,
              color: Colors.redAccent,
            ),
            const SizedBox(height: 16),
            const Text(
              'Failed to load recipe details',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF1F2147),
                fontSize: 17,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black54,
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
                backgroundColor: AppColors.bottomNavigationBar,
                foregroundColor: Colors.white,
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

_IngredientStatusData _statusDataForIngredient(
    RecipeIngredientModel ingredient,
    ) {
  if (ingredient.isAvailable) {
    return const _IngredientStatusData(
      icon: Icons.check_circle_outline,
      label: 'Available in your inventory',
      fillColor: Color(0xFFEAF8ED),
      borderColor: Color(0xFFC5EBCB),
      iconColor: Color(0xFF3E9F4D),
    );
  }

  if (ingredient.isInsufficient) {
    return const _IngredientStatusData(
      icon: Icons.warning_amber_rounded,
      label: 'Not enough in inventory',
      fillColor: Color(0xFFFFF6DF),
      borderColor: Color(0xFFF1D999),
      iconColor: Color(0xFFD99A35),
    );
  }

  if (ingredient.isUnknownAmount) {
    return const _IngredientStatusData(
      icon: Icons.help_outline,
      label: 'You have this item, check amount manually',
      fillColor: Color(0xFFEFF6FA),
      borderColor: Color(0xFFC8E1ED),
      iconColor: AppColors.bottomNavigationBar,
    );
  }

  return const _IngredientStatusData(
    icon: Icons.remove_circle_outline,
    label: 'Missing from inventory',
    fillColor: Color(0xFFFFEEEE),
    borderColor: Color(0xFFF3C6C6),
    iconColor: Color(0xFFD85C5C),
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