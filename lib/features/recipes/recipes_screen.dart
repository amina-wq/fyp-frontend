import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/recipes/recipes.dart';
import '../../core/constants/api_constants.dart';
import '../../models/recipes/recipes.dart';
import '../../router/router.dart';
import '../../ui/theme/app_colors.dart';
import '../../ui/widgets/widgets.dart';

@RoutePage()
class RecipesScreen extends StatefulWidget {
  const RecipesScreen({super.key});

  @override
  State<RecipesScreen> createState() => _RecipesScreenState();
}

class _RecipesScreenState extends State<RecipesScreen> {
  @override
  void initState() {
    super.initState();

    context.read<RecipesBloc>().add(
      const RecipesLoadRequested(
        number: 10,
      ),
    );
  }

  Future<void> _refreshRecipes() async {
    context.read<RecipesBloc>().add(
      const RecipesLoadRequested(
        number: 10,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: BlocConsumer<RecipesBloc, RecipesState>(
          listener: (context, state) {
            if (state is RecipesFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is RecipesInitial || state is RecipesLoading) {
              return Center(
                child: CircularProgressIndicator(
                  color: colors.primary,
                ),
              );
            }

            if (state is RecipesFailure) {
              return _RecipesErrorView(
                message: state.message,
                onRetry: _refreshRecipes,
              );
            }

            if (state is RecipesLoaded) {
              return _RecipesContent(
                recipes: state.recipes,
                onRefresh: _refreshRecipes,
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _RecipesContent extends StatelessWidget {
  final List<RecipeSummaryModel> recipes;
  final Future<void> Function() onRefresh;

  const _RecipesContent({
    required this.recipes,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return RefreshIndicator(
      color: colors.primary,
      backgroundColor: colors.card,
      onRefresh: onRefresh,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 120),
        children: [
          const _RecipesHeader(),
          const SizedBox(height: 18),
          const _RecipesInfoCard(),
          const SizedBox(height: 20),
          if (recipes.isEmpty)
            const _EmptyRecipesCard()
          else
            for (final recipe in recipes) ...[
              _RecipeCard(
                recipe: recipe,
                onTap: () {
                  context.router.push(
                    RecipeDetailRoute(
                      spoonacularId: recipe.spoonacularId,
                    ),
                  );
                },
              ),
              const SizedBox(height: 14),
            ],
        ],
      ),
    );
  }
}

class _RecipesHeader extends StatelessWidget {
  const _RecipesHeader();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Row(
      children: [
        Expanded(
          child: Text(
            'Recipe Suggestions',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: colors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
        ),
        IconButton(
          onPressed: () {
            context.read<RecipesBloc>().add(
              const RecipesLoadRequested(
                number: 10,
              ),
            );
          },
          icon: Icon(
            Icons.refresh,
            color: colors.primary,
          ),
        ),
      ],
    );
  }
}

class _RecipesInfoCard extends StatelessWidget {
  const _RecipesInfoCard();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: colors.surfaceSoft,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colors.border,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.auto_awesome_outlined,
            color: colors.primary,
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Recipes are suggested based on your active inventory items. Higher match score means more ingredients are already available.',
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecipeCard extends StatelessWidget {
  final RecipeSummaryModel recipe;
  final VoidCallback onTap;

  const _RecipeCard({
    required this.recipe,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final imageUrl = recipe.image == null || recipe.image!.isEmpty
        ? null
        : ApiConstants.resolveImageUrl(recipe.image);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: colors.border,
          ),
          boxShadow: [
            BoxShadow(
              color: colors.shadow,
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            _RecipeImage(
              imageUrl: imageUrl,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _RecipeCardInfo(
                recipe: recipe,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right,
              color: colors.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}

class _RecipeImage extends StatelessWidget {
  final String? imageUrl;

  const _RecipeImage({
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;

    return Container(
      width: 82,
      height: 82,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: colors.surfaceSoft,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colors.border,
        ),
      ),
      child: hasImage
          ? AppCachedNetworkImage(
        imageUrl: imageUrl!,
        fit: BoxFit.cover,
        fallback: Icon(
          Icons.restaurant_menu_outlined,
          color: colors.primary,
          size: 34,
        ),
      )
          : Icon(
        Icons.restaurant_menu_outlined,
        color: colors.primary,
        size: 34,
      ),
    );
  }
}

class _RecipeCardInfo extends StatelessWidget {
  final RecipeSummaryModel recipe;

  const _RecipeCardInfo({
    required this.recipe,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          recipe.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: colors.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w900,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _RecipeBadge(
              icon: Icons.percent_outlined,
              label: '${_formatScore(recipe.matchScore)}% match',
            ),
            _RecipeBadge(
              icon: Icons.check_circle_outline,
              label: '${recipe.usedIngredientCount} used',
            ),
            _RecipeBadge(
              icon: Icons.remove_circle_outline,
              label: '${recipe.missedIngredientCount} missing',
            ),
          ],
        ),
      ],
    );
  }
}

class _RecipeBadge extends StatelessWidget {
  final IconData icon;
  final String label;

  const _RecipeBadge({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: colors.chipSelected,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colors.chipSelectedBorder,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: colors.primary,
          ),
          const SizedBox(width: 5),
          Text(
            label,
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

class _EmptyRecipesCard extends StatelessWidget {
  const _EmptyRecipesCard();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 28),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: colors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.shadow,
            blurRadius: 14,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.restaurant_menu_outlined,
            size: 50,
            color: colors.primary,
          ),
          const SizedBox(height: 14),
          Text(
            'No recipes found',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add more products to your inventory and try again.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecipesErrorView extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const _RecipesErrorView({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 52,
              color: colors.danger,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load recipes',
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

String _formatScore(double value) {
  if (value % 1 == 0) {
    return value.toStringAsFixed(0);
  }

  return value.toStringAsFixed(1);
}