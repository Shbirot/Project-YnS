*** Settings ***
Library    tests.robot.lib.godot_keywords.GodotKeywords

*** Variables ***
${CASE_DIR}    res://tests/robot/cases

*** Test Cases ***
World Boot
    Run Single Case    ${CASE_DIR}/world_boot_test.gd

Hero Weapon Fire
    Run Single Case    ${CASE_DIR}/weapon_fire_test.gd

XP Collection
    Run Single Case    ${CASE_DIR}/xp_collection_test.gd

*** Keywords ***
Run Single Case
    [Arguments]    ${case_path}
    Run Godot Logic Case    ${case_path}
