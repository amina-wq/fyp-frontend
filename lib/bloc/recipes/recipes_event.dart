abstract class RecipesEvent {
  const RecipesEvent();
}

class RecipesLoadRequested extends RecipesEvent {
  final int number;

  const RecipesLoadRequested({
    this.number = 10,
  });
}
