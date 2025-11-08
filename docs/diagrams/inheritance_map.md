# Inheritance Map

This diagram shows the class inheritance hierarchy for the core gameplay objects.

```
CharacterBody2D
└── VisualGameObject (visual_game_object.gd)
    ├── MovableGameObject (movable_game_object.gd)
    │   └── Character (character.gd)
    │       ├── HeroCharacter (hero_character.gd)
    │       │   └── Hero (hero.gd)
    │       └── MonsterCharacter (monster_character.gd)
    │           └── Enemy (enemy.gd)
    ├── InteractableObject (interactable_object.gd)
    │   └── Collectible (collectible.gd)
    │       └── CoinCollectible (coin_collectible.gd)
    └── NonInteractableObject (non_interactable_object.gd)
        └── ImmovableObject (immovable_object.gd)
```
