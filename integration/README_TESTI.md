# GUT integrācijas testu īsie paskaidrojumi

Šeit katram testam ir **viena saprotama doma** — ko tieši mēs gribam noķert, ja kāds kaut ko projektā nejauši salauž.

## Inventory
- **test_inventory_ui_refresh_on_add.gd**  
  Pārbauda, ka, pievienojot item, inventāra logs tiešām parāda jauno item.

- **test_inventory_ui_refresh_on_clear.gd**  
  Pārbauda, ka pēc iztīrīšanas UI nepaliek “spoki” no iepriekšējiem itemiem.

- **test_inventory_ui_toggle_refreshes_hidden_changes.gd**  
  Pārbauda, ka inventārs ir korekts arī tad, ja izmaiņas notiek, kamēr logs nav redzams.

## Currency
- **test_currency_manager_signals.gd**  
  Pārbauda, ka currency sistēma ne tikai maina skaitli, bet arī paziņo par to pārējai spēlei.

## Save/Load
- **test_save_manager_collects_scene_and_saveables.gd**  
  Pārbauda, ka saglabāšanā savācas vajadzīgie dati no scēnas un “saveable” objektiem.

- **test_save_manager_applies_data_to_nodes.gd**  
  Pārbauda, ka ielāde iedod datus atpakaļ pareizajiem objektiem.

- **test_save_manager_file_roundtrip.gd**  
  Pārbauda pilnu “save -> file -> load” plūsmu.

## HealthBar
- **test_healthbar_save_load_roundtrip.gd**  
  Pārbauda, ka dzīvības stāvoklis izdzīvo pēc saglabāšanas/ielādes.

- **test_healthbar_add_remove_max_hp_sync.gd**  
  Pārbauda, ka sirsniņu skaits un HP loģika nesajūk pēc max HP maiņas.

## Player
- **test_player_ready_populates_inventory.gd**  
  Pārbauda, ka spēlētājs startējot iedod sākuma itemus.
