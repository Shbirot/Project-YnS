*** Settings ***
Library    tests.robot.lib.godot_keywords.GodotKeywords

*** Variables ***
${CASE_DIR}    res://tests/robot/cases

*** Test Cases ***
Catalog Spec
    Run Single Case    ${CASE_DIR}/catalog_test.gd

Catalog Spec (Missing Entry)
    Run Single Case    ${CASE_DIR}/catalog_error_test.gd

Weapon Application
    Run Single Case    ${CASE_DIR}/weapon_application_test.gd

API Manager
    Run Single Case    ${CASE_DIR}/api_manager_test.gd

API Manager (Error Path)
    Run Single Case    ${CASE_DIR}/api_manager_error_test.gd

Factory Base Object
    Run Single Case    ${CASE_DIR}/factory_base_object_test.gd

Factory Base Object (Error Path)
    Run Single Case    ${CASE_DIR}/factory_base_object_error_test.gd

Factory Hero
    Run Single Case    ${CASE_DIR}/factory_hero_test.gd

Factory Hero (Error Path)
    Run Single Case    ${CASE_DIR}/factory_hero_error_test.gd

Factory Monster
    Run Single Case    ${CASE_DIR}/factory_monster_test.gd

Factory Monster (Error Path)
    Run Single Case    ${CASE_DIR}/factory_monster_error_test.gd

Factory Projectile
    Run Single Case    ${CASE_DIR}/factory_projectile_test.gd

Factory Projectile (Error Path)
    Run Single Case    ${CASE_DIR}/factory_projectile_error_test.gd

Game Controller
    Run Single Case    ${CASE_DIR}/game_controller_test.gd

Game Controller (Error Path)
    Run Single Case    ${CASE_DIR}/game_controller_error_test.gd

World Bounds
    Run Single Case    ${CASE_DIR}/world_bounds_test.gd

Movement System
    Run Single Case    ${CASE_DIR}/movement_system_test.gd

Movement System (Error Path)
    Run Single Case    ${CASE_DIR}/movement_system_error_test.gd

Attributes Manager
    Run Single Case    ${CASE_DIR}/attributes_manager_test.gd

Attributes Manager (Error Path)
    Run Single Case    ${CASE_DIR}/attributes_manager_error_test.gd

Visual Game Object
    Run Single Case    ${CASE_DIR}/visual_game_object_test.gd

Visual Game Object (Error Path)
    Run Single Case    ${CASE_DIR}/visual_game_object_error_test.gd

Damage System
    Run Single Case    ${CASE_DIR}/damage_system_test.gd

Damage System (Error Path)
    Run Single Case    ${CASE_DIR}/damage_system_error_test.gd

Weapon Ammunition
    Run Single Case    ${CASE_DIR}/weapon_ammunition_test.gd

Weapon Ammunition (Error Path)
    Run Single Case    ${CASE_DIR}/weapon_ammunition_error_test.gd

Logger
    Run Single Case    ${CASE_DIR}/logger_test.gd

Script Loader
    Run Single Case    ${CASE_DIR}/script_load_test.gd

UI Windows
    [Tags]    ui
    Run Single Case    ${CASE_DIR}/ui_windows_test.gd

*** Keywords ***
Run Single Case
    [Arguments]    ${case_path}
    Run Godot Logic Case    ${case_path}
