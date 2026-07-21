// Programmer Name: Rakhmatullayeva Amina
// Program Name: FoodTrack
// Description: Events for the recipes bloc.
// First Written on: Tuesday, 30-Jun-2026
// Edited on: Sunday, 12-Jul-2026
abstract class RecipesEvent {
  const RecipesEvent();
}

class RecipesLoadRequested extends RecipesEvent {
  final int number;

  const RecipesLoadRequested({this.number = 10});
}
