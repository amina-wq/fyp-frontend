// Programmer Name: Rakhmatullayeva Amina
// Program Name: FoodTrack
// Description: Events for the categories bloc.
// First Written on: Friday, 03-Jul-2026
// Edited on: Sunday, 12-Jul-2026
abstract class CategoriesEvent {
  const CategoriesEvent();
}

class CategoriesLoadRequested extends CategoriesEvent {
  const CategoriesLoadRequested();
}
