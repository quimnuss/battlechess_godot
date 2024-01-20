# battlechess_godot

## quickstart a game

```mermaid
graph LR
    Start --> islogged{is logged in?}
    islogged -- yes --> rnd_game{random_game_exists?}
    islogged -- no --> login --> rnd_game
    rnd_game -- yes --> game_lobby -- "both players" --> game
    rnd_game -- no --> create_game --> game_lobby
```

## production flow

```mermaid
graph LR
    Start --> islogged{is logged in?}
    islogged -- yes --> games_menu
    islogged -- no --> login --> games_menu
    login -- signup --> singup --> games_menu

    games_menu -- create --> game_lobby
    games_menu -- join --> game_lobby

    game_lobby -- "both players" --> game

    game -- move --> game_over{game over?}

    game_over -- no --> game
    game_over -- yes --> game_over_button --> games_menu
```

# TODOs

[ ] Remove full games not owned by player from list
[ ] Add show/hide finished games button
[ ] Add replay game scene
[ ] Add back button on game or show menu/game list to go to lobby
